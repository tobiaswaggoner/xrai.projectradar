using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;
using OpenTelemetry.Exporter;
using OpenTelemetry.Resources;
using Serilog;
using Serilog.Events;
using Serilog.Enrichers;
using xrai.projectradar.backend.Telemetry;

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithThreadId()
    .Enrich.WithEnvironmentName()
    .Enrich.WithMachineName()
    .CreateBootstrapLogger();

try
{
    Log.Information("Starting web application");
    
    var builder = WebApplication.CreateBuilder(args);
    
    // Ensure we have HTTP URLs configured when running under Aspire
    if (string.IsNullOrEmpty(builder.Configuration["ASPNETCORE_URLS"]))
    {
        builder.WebHost.UseUrls("http://+:5000");
    }
    
    // Add Serilog
    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.OpenTelemetry(options =>
        {
            options.Endpoint = builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"] ?? "http://localhost:4317";
            options.Protocol = Serilog.Sinks.OpenTelemetry.OtlpProtocol.Grpc;
            options.IncludedData = Serilog.Sinks.OpenTelemetry.IncludedData.TraceIdField | 
                                   Serilog.Sinks.OpenTelemetry.IncludedData.SpanIdField;
            options.ResourceAttributes = new Dictionary<string, object>
            {
                ["service.name"] = TelemetryConstants.ServiceName,
                ["service.version"] = TelemetryConstants.ServiceVersion
            };
        }));

// Add service discovery for Aspire
builder.Services.AddServiceDiscovery();

// Configure service discovery for HTTP client
builder.Services.ConfigureHttpClientDefaults(http =>
{
    // Turn on resilience by default
    http.AddStandardResilienceHandler();
    
    // Turn on service discovery by default
    http.AddServiceDiscovery();
});

// Add health checks
builder.Services.AddHealthChecks();

// Configure OpenTelemetry Resource
var resourceBuilder = ResourceBuilder.CreateDefault()
    .AddService(serviceName: TelemetryConstants.ServiceName, serviceVersion: TelemetryConstants.ServiceVersion)
    .AddAttributes(new Dictionary<string, object>
    {
        [TelemetryConstants.Tags.Environment] = builder.Environment.EnvironmentName,
        [TelemetryConstants.Tags.DeploymentId] = Environment.MachineName
    });

// Add OpenTelemetry
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService(
        serviceName: TelemetryConstants.ServiceName,
        serviceVersion: TelemetryConstants.ServiceVersion))
    .WithMetrics(metrics =>
    {
        metrics
            .SetResourceBuilder(resourceBuilder)
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddRuntimeInstrumentation()
            .AddProcessInstrumentation()
            .AddMeter(TelemetryConstants.Meter.Name)
            .AddView("request.duration", 
                new ExplicitBucketHistogramConfiguration 
                { 
                    Boundaries = new double[] { 0, 5, 10, 25, 50, 75, 100, 250, 500, 1000, 2500, 5000, 10000 } 
                })
            .AddPrometheusExporter();
    })
    .WithTracing(tracing =>
    {
        tracing
            .SetResourceBuilder(resourceBuilder)
            .AddSource(TelemetryConstants.ActivitySource.Name)
            .AddAspNetCoreInstrumentation(options =>
            {
                options.RecordException = true;
                options.Filter = (httpContext) => 
                    !httpContext.Request.Path.StartsWithSegments("/health") &&
                    !httpContext.Request.Path.StartsWithSegments("/alive");
            })
            .AddHttpClientInstrumentation(options =>
            {
                options.RecordException = true;
            })
            .AddSqlClientInstrumentation(options =>
            {
                options.SetDbStatementForText = true;
                options.RecordException = true;
            });
    });

// Add OpenTelemetry OTLP exporter (works with Aspire dashboard)
builder.Services.ConfigureOpenTelemetryMeterProvider(metrics => metrics.AddOtlpExporter());
builder.Services.ConfigureOpenTelemetryTracerProvider(tracing => tracing.AddOtlpExporter());

// Configure OTLP exporter to work with Aspire
builder.Services.Configure<OtlpExporterOptions>(options =>
{
    // Aspire will set the OTLP endpoint environment variable
    if (!string.IsNullOrEmpty(builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]))
    {
        options.Endpoint = new Uri(builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]!);
    }
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

    var app = builder.Build();
    
    // Add Serilog request logging
    app.UseSerilogRequestLogging(options =>
    {
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
            var userAgent = httpContext.Request.Headers.UserAgent.FirstOrDefault();
            if (!string.IsNullOrEmpty(userAgent))
            {
                diagnosticContext.Set("UserAgent", userAgent);
            }
            
            // Add correlation ID if present
            if (httpContext.Request.Headers.TryGetValue("X-Correlation-Id", out var correlationId))
            {
                var correlationIdValue = correlationId.FirstOrDefault();
                if (!string.IsNullOrEmpty(correlationIdValue))
                {
                    diagnosticContext.Set(TelemetryConstants.Tags.CorrelationId, correlationIdValue);
                }
            }
        };
    });

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Map health check endpoints
app.MapHealthChecks("/health");
app.MapHealthChecks("/alive");

// Map Prometheus metrics endpoint
app.MapPrometheusScrapingEndpoint();

    app.MapGet("/", () => 
    {
        using var activity = TelemetryConstants.ActivitySource.StartActivity("RootEndpoint");
        TelemetryConstants.OpportunityCreatedCounter.Add(1, 
            new KeyValuePair<string, object?>("demo", true));
        
        Log.Information("Root endpoint called");
        return Results.Ok(new { 
            Status = "Running", 
            Service = TelemetryConstants.ServiceName,
            Version = TelemetryConstants.ServiceVersion,
            Environment = builder.Environment.EnvironmentName
        });
    })
    .WithName("Root")
    .WithOpenApi();

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}

// Make Program class accessible for testing
public partial class Program { }

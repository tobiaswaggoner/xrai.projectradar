using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;
using OpenTelemetry.Exporter;

var builder = WebApplication.CreateBuilder(args);

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

// Add OpenTelemetry
builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddRuntimeInstrumentation();
    })
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation();
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

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Map health check endpoints
app.MapHealthChecks("/health");
app.MapHealthChecks("/alive");

app.MapGet("/", () => Results.Ok(new { Status = "Running", Service = "xrai.projectradar.backend" }))
   .WithName("Root")
   .WithOpenApi();

app.Run();

// Make Program class accessible for testing
public partial class Program { }

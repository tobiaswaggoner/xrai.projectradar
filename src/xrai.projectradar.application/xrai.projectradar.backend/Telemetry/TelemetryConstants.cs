using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace xrai.projectradar.backend.Telemetry;

public static class TelemetryConstants
{
    public const string ServiceName = "xrai.projectradar.backend";
    public const string ServiceVersion = "1.0.0";
    
    // Activity source for distributed tracing
    public static readonly ActivitySource ActivitySource = new(ServiceName, ServiceVersion);
    
    // Meter for custom metrics
    public static readonly Meter Meter = new(ServiceName, ServiceVersion);
    
    // Custom metrics
    public static readonly Counter<long> OpportunityCreatedCounter = 
        Meter.CreateCounter<long>("opportunities.created", description: "Number of opportunities created");
    
    public static readonly Histogram<double> RequestDuration = 
        Meter.CreateHistogram<double>("request.duration", unit: "ms", description: "Request duration in milliseconds");
    
    // Activity names for custom spans
    public static class Activities
    {
        public const string CreateOpportunity = "CreateOpportunity";
        public const string ProcessCommand = "ProcessCommand";
        public const string QueryReadModel = "QueryReadModel";
    }
    
    // Tag names for enriching telemetry
    public static class Tags
    {
        public const string Environment = "environment";
        public const string DeploymentId = "deployment.id";
        public const string CorrelationId = "correlation.id";
        public const string UserId = "user.id";
        public const string OpportunityId = "opportunity.id";
    }
}
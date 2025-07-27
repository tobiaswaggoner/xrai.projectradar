var builder = DistributedApplication.CreateBuilder(args);

// Add PostgreSQL resource
var postgres = builder.AddPostgres("postgres")
    .WithPgAdmin()
    .WithDataVolume("postgres_data");

var projectradarDb = postgres.AddDatabase("projectradar");

// Add RabbitMQ resource
var rabbitmq = builder.AddRabbitMQ("rabbitmq")
    .WithManagementPlugin()
    .WithDataVolume("rabbitmq_data");

// Add backend project with references to PostgreSQL and RabbitMQ
var backend = builder.AddProject<Projects.xrai_projectradar_backend>("backend")
    .WithReference(projectradarDb)
    .WithReference(rabbitmq)
    .WithExternalHttpEndpoints()
    .WithEnvironment("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317");

builder.Build().Run();

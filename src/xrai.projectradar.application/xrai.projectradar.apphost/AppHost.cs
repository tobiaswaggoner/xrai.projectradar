var builder = DistributedApplication.CreateBuilder(args);

var backend = builder.AddProject<Projects.xrai_projectradar_backend>("backend");

builder.Build().Run();

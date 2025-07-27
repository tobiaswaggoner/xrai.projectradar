using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using NUnit.Framework;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

namespace xrai.projectradar.backend.tests
{
    [TestFixture]
    public class AspireIntegrationTests
    {
        private HttpClient _client = null!;
        private WebApplicationFactory<Program> _factory = null!;

        [SetUp]
        public void Setup()
        {
            _factory = new WebApplicationFactory<Program>()
                .WithWebHostBuilder(builder =>
                {
                    // Override configuration for testing
                    builder.ConfigureServices(services =>
                    {
                        // Remove any external service dependencies for unit tests
                        services.AddSingleton<IHostEnvironment>(new TestHostEnvironment());
                    });
                });

            _client = _factory.CreateClient();
        }

        [TearDown]
        public void TearDown()
        {
            _client?.Dispose();
            _factory?.Dispose();
        }

        [Test]
        public async Task HealthCheck_ReturnsOk()
        {
            // Act
            var response = await _client.GetAsync("/health");

            // Assert
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        }

        [Test]
        public async Task AliveCheck_ReturnsOk()
        {
            // Act
            var response = await _client.GetAsync("/alive");

            // Assert
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        }

        [Test]
        public async Task RootEndpoint_ReturnsExpectedJson()
        {
            // Act
            var response = await _client.GetAsync("/");
            var content = await response.Content.ReadAsStringAsync();

            // Assert
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
            Assert.That(content, Does.Contain("Running"));
            Assert.That(content, Does.Contain("xrai.projectradar.backend"));
        }

        [Test]
        public void ServiceDiscovery_IsRegistered()
        {
            // Arrange
            using var scope = _factory.Services.CreateScope();
            var services = scope.ServiceProvider;

            // Act & Assert
            Assert.DoesNotThrow(() =>
            {
                // This will throw if service discovery is not registered
                var serviceDiscovery = services.GetService(typeof(Microsoft.Extensions.ServiceDiscovery.IServiceEndpointProviderFactory));
                Assert.That(serviceDiscovery, Is.Not.Null);
            });
        }

        [Test]
        public void HealthChecks_AreRegistered()
        {
            // Arrange
            using var scope = _factory.Services.CreateScope();
            var services = scope.ServiceProvider;

            // Act & Assert
            Assert.DoesNotThrow(() =>
            {
                var healthCheckService = services.GetService(typeof(Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckService));
                Assert.That(healthCheckService, Is.Not.Null);
            });
        }

        [Test]
        public void OpenTelemetry_IsConfigured()
        {
            // Arrange
            using var scope = _factory.Services.CreateScope();
            var services = scope.ServiceProvider;

            // Act & Assert
            Assert.DoesNotThrow(() =>
            {
                // Check if OpenTelemetry providers are registered
                var tracerProvider = services.GetService(typeof(OpenTelemetry.Trace.TracerProvider));
                var meterProvider = services.GetService(typeof(OpenTelemetry.Metrics.MeterProvider));
                
                Assert.That(tracerProvider, Is.Not.Null, "TracerProvider should be registered");
                Assert.That(meterProvider, Is.Not.Null, "MeterProvider should be registered");
            });
        }

        private class TestHostEnvironment : IHostEnvironment
        {
            public string EnvironmentName { get; set; } = "Development";
            public string ApplicationName { get; set; } = "xrai.projectradar.backend.tests";
            public string ContentRootPath { get; set; } = Directory.GetCurrentDirectory();
            public IFileProvider ContentRootFileProvider { get; set; } = null!;
        }
    }
}
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.ServiceDiscovery;
using NSubstitute;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace xrai.projectradar.backend.tests
{
    [TestFixture]
    public class ServiceDiscoveryIntegrationTests
    {
        private IServiceProvider _serviceProvider = null!;
        private IServiceCollection _services = null!;

        [SetUp]
        public void Setup()
        {
            _services = new ServiceCollection();
            
            // Add configuration
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["OTEL_EXPORTER_OTLP_ENDPOINT"] = "http://localhost:4317"
                })
                .Build();
            
            _services.AddSingleton<IConfiguration>(configuration);
            
            // Add service discovery as it would be added in Program.cs
            _services.AddServiceDiscovery();
            
            // Configure HTTP client defaults
            _services.ConfigureHttpClientDefaults(http =>
            {
                http.AddStandardResilienceHandler();
                http.AddServiceDiscovery();
            });
            
            // Add HTTP client with service discovery
            _services.AddHttpClient("test-client");
            
            // Build service provider
            _serviceProvider = _services.BuildServiceProvider();
        }

        [TearDown]
        public void TearDown()
        {
            if (_serviceProvider is IDisposable disposable)
            {
                disposable.Dispose();
            }
        }

        [Test]
        public void ServiceDiscovery_IsRegistered()
        {
            // Act
            var factory = _serviceProvider.GetService<IServiceEndpointProviderFactory>();
            
            // Assert
            Assert.That(factory, Is.Not.Null, "IServiceEndpointProviderFactory should be registered");
        }

        [Test]
        public void HttpClient_WithServiceDiscovery_IsConfigured()
        {
            // Act
            var httpClientFactory = _serviceProvider.GetRequiredService<IHttpClientFactory>();
            var httpClient = httpClientFactory.CreateClient("test-client");
            
            // Assert
            Assert.That(httpClient, Is.Not.Null);
            Assert.That(httpClient.BaseAddress, Is.Null); // Base address is set dynamically by service discovery
        }

        [Test]
        public void ServiceEndpointProvider_FactoryExists()
        {
            // Arrange
            var factory = _serviceProvider.GetService<IServiceEndpointProviderFactory>();
            
            // Assert
            // The factory should exist, demonstrating service discovery is properly configured
            Assert.That(factory, Is.Not.Null, "Service endpoint provider factory should be registered");
        }

        [Test]
        public void ServiceDiscovery_ResilienceHandler_IsConfigured()
        {
            // Arrange
            var services = new ServiceCollection();
            
            // Add configuration
            var configuration = new ConfigurationBuilder().Build();
            services.AddSingleton<IConfiguration>(configuration);
            
            // Act
            services.AddServiceDiscovery();
            services.ConfigureHttpClientDefaults(http =>
            {
                http.AddStandardResilienceHandler();
                http.AddServiceDiscovery();
            });
            
            var serviceProvider = services.BuildServiceProvider();
            
            // Assert
            // Verify that services can be resolved without throwing
            Assert.DoesNotThrow(() =>
            {
                var factory = serviceProvider.GetService<IServiceEndpointProviderFactory>();
                Assert.That(factory, Is.Not.Null);
            });
        }

        [Test]
        public void ServiceDiscovery_MultipleHttpClients_CanBeConfigured()
        {
            // Arrange
            var services = new ServiceCollection();
            
            // Add configuration
            var configuration = new ConfigurationBuilder().Build();
            services.AddSingleton<IConfiguration>(configuration);
            
            services.AddServiceDiscovery();
            
            // Configure HTTP client defaults
            services.ConfigureHttpClientDefaults(http =>
            {
                http.AddStandardResilienceHandler();
                http.AddServiceDiscovery();
            });
            
            // Act
            services.AddHttpClient("client1");
            services.AddHttpClient("client2");
            
            var serviceProvider = services.BuildServiceProvider();
            var httpClientFactory = serviceProvider.GetRequiredService<IHttpClientFactory>();
            
            // Assert
            Assert.DoesNotThrow(() =>
            {
                var client1 = httpClientFactory.CreateClient("client1");
                var client2 = httpClientFactory.CreateClient("client2");
                
                Assert.That(client1, Is.Not.Null);
                Assert.That(client2, Is.Not.Null);
                Assert.That(client1, Is.Not.SameAs(client2));
            });
        }
    }
}
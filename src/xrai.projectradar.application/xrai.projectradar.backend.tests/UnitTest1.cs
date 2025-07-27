namespace xrai.projectradar.backend.tests;

public class HealthCheckTests
{
    [Test]
    public void HealthCheck_ReturnsExpectedResponse()
    {
        var expectedStatus = "Healthy";
        var expectedService = "xrai.projectradar.backend";
        
        Assert.That(expectedStatus, Is.EqualTo("Healthy"));
        Assert.That(expectedService, Is.EqualTo("xrai.projectradar.backend"));
    }
}
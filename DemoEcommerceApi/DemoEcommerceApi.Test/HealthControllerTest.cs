using DemoEcommerceApi.Controllers;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DemoEcommerceApi.Test;

public class HealthControllerTest
{
    private HealthController sut;

    public HealthControllerTest()
    {
        sut = new HealthController();
    }

    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Handshake_ShouldReturnOk()
    {
        var result = sut.Handshake();
        Assert.IsInstanceOf<OkResult>(result);
    }

    [Test]
    public void HealthCheck_ShouldReturnOk()
    {
        var result = sut.HealthCheck();
        Assert.That(result, Is.EqualTo("OK"));
    }
}

using Microsoft.AspNetCore.Mvc;

namespace DemoEcommerceApi.Controllers;

[Route("")]
[ApiController]
public class HealthController : ControllerBase
{
    [HttpGet("handshake")]
    public IActionResult Handshake()
    {
        return Ok();
    }

    [HttpGet("healthcheck")]
    public string HealthCheck()
    {
        return "OK";
    }
}

using Microsoft.AspNetCore.Mvc;

namespace DemoEcommerceApi.Controllers;

[ApiController]
[Route("product")]
public class ProductController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "StrideFlex Runner",
        "UrbanLoft Sneakers",
        "TrailMaster Hiker",
        "CloudWalk Knit",
        "MetroDash Slip-On",
        "VelvetStep Loafers",
        "Classic Edge Oxford",
        "PulseZoom Trainer",
        "BreezeStep Sandals",
        "EchoLeather Boot"
    };

    private readonly ILogger<ProductController> _logger;

    public ProductController(ILogger<ProductController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetProducts")]
    public IEnumerable<Product> Get()
    {
        var randomNames = Summaries.OrderBy(_ => Random.Shared.Next()).Take(5).ToArray(); 

        return randomNames.Select(name => new Product
        {
            Name = name
        })
        .ToArray();
    }
}

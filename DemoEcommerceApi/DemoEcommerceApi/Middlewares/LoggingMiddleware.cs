using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace DemoEcommerceApi.Middlewares;
// You may need to install the Microsoft.AspNetCore.Http.Abstractions package into your project
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<LoggingMiddleware> _logger;

    public LoggingMiddleware(RequestDelegate next, ILogger<LoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task Invoke(HttpContext httpContext)
    {
        _logger.LogInformation("Request Started! {method} {path}", httpContext.Request.Method, httpContext.Request.Path);

        await _next(httpContext);

        _logger.LogInformation("Request Finished!");
    }
}

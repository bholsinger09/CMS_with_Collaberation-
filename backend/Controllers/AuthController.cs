using CMSCollaboration.Services;
using Microsoft.AspNetCore.Mvc;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _authService.AuthenticateAsync(request.Email, request.Password);
        
        if (user == null)
        {
            return Unauthorized(new { message = "Invalid email or password" });
        }

        var token = _authService.GenerateJwtToken(user);

        return Ok(new
        {
            id = user.Id,
            username = user.Username,
            email = user.Email,
            role = user.Role,
            token = token
        });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var user = await _authService.RegisterAsync(
            request.Username,
            request.Email,
            request.Password,
            request.Role ?? "Editor"
        );

        if (user == null)
        {
            return BadRequest(new { message = "User with this email already exists" });
        }

        var token = _authService.GenerateJwtToken(user);

        return Ok(new
        {
            id = user.Id,
            username = user.Username,
            email = user.Email,
            role = user.Role,
            token = token
        });
    }
}

public record LoginRequest(string Email, string Password);
public record RegisterRequest(string Username, string Email, string Password, string? Role);

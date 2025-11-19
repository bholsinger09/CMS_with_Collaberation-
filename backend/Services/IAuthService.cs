using CMSCollaboration.Models;

namespace CMSCollaboration.Services;

public interface IAuthService
{
    Task<User?> AuthenticateAsync(string email, string password);
    Task<User?> RegisterAsync(string username, string email, string password, string role = "Editor");
    string GenerateJwtToken(User user);
    string HashPassword(string password);
    bool VerifyPassword(string password, string passwordHash);
}

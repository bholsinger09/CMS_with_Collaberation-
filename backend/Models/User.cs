namespace CMSCollaboration.Models;

public class User
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = "Editor";
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }
    
    public ICollection<Content> Contents { get; set; } = new List<Content>();
    public ICollection<ContentVersion> ContentVersions { get; set; } = new List<ContentVersion>();
}

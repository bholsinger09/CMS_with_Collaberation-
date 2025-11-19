namespace CMSCollaboration.Models;

public class CollaborationSession
{
    public Guid Id { get; set; }
    public Guid ContentId { get; set; }
    public Content Content { get; set; } = null!;
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string ConnectionId { get; set; } = string.Empty;
    public DateTime JoinedAt { get; set; }
    public DateTime? LeftAt { get; set; }
    public bool IsActive { get; set; }
}

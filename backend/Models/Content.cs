namespace CMSCollaboration.Models;

public class Content
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Status { get; set; } = "draft";
    public Guid AuthorId { get; set; }
    public User Author { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? PublishedAt { get; set; }
    
    public ICollection<ContentVersion> Versions { get; set; } = new List<ContentVersion>();
    public ICollection<CollaborationSession> CollaborationSessions { get; set; } = new List<CollaborationSession>();
}

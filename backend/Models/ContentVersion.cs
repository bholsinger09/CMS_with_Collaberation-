namespace CMSCollaboration.Models;

public class ContentVersion
{
    public Guid Id { get; set; }
    public Guid ContentId { get; set; }
    public Content Content { get; set; } = null!;
    public int VersionNumber { get; set; }
    public string Body { get; set; } = string.Empty;
    public Guid CreatedById { get; set; }
    public User CreatedBy { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public string? ChangeDescription { get; set; }
}

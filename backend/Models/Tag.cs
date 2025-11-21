using System.ComponentModel.DataAnnotations;

namespace CMSCollaboration.Models;

public class Tag
{
    [Key]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(100)]
    public string? Slug { get; set; }

    public ICollection<ContentTag> ContentTags { get; set; } = new List<ContentTag>();

    public DateTime CreatedAt { get; set; }
}

// Junction table for many-to-many relationship
public class ContentTag
{
    public Guid ContentId { get; set; }
    public Content Content { get; set; } = null!;

    public Guid TagId { get; set; }
    public Tag Tag { get; set; } = null!;

    public DateTime TaggedAt { get; set; }
}

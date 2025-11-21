using System.ComponentModel.DataAnnotations;

namespace CMSCollaboration.Models;

public class Media
{
    [Key]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(255)]
    public string FileName { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string FilePath { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string FileType { get; set; } = string.Empty;

    public long FileSize { get; set; }

    [MaxLength(255)]
    public string? AltText { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }

    public Guid UploadedById { get; set; }
    public User UploadedBy { get; set; } = null!;

    public DateTime UploadedAt { get; set; }
}

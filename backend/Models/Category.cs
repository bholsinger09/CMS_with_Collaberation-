using System.ComponentModel.DataAnnotations;

namespace CMSCollaboration.Models;

public class Category
{
    [Key]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? Slug { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }

    public Guid? ParentCategoryId { get; set; }
    public Category? ParentCategory { get; set; }

    public ICollection<Category> SubCategories { get; set; } = new List<Category>();
    public ICollection<Content> Contents { get; set; } = new List<Content>();

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

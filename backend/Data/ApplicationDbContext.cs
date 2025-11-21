using CMSCollaboration.Models;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<Content> Contents { get; set; }
    public DbSet<ContentVersion> ContentVersions { get; set; }
    public DbSet<CollaborationSession> CollaborationSessions { get; set; }
    public DbSet<Media> Media { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Tag> Tags { get; set; }
    public DbSet<ContentTag> ContentTags { get; set; }
    public DbSet<ContentTemplate> ContentTemplates { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Username).IsUnique();
            
            entity.HasMany(e => e.Contents)
                .WithOne(e => e.Author)
                .HasForeignKey(e => e.AuthorId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Content>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Status);
            entity.HasIndex(e => e.CreatedAt);
            entity.HasIndex(e => e.UpdatedAt);
            
            entity.HasMany(e => e.Versions)
                .WithOne(e => e.Content)
                .HasForeignKey(e => e.ContentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ContentVersion>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => new { e.ContentId, e.VersionNumber }).IsUnique();
        });

        modelBuilder.Entity<CollaborationSession>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.ConnectionId);
            entity.HasIndex(e => new { e.ContentId, e.IsActive });
        });

        modelBuilder.Entity<Media>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.UploadedAt);
            entity.HasIndex(e => e.FileType);
            
            entity.HasOne(e => e.UploadedBy)
                .WithMany()
                .HasForeignKey(e => e.UploadedById)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Slug).IsUnique();
            entity.HasIndex(e => e.ParentCategoryId);
            
            entity.HasOne(e => e.ParentCategory)
                .WithMany(e => e.SubCategories)
                .HasForeignKey(e => e.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Tag>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Name).IsUnique();
            entity.HasIndex(e => e.Slug).IsUnique();
        });

        modelBuilder.Entity<ContentTag>(entity =>
        {
            entity.HasKey(e => new { e.ContentId, e.TagId });
            
            entity.HasOne(e => e.Content)
                .WithMany(e => e.ContentTags)
                .HasForeignKey(e => e.ContentId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne(e => e.Tag)
                .WithMany(e => e.ContentTags)
                .HasForeignKey(e => e.TagId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ContentTemplate>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Name);
            
            entity.HasOne(e => e.CreatedBy)
                .WithMany()
                .HasForeignKey(e => e.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}

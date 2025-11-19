using CMSCollaboration.Data;
using CMSCollaboration.Models;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Services;

public class ContentService : IContentService
{
    private readonly ApplicationDbContext _context;

    public ContentService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Content>> GetAllContentAsync()
    {
        return await _context.Contents
            .Include(c => c.Author)
            .Include(c => c.CollaborationSessions.Where(s => s.IsActive))
            .OrderByDescending(c => c.UpdatedAt)
            .ToListAsync();
    }

    public async Task<Content?> GetContentByIdAsync(Guid id)
    {
        return await _context.Contents
            .Include(c => c.Author)
            .Include(c => c.Versions)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<Content> CreateContentAsync(Content content)
    {
        content.Id = Guid.NewGuid();
        content.CreatedAt = DateTime.UtcNow;
        content.UpdatedAt = DateTime.UtcNow;
        content.Status = "draft";

        _context.Contents.Add(content);
        await _context.SaveChangesAsync();

        // Create initial version
        await CreateVersionAsync(content.Id, content.Body, content.AuthorId, "Initial version");

        return content;
    }

    public async Task<Content?> UpdateContentAsync(Guid id, Content content)
    {
        var existingContent = await _context.Contents.FindAsync(id);
        if (existingContent == null)
        {
            return null;
        }

        existingContent.Title = content.Title;
        existingContent.Body = content.Body;
        existingContent.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Create new version
        await CreateVersionAsync(id, content.Body, content.AuthorId, "Content updated");

        return existingContent;
    }

    public async Task<bool> DeleteContentAsync(Guid id)
    {
        var content = await _context.Contents.FindAsync(id);
        if (content == null)
        {
            return false;
        }

        _context.Contents.Remove(content);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<Content?> PublishContentAsync(Guid id)
    {
        var content = await _context.Contents.FindAsync(id);
        if (content == null)
        {
            return null;
        }

        content.Status = "published";
        content.PublishedAt = DateTime.UtcNow;
        content.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return content;
    }

    public async Task<IEnumerable<ContentVersion>> GetContentVersionsAsync(Guid contentId)
    {
        return await _context.ContentVersions
            .Where(v => v.ContentId == contentId)
            .Include(v => v.CreatedBy)
            .OrderByDescending(v => v.VersionNumber)
            .ToListAsync();
    }

    public async Task<ContentVersion> CreateVersionAsync(Guid contentId, string body, Guid userId, string? changeDescription = null)
    {
        var lastVersion = await _context.ContentVersions
            .Where(v => v.ContentId == contentId)
            .OrderByDescending(v => v.VersionNumber)
            .FirstOrDefaultAsync();

        var version = new ContentVersion
        {
            Id = Guid.NewGuid(),
            ContentId = contentId,
            VersionNumber = (lastVersion?.VersionNumber ?? 0) + 1,
            Body = body,
            CreatedById = userId,
            CreatedAt = DateTime.UtcNow,
            ChangeDescription = changeDescription
        };

        _context.ContentVersions.Add(version);
        await _context.SaveChangesAsync();

        return version;
    }
}

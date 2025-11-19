using CMSCollaboration.Models;

namespace CMSCollaboration.Services;

public interface IContentService
{
    Task<IEnumerable<Content>> GetAllContentAsync();
    Task<Content?> GetContentByIdAsync(Guid id);
    Task<Content> CreateContentAsync(Content content);
    Task<Content?> UpdateContentAsync(Guid id, Content content);
    Task<bool> DeleteContentAsync(Guid id);
    Task<Content?> PublishContentAsync(Guid id);
    Task<IEnumerable<ContentVersion>> GetContentVersionsAsync(Guid contentId);
    Task<ContentVersion> CreateVersionAsync(Guid contentId, string body, Guid userId, string? changeDescription = null);
}

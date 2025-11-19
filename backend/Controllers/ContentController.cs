using CMSCollaboration.Models;
using CMSCollaboration.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ContentController : ControllerBase
{
    private readonly IContentService _contentService;
    private readonly ILogger<ContentController> _logger;

    public ContentController(IContentService contentService, ILogger<ContentController> logger)
    {
        _contentService = contentService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var contents = await _contentService.GetAllContentAsync();
        
        var response = contents.Select(c => new
        {
            id = c.Id,
            title = c.Title,
            status = c.Status,
            author = c.Author.Username,
            lastModified = c.UpdatedAt,
            activeEditors = c.CollaborationSessions.Count(s => s.IsActive)
        });

        return Ok(response);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var content = await _contentService.GetContentByIdAsync(id);
        
        if (content == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = content.Id,
            title = content.Title,
            content = content.Body,
            status = content.Status,
            author = content.Author.Username,
            createdAt = content.CreatedAt,
            updatedAt = content.UpdatedAt,
            publishedAt = content.PublishedAt
        });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateContentRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }

        var content = new Content
        {
            Title = request.Title,
            Body = request.Content,
            AuthorId = Guid.Parse(userId)
        };

        var createdContent = await _contentService.CreateContentAsync(content);

        return CreatedAtAction(nameof(GetById), new { id = createdContent.Id }, new
        {
            id = createdContent.Id,
            title = createdContent.Title,
            content = createdContent.Body,
            status = createdContent.Status
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateContentRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }

        var content = new Content
        {
            Title = request.Title,
            Body = request.Content,
            AuthorId = Guid.Parse(userId)
        };

        var updatedContent = await _contentService.UpdateContentAsync(id, content);

        if (updatedContent == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = updatedContent.Id,
            title = updatedContent.Title,
            content = updatedContent.Body,
            status = updatedContent.Status
        });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var result = await _contentService.DeleteContentAsync(id);
        
        if (!result)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpPut("{id}/publish")]
    public async Task<IActionResult> Publish(Guid id)
    {
        var content = await _contentService.PublishContentAsync(id);
        
        if (content == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = content.Id,
            title = content.Title,
            status = content.Status,
            publishedAt = content.PublishedAt
        });
    }

    [HttpGet("{id}/versions")]
    public async Task<IActionResult> GetVersions(Guid id)
    {
        var versions = await _contentService.GetContentVersionsAsync(id);
        
        var response = versions.Select(v => new
        {
            id = v.Id,
            versionNumber = v.VersionNumber,
            createdBy = v.CreatedBy.Username,
            createdAt = v.CreatedAt,
            changeDescription = v.ChangeDescription
        });

        return Ok(response);
    }
}

public record CreateContentRequest(string Title, string Content);
public record UpdateContentRequest(string Title, string Content, string? Status);

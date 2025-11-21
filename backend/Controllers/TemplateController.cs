using CMSCollaboration.Data;
using CMSCollaboration.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TemplateController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TemplateController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool includePrivate = false)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var query = _context.ContentTemplates.AsQueryable();

        if (!includePrivate)
        {
            query = query.Where(t => t.IsPublic || t.CreatedById.ToString() == userId);
        }

        var templates = await query
            .Include(t => t.CreatedBy)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new
            {
                id = t.Id,
                name = t.Name,
                description = t.Description,
                isPublic = t.IsPublic,
                createdBy = t.CreatedBy.Username,
                createdAt = t.CreatedAt
            })
            .ToListAsync();

        return Ok(templates);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var template = await _context.ContentTemplates
            .Include(t => t.CreatedBy)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (template == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = template.Id,
            name = template.Name,
            description = template.Description,
            templateBody = template.TemplateBody,
            isPublic = template.IsPublic,
            createdBy = template.CreatedBy.Username,
            createdAt = template.CreatedAt
        });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTemplateRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }

        var template = new ContentTemplate
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Description = request.Description,
            TemplateBody = request.TemplateBody,
            IsPublic = request.IsPublic,
            CreatedById = Guid.Parse(userId),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.ContentTemplates.Add(template);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = template.Id }, new
        {
            id = template.Id,
            name = template.Name
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTemplateRequest request)
    {
        var template = await _context.ContentTemplates.FindAsync(id);
        if (template == null)
        {
            return NotFound();
        }

        template.Name = request.Name;
        template.Description = request.Description;
        template.TemplateBody = request.TemplateBody;
        template.IsPublic = request.IsPublic;
        template.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new { id = template.Id, name = template.Name });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var template = await _context.ContentTemplates.FindAsync(id);
        if (template == null)
        {
            return NotFound();
        }

        _context.ContentTemplates.Remove(template);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}

public record CreateTemplateRequest(string Name, string? Description, string TemplateBody, bool IsPublic);
public record UpdateTemplateRequest(string Name, string? Description, string TemplateBody, bool IsPublic);

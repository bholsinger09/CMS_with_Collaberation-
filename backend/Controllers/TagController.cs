using CMSCollaboration.Data;
using CMSCollaboration.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TagController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TagController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? search = null)
    {
        var query = _context.Tags.AsQueryable();

        if (!string.IsNullOrEmpty(search))
        {
            query = query.Where(t => t.Name.Contains(search));
        }

        var tags = await query
            .OrderBy(t => t.Name)
            .Select(t => new
            {
                id = t.Id,
                name = t.Name,
                slug = t.Slug,
                usageCount = t.ContentTags.Count
            })
            .ToListAsync();

        return Ok(tags);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var tag = await _context.Tags
            .Include(t => t.ContentTags)
            .FirstOrDefaultAsync(t => t.Id == id);

        if (tag == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = tag.Id,
            name = tag.Name,
            slug = tag.Slug,
            usageCount = tag.ContentTags.Count
        });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTagRequest request)
    {
        var slug = GenerateSlug(request.Name);

        var existingTag = await _context.Tags.FirstOrDefaultAsync(t => t.Name == request.Name);
        if (existingTag != null)
        {
            return Ok(new { id = existingTag.Id, name = existingTag.Name, slug = existingTag.Slug });
        }

        var tag = new Tag
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = slug,
            CreatedAt = DateTime.UtcNow
        };

        _context.Tags.Add(tag);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = tag.Id }, new
        {
            id = tag.Id,
            name = tag.Name,
            slug = tag.Slug
        });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var tag = await _context.Tags.FindAsync(id);
        if (tag == null)
        {
            return NotFound();
        }

        _context.Tags.Remove(tag);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private string GenerateSlug(string name)
    {
        return name.ToLower()
            .Replace(" ", "-")
            .Replace("&", "and")
            .Trim();
    }
}

public record CreateTagRequest(string Name);

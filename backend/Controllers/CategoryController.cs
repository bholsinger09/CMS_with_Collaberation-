using CMSCollaboration.Data;
using CMSCollaboration.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CategoryController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public CategoryController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool includeChildren = true)
    {
        var query = _context.Categories.AsQueryable();

        if (includeChildren)
        {
            query = query.Include(c => c.SubCategories);
        }

        var categories = await query
            .Where(c => c.ParentCategoryId == null)
            .Select(c => new
            {
                id = c.Id,
                name = c.Name,
                slug = c.Slug,
                description = c.Description,
                childCount = c.SubCategories.Count,
                contentCount = c.Contents.Count,
                children = includeChildren ? c.SubCategories.Select(sc => new
                {
                    id = sc.Id,
                    name = sc.Name,
                    slug = sc.Slug,
                    contentCount = sc.Contents.Count
                }).ToList() : null
            })
            .ToListAsync();

        return Ok(categories);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var category = await _context.Categories
            .Include(c => c.SubCategories)
            .Include(c => c.ParentCategory)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = category.Id,
            name = category.Name,
            slug = category.Slug,
            description = category.Description,
            parentId = category.ParentCategoryId,
            parentName = category.ParentCategory?.Name,
            children = category.SubCategories.Select(sc => new { id = sc.Id, name = sc.Name }).ToList()
        });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request)
    {
        var slug = GenerateSlug(request.Name);

        var category = new Category
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = slug,
            Description = request.Description,
            ParentCategoryId = request.ParentCategoryId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = category.Id }, new
        {
            id = category.Id,
            name = category.Name,
            slug = category.Slug
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCategoryRequest request)
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null)
        {
            return NotFound();
        }

        category.Name = request.Name;
        category.Slug = GenerateSlug(request.Name);
        category.Description = request.Description;
        category.ParentCategoryId = request.ParentCategoryId;
        category.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new { id = category.Id, name = category.Name, slug = category.Slug });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var category = await _context.Categories
            .Include(c => c.SubCategories)
            .Include(c => c.Contents)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
        {
            return NotFound();
        }

        if (category.SubCategories.Any() || category.Contents.Any())
        {
            return BadRequest("Cannot delete category with sub-categories or associated content");
        }

        _context.Categories.Remove(category);
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

public record CreateCategoryRequest(string Name, string? Description, Guid? ParentCategoryId);
public record UpdateCategoryRequest(string Name, string? Description, Guid? ParentCategoryId);

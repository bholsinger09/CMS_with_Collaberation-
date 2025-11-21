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
public class MediaController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MediaController> _logger;
    private readonly string _uploadPath;

    public MediaController(ApplicationDbContext context, ILogger<MediaController> logger, IWebHostEnvironment env)
    {
        _context = context;
        _logger = logger;
        _uploadPath = Path.Combine(env.ContentRootPath, "wwwroot", "uploads");
        
        if (!Directory.Exists(_uploadPath))
        {
            Directory.CreateDirectory(_uploadPath);
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? type = null, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var query = _context.Media.Include(m => m.UploadedBy).AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(m => m.FileType.StartsWith(type));
        }

        var total = await query.CountAsync();
        var media = await query
            .OrderByDescending(m => m.UploadedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(m => new
            {
                id = m.Id,
                fileName = m.FileName,
                filePath = m.FilePath,
                fileType = m.FileType,
                fileSize = m.FileSize,
                altText = m.AltText,
                description = m.Description,
                uploadedBy = m.UploadedBy.Username,
                uploadedAt = m.UploadedAt
            })
            .ToListAsync();

        return Ok(new { media, total, page, pageSize, totalPages = (int)Math.Ceiling(total / (double)pageSize) });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var media = await _context.Media
            .Include(m => m.UploadedBy)
            .FirstOrDefaultAsync(m => m.Id == id);

        if (media == null)
        {
            return NotFound();
        }

        return Ok(new
        {
            id = media.Id,
            fileName = media.FileName,
            filePath = media.FilePath,
            fileType = media.FileType,
            fileSize = media.FileSize,
            altText = media.AltText,
            description = media.Description,
            uploadedBy = media.UploadedBy.Username,
            uploadedAt = media.UploadedAt
        });
    }

    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] IFormFile file, [FromForm] string? altText, [FromForm] string? description)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("No file uploaded");
        }

        // Validate file size (10MB max)
        if (file.Length > 10 * 1024 * 1024)
        {
            return BadRequest("File size exceeds 10MB limit");
        }

        // Validate file type
        var allowedTypes = new[] { "image/jpeg", "image/png", "image/gif", "image/webp", "video/mp4", "application/pdf" };
        if (!allowedTypes.Contains(file.ContentType))
        {
            return BadRequest("File type not allowed");
        }

        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null)
        {
            return Unauthorized();
        }

        // Generate unique filename
        var fileName = $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}";
        var filePath = Path.Combine(_uploadPath, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var media = new Media
        {
            Id = Guid.NewGuid(),
            FileName = file.FileName,
            FilePath = $"/uploads/{fileName}",
            FileType = file.ContentType,
            FileSize = file.Length,
            AltText = altText,
            Description = description,
            UploadedById = Guid.Parse(userId),
            UploadedAt = DateTime.UtcNow
        };

        _context.Media.Add(media);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = media.Id }, new
        {
            id = media.Id,
            fileName = media.FileName,
            filePath = media.FilePath,
            fileType = media.FileType,
            fileSize = media.FileSize
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateMediaRequest request)
    {
        var media = await _context.Media.FindAsync(id);
        if (media == null)
        {
            return NotFound();
        }

        media.AltText = request.AltText;
        media.Description = request.Description;

        await _context.SaveChangesAsync();

        return Ok(new { id = media.Id, altText = media.AltText, description = media.Description });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var media = await _context.Media.FindAsync(id);
        if (media == null)
        {
            return NotFound();
        }

        // Delete physical file
        var physicalPath = Path.Combine(_uploadPath, Path.GetFileName(media.FilePath));
        if (System.IO.File.Exists(physicalPath))
        {
            System.IO.File.Delete(physicalPath);
        }

        _context.Media.Remove(media);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}

public record UpdateMediaRequest(string? AltText, string? Description);

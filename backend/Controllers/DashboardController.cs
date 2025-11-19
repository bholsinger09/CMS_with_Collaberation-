using CMSCollaboration.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public DashboardController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        var totalDocuments = await _context.Contents.CountAsync();
        var activeCollaborations = await _context.CollaborationSessions
            .Where(s => s.IsActive)
            .Select(s => s.ContentId)
            .Distinct()
            .CountAsync();
        var recentEdits = await _context.ContentVersions
            .Where(v => v.CreatedAt >= DateTime.UtcNow.AddHours(-24))
            .CountAsync();
        var totalUsers = await _context.Users.CountAsync();

        return Ok(new
        {
            totalDocuments,
            activeCollaborations,
            recentEdits,
            totalUsers
        });
    }

    [HttpGet("recent-activities")]
    public async Task<IActionResult> GetRecentActivities()
    {
        var activities = await _context.ContentVersions
            .Include(v => v.Content)
            .Include(v => v.CreatedBy)
            .OrderByDescending(v => v.CreatedAt)
            .Take(20)
            .Select(v => new
            {
                id = v.Id,
                documentTitle = v.Content.Title,
                username = v.CreatedBy.Username,
                action = v.ChangeDescription ?? "Updated",
                timestamp = v.CreatedAt
            })
            .ToListAsync();

        return Ok(activities);
    }
}

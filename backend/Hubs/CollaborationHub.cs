using Microsoft.AspNetCore.SignalR;
using CMSCollaboration.Data;
using CMSCollaboration.Models;
using Microsoft.EntityFrameworkCore;

namespace CMSCollaboration.Hubs;

public class CollaborationHub : Hub
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<CollaborationHub> _logger;

    public CollaborationHub(ApplicationDbContext context, ILogger<CollaborationHub> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task JoinDocument(string documentId, string userId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, documentId);

        var session = new CollaborationSession
        {
            Id = Guid.NewGuid(),
            ContentId = Guid.Parse(documentId),
            UserId = Guid.Parse(userId),
            ConnectionId = Context.ConnectionId,
            JoinedAt = DateTime.UtcNow,
            IsActive = true
        };

        _context.CollaborationSessions.Add(session);
        await _context.SaveChangesAsync();

        var user = await _context.Users.FindAsync(Guid.Parse(userId));
        var activeUser = new
        {
            Id = userId,
            Username = user?.Username ?? "Unknown",
            Color = GenerateUserColor(userId)
        };

        await Clients.Group(documentId).SendAsync("UserJoined", activeUser);
        _logger.LogInformation($"User {userId} joined document {documentId}");
    }

    public async Task LeaveDocument(string documentId, string userId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, documentId);

        var session = await _context.CollaborationSessions
            .FirstOrDefaultAsync(s => s.ConnectionId == Context.ConnectionId && s.IsActive);

        if (session != null)
        {
            session.IsActive = false;
            session.LeftAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        await Clients.Group(documentId).SendAsync("UserLeft", userId);
        _logger.LogInformation($"User {userId} left document {documentId}");
    }

    public async Task UpdateContent(string content)
    {
        var session = await _context.CollaborationSessions
            .FirstOrDefaultAsync(s => s.ConnectionId == Context.ConnectionId && s.IsActive);

        if (session != null)
        {
            var documentId = session.ContentId.ToString();
            await Clients.OthersInGroup(documentId).SendAsync("ContentChanged", content, session.UserId.ToString());
        }
    }

    public async Task UpdateCursor(int position)
    {
        var session = await _context.CollaborationSessions
            .FirstOrDefaultAsync(s => s.ConnectionId == Context.ConnectionId && s.IsActive);

        if (session != null)
        {
            var documentId = session.ContentId.ToString();
            await Clients.OthersInGroup(documentId).SendAsync("CursorMoved", session.UserId.ToString(), position);
        }
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var session = await _context.CollaborationSessions
            .FirstOrDefaultAsync(s => s.ConnectionId == Context.ConnectionId && s.IsActive);

        if (session != null)
        {
            session.IsActive = false;
            session.LeftAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var documentId = session.ContentId.ToString();
            await Clients.Group(documentId).SendAsync("UserLeft", session.UserId.ToString());
        }

        await base.OnDisconnectedAsync(exception);
    }

    private static string GenerateUserColor(string userId)
    {
        var colors = new[]
        {
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
            "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2"
        };

        var hash = userId.GetHashCode();
        var index = Math.Abs(hash) % colors.Length;
        return colors[index];
    }
}

<?php

namespace CMSCollaboration\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use PDO;

class ContentController
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function getPublishedContent(Request $request, Response $response): Response
    {
        try {
            $stmt = $this->db->prepare("
                SELECT 
                    c.Id,
                    c.Title,
                    c.Body,
                    c.PublishedAt,
                    u.Username as Author
                FROM Contents c
                JOIN Users u ON c.AuthorId = u.Id
                WHERE c.Status = 'published'
                ORDER BY c.PublishedAt DESC
                LIMIT 50
            ");
            
            $stmt->execute();
            $contents = $stmt->fetchAll();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => $contents
            ]));

            return $response->withHeader('Content-Type', 'application/json');
        } catch (\Exception $e) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }

    public function getContentAsHtml(Request $request, Response $response, array $args): Response
    {
        try {
            $id = $args['id'];
            
            $stmt = $this->db->prepare("
                SELECT 
                    c.Id,
                    c.Title,
                    c.Body,
                    c.PublishedAt,
                    u.Username as Author
                FROM Contents c
                JOIN Users u ON c.AuthorId = u.Id
                WHERE c.Id = :id AND c.Status = 'published'
            ");
            
            $stmt->execute(['id' => $id]);
            $content = $stmt->fetch();

            if (!$content) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Content not found'
                ]));
                return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
            }

            // Generate HTML
            $html = $this->generateHtml($content);

            $response->getBody()->write($html);
            return $response->withHeader('Content-Type', 'text/html');
        } catch (\Exception $e) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }

    public function exportContent(Request $request, Response $response, array $args): Response
    {
        try {
            $id = $args['id'];
            $data = $request->getParsedBody();
            $format = $data['format'] ?? 'json';

            $stmt = $this->db->prepare("
                SELECT 
                    c.Id,
                    c.Title,
                    c.Body,
                    c.Status,
                    c.CreatedAt,
                    c.UpdatedAt,
                    c.PublishedAt,
                    u.Username as Author
                FROM Contents c
                JOIN Users u ON c.AuthorId = u.Id
                WHERE c.Id = :id
            ");
            
            $stmt->execute(['id' => $id]);
            $content = $stmt->fetch();

            if (!$content) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Content not found'
                ]));
                return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
            }

            switch ($format) {
                case 'html':
                    $output = $this->generateHtml($content);
                    $contentType = 'text/html';
                    break;
                case 'markdown':
                    $output = $this->convertToMarkdown($content);
                    $contentType = 'text/markdown';
                    break;
                case 'json':
                default:
                    $output = json_encode($content, JSON_PRETTY_PRINT);
                    $contentType = 'application/json';
                    break;
            }

            $response->getBody()->write($output);
            return $response
                ->withHeader('Content-Type', $contentType)
                ->withHeader('Content-Disposition', "attachment; filename=\"{$content['Title']}.{$format}\"");
        } catch (\Exception $e) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }

    public function getContentByTag(Request $request, Response $response, array $args): Response
    {
        try {
            $tag = $args['tag'];
            
            $stmt = $this->db->prepare("
                SELECT 
                    c.Id,
                    c.Title,
                    c.Body,
                    c.PublishedAt,
                    u.Username as Author
                FROM Contents c
                JOIN Users u ON c.AuthorId = u.Id
                JOIN ContentTags ct ON c.Id = ct.ContentId
                JOIN Tags t ON ct.TagId = t.Id
                WHERE t.Name = :tag AND c.Status = 'published'
                ORDER BY c.PublishedAt DESC
            ");
            
            $stmt->execute(['tag' => $tag]);
            $contents = $stmt->fetchAll();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => $contents
            ]));

            return $response->withHeader('Content-Type', 'application/json');
        } catch (\Exception $e) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }

    private function generateHtml(array $content): string
    {
        return <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$content['Title']}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            line-height: 1.6;
        }
        h1 {
            color: #333;
            margin-bottom: 0.5rem;
        }
        .meta {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 2rem;
        }
        .content {
            color: #444;
        }
    </style>
</head>
<body>
    <h1>{$content['Title']}</h1>
    <div class="meta">
        By {$content['Author']} | Published: {$content['PublishedAt']}
    </div>
    <div class="content">
        {$content['Body']}
    </div>
</body>
</html>
HTML;
    }

    private function convertToMarkdown(array $content): string
    {
        $markdown = "# {$content['Title']}\n\n";
        $markdown .= "**Author:** {$content['Author']}\n";
        $markdown .= "**Published:** {$content['PublishedAt']}\n\n";
        $markdown .= "---\n\n";
        
        // Basic HTML to Markdown conversion
        $body = $content['Body'];
        $body = strip_tags($body);
        $markdown .= $body;
        
        return $markdown;
    }
}

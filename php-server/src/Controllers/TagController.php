<?php

namespace CMSCollaboration\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use PDO;

class TagController
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    public function getAllTags(Request $request, Response $response): Response
    {
        try {
            $stmt = $this->db->query("
                SELECT 
                    t.Id,
                    t.Name,
                    COUNT(ct.ContentId) as ContentCount
                FROM Tags t
                LEFT JOIN ContentTags ct ON t.Id = ct.TagId
                GROUP BY t.Id, t.Name
                ORDER BY t.Name ASC
            ");
            
            $tags = $stmt->fetchAll();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => $tags
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

    public function createTag(Request $request, Response $response): Response
    {
        try {
            $data = $request->getParsedBody();
            $name = $data['name'] ?? '';

            if (empty($name)) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Tag name is required'
                ]));
                return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
            }

            $stmt = $this->db->prepare("
                INSERT INTO Tags (Id, Name, CreatedAt)
                VALUES (UUID(), :name, NOW())
            ");
            
            $stmt->execute(['name' => $name]);
            $tagId = $this->db->lastInsertId();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => [
                    'id' => $tagId,
                    'name' => $name
                ]
            ]));

            return $response->withStatus(201)->withHeader('Content-Type', 'application/json');
        } catch (\Exception $e) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
            return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
        }
    }
}

<?php

namespace CMSCollaboration\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\UploadedFileInterface;
use PDO;

class MediaController
{
    private PDO $db;
    private string $uploadDir;

    public function __construct(PDO $db)
    {
        $this->db = $db;
        $this->uploadDir = __DIR__ . '/../../public/uploads/';
        
        if (!is_dir($this->uploadDir)) {
            mkdir($this->uploadDir, 0755, true);
        }
    }

    public function uploadMedia(Request $request, Response $response): Response
    {
        try {
            $uploadedFiles = $request->getUploadedFiles();
            
            if (!isset($uploadedFiles['file'])) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'No file uploaded'
                ]));
                return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
            }

            /** @var UploadedFileInterface $uploadedFile */
            $uploadedFile = $uploadedFiles['file'];

            if ($uploadedFile->getError() !== UPLOAD_ERR_OK) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Upload error'
                ]));
                return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
            }

            $filename = $this->moveUploadedFile($uploadedFile);
            
            // Save to database
            $stmt = $this->db->prepare("
                INSERT INTO Media (Id, Filename, OriginalName, MimeType, Size, UploadedAt)
                VALUES (UUID(), :filename, :originalName, :mimeType, :size, NOW())
            ");
            
            $stmt->execute([
                'filename' => $filename,
                'originalName' => $uploadedFile->getClientFilename(),
                'mimeType' => $uploadedFile->getClientMediaType(),
                'size' => $uploadedFile->getSize()
            ]);

            $mediaId = $this->db->lastInsertId();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => [
                    'id' => $mediaId,
                    'filename' => $filename,
                    'url' => "/uploads/{$filename}"
                ]
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

    public function getMediaList(Request $request, Response $response): Response
    {
        try {
            $stmt = $this->db->query("
                SELECT Id, Filename, OriginalName, MimeType, Size, UploadedAt
                FROM Media
                ORDER BY UploadedAt DESC
                LIMIT 100
            ");
            
            $media = $stmt->fetchAll();

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => $media
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

    public function getMedia(Request $request, Response $response, array $args): Response
    {
        try {
            $id = $args['id'];
            
            $stmt = $this->db->prepare("
                SELECT Id, Filename, OriginalName, MimeType, Size, UploadedAt
                FROM Media
                WHERE Id = :id
            ");
            
            $stmt->execute(['id' => $id]);
            $media = $stmt->fetch();

            if (!$media) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Media not found'
                ]));
                return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
            }

            $response->getBody()->write(json_encode([
                'success' => true,
                'data' => $media
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

    public function deleteMedia(Request $request, Response $response, array $args): Response
    {
        try {
            $id = $args['id'];
            
            $stmt = $this->db->prepare("SELECT Filename FROM Media WHERE Id = :id");
            $stmt->execute(['id' => $id]);
            $media = $stmt->fetch();

            if (!$media) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'error' => 'Media not found'
                ]));
                return $response->withStatus(404)->withHeader('Content-Type', 'application/json');
            }

            // Delete file
            $filepath = $this->uploadDir . $media['Filename'];
            if (file_exists($filepath)) {
                unlink($filepath);
            }

            // Delete from database
            $stmt = $this->db->prepare("DELETE FROM Media WHERE Id = :id");
            $stmt->execute(['id' => $id]);

            $response->getBody()->write(json_encode([
                'success' => true,
                'message' => 'Media deleted successfully'
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

    private function moveUploadedFile(UploadedFileInterface $uploadedFile): string
    {
        $extension = pathinfo($uploadedFile->getClientFilename(), PATHINFO_EXTENSION);
        $basename = bin2hex(random_bytes(8));
        $filename = sprintf('%s.%s', $basename, $extension);

        $uploadedFile->moveTo($this->uploadDir . $filename);

        return $filename;
    }
}

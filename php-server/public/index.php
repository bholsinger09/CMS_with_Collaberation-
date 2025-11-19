<?php

use Slim\Factory\AppFactory;
use DI\Container;
use CMSCollaboration\Middleware\CorsMiddleware;
use CMSCollaboration\Controllers\ContentController;
use CMSCollaboration\Controllers\MediaController;
use CMSCollaboration\Controllers\TagController;

require __DIR__ . '/../vendor/autoload.php';

// Create Container
$container = new Container();
AppFactory::setContainer($container);

// Database connection
$container->set('db', function () {
    $host = getenv('DB_HOST') ?: 'localhost';
    $database = getenv('DB_DATABASE') ?: 'cms_collaboration';
    $username = getenv('DB_USERNAME') ?: 'cmsuser';
    $password = getenv('DB_PASSWORD') ?: 'cmspassword';
    
    $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
    
    try {
        $pdo = new PDO($dsn, $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]);
        return $pdo;
    } catch (PDOException $e) {
        throw new PDOException($e->getMessage(), (int)$e->getCode());
    }
});

// Create App
$app = AppFactory::create();

// Add middleware
$app->add(new CorsMiddleware());
$app->addErrorMiddleware(true, true, true);

// Routes
$app->group('/api', function ($group) {
    // Content routes
    $group->get('/content/published', ContentController::class . ':getPublishedContent');
    $group->get('/content/{id}/html', ContentController::class . ':getContentAsHtml');
    $group->post('/content/{id}/export', ContentController::class . ':exportContent');
    
    // Media routes
    $group->post('/media/upload', MediaController::class . ':uploadMedia');
    $group->get('/media', MediaController::class . ':getMediaList');
    $group->get('/media/{id}', MediaController::class . ':getMedia');
    $group->delete('/media/{id}', MediaController::class . ':deleteMedia');
    
    // Tag routes
    $group->get('/tags', TagController::class . ':getAllTags');
    $group->post('/tags', TagController::class . ':createTag');
    $group->get('/content/tags/{tag}', ContentController::class . ':getContentByTag');
});

$app->run();

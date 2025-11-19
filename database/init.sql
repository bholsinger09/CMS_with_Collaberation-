-- CMS Collaboration Platform Database Schema
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS cms_collaboration CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cms_collaboration;

-- Users table
CREATE TABLE IF NOT EXISTS Users (
    Id CHAR(36) PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(50) NOT NULL DEFAULT 'Editor',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastLoginAt DATETIME NULL,
    INDEX idx_email (Email),
    INDEX idx_username (Username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contents table
CREATE TABLE IF NOT EXISTS Contents (
    Id CHAR(36) PRIMARY KEY,
    Title VARCHAR(500) NOT NULL,
    Body LONGTEXT NOT NULL,
    Status VARCHAR(50) NOT NULL DEFAULT 'draft',
    AuthorId CHAR(36) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PublishedAt DATETIME NULL,
    FOREIGN KEY (AuthorId) REFERENCES Users(Id) ON DELETE RESTRICT,
    INDEX idx_status (Status),
    INDEX idx_author (AuthorId),
    INDEX idx_created (CreatedAt),
    INDEX idx_published (PublishedAt),
    FULLTEXT idx_fulltext (Title, Body)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Content Versions table
CREATE TABLE IF NOT EXISTS ContentVersions (
    Id CHAR(36) PRIMARY KEY,
    ContentId CHAR(36) NOT NULL,
    VersionNumber INT NOT NULL,
    Body LONGTEXT NOT NULL,
    CreatedById CHAR(36) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ChangeDescription VARCHAR(500) NULL,
    FOREIGN KEY (ContentId) REFERENCES Contents(Id) ON DELETE CASCADE,
    FOREIGN KEY (CreatedById) REFERENCES Users(Id) ON DELETE RESTRICT,
    UNIQUE KEY unique_version (ContentId, VersionNumber),
    INDEX idx_content_version (ContentId, VersionNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Collaboration Sessions table
CREATE TABLE IF NOT EXISTS CollaborationSessions (
    Id CHAR(36) PRIMARY KEY,
    ContentId CHAR(36) NOT NULL,
    UserId CHAR(36) NOT NULL,
    ConnectionId VARCHAR(100) NOT NULL,
    JoinedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LeftAt DATETIME NULL,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (ContentId) REFERENCES Contents(Id) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    INDEX idx_connection (ConnectionId),
    INDEX idx_active (ContentId, IsActive),
    INDEX idx_user_session (UserId, IsActive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tags table
CREATE TABLE IF NOT EXISTS Tags (
    Id CHAR(36) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Content Tags (many-to-many)
CREATE TABLE IF NOT EXISTS ContentTags (
    ContentId CHAR(36) NOT NULL,
    TagId CHAR(36) NOT NULL,
    PRIMARY KEY (ContentId, TagId),
    FOREIGN KEY (ContentId) REFERENCES Contents(Id) ON DELETE CASCADE,
    FOREIGN KEY (TagId) REFERENCES Tags(Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Media table
CREATE TABLE IF NOT EXISTS Media (
    Id CHAR(36) PRIMARY KEY,
    Filename VARCHAR(255) NOT NULL,
    OriginalName VARCHAR(255) NOT NULL,
    MimeType VARCHAR(100) NOT NULL,
    Size BIGINT NOT NULL,
    UploadedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UploadedById CHAR(36) NULL,
    FOREIGN KEY (UploadedById) REFERENCES Users(Id) ON DELETE SET NULL,
    INDEX idx_uploaded (UploadedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments table
CREATE TABLE IF NOT EXISTS Comments (
    Id CHAR(36) PRIMARY KEY,
    ContentId CHAR(36) NOT NULL,
    UserId CHAR(36) NOT NULL,
    ParentId CHAR(36) NULL,
    Body TEXT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ContentId) REFERENCES Contents(Id) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    FOREIGN KEY (ParentId) REFERENCES Comments(Id) ON DELETE CASCADE,
    INDEX idx_content (ContentId),
    INDEX idx_parent (ParentId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Activity Log table
CREATE TABLE IF NOT EXISTS ActivityLog (
    Id BIGINT AUTO_INCREMENT PRIMARY KEY,
    UserId CHAR(36) NOT NULL,
    Action VARCHAR(100) NOT NULL,
    EntityType VARCHAR(50) NOT NULL,
    EntityId CHAR(36) NOT NULL,
    Details JSON NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    INDEX idx_user (UserId),
    INDEX idx_entity (EntityType, EntityId),
    INDEX idx_created (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample admin user
-- Password: admin123 (hashed with SHA256)
INSERT INTO Users (Id, Username, Email, PasswordHash, Role, CreatedAt) VALUES
(UUID(), 'admin', 'admin@cms.local', 'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=', 'Admin', NOW()),
(UUID(), 'editor', 'editor@cms.local', 'XohImNooBHFR0OVvjcYpJ3NgPQ1qq73WKhHvch0VQtg=', 'Editor', NOW())
ON DUPLICATE KEY UPDATE Email=Email;

-- Insert sample tags
INSERT INTO Tags (Id, Name, CreatedAt) VALUES
(UUID(), 'Technology', NOW()),
(UUID(), 'Business', NOW()),
(UUID(), 'Design', NOW()),
(UUID(), 'Development', NOW()),
(UUID(), 'Marketing', NOW())
ON DUPLICATE KEY UPDATE Name=Name;

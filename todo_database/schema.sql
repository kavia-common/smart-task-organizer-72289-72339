-- Schema for Todo List App (MySQL)
-- Includes: users, tasks, subtasks with appropriate constraints and indexes
-- Supports LIKE and FULLTEXT search on title and description

-- Safety/session settings
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  priority TINYINT UNSIGNED NOT NULL DEFAULT 2, -- 1=low, 2=medium, 3=high
  estimated_minutes INT UNSIGNED NULL,
  due_at DATETIME NULL,
  completed TINYINT(1) NOT NULL DEFAULT 0,
  parent_task_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_tasks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_tasks_parent FOREIGN KEY (parent_task_id) REFERENCES tasks(id) ON DELETE SET NULL,
  -- Indexes for filtering/sorting/joins
  KEY idx_tasks_user_id (user_id),
  KEY idx_tasks_parent_task_id (parent_task_id),
  KEY idx_tasks_due_at (due_at),
  KEY idx_tasks_priority (priority),
  KEY idx_tasks_completed (completed),
  -- Helpful for simple LIKE queries (prefix matches may use this; leading-wildcard won't)
  KEY idx_tasks_title (title(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Full-text index for better search on title and description
-- Note: Requires MySQL/InnoDB with FULLTEXT support (available in MySQL 5.6+ for InnoDB, recommended MySQL 8+).
-- Will be used with MATCH ... AGAINST; LIKE will still work regardless of this index.
ALTER TABLE tasks
  ADD FULLTEXT KEY ftx_tasks_title_description (title, description);

-- Subtasks table (child items of tasks)
-- Subtasks can optionally override attributes; otherwise inherit from parent task at the application layer.
CREATE TABLE IF NOT EXISTS subtasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  task_id BIGINT UNSIGNED NOT NULL, -- parent task
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  priority TINYINT UNSIGNED NULL, -- if NULL, inherit from parent task
  estimated_minutes INT UNSIGNED NULL,
  due_at DATETIME NULL,
  completed TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_subtasks_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  -- Indexes for filtering/sorting/joins
  KEY idx_subtasks_task_id (task_id),
  KEY idx_subtasks_due_at (due_at),
  KEY idx_subtasks_completed (completed),
  KEY idx_subtasks_priority (priority),
  KEY idx_subtasks_title (title(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Full-text index for subtasks title/description
ALTER TABLE subtasks
  ADD FULLTEXT KEY ftx_subtasks_title_description (title, description);

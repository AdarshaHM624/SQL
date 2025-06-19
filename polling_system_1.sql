
-- README: Online Polling/Voting System (MySQL)
-- Description: Implements a complete polling system with user management, poll creation, voting, and analytics.
-- Supports: Anonymous voting, Multi-select polls, Most active users, Trending polls, Soft deletion

-- Create and use the database
CREATE DATABASE IF NOT EXISTS polling_system;
USE polling_system;

-- Drop tables if they already exist (for reset purposes)
DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS poll_options;
DROP TABLE IF EXISTS polls;
DROP TABLE IF EXISTS users;

-- Feature 1: User Management
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Feature 2: Poll Creation
CREATE TABLE polls (
    poll_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    expiration_date DATETIME NOT NULL,
    is_multi_select BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);

-- Feature 3: Poll Options
CREATE TABLE poll_options (
    option_id INT AUTO_INCREMENT PRIMARY KEY,
    poll_id INT,
    option_text VARCHAR(255) NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (poll_id) REFERENCES polls(poll_id) ON DELETE CASCADE
);

-- Feature 4, 5: Voting and Vote Recording (now supports multi-select)
CREATE TABLE votes (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    poll_id INT,
    option_id INT,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    anonymous BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (poll_id) REFERENCES polls(poll_id),
    FOREIGN KEY (option_id) REFERENCES poll_options(option_id)
);

-- Sample users
INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('carol', 'carol@example.com'),
('dave', 'dave@example.com'),
('eve', 'eve@example.com'),
('frank', 'frank@example.com'),
('grace', 'grace@example.com'),
('heidi', 'heidi@example.com'),
('ivan', 'ivan@example.com'),
('judy', 'judy@example.com');

-- Sample polls
INSERT INTO polls (title, description, expiration_date, is_multi_select, created_by) VALUES
('Vote for National Party', 'Choose your favorite national party.', NOW(), FALSE, 1),
('State Election Vote', 'Select state-level parties (multi-select).', NOW() + INTERVAL 7 DAY, TRUE, 2),
('Local Governance Poll', 'Vote for local bodies.', NOW() + INTERVAL 7 DAY, FALSE, 3);


-- Sample poll options
INSERT INTO poll_options (poll_id, option_text) VALUES
(1, 'Party A'), (1, 'Party B'), (1, 'Party C'), (1, 'Party D'),
(2, 'Party E'), (2, 'Party F'), (2, 'Party G'), (2, 'Party H'),
(3, 'Party I'), (3, 'Party J'), (3, 'Party K');


-- Sample votes with multi-select enabled on poll_id 2
INSERT INTO votes (user_id, poll_id, option_id, anonymous) VALUES
(1, 1, 1, FALSE), (2, 1, 2, TRUE), (3, 1, 1, FALSE),
(4, 2, 5, FALSE), (4, 2, 6, FALSE), -- user 4 votes for 2 options in poll 2
(5, 2, 6, FALSE), (6, 2, 5, TRUE),
(7, 3, 9, FALSE), (8, 3, 10, FALSE), (9, 3, 9, FALSE), (10, 3, 11, TRUE);

-- Feature 6: Poll Status
-- Result 6: Active vs expired
SELECT poll_id, title,
       CASE
           WHEN expiration_date > NOW() THEN 'Active'
           ELSE 'Expired'
       END AS status
FROM polls
WHERE is_deleted = FALSE;

-- Feature 7: Poll Analytics
-- Result 1: Total votes per poll
SELECT p.title, COUNT(v.vote_id) AS total_votes
FROM polls p
LEFT JOIN votes v ON p.poll_id = v.poll_id
GROUP BY p.poll_id;

-- Result 2: Total votes per option
SELECT po.option_text, COUNT(v.vote_id) AS votes
FROM poll_options po
LEFT JOIN votes v ON po.option_id = v.option_id
GROUP BY po.option_id;

-- Feature 8: User Participation
-- Result 3: Polls participated by a specific user (example: user_id = 1)
SELECT DISTINCT p.title
FROM polls p
JOIN votes v ON p.poll_id = v.poll_id
WHERE v.user_id = 1;

-- Bonus Feature: Most active users
-- Result 4
SELECT u.username, COUNT(v.vote_id) AS vote_count
FROM users u
JOIN votes v ON u.user_id = v.user_id
GROUP BY u.user_id
ORDER BY vote_count DESC;

-- Bonus Feature: Trending polls (votes in last 24 hours)
-- Result 5
SELECT p.title, COUNT(v.vote_id) AS recent_votes
FROM polls p
JOIN votes v ON p.poll_id = v.poll_id
WHERE v.voted_at >= NOW() - INTERVAL 1 DAY
GROUP BY p.poll_id
ORDER BY recent_votes DESC;

-- Bonus Feature: Soft delete example
UPDATE polls SET is_deleted = TRUE WHERE poll_id = 1;

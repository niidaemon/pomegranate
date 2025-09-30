-- ===================================================================
-- Description: Repeatable migration for maintaining views
-- ===================================================================

-- View of active users (those who logged in within the last 30 days)
CREATE OR REPLACE VIEW active_users AS
SELECT
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.created_at,
    u.updated_at
FROM users u
WHERE u.updated_at >= NOW() - INTERVAL '30 days';

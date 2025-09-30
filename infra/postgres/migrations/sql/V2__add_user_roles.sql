-- ===================================================================
-- Description: Add roles table and user-role relationships
-- ===================================================================

-- Roles table (e.g., admin, customer, support)
CREATE TABLE roles (
    id          SERIAL PRIMARY KEY,
    name        TEXT UNIQUE NOT NULL,
    description TEXT
);

-- Mapping table for many-to-many relationship between users and roles
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- Index for quick lookups by user
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);

-- Index for quick lookups by role
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

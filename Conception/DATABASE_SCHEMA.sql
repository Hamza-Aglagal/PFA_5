-- ============================================================
-- SIMSTRUCT - PostgreSQL Database Schema
-- Version: 1.0.0
-- Database: PostgreSQL 16
-- Generated: 2024
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search optimization

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE user_role AS ENUM ('USER', 'PRO', 'ADMIN');
CREATE TYPE material_type AS ENUM ('CONCRETE', 'STEEL', 'WOOD', 'ALUMINUM', 'COMPOSITE');
CREATE TYPE load_type AS ENUM ('POINT', 'DISTRIBUTED', 'MOMENT', 'TRIANGULAR', 'TRAPEZOIDAL', 'UNIFORM');
CREATE TYPE support_type AS ENUM ('SIMPLY_SUPPORTED', 'FIXED_FIXED', 'FIXED_FREE', 'FIXED_PINNED', 'CONTINUOUS', 'FIXED', 'PINNED');
CREATE TYPE simulation_status AS ENUM ('DRAFT', 'RUNNING', 'COMPLETED', 'FAILED');
CREATE TYPE friendship_status AS ENUM ('PENDING', 'ACCEPTED', 'BLOCKED');
CREATE TYPE invitation_status AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED');
CREATE TYPE share_permission AS ENUM ('VIEW', 'COMMENT', 'EDIT');
CREATE TYPE notification_type AS ENUM ('INFO', 'SUCCESS', 'WARNING', 'ERROR');
CREATE TYPE notification_category AS ENUM ('SIMULATION', 'COMMUNITY', 'SYSTEM', 'MARKETING');

-- ============================================================
-- TABLE: users
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'USER',
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_url VARCHAR(512),
    phone VARCHAR(20),
    company VARCHAR(100),
    job_title VARCHAR(100),
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_name_length CHECK (LENGTH(name) >= 2)
);

-- Indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_role ON users(role) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_name_search ON users USING gin(name gin_trgm_ops) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);

COMMENT ON TABLE users IS 'User accounts for the SimStruct application';
COMMENT ON COLUMN users.deleted_at IS 'Soft delete timestamp - NULL means active';

-- ============================================================
-- TABLE: simulations
-- ============================================================

CREATE TABLE simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Beam Geometry
    beam_length DOUBLE PRECISION NOT NULL,
    beam_height DOUBLE PRECISION NOT NULL,
    beam_width DOUBLE PRECISION NOT NULL,
    
    -- Material Properties
    material_type material_type NOT NULL,
    elastic_modulus DOUBLE PRECISION NOT NULL,
    
    -- Load Configuration
    load_type load_type NOT NULL,
    load_magnitude DOUBLE PRECISION NOT NULL,
    load_position DOUBLE PRECISION,
    
    -- Support Configuration
    support_type support_type NOT NULL,
    
    -- Flags
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    status simulation_status NOT NULL DEFAULT 'DRAFT',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign Keys
    CONSTRAINT fk_simulations_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Validation Constraints
    CONSTRAINT chk_beam_length_positive CHECK (beam_length > 0),
    CONSTRAINT chk_beam_height_positive CHECK (beam_height > 0),
    CONSTRAINT chk_beam_width_positive CHECK (beam_width > 0),
    CONSTRAINT chk_elastic_modulus_positive CHECK (elastic_modulus > 0),
    CONSTRAINT chk_load_magnitude_positive CHECK (load_magnitude > 0),
    CONSTRAINT chk_load_position_valid CHECK (load_position IS NULL OR (load_position >= 0 AND load_position <= beam_length))
);

-- Indexes
CREATE INDEX idx_simulations_user_id ON simulations(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_simulations_public ON simulations(is_public) WHERE deleted_at IS NULL AND is_public = TRUE;
CREATE INDEX idx_simulations_favorite ON simulations(user_id, is_favorite) WHERE deleted_at IS NULL AND is_favorite = TRUE;
CREATE INDEX idx_simulations_status ON simulations(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_simulations_created_at ON simulations(created_at DESC);
CREATE INDEX idx_simulations_name_search ON simulations USING gin(name gin_trgm_ops) WHERE deleted_at IS NULL;

COMMENT ON TABLE simulations IS 'Structural beam simulations created by users';
COMMENT ON COLUMN simulations.is_public IS 'Whether simulation is visible in public gallery';

-- ============================================================
-- TABLE: simulation_results
-- ============================================================

CREATE TABLE simulation_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    simulation_id UUID NOT NULL UNIQUE,
    
    -- Calculated Results
    max_deflection DOUBLE PRECISION NOT NULL,
    max_bending_moment DOUBLE PRECISION NOT NULL,
    max_shear_force DOUBLE PRECISION NOT NULL,
    max_stress DOUBLE PRECISION NOT NULL,
    safety_factor DOUBLE PRECISION NOT NULL,
    
    -- Extended Data (JSON)
    recommendations JSONB DEFAULT '[]',
    stress_distribution JSONB,
    deflection_curve JSONB,
    ai_insights JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_simulation_results_simulation 
        FOREIGN KEY (simulation_id) 
        REFERENCES simulations(id) 
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_simulation_results_simulation_id ON simulation_results(simulation_id);
CREATE INDEX idx_simulation_results_safety_factor ON simulation_results(safety_factor);

COMMENT ON TABLE simulation_results IS 'Calculated results for completed simulations';
COMMENT ON COLUMN simulation_results.recommendations IS 'JSON array of recommendation strings';

-- ============================================================
-- TABLE: friendships
-- ============================================================

CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL,
    addressee_id UUID NOT NULL,
    status friendship_status NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_friendships_requester 
        FOREIGN KEY (requester_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_friendships_addressee 
        FOREIGN KEY (addressee_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_no_self_friendship CHECK (requester_id != addressee_id),
    CONSTRAINT uk_friendship_pair UNIQUE (requester_id, addressee_id)
);

-- Indexes
CREATE INDEX idx_friendships_requester ON friendships(requester_id);
CREATE INDEX idx_friendships_addressee ON friendships(addressee_id);
CREATE INDEX idx_friendships_status ON friendships(status);
CREATE INDEX idx_friendships_pending ON friendships(addressee_id, status) WHERE status = 'PENDING';

-- Function to ensure no duplicate reverse friendship
CREATE OR REPLACE FUNCTION check_duplicate_friendship()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM friendships 
        WHERE requester_id = NEW.addressee_id 
        AND addressee_id = NEW.requester_id
    ) THEN
        RAISE EXCEPTION 'Friendship already exists between these users';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_duplicate_friendship
    BEFORE INSERT ON friendships
    FOR EACH ROW
    EXECUTE FUNCTION check_duplicate_friendship();

COMMENT ON TABLE friendships IS 'Friend connections between users';

-- ============================================================
-- TABLE: invitations
-- ============================================================

CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    message TEXT,
    status invitation_status NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_invitations_sender 
        FOREIGN KEY (sender_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_invitation_email_format CHECK (recipient_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes
CREATE INDEX idx_invitations_sender ON invitations(sender_id);
CREATE INDEX idx_invitations_recipient ON invitations(recipient_email);
CREATE INDEX idx_invitations_status ON invitations(status) WHERE status = 'PENDING';
CREATE INDEX idx_invitations_expires ON invitations(expires_at) WHERE status = 'PENDING';

COMMENT ON TABLE invitations IS 'Email invitations sent to non-users';

-- ============================================================
-- TABLE: shared_simulations
-- ============================================================

CREATE TABLE shared_simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    simulation_id UUID NOT NULL,
    owner_id UUID NOT NULL,
    shared_with_id UUID NOT NULL,
    permission share_permission NOT NULL DEFAULT 'VIEW',
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_shared_simulations_simulation 
        FOREIGN KEY (simulation_id) 
        REFERENCES simulations(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_shared_simulations_owner 
        FOREIGN KEY (owner_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_shared_simulations_shared_with 
        FOREIGN KEY (shared_with_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_no_self_share CHECK (owner_id != shared_with_id),
    CONSTRAINT uk_shared_simulation UNIQUE (simulation_id, shared_with_id)
);

-- Indexes
CREATE INDEX idx_shared_simulations_simulation ON shared_simulations(simulation_id);
CREATE INDEX idx_shared_simulations_owner ON shared_simulations(owner_id);
CREATE INDEX idx_shared_simulations_shared_with ON shared_simulations(shared_with_id);
CREATE INDEX idx_shared_simulations_permission ON shared_simulations(permission);

COMMENT ON TABLE shared_simulations IS 'Simulations shared between users with specific permissions';

-- ============================================================
-- TABLE: notifications
-- ============================================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type notification_type NOT NULL DEFAULT 'INFO',
    category notification_category NOT NULL DEFAULT 'SYSTEM',
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(512),
    data JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_notifications_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_category ON notifications(user_id, category);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Partial index for recent notifications (last 30 days)
CREATE INDEX idx_notifications_recent ON notifications(user_id, created_at DESC) 
    WHERE created_at > NOW() - INTERVAL '30 days';

COMMENT ON TABLE notifications IS 'User notifications for various system events';

-- ============================================================
-- TABLE: conversations
-- ============================================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_1_id UUID NOT NULL,
    participant_2_id UUID NOT NULL,
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_conversations_participant_1 
        FOREIGN KEY (participant_1_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_conversations_participant_2 
        FOREIGN KEY (participant_2_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_no_self_conversation CHECK (participant_1_id != participant_2_id),
    CONSTRAINT uk_conversation_participants UNIQUE (participant_1_id, participant_2_id)
);

-- Indexes
CREATE INDEX idx_conversations_participant_1 ON conversations(participant_1_id);
CREATE INDEX idx_conversations_participant_2 ON conversations(participant_2_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- Function to ensure no duplicate reverse conversation
CREATE OR REPLACE FUNCTION check_duplicate_conversation()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM conversations 
        WHERE participant_1_id = NEW.participant_2_id 
        AND participant_2_id = NEW.participant_1_id
    ) THEN
        RAISE EXCEPTION 'Conversation already exists between these users';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_duplicate_conversation
    BEFORE INSERT ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION check_duplicate_conversation();

COMMENT ON TABLE conversations IS 'Chat conversations between two users';

-- ============================================================
-- TABLE: chat_messages
-- ============================================================

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Foreign Keys
    CONSTRAINT fk_chat_messages_conversation 
        FOREIGN KEY (conversation_id) 
        REFERENCES conversations(id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_chat_messages_sender 
        FOREIGN KEY (sender_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_message_not_empty CHECK (LENGTH(TRIM(content)) > 0)
);

-- Indexes
CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(conversation_id, created_at DESC);
CREATE INDEX idx_chat_messages_unread ON chat_messages(conversation_id, is_read) WHERE is_read = FALSE;

-- Trigger to update conversation's last_message_at
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations 
    SET last_message_at = NEW.created_at 
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_conversation_last_message
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_last_message();

COMMENT ON TABLE chat_messages IS 'Individual chat messages within conversations';

-- ============================================================
-- TABLE: refresh_tokens
-- ============================================================

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign Keys
    CONSTRAINT fk_refresh_tokens_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token_hash) WHERE revoked_at IS NULL;
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at) WHERE revoked_at IS NULL;

-- Cleanup function for expired tokens
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM refresh_tokens 
    WHERE expires_at < NOW() OR revoked_at IS NOT NULL;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE refresh_tokens IS 'JWT refresh tokens for authentication';
COMMENT ON COLUMN refresh_tokens.token_hash IS 'SHA-256 hash of the refresh token';

-- ============================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_simulations_updated_at
    BEFORE UPDATE ON simulations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_friendships_updated_at
    BEFORE UPDATE ON friendships
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_invitations_updated_at
    BEFORE UPDATE ON invitations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VIEWS
-- ============================================================

-- View: Active users (non-deleted)
CREATE VIEW v_active_users AS
SELECT id, email, name, role, avatar_url, company, job_title, created_at
FROM users
WHERE deleted_at IS NULL;

-- View: Public simulations with user info
CREATE VIEW v_public_simulations AS
SELECT 
    s.id,
    s.name,
    s.description,
    s.material_type,
    s.load_type,
    s.support_type,
    s.status,
    s.created_at,
    u.id AS user_id,
    u.name AS user_name,
    u.avatar_url AS user_avatar
FROM simulations s
JOIN users u ON s.user_id = u.id
WHERE s.is_public = TRUE 
AND s.deleted_at IS NULL 
AND u.deleted_at IS NULL;

-- View: User statistics
CREATE VIEW v_user_stats AS
SELECT 
    u.id AS user_id,
    COUNT(DISTINCT s.id) AS total_simulations,
    COUNT(DISTINCT CASE WHEN s.created_at > NOW() - INTERVAL '30 days' THEN s.id END) AS monthly_simulations,
    COUNT(DISTINCT CASE WHEN s.status = 'COMPLETED' THEN s.id END) AS completed_simulations,
    COUNT(DISTINCT ss.id) AS shared_simulations,
    COUNT(DISTINCT f.id) FILTER (WHERE f.status = 'ACCEPTED') AS friend_count
FROM users u
LEFT JOIN simulations s ON u.id = s.user_id AND s.deleted_at IS NULL
LEFT JOIN shared_simulations ss ON u.id = ss.owner_id
LEFT JOIN friendships f ON u.id = f.requester_id OR u.id = f.addressee_id
WHERE u.deleted_at IS NULL
GROUP BY u.id;

-- View: Unread notification counts
CREATE VIEW v_unread_notification_counts AS
SELECT 
    user_id,
    COUNT(*) AS unread_count,
    COUNT(*) FILTER (WHERE category = 'SIMULATION') AS simulation_count,
    COUNT(*) FILTER (WHERE category = 'COMMUNITY') AS community_count,
    COUNT(*) FILTER (WHERE category = 'SYSTEM') AS system_count
FROM notifications
WHERE is_read = FALSE
GROUP BY user_id;

-- ============================================================
-- FUNCTIONS FOR COMMON OPERATIONS
-- ============================================================

-- Function: Get friends for a user
CREATE OR REPLACE FUNCTION get_friends(p_user_id UUID)
RETURNS TABLE (
    friend_id UUID,
    friend_name VARCHAR,
    friend_email VARCHAR,
    friend_avatar VARCHAR,
    friendship_id UUID,
    connected_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE 
            WHEN f.requester_id = p_user_id THEN f.addressee_id 
            ELSE f.requester_id 
        END AS friend_id,
        u.name AS friend_name,
        u.email AS friend_email,
        u.avatar_url AS friend_avatar,
        f.id AS friendship_id,
        f.updated_at AS connected_at
    FROM friendships f
    JOIN users u ON u.id = CASE 
        WHEN f.requester_id = p_user_id THEN f.addressee_id 
        ELSE f.requester_id 
    END
    WHERE (f.requester_id = p_user_id OR f.addressee_id = p_user_id)
    AND f.status = 'ACCEPTED'
    AND u.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Function: Get conversation between two users (or create if not exists)
CREATE OR REPLACE FUNCTION get_or_create_conversation(p_user_1 UUID, p_user_2 UUID)
RETURNS UUID AS $$
DECLARE
    v_conversation_id UUID;
BEGIN
    -- Check existing conversation (either direction)
    SELECT id INTO v_conversation_id
    FROM conversations
    WHERE (participant_1_id = p_user_1 AND participant_2_id = p_user_2)
       OR (participant_1_id = p_user_2 AND participant_2_id = p_user_1);
    
    -- Create if not exists
    IF v_conversation_id IS NULL THEN
        INSERT INTO conversations (participant_1_id, participant_2_id)
        VALUES (p_user_1, p_user_2)
        RETURNING id INTO v_conversation_id;
    END IF;
    
    RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Mark all notifications as read for a user
CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE notifications 
    SET is_read = TRUE 
    WHERE user_id = p_user_id AND is_read = FALSE;
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Function: Soft delete a simulation and related shares
CREATE OR REPLACE FUNCTION soft_delete_simulation(p_simulation_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verify ownership
    IF NOT EXISTS (
        SELECT 1 FROM simulations 
        WHERE id = p_simulation_id AND user_id = p_user_id AND deleted_at IS NULL
    ) THEN
        RETURN FALSE;
    END IF;
    
    -- Soft delete
    UPDATE simulations 
    SET deleted_at = NOW() 
    WHERE id = p_simulation_id;
    
    -- Remove shares
    DELETE FROM shared_simulations WHERE simulation_id = p_simulation_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SEED DATA (Development Only)
-- ============================================================

-- This section should only be run in development/testing environments

-- INSERT INTO users (email, password, name, role, email_verified) VALUES
-- ('admin@simstruct.com', '$2a$10$...', 'Admin User', 'ADMIN', TRUE),
-- ('user@simstruct.com', '$2a$10$...', 'Test User', 'USER', TRUE);

-- ============================================================
-- GRANTS (Adjust according to your database roles)
-- ============================================================

-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO simstruct_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO simstruct_app;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO simstruct_app;

-- ============================================================
-- END OF SCHEMA
-- ============================================================

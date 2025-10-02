CREATE TABLE carts(
    id BIGSERIAL PRIMARY KEY,
    cart_token VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    subtotal_cents BIGINT NOT NULL DEFAULT 0,
    discount_cents BIGINT NOT NULL DEFAULT 0,
    tax_cents BIGINT NOT NULL DEFAULT 0,
    shipping_cents BIGINT NOT NULL DEFAULT 0,
    total_cents BIGINT NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    coupon_code VARCHAR(50),
    coupon_discount_cents BIGINT DEFAULT 0,
    converted_to_order_id BIGINT,
    converted_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_carts_status CHECK (status IN ('active', 'abandoned', 'converted', 'merged'))
);

CREATE INDEX idx_carts_user ON carts(user_id, status);
CREATE INDEX idx_carts_token ON carts(cart_token) WHERE status = 'active';
CREATE INDEX idx_carts_expires ON carts(expires_at) WHERE status = 'active';

CREATE TABLE cart_items(
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    quantity INTEGER NOT NULL,
    unit_price_cents BIGINT NOT NULL,
    compare_at_price_cents BIGINT,
    total_price_cents BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    product_name VARCHAR(500) NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    variant_name VARCHAR(200),
    image_url VARCHAR(500),
    custom_options JSONB DEFAULT '{}',
    added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_cart_items_quantity CHECK (quantity > 0),
    CONSTRAINT unq_cart_items_product UNIQUE(cart_id, product_id, variant_id)
);

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product ON cart_items(product_id);

CREATE TABLE abandoned_cart_recovery (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    user_id BIGINT,
    email_sent_count INTEGER NOT NULL DEFAULT 0,
    first_email_sent_at TIMESTAMP WITH TIME ZONE,
    last_email_sent_at TIMESTAMP WITH TIME ZONE,
    email_opened_count INTEGER NOT NULL DEFAULT 0,
    email_clicked_count INTEGER NOT NULL DEFAULT 0,
    recovered BOOLEAN NOT NULL DEFAULT FALSE,
    recovered_at TIMESTAMP WITH TIME ZONE,
    recovery_order_id BIGINT,
    discount_code VARCHAR(50),
    discount_amount_cents BIGINT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_abandoned_cart_recovery_cart ON abandoned_cart_recovery(cart_id);
CREATE INDEX idx_abandoned_cart_recovery_user ON abandoned_cart_recovery(user_id, recovered);
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT REFERENCES categories(id) ON DELETE RESTRICT,
    lft INTEGER NOT NULL,
    rgt INTEGER NOT NULL,
    depth INTEGER NOT NULL DEFAULT 0,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(500),
    icon VARCHAR(100),
    sort_order INTEGER NOT NULL DEFAULT 0,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_categories_nested_set CHECK (lft < rgt)
);

CREATE INDEX idx_categories_parent ON categories(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_nested_set ON categories(lft, rgt) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_slug ON categories(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_active ON categories(is_active, sort_order);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    barcode VARCHAR(100) UNIQUE,
    category_id BIGINT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    brand VARCHAR(100),
    name VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    short_description TEXT,
    long_description TEXT,
    price_cents BIGINT NOT NULL,
    compare_at_price_cents BIGINT,
    cost_cents BIGINT,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    weight_grams INTEGER,
    length_cm DECIMAL(10, 2),
    width_cm DECIMAL(10, 2),
    height_cm DECIMAL(10, 2),
    track_inventory BOOLEAN NOT NULL DEFAULT TRUE,
    allow_back_order BOOLEAN NOT NULL DEFAULT FALSE,
    low_stock_threshold INTEGER DEFAULT 10,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_digital BOOLEAN NOT NULL DEFAULT FALSE,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    attributes JSONB DEFAULT '{}',
    view_count BIGINT NOT NULL DEFAULT 0,
    purchase_count BIGINT NOT NULL DEFAULT 0,
    rating_average DECIMAL(3, 2),
    rating_count INTEGER NOT NULL DEFAULT 0,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_products_status CHECK (status IN ('draft', 'active', 'archived', 'out_of_stock')),
    CONSTRAINT chk_products_price CHECK (price_cents >= 0),
    CONSTRAINT chk_products_rating CHECK (rating_average >= 0 AND rating_average <= 5)
);

CREATE INDEX idx_products_sku ON products(sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_category ON products(category_id,status);
CREATE INDEX idx_products_status ON products(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_featured ON products(is_featured, created_at DESC) WHERE is_featured=TRUE;
CREATE INDEX idx_products_price ON products(price_cents);
CREATE INDEX idx_products_rating ON products(rating_average DESC NULLS LAST);
CREATE INDEX idx_products_attributes ON products USING GIN(attributes);
CREATE INDEX idx_products_search ON products USING GIN(to_tsvector('english', name || '' || COALESCE(short_description)));

CREATE TABLE product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    thumbnail_url VARCHAR(500),
    medium_url VARCHAR(500),
    large_url VARCHAR(500),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX unq_product_images_primary ON product_images(product_id) WHERE is_primary = TRUE;

CREATE INDEX idx_product_images_product ON product_images(product_id, sort_order);

CREATE TABLE product_variants (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    attributes JSONB NOT NULL,
    price_cents BIGINT,
    compare_at_price_cents BIGINT,
    weight_grams INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unq_product_variants_attributes UNIQUE(product_id, attributes)
);

CREATE INDEX idx_product_variants_product ON product_variants(product_id);
CREATE INDEX idx_product_variants_sku ON product_variants(sku);
CREATE INDEX idx_product_variants_attributes ON product_variants USING GIN(attributes);

CREATE TABLE product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL,
    order_id BIGINT,
    rating INTEGER NOT NULL,
    title VARCHAR(200),
    review TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    moderated_by BIGINT,
    moderated_at TIMESTAMP WITH TIME ZONE,
    moderation_notes TEXT,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    not_helpful_count INTEGER NOT NULL DEFAULT 0,
    is_verified_purchase BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_product_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_product_reviews_status CHECK (status IN ('pending', 'approved', 'rejected', 'flagged')),
    CONSTRAINT unq_product_reviews_user_product UNIQUE(user_id, product_id, order_id)
);

CREATE INDEX idx_product_reviews_product ON product_reviews(product_id, status, created_at DESC);
CREATE INDEX idx_product_reviews_user ON product_reviews(user_id);
CREATE INDEX idx_product_reviews_rating ON product_reviews(product_id, rating);
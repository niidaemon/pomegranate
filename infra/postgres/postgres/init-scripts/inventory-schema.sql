CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

CREATE TABLE warehouses(
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(2) NOT NULL DEFAULT 'US',
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    phone VARCHAR(20),
    email VARCHAR(255),
    manager VARCHAR(200),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    priority INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_warehouses_active ON warehouses(is_active,priority DESC);
CREATE INDEX idx_warehouses_location ON warehouses USING GIST(ll_to_earth(latitude, longitude));

CREATE TABLE inventory_stock(
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    warehouse_id BIGINT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    quantity_available INTEGER NOT NULL DEFAULT 0,
    quantity_reserved INTEGER NOT NULL DEFAULT 0,
    quantity_committed INTEGER NOT NULL DEFAULT 0,
    bin_location VARCHAR(50),
    aisle VARCHAR(20),
    shelf VARCHAR(20),
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    last_counted_at TIMESTAMP WITH TIME ZONE,
    last_counted_by BIGINT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_inventory_stock_quantities CHECK (
        quantity_available >= 0 AND 
        quantity_reserved >= 0 AND 
        quantity_committed >= 0
    ),
    CONSTRAINT unq_inventory_stock_product_warehouse UNIQUE(product_id, variant_id, warehouse_id)
);

CREATE INDEX idx_inventory_stock_product ON inventory_stock(product_id, warehouse_id);
CREATE INDEX idx_inventory_stock_variant ON inventory_stock(variant_id, warehouse_id);
CREATE INDEX idx_inventory_stock_warehouse ON inventory_stock(warehouse_id);
CREATE INDEX idx_inventory_stock_low_stock ON inventory_stock(product_id) WHERE quantity_available <= reorder_point;

CREATE TABLE inventory_reservations(
    id BIGSERIAL PRIMARY KEY,
    reservation_code VARCHAR(50) NOT NULL UNIQUE,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    warehouse_id BIGINT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    order_id BIGINT,
    user_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    committed_at TIMESTAMP WITH TIME ZONE,
    released_at TIMESTAMP WITH TIME ZONE,
    release_reason VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_inventory_reservations_quantity CHECK (quantity > 0),
    CONSTRAINT chk_inventory_reservations_status CHECK (status IN ('active', 'committed', 'released', 'expired'))
);

CREATE INDEX idx_inventory_reservations_product ON inventory_reservations(product_id, status);
CREATE INDEX idx_inventory_reservations_order ON inventory_reservations(order_id);
CREATE INDEX idx_inventory_reservations_expires ON inventory_reservations(expires_at) WHERE status = 'active';
CREATE INDEX idx_inventory_reservations_user ON inventory_reservations(user_id, status);

CREATE TABLE inventory_movements(
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT,
    warehouse_id BIGINT NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
    movement_type VARCHAR(50) NOT NULL,
    quantity_change INTEGER NOT NULL,
    quantity_before INTEGER NOT NULL,
    quantity_after INTEGER NOT NULL,
    reference_type VARCHAR(50),
    reference_id BIGINT,
    reason TEXT,
    notes TEXT,
    performed_by BIGINT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_inventory_movements_type CHECK (movement_type IN (
        'purchase', 'sale', 'return', 'adjustment', 'transfer_in', 'transfer_out',
        'damage', 'theft', 'recount'
    ))
);

CREATE INDEX idx_inventory_movements_product ON inventory_movements(product_id, created_at DESC);
CREATE INDEX idx_inventory_movements_warehouse ON inventory_movements(warehouse_id, created_at DESC);
CREATE INDEX idx_inventory_movements_type ON inventory_movements(movement_type, created_at DESC);
CREATE INDEX idx_inventory_movements_reference ON inventory_movements(reference_type, reference_id);
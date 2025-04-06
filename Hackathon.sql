-- 🚀 Create Database
CREATE DATABASE Spacy;
USE Spacy;

-- 1️⃣ User Roles Table (Prevents Role Redundancy)
CREATE TABLE user_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name ENUM('admin', 'astronaut', 'staff') UNIQUE NOT NULL
);

-- 2️⃣ Users Table (Stores User Data)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(role_id) ON DELETE CASCADE
);

-- 3️⃣ Storage Locations Table (Prevents Redundancy in Storage Units)
CREATE TABLE storage_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(255) UNIQUE NOT NULL
);

-- 4️⃣ Storage Units Table (ISS Storage Compartments)
CREATE TABLE storage_units (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    unit_name VARCHAR(100) UNIQUE NOT NULL,
    location_id INT NOT NULL,
    max_capacity INT NOT NULL,
    current_load INT DEFAULT 0,
    FOREIGN KEY (location_id) REFERENCES storage_locations(location_id) ON DELETE CASCADE
);

-- 5️⃣ Cargo Categories Table (Avoids Repeating ENUM in Cargo Items)
CREATE TABLE cargo_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name ENUM('food', 'medicine', 'equipment', 'supplies', 'waste') UNIQUE NOT NULL
);

-- 6️⃣ Cargo Items Table (Stores Cargo Details)
CREATE TABLE cargo_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    unit_weight DECIMAL(10,2) NOT NULL, -- Weight in kg
    expiration_date DATE,
    stored_in_unit INT NOT NULL,
    added_by INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES cargo_categories(category_id) ON DELETE CASCADE,
    FOREIGN KEY (stored_in_unit) REFERENCES storage_units(unit_id) ON DELETE CASCADE,
    FOREIGN KEY (added_by) REFERENCES users(user_id) ON DELETE SET NULL
);
CREATE TABLE cargo_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    unit_weight DECIMAL(10,2) NOT NULL, -- Weight in kg
    expiration_date DATE,
    stored_in_unit INT NOT NULL,
    added_by INT NULL,  
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES cargo_categories(category_id) ON DELETE CASCADE,
    FOREIGN KEY (stored_in_unit) REFERENCES storage_units(unit_id) ON DELETE CASCADE,
    FOREIGN KEY (added_by) REFERENCES users(user_id) ON DELETE SET NULL  -- ✅ Now it works!
);
-- 7️⃣ Cargo Movements Table (Tracks Storage & Retrieval Actions)
CREATE TABLE cargo_movements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    action ENUM('stored', 'retrieved', 'moved', 'disposed') NOT NULL,
    quantity INT NOT NULL,
    moved_by INT NULL, 
    moved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    from_unit INT DEFAULT NULL,
    to_unit INT DEFAULT NULL,
    FOREIGN KEY (item_id) REFERENCES cargo_items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (moved_by) REFERENCES users(user_id) ON DELETE SET NULL,  -- ✅ Now it works!
    FOREIGN KEY (from_unit) REFERENCES storage_units(unit_id) ON DELETE SET NULL,
    FOREIGN KEY (to_unit) REFERENCES storage_units(unit_id) ON DELETE SET NULL
);


-- 8️⃣ Waste Reasons Table (Avoids Hardcoded ENUM)
CREATE TABLE waste_reasons (
    reason_id INT AUTO_INCREMENT PRIMARY KEY,
    reason_description ENUM('expired', 'damaged', 'unusable') UNIQUE NOT NULL
);

-- 9️⃣ Waste Management Table (Tracks Expired/Waste Items)
CREATE TABLE waste_management (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    reason_id INT NOT NULL,
    recorded_by INT NULL,  
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'disposed', 'returned') DEFAULT 'pending',
    FOREIGN KEY (item_id) REFERENCES cargo_items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (reason_id) REFERENCES waste_reasons(reason_id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by) REFERENCES users(user_id) ON DELETE SET NULL  -- ✅ Now it works!
);


-- 🔟 Cargo Imports Table (For Bulk Cargo Uploads via CSV)
CREATE TABLE cargo_imports (
    import_id INT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    uploaded_by INT NULL,  
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processed', 'failed') DEFAULT 'pending',
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE SET NULL  -- ✅ Now it works!
);

-- 1️⃣1️⃣ Alert Types Table (Avoids Hardcoded ENUM)
CREATE TABLE alert_types (
    alert_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name ENUM('low_stock', 'expiration', 'system_warning') UNIQUE NOT NULL
);

-- 1️⃣2️⃣ Alerts Table (For Notifications & Critical Warnings)
CREATE TABLE alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    alert_type_id INT NOT NULL,
    status ENUM('unread', 'read', 'resolved') DEFAULT 'unread',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alert_type_id) REFERENCES alert_types(alert_type_id) ON DELETE CASCADE
);

INSERT INTO user_roles (role_name) VALUES ('admin')
ON DUPLICATE KEY UPDATE role_id=role_id;

INSERT INTO users (name, email, password_hash, role_id)
VALUES ('Sahil Shah', 'sahil@spacy.com', 'sahilshah35',
       (SELECT role_id FROM user_roles WHERE role_name = 'admin'));

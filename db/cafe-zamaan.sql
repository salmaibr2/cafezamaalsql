-- CAFE ZAMAAN DATABASE

-- Drop existing tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS staff;

-- Table creation 

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    display_order INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_order_date TIMESTAMP NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    tip_amount DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id) ON DELETE SET NULL
);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hourly_rate DECIMAL(10, 2),
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- sample data insertion

INSERT INTO categories (category_name, description, display_order) VALUES
('Coffee', 'Specialty coffee drinks', 1),
('Matcha', 'Premium matcha beverages', 2),
('Non-Coffee Drinks', 'Alternative beverages', 3),
('Desserts', 'Sweet treats', 4);

INSERT INTO menu_items (item_name, description, price, category_id) VALUES
-- Coffee Drinks (category_id = 1)
('Baklawa Brew Latte', 'house made baklawa syrup made with orange blossom water, cinnamon and vanilla + cardamom cream top + pistachio sprinkle', 7.50, 1),
('Brown Sugar Cardamom Latte', 'house made brown sugar cardamom syrup + double shot of espresso + your choice of milk', 6.00, 1),
('Spanish Latte', 'sweetened with sweetened condensed milk', 6.00, 1),
('Sticky Date Latte', 'buttery and rich salted date carmel', 6.00, 1),
('S''mores Latte', 'mocha latte with toasted marshmallow topping', 7.00, 1),

-- Matcha Drinks (category_id = 2)
('Brown Sugar Cardamom Matcha', 'house made brown sugar cardamom syrup + premium grade ceremonial matcha sourced from Fukuoka, Japan', 7.00, 2),
('Brown Sugar Matcha Latte', 'house made brown sugar syrup + premium grade ceremonial matcha sourced from Fukuoka, Japan', 7.00, 2),
('Fig and Vanilla Matcha', 'house made organic fig + vanilla syrup paired with ceremonial blend matcha sourced from Uji, Kyoto and your choice of milk', 7.00, 2),
('Sticky Date Matcha', 'buttery and rich salted date carmel with premium matcha', 7.00, 2),

-- Non-Coffee Drinks (category_id = 3)
('Hot Chocolate', 'hot chocolate with toasted marshmallow topping', 5.00, 3),
('Mint Lemonade', 'freshly squeezed lemon juice blended with mint and cane sugar', 5.00, 3),
('Sahlab', 'traditional hot, thick, sweet and creamy milk drink', 5.00, 3),
-- Desserts (category_id = 4)
('Omm Ali', 'Fresh, hot, Egyptian bread pudding', 6.50, 4);

-- Insert sample staff
INSERT INTO staff (first_name, last_name, email, phone, position, hourly_rate, hire_date) VALUES
('Sana', 'Alh', 'sana.a@cafezamaan.com', '123-555-1004', 'Barista', 25.00, '2022-07-15'),
('Salma', 'Ibrahim', 'salma.i@cafezamaan.com', '408-555-1005', 'Manager', 40.00, '2020-05-01'),
('Omar', 'Khan', 'omar.k@cafezamaan.com', '408-555-1006', 'Barista', 25.00, '2021-03-10');


-- Example queries for analytics

-- Get all orders for a specific customer (customer_id = 1)

-- SELECT o.order_id, o.order_date, o.total_amount, o.status
-- FROM orders o
-- WHERE o.customer_id = 1;

-- -- Get all customers with their order counts

-- SELECT c.first_name, c.last_name, COUNT(o.order_id) as num_orders
-- FROM customers c
-- LEFT JOIN orders o ON c.customer_id = o.customer_id
-- GROUP BY c.customer_id, c.first_name, c.last_name;

-- -- Get top 5 spending customers

-- SELECT c.first_name, c.last_name,
--        COUNT(o.order_id) as visit_count,
--        SUM(o.total_amount) as total_spent
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- GROUP BY c.customer_id, c.first_name, c.last_name
-- ORDER BY total_spent DESC
-- LIMIT 5;

-- Menu items organized by category

-- SELECT c.category_name, m.item_name, m.price, m.description
-- FROM menu_items m
-- JOIN categories c ON m.category_id = c.category_id
-- WHERE m.is_available = TRUE
-- ORDER BY c.display_order, m.item_name;

-- Revenue by drink category

-- SELECT c.category_name, 
--        COUNT(DISTINCT oi.order_id) as num_orders,
--        SUM(oi.quantity) as items_sold,
--        SUM(oi.subtotal) as total_revenue,
--        AVG(oi.unit_price) as avg_price
-- FROM order_items oi
-- JOIN menu_items m ON oi.item_id = m.item_id
-- JOIN categories c ON m.category_id = c.category_id
-- GROUP BY c.category_name
-- ORDER BY total_revenue DESC;

-- Best selling items

-- SELECT m.item_name, 
--        c.category_name,
--        COUNT(*) as times_ordered,
--        SUM(oi.quantity) as total_sold,
--        SUM(oi.subtotal) as revenue
-- FROM order_items oi
-- JOIN menu_items m ON oi.item_id = m.item_id
-- JOIN categories c ON m.category_id = c.category_id
-- GROUP BY m.item_id, m.item_name, c.category_name
-- ORDER BY total_sold DESC
-- LIMIT 10;

-- Daily sales summary

-- SELECT DATE(order_date) as sale_date,
--        COUNT(*) as num_orders,
--        SUM(total_amount) as daily_revenue,
--        SUM(tip_amount) as daily_tips,
--        AVG(total_amount) as avg_order_value
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY DATE(order_date)
-- ORDER BY sale_date DESC;

-- Peak hours analysis

-- SELECT HOUR(order_date) as hour_of_day,
--        COUNT(*) as num_orders,
--        SUM(total_amount) as hourly_revenue
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY HOUR(order_date)
-- ORDER BY num_orders DESC;

-- Revenue by payment method

-- SELECT payment_method,
--        COUNT(*) as num_transactions,
--        SUM(total_amount) as total_revenue,
--        AVG(total_amount) as avg_transaction
-- FROM orders
-- WHERE status = 'completed'
-- GROUP BY payment_method
-- ORDER BY total_revenue DESC;

-- Top spending customers

-- SELECT c.first_name, c.last_name,
--        COUNT(o.order_id) as visit_count,
--        SUM(o.total_amount) as total_spent,
--        SUM(o.tip_amount) as total_tips,
--        AVG(o.total_amount) as avg_order
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- WHERE o.status = 'completed'
-- GROUP BY c.customer_id
-- ORDER BY total_spent DESC
-- LIMIT 5;

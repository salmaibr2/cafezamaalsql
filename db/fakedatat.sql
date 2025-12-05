-- inster sample order items
INSERT INTO order_items (order_id, item_id, quantity, unit_price, subtotal, special_instructions) VALUES
(1, 1, 2, 7.50, 15.00, 'No pistachios'),
(1, 3, 1, 6.00, 6.00, 'Extra foam'),
(2, 5, 1, 7.00, 7.00, ''),
(2, 10, 2, 5.00, 10.00, 'Less sugar'),
(3, 2, 1, 6.00, 6.00, 'Almond milk'),
(3, 8, 1, 7.00, 7.00, ''),
(4, 4, 2, 6.00, 12.00, 'No caramel drizzle'),
(4, 11, 1, 6.50, 6.50, ''),
(5, 6, 1, 7.00, 7.00, 'Extra hot'),
(5, 9, 1, 5.00, 5.00, 'With marshmallows'),
(6, 7, 2, 7.00, 14.00, ''),
(6, 1, 1, 7.50, 7.50, 'No cardamom cream'),
(7, 3, 1, 6.00, 6.00, ''),
(7, 10, 1, 5.00, 5.00, 'No mint'),
(8, 2, 2, 6.00, 12.00, 'Oat milk'),
(8, 4, 1, 6.00, 6.00, ''),
(9, 5, 1, 7.00, 7.00, 'Extra marshmallow topping'),
(9, 11, 2, 6.50, 13.00, ''),
(10, 6, 1, 7.00, 7.00, ''),
(10, 9, 1, 5.00, 5.00, 'Less sugar'),
(11, 8, 1, 7.00, 7.00, ''),
(12, 1, 2, 7.50, 15.00, 'No pistachios'),
(13, 2, 1, 6.00, 6.00, 'Almond milk'),
(14, 3, 1, 6.00, 6.00, 'Extra foam'),
(15, 4, 2, 6.00, 12.00, '');

--- Insert sample orders total ammount needs to include tax amount and tip amount
INSERT INTO orders (customer_id, total_amount, tax_amount, tip_amount, status, payment_method) VALUES
(1, 24.05, 1.05, 2.00, 'completed', 'credit_card'),
(2, 19.45, 0.85, 1.50, 'completed', 'cash'),
(3, 13.65, 0.65, 0.00, 'completed', 'credit_card'),
(4, 21.93, 0.93, 2.50, 'completed', 'debit_card'),
(5, 13.60, 0.60, 1.00, 'completed', 'cash'),
(6, 24.58, 1.08, 2.00, 'completed', 'credit_card'),
(7, 12.05, 0.55, 0.50, 'completed', 'debit_card'),
(8, 20.90, 0.90, 2.00, 'completed', 'credit_card'),
(9, 23.50, 1.00, 2.50, 'completed', 'cash'),
(10, 13.60, 0.60, 1.00, 'completed', 'debit_card'),
(11, 7.49, 0.49, 0.00, 'completed', 'credit_card'),
(12, 24.05, 1.05, 2.00, 'completed', 'cash'),
(13, 12.60, 0.60, 0.50, 'completed', 'debit_card'),
(14, 13.65, 0.65, 0.00, 'completed', 'credit_card'),
(15, 12.60, 0.60, 1.00, 'completed', 'cash');


-- Insert sample customers loyalty points based on 15 orders above
INSERT INTO customers (first_name, last_name, email, phone, loyalty_points, last_order_date) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '493-555-1234', 250, '2025-10-05'),
('Bob', 'Smith', 'bob.smith@example.com', '302-555-5678', 85, '2025-10-04'),
('David', 'Wilson', 'david.wilson@example.com', '238-555-4321', 110, '2025-10-04'),
('Eva', 'Brown', 'eva.brown@example.com', '234-555-6789', 100, '2025-10-02'),
('Frank', 'Miller', 'frank.miller@example.com', '454-555-9876', 105, '2025-10-01'),
('Jamila', 'Ahmed', 'jamila.ahmed@example.com', '344-555-3456', 90, '2025-10-02'),
('Hassan', 'Ali', 'hassan.ali@example.com', '493-555-1234', 80, '2025-10-01'),
('Irene', 'Garcia', 'irene.garcia@example.com', '493-555-1234', 85, '2025-10-03'),
('Jason', 'Lee', 'jason.lee@example.com', '493-555-1234', 75, '2025-10-02'),
('Kate', 'Martinez', 'kate.martinez@example.com', '493-555-1234', 70, '2025-10-01'),
('Carol', 'Davis', 'carol.davis@example.com', '345-555-8765', 95, '2025-10-03'),
('Mike', 'Garcia', 'mike.garcia@example.com', '345-555-8765', 85, '2025-10-02'),
('Nina', 'Rodriguez', 'nina.rodriguez@example.com', '345-555-8765', 80, '2025-10-01'),
('Olivia', 'Martinez', 'olivia.martinez@example.com', '345-555-8765', 75, '2025-10-01'),
('Paul', 'Hernandez', 'paul.hernandez@example.com', '345-555-8765', 70, '2025-10-01');
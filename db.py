import os
import mysql.connector
from mysql.connector import errorcode


def get_db_config_from_env():
    return {
        'host': os.environ.get('MYSQL_HOST', '127.0.0.1'),
        'port': int(os.environ.get('MYSQL_PORT', 3306)),
        'user': os.environ.get('MYSQL_USER', 'root'),
    # YOU NEED TO CHANGE THE PASSWORD TO YOUR OWN MYSQL PASSWORD BEFORE RUNNING THE APPLICATION
        'password': os.environ.get('MYSQL_PASSWORD', 'YourPasswordHere'),
        'database': os.environ.get('MYSQL_DB', 'cafezamaan')
    }


def get_connection():
    cfg = get_db_config_from_env()
    try:
        conn = mysql.connector.connect(**cfg)
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            raise RuntimeError('DB access denied — check credentials')
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            raise RuntimeError('Database does not exist')
        else:
            raise


def get_categories():
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT category_id, category_name, display_order FROM categories ORDER BY display_order")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows


def get_menu_items_by_category(category_id):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute(
        "SELECT item_id, item_name, description, price, is_available FROM menu_items WHERE category_id = %s AND is_available = TRUE ORDER BY item_name",
        (category_id,)
    )
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows


def get_menu_item(item_id):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM menu_items WHERE item_id = %s", (item_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    return row


def create_order(customer_id, items, tip_amount=0.0, payment_method='cash'):
    conn = get_connection()
    try:
        cur = conn.cursor()
        conn.start_transaction()

        # compute totals by querying current prices
        total = 0.0
        order_items_data = []
        for it in items:
            cur.execute("SELECT price FROM menu_items WHERE item_id = %s", (it['item_id'],))
            r = cur.fetchone()
            if not r:
                raise RuntimeError(f"Menu item id {it['item_id']} not found")
            unit_price = float(r[0])
            qty = int(it.get('quantity', 1))
            subtotal = round(unit_price * qty, 2)
            total += subtotal
            order_items_data.append((it['item_id'], qty, unit_price, subtotal, it.get('special_instructions')))

        tax = round(total * 0.08, 2)  # example 8% tax
        grand_total = round(total + tax + float(tip_amount), 2)

        # insert order
        cur.execute(
            "INSERT INTO orders (customer_id, total_amount, tax_amount, tip_amount, status, payment_method) VALUES (%s, %s, %s, %s, %s, %s)",
            (customer_id, grand_total, tax, tip_amount, 'completed', payment_method)
        )
        order_id = cur.lastrowid

        # insert order items
        for item in order_items_data:
            cur.execute(
                "INSERT INTO order_items (order_id, item_id, quantity, unit_price, subtotal, special_instructions) VALUES (%s, %s, %s, %s, %s, %s)",
                (order_id, item[0], item[1], item[2], item[3], item[4])
            )

        # update customer's last_order_date and loyalty points if customer exists
        if customer_id:
            cur.execute("UPDATE customers SET last_order_date = NOW(), loyalty_points = COALESCE(loyalty_points,0) + FLOOR(%s) WHERE customer_id = %s", (total, customer_id))

        conn.commit()
        cur.close()
        return order_id
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

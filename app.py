import os
import tkinter as tk
from tkinter import ttk, simpledialog, messagebox
import db

class CafeApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Cafe Zamaan - Ordering')
        self.geometry('1000x600')

        self.categories = []
        self.menu_items = []
        self.cart = []  # list of dicts {item_id, item_name, qty, unit_price, subtotal}

        self.create_widgets()
        self.load_categories()

    def create_widgets(self):
        # layout: left categories, center menu, right cart
        self.left_frame = ttk.Frame(self, width=200)
        self.left_frame.pack(side='left', fill='y')

        self.center_frame = ttk.Frame(self)
        self.center_frame.pack(side='left', fill='both', expand=True)

        self.right_frame = ttk.Frame(self, width=300)
        self.right_frame.pack(side='right', fill='y')

        ttk.Label(self.left_frame, text='Categories').pack(pady=8)
        self.cat_list = tk.Listbox(self.left_frame, exportselection=False)
        self.cat_list.pack(fill='y', expand=True, padx=8, pady=8)
        self.cat_list.bind('<<ListboxSelect>>', self.on_category_select)

        ttk.Label(self.center_frame, text='Menu').pack(anchor='w', padx=8, pady=6)
        self.menu_canvas = tk.Canvas(self.center_frame)
        self.menu_scroll = ttk.Scrollbar(self.center_frame, orient='vertical', command=self.menu_canvas.yview)
        self.menu_container = ttk.Frame(self.menu_canvas)
        self.menu_container.bind('<Configure>', lambda e: self.menu_canvas.configure(scrollregion=self.menu_canvas.bbox('all')))
        self.menu_canvas.create_window((0, 0), window=self.menu_container, anchor='nw')
        self.menu_canvas.configure(yscrollcommand=self.menu_scroll.set)
        self.menu_canvas.pack(side='left', fill='both', expand=True)
        self.menu_scroll.pack(side='right', fill='y')

        ttk.Label(self.right_frame, text='Cart').pack(pady=8)
        # Use a Treeview to show items and (optional) special instructions beneath each item
        self.cart_tree = ttk.Treeview(self.right_frame)
        self.cart_tree.pack(fill='both', expand=True, padx=8)

        self.total_var = tk.StringVar(value='Total: $0.00')
        ttk.Label(self.right_frame, textvariable=self.total_var).pack(pady=4)

        btn_frame = ttk.Frame(self.right_frame)
        btn_frame.pack(pady=8)
        ttk.Button(btn_frame, text='Remove Item', command=self.remove_cart_item).pack(side='left', padx=6)
        ttk.Button(btn_frame, text='Checkout', command=self.checkout).pack(side='left', padx=6)

    def load_categories(self):
        try:
            cats = db.get_categories()
        except Exception as e:
            messagebox.showerror('DB Error', str(e))
            return
        self.categories = cats
        self.cat_list.delete(0, tk.END)
        for c in cats:
            self.cat_list.insert(tk.END, c['category_name'])
        if cats:
            self.cat_list.selection_set(0)
            self.on_category_select()

    def on_category_select(self, event=None):
        sel = self.cat_list.curselection()
        if not sel:
            return
        idx = sel[0]
        cat = self.categories[idx]
        self.load_menu(cat['category_id'])

    def load_menu(self, category_id):
        for w in self.menu_container.winfo_children():
            w.destroy()
        try:
            items = db.get_menu_items_by_category(category_id)
        except Exception as e:
            messagebox.showerror('DB Error', str(e))
            return
        for it in items:
            frame = ttk.Frame(self.menu_container, padding=6, relief='ridge')
            frame.pack(fill='x', padx=6, pady=6)
            name = f"{it['item_name']} - ${it['price']:.2f}"
            ttk.Label(frame, text=name, font=('Segoe UI', 10, 'bold')).pack(anchor='w')
            ttk.Label(frame, text=it.get('description') or '', wraplength=500).pack(anchor='w')
            btn = ttk.Button(frame, text='Add to cart', command=lambda i=it: self.add_to_cart_dialog(i))
            btn.pack(anchor='e')

    def add_to_cart_dialog(self, item):
        qty = simpledialog.askinteger('Quantity', f"How many '{item['item_name']}'?", minvalue=1, initialvalue=1)
        if not qty:
            return
        instr = simpledialog.askstring('Instructions', 'Any special instructions? (optional)')
        self.add_to_cart(item, qty, instr)

    def add_to_cart(self, item, qty, special_instructions=None):
        subtotal = round(float(item['price']) * qty, 2)
        entry = {
            'item_id': item['item_id'],
            'item_name': item['item_name'],
            'qty': qty,
            'unit_price': float(item['price']),
            'subtotal': float(subtotal),
            'special_instructions': special_instructions
        }
        self.cart.append(entry)
        self.refresh_cart()

    def refresh_cart(self):
        # Clear tree
        for iid in self.cart_tree.get_children():
            self.cart_tree.delete(iid)

        total = 0.0
        for idx, it in enumerate(self.cart):
            subtotal = float(it.get('subtotal', 0.0))
            line = f"{it['qty']}x {it['item_name']} - ${subtotal:.2f}"
            parent_id = f"item{idx}"
            # Insert the main item row
            self.cart_tree.insert('', 'end', iid=parent_id, text=line)
            # If special instructions exist, insert a child row to show them
            instr = it.get('special_instructions')
            if instr:
                child_id = f"{parent_id}_note"
                self.cart_tree.insert(parent_id, 'end', iid=child_id, text=f"    Note: {instr}")
            total += subtotal
        self.total_var.set(f'Total: ${total:.2f}')

    def remove_cart_item(self):
        sel = self.cart_tree.selection()
        if not sel:
            return
        sel_id = sel[0]
        if sel_id.endswith('_note'):
            parent_id = sel_id.rsplit('_', 1)[0]
        else:
            parent_id = sel_id
        try:
            idx = int(parent_id.replace('item', ''))
        except Exception:
            return
        if 0 <= idx < len(self.cart):
            del self.cart[idx]
            self.refresh_cart()

    def checkout(self):
        if not self.cart:
            messagebox.showinfo('Cart Empty', 'Please add items to the cart before checkout.')
            return
        # simple checkout dialog
        email = simpledialog.askstring('Customer Email', 'Customer email (optional):')
        tip = simpledialog.askfloat('Tip', 'Tip amount (e.g., 1.50)', minvalue=0.0, initialvalue=0.0)
        pay = simpledialog.askstring('Payment', 'Payment method (cash/card):', initialvalue='cash')
        # attempt to find customer id by email if provided
        customer_id = None
        first_name = ''
        loyalty_points = 0
        if email:
            # try to find customer and retrieve name and loyalty points if they exist
            try:
                conn = db.get_connection()
                cur = conn.cursor()
                cur.execute("SELECT customer_id, first_name, loyalty_points FROM customers WHERE email = %s", (email,))
                r = cur.fetchone()
                if r:
                    customer_id = r[0]
                    first_name = r[1] or ''
                    loyalty_points = r[2] or 0
                cur.close()
                conn.close()
            except Exception:
                customer_id = None

        # If email provided but customer not found, create a new customer with base loyalty points (10)
        if email and not customer_id:
            try:
                first = simpledialog.askstring('First name', 'Customer first name (optional):') or ''
                last = simpledialog.askstring('Last name', 'Customer last name (optional):') or ''
                conn = db.get_connection()
                cur = conn.cursor()
                # insert new customer with base loyalty points = 10
                cur.execute(
                    "INSERT INTO customers (first_name, last_name, email, loyalty_points) VALUES (%s, %s, %s, %s)",
                    (first, last, email, 10)
                )
                customer_id = cur.lastrowid
                # assign locally used values
                first_name = first
                loyalty_points = 10
                conn.commit()
                cur.close()
                conn.close()
            except Exception as e:
                messagebox.showerror('Customer Error', f'Failed to create customer: {e}')
                return

        items_payload = [{'item_id': it['item_id'], 'quantity': it['qty'], 'special_instructions': it.get('special_instructions')} for it in self.cart]
        try:
            order_id = db.create_order(customer_id, items_payload, tip_amount=tip or 0.0, payment_method=pay or 'cash')
        except Exception as e:
            messagebox.showerror('Order Error', str(e))
            return
        # retrieve updated loyalty points
        if customer_id:
            try:
                conn = db.get_connection()
                cur = conn.cursor()
                cur.execute("SELECT loyalty_points FROM customers WHERE customer_id = %s", (customer_id,))
                r = cur.fetchone()
                if r:
                    loyalty_points = r[0] or 0
                cur.close()
                conn.close()
            except Exception:
                pass
        message = f'Thanks {first_name if first_name else ""}!\nYour Order Number is #{order_id}!\nYou now have {loyalty_points} loyalty points.'
        messagebox.showinfo('Order Complete', message)
        self.cart = []
        self.refresh_cart()

if __name__ == '__main__':
    app = CafeApp()
    app.mainloop()

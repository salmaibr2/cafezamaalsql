# Cafe Zamaan - Tkinter Ordering App

This is a small Python Tkinter application that connects to a MySQL database (schema included in `cafe-zamaan.sql`) to display the cafe menu, build a cart, and place orders. The instructions below explain how to run the app locally after unzipping the project folder.

**Technologies needed**
- Python 
- MySQL server (local or accessible remotely)
- Terminal command lineb(instructions are based on mac os)

**Instructions for set up**
1. Unzip the project and open a terminal in the project folder.

2. Create and activate a Python virtual environment, then install dependencies:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Ensure MySQL is installed and running on the machine. Common options:
- Homebrew on macOS: `brew services start mysql`
- Official package: `sudo /usr/local/mysql/support-files/mysql.server start`
- Docker: run a MySQL container and expose port 3306

4. Create the database and import the schema (run these in the terminal). If MySQL root has no password (Homebrew default):
```bash
mysql -u root -e "CREATE DATABASE IF NOT EXISTS cafezamaan;"
mysql -u root cafezamaan < cafe-zamaan.sql
mysql -u root
use cafezamaan;
#now you can run commands like select etc.
```
If `root` has a password, add `-p` and enter it when prompted:
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS cafezamaan;"
mysql -u root -p cafezamaan < cafe-zamaan.sql
mysql -u root -p 
use cafezamaan;
#now you can run commands like select etc.
```

6. Set the environment variables the app reads (example for bash):
```bash
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=cafe_app
export MYSQL_PASSWORD='Your Password'
export MYSQL_DB=cafezamaan
```

7. Run the app:
```bash
python3 app.py
```


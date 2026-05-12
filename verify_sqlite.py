import sqlite3

db_file = r'c:\Users\anuma\Desktop\ASSIGNMENT\northstar_dataset\NorthStar.db'
conn = sqlite3.connect(db_file)
cursor = conn.cursor()

# Get list of tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()
print("Tables in NorthStar.db:", [t[0] for t in tables])

# Check row counts
for table in tables:
    table_name = table[0]
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    count = cursor.fetchone()[0]
    print(f"Table: {table_name}, Rows: {count}")

conn.close()

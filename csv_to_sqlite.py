import pandas as pd
import sqlite3
import os
import glob

data_dir = r'c:\Users\Randiv\Desktop\ASSIGNMENT\northstar_dataset\data'
db_dir = r'c:\Users\Randiv\Desktop\ASSIGNMENT\northstar_dataset\db'

csv_files = glob.glob(os.path.join(data_dir, "*.csv"))

print(f"Found {len(csv_files)} CSV files.")

for csv_file in csv_files:
    file_name = os.path.basename(csv_file)
    db_name = file_name.replace('.csv', '.db')
    db_path = os.path.join(db_dir, db_name)
    
    table_name = file_name.replace('.csv', '')
    
    print(f"Converting {file_name} -> {db_name} (Table: {table_name})")
    
    try:
        df = pd.read_csv(csv_file)
        
        # Connect to SQLite (creates the file if it doesn't exist)
        conn = sqlite3.connect(db_path)
        
        # Write to SQL
        df.to_sql(table_name, conn, index=False, if_exists='replace')
        
        conn.close()
    except Exception as e:
        print(f"Error processing {file_name}: {e}")

print("All conversions complete!")

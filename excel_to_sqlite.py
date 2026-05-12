import pandas as pd
import sqlite3
import os

excel_file = r'c:\Users\Randiv\Desktop\ASSIGNMENT\northstar_dataset\NorthStar_Full_Dataset.xlsx'
db_file = r'c:\Users\Randiv\Desktop\ASSIGNMENT\northstar_dataset\NorthStar.db'

# Remove existing DB if it exists to start fresh
if os.path.exists(db_file):
    os.remove(db_file)

# Connect to SQLite database
conn = sqlite3.connect(db_file)

# Read Excel file
xl = pd.ExcelFile(excel_file)

print(f"Converting {excel_file} to {db_file}...")

for sheet in xl.sheet_names:
    print(f"Processing sheet: {sheet}")
    df = pd.read_excel(excel_file, sheet_name=sheet)
    
    # Clean column names (replace spaces with underscores, lowercase, etc. if needed)
    # df.columns = [c.replace(' ', '_').lower() for c in df.columns]
    
    # Write to SQL
    df.to_sql(sheet, conn, index=False, if_exists='replace')

conn.close()
print("Conversion complete!")

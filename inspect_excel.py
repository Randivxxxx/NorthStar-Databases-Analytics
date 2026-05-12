import pandas as pd

file_path = r'c:\Users\anuma\Desktop\ASSIGNMENT\northstar_dataset\NorthStar_Full_Dataset.xlsx'
xl = pd.ExcelFile(file_path)
print("Sheet Names:", xl.sheet_names)

for sheet in xl.sheet_names:
    df = pd.read_excel(file_path, sheet_name=sheet, nrows=5)
    print(f"\n--- Sheet: {sheet} ---")
    print("Columns:", df.columns.tolist())
    print("Head:\n", df.head())

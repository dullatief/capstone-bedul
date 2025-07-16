import sys
sys.path.append('/Users/abdullatif/Documents/capstone')
from backend.utilitas.database import get_db_connection

def check_table_schema(table_name):
    conn = get_db_connection()
    if not conn:
        print(f"Failed to connect to database")
        return
        
    cur = conn.cursor()
    
    # Describe the table structure
    cur.execute(f"DESCRIBE {table_name}")
    columns = cur.fetchall()
    
    print(f"\nSchema for table '{table_name}':")
    for col in columns:
        print(f"{col[0]}: {col[1]}")
    
    cur.close()
    conn.close()

# Check the tables we're working with
check_table_schema("riwayat_konsumsi")
check_table_schema("kompetisi_konsumsi")

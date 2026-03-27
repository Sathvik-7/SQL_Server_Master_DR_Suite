import pyodbc
import time
import random
import datetime

# Database Connection Configuration
# (Change Server name to your actual instance if not using localhost '.')
SERVER = ''
DATABASE = 'EnterpriseSales_Primary'
DRIVER = '{ODBC Driver 17 for SQL Server}' # Adjust if using a different ODBC driver

CONNECTION_STRING = f'DRIVER={DRIVER};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'

def insert_random_transaction(cursor):
    customer_id = random.randint(100, 999)
    product_id = random.randint(10, 99)
    quantity = random.randint(1, 10)
    revenue = round(random.uniform(10.0, 500.0), 2)
    region_id = random.randint(1, 4)

    query = """
    INSERT INTO Sales.Transactions (CustomerID, ProductID, Quantity, Revenue, RegionID)
    VALUES (?, ?, ?, ?, ?)
    """
    
    cursor.execute(query, (customer_id, product_id, quantity, revenue, region_id))

if __name__ == "__main__":
    print("==================================================")
    print(" Starting EnterpriseSales Traffic Simulator... ")
    print("==================================================")
    print("Press Ctrl+C to stop the simulator at any time.\n")

    try:
        with pyodbc.connect(CONNECTION_STRING) as conn:
            cursor = conn.cursor()
            transactions_inserted = 0
            
            while True:
                insert_random_transaction(cursor)
                conn.commit()
                transactions_inserted += 1
                
                # Log to console every 10 transactions
                if transactions_inserted % 10 == 0:
                    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    print(f"[{current_time}] Inserted {transactions_inserted} live transactions so far...")
                    
                # Sleep briefly between inserts to simulate sporadic human traffic
                time.sleep(random.uniform(0.5, 2.5))
                
    except pyodbc.Error as e:
        print(f"Database Error: Ensure '{DATABASE}' exists and your ODBC driver is installed.\nDetail: {e}")
    except KeyboardInterrupt:
        print(f"\nSimulator stopped by user. Total transactions inserted: {transactions_inserted}")
    except Exception as e:
        print(f"Unexpected error: {e}")

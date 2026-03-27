import pyodbc
import time
import os
import datetime
import glob

# Configuration
SERVER = ''
DATABASE = 'EnterpriseSales_Primary'
DRIVER = '{ODBC Driver 17 for SQL Server}'
BACKUP_DIR = r'\Backups'

# Connect to master so we can backup our target database freely
CONNECTION_STRING = f'DRIVER={DRIVER};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'

def run_backups_and_validate(cursor):
    # Ensure offsite backup directory exists
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)
        print(f"Created Backup Directory at: {BACKUP_DIR}")

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    full_path = os.path.join(BACKUP_DIR, f'ES_Primary_FULL_{timestamp}.bak')
    log_path = os.path.join(BACKUP_DIR, f'ES_Primary_LOG_{timestamp}.trn')
    
    # 1. Take FULL Backup
    print(f"\n[{datetime.datetime.now()}] Step 1: Taking FULL Database Backup...")
    cursor.execute(f"BACKUP DATABASE [{DATABASE}] TO DISK = '{full_path}' WITH INIT")
    while cursor.nextset():
        pass
    print(f"--> Saved to: {full_path}")
    
    # 2. Take LOG Backup
    print(f"\n[{datetime.datetime.now()}] Step 2: Taking Transaction LOG Backup...")
    cursor.execute(f"BACKUP LOG [{DATABASE}] TO DISK = '{log_path}' WITH INIT")
    while cursor.nextset():
        pass
    print(f"--> Saved to: {log_path}")
    
    # 3. Validation Process (RESTORE VERIFYONLY acts as a lightweight DBCC CHECKDB for the backup file)
    print("\n=============================================")
    print("[CRITICAL] Step 3: Verifying Backup Integrity")
    print("=============================================")
    
    cursor.execute(f"RESTORE VERIFYONLY FROM DISK = '{full_path}'")
    while cursor.nextset():
        pass
    print(f"SUCCESS: FULL Backup {os.path.basename(full_path)} is VALID and structurally intact.")
    
    cursor.execute(f"RESTORE VERIFYONLY FROM DISK = '{log_path}'")
    while cursor.nextset():
        pass
    print(f"SUCCESS: LOG Backup {os.path.basename(log_path)} is VALID and structurally intact.")

if __name__ == "__main__":
    print("--- SQL Server Automated Backup & Validator pipeline ---")
    try:
        # Autocommit MUST be True since BACKUP and DBCC statements cannot run inside a multi-statement transaction
        with pyodbc.connect(CONNECTION_STRING, autocommit=True) as conn:
            cursor = conn.cursor()
            run_backups_and_validate(cursor)
            
        print("\nPipeline Execution Finished Successfully.")
    except Exception as e:
        print(f"\nCRITICAL FAILURE During Backup/Validation Pipeline:\n{e}")

# 🛡️ Enterprise SQL Server Disaster Recovery (DR) Suite

A comprehensive, simulated **Enterprise Production Environment** designed to demonstrate mastery in Microsoft SQL Server Database Administration, High Availability (HA) architecture, Point-in-Time Recovery (PITR), and Python-driven automation.

This project moves beyond theoretical queries; it spins up a live primary database, injects continuous simulated transactional traffic, performs automated, validated backups, intentionally destroys the data, and successfully executes a flawless Point-in-Time Recovery.

---

## 🏗️ Architecture & Core Components

1. **Primary Database:** `EnterpriseSales_Primary` (Running in FULL Recovery Mode).
2. **Warm Standby:** `EnterpriseSales_Secondary` (Conceptualized via Log Shipping configurations).
3. **Live Workload Simulator:** A Python (`pyodbc`) application injecting continuous randomized sales transactions to emulate an active production server.
4. **Automated DBA Agent:** A Python script mimicking an automated SQL Server Agent Job to execute Full/T-Log backups and immediately validate their structural integrity via `RESTORE VERIFYONLY`.

---

## 🚀 The Disaster Recovery Workflow

The project is structured into six precise operational phases:

### 1. The Setup (`01_Initialize_Schema.sql`)
Initializes the `EnterpriseSales_Primary` database. **Crucially, the database is set to FULL Recovery Mode**. Without FULL recovery, transaction logs are not retained, making High Availability (HA) and Point-in-Time Recovery (PITR) impossible.

### 2. Live Production Traffic (`Simulator\Traffic_Simulator.py`)
Utilizes Python and `pyodbc` to connect to the SQL Server instance. The script runs an infinite loop, inserting randomized sales transactions every 1-2 seconds. This proves the ability to operate within and manage a live, active, and constantly changing database environment.

### 3. The Safety Net (`03_AutoBackup_Validator.py`)
Acts as an automated SQL Server Agent. When executed, it takes a **FULL Backup** and a **Transaction LOG Backup**, dropping them into an offsite `Backups` directory. It then automatically executes a `RESTORE VERIFYONLY` command to validate the structural integrity of the backup files, ensuring they are functional before a crisis occurs.

### 4. High Availability Concept (`02_Configure_LogShipping.sql`)
Provides the foundational T-SQL architecture behind maintaining a "Warm Standby" server. It documents taking the Full Backup from Step 3, restoring it to a secondary server `WITH STANDBY`, and continuously applying transaction logs to keep the secondary synchronized for immediate failover.

### 5. THE DISASTER! (`04_The_Disaster.sql`)
While the Python simulator is actively pumping data into the system, a catastrophic `DELETE FROM Sales.Transactions;` command (without a `WHERE` clause) is executed. All live production data instantly vanishes, proving the absolute necessity of the DR strategy in preventing data loss from human error.

### 6. The Rescue (`05_The_PITR_Rescue.sql`)
Executes the exact Rescue Sequence:
1. Kicks all users off the database and locks it recursively.
2. Captures a **Tail-Log Backup** to save any final, uncommitted transactions living in memory.
3. Restores the verified FULL Backup.
4. Restores the Transaction Logs using the `WITH STOPAT = '...'` parameter, recovering the database to the *exact second* before the disaster occurred, resulting in zero data loss.

---

## 💻 How to Run This Project Locally

To test this architecture on your local machine:

1. **Build the DB:** Open SSMS or Azure Data Studio and execute `1_Database_Setup/01_Initialize_Schema.sql`.
2. **Start the Traffic:** Open a terminal and run `python Simulator/Traffic_Simulator.py`. Watch the live transactions flow in.
3. **Automate the Backups:** Open a second terminal and run `python 3_Automated_Backups/03_AutoBackup_Validator.py` to secure the initial data points.
4. **Trigger the Catastrophe:** In SSMS, navigate to `4_Disaster_Simulation/04_The_Disaster.sql` and execute the `DELETE` statement to intentionally wipe the transaction tables. 
5. **Execute the Rescue:** Stop the Python simulator, identify the exact time the disaster occurred, and run `05_The_PITR_Rescue.sql` to perfectly restore the lost data!

---
*Created by a Database Engineer specializing in High Availability, Backup/Disaster Recovery Strategies, and Infrastructure Automation.*

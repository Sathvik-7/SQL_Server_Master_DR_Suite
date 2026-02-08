-- ==============================================================
-- SQL Server Master DR Suite
-- Phase 6B: Point-in-Time Recovery (PITR) Rescue
-- ==============================================================

USE master;
GO

-- 1. ISOLATE THE DATABASE
-- Kick all remaining users/application connections off the primary database to perform the rescue safely.
ALTER DATABASE [EnterpriseSales_Primary] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 2. TAKE A TAIL-LOG BACKUP
-- We must capture all transactions leading up to the disaster. 
-- NORECOVERY leaves the database in a restoring state.
BACKUP LOG [EnterpriseSales_Primary] 
TO DISK = 'd:\Database Engineer\SQL_Server_Master_DR_Suite\Backups\ES_Primary_TAIL_LOG.trn' 
WITH NORECOVERY, INIT;
GO

-- 3. RESTORE THE LAST KNOWN GOOD FULL BACKUP
-- (Replace <Timestamp> with your actual backup filename timestamp)
/*
RESTORE DATABASE [EnterpriseSales_Primary] 
FROM DISK = 'd:\Database Engineer\SQL_Server_Master_DR_Suite\Backups\ES_Primary_FULL_<Timestamp>.bak' 
WITH NORECOVERY, REPLACE;
GO
*/

-- 4. RESTORE INTERMEDIATE LOG BACKUPS
-- (If any log backups occurred after the FULL backup, restore them here WITH NORECOVERY)
/*
RESTORE LOG [EnterpriseSales_Primary] 
FROM DISK = 'd:\Database Engineer\SQL_Server_Master_DR_Suite\Backups\ES_Primary_LOG_<Timestamp>.trn' 
WITH NORECOVERY;
GO
*/

-- 5. THE POINT-IN-TIME (STOPAT) RECOVERY!
-- Restore the Tail-Log With STOPAT (Point-in-Time exactly 1 second before the DELETE statement ran)
-- Replace 'YYYY-MM-DD HH:MM:SS' with the exact safe timestamp BEFORE the disaster struck.
/*
RESTORE LOG [EnterpriseSales_Primary] 
FROM DISK = 'd:\Database Engineer\SQL_Server_Master_DR_Suite\Backups\ES_Primary_TAIL_LOG.trn' 
WITH STOPAT = '2026-03-25 14:04:59', RECOVERY;
GO
*/

-- 6. RE-ALLOW MULTI-USER ACCESS
ALTER DATABASE [EnterpriseSales_Primary] SET MULTI_USER;
GO

-- 7. VERIFY RESCUE SUCCESS
USE [EnterpriseSales_Primary];
GO
SELECT COUNT(*) AS RescuedRows FROM Sales.Transactions;
-- You are a hero! You saved the enterprise data.

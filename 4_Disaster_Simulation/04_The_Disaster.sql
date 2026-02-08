-- ==============================================================
-- SQL Server Master DR Suite
-- Phase 6A: The Catastrophic Event
-- ==============================================================

USE [EnterpriseSales_Primary];
GO

-- Scenario: A junior developer attempts to clear out test rows but highlights the 
-- wrong text in SSMS, completely omitting the WHERE clause.

-- Execute this section while Python Traffic_Simulator is running:
DELETE FROM Sales.Transactions;

-- Oh no! All production data is GONE.
-- Verify the destruction:
SELECT COUNT(*) AS RemainingRows FROM Sales.Transactions;
-- Result: 0

-- QUICK! Look at the clock to note the exact disaster time (e.g., 14:05:00).
-- Stop the Python Traffic_Simulator script immediately!
-- Then move to script 05_The_PITR_Rescue.sql to save your job!

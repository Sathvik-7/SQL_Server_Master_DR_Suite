-- ==============================================================
-- SQL Server Master DR Suite
-- Phase 2: Database and Schema Creation
-- This script initializes the primary mock environment.
-- ==============================================================

USE master;
GO

-- 1. Create the Primary Database
-- We are setting recovery model to FULL because we need Transaction Logs for Log Shipping and PITR.
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'EnterpriseSales_Primary')
BEGIN
    CREATE DATABASE [EnterpriseSales_Primary];
END
GO

ALTER DATABASE [EnterpriseSales_Primary] SET RECOVERY FULL;
GO

USE [EnterpriseSales_Primary];
GO

-- 2. Create Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sales')
BEGIN
    EXEC('CREATE SCHEMA [Sales]');
END
GO

-- 3. Create the Sales.Transactions table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Transactions' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE Sales.Transactions (
        TransactionID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL,
        Revenue DECIMAL(10,2) NOT NULL,
        TransactionDate DATETIME DEFAULT GETDATE(),
        RegionID INT NOT NULL
    );
END
GO

-- 4. Insert some initial dummy data
INSERT INTO Sales.Transactions (CustomerID, ProductID, Quantity, Revenue, RegionID)
VALUES 
(101, 50, 2, 120.50, 1),
(102, 51, 1, 60.00, 2),
(103, 52, 5, 250.00, 1);
GO

SELECT 'EnterpriseSales_Primary Initialized Successfully in FULL Recovery Mode!' AS StatusMsg;
GO

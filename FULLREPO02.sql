CREATE TABLE dbo.Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    ShipCountry NVARCHAR(50),
    EmployeeID INT,
    OrderDate DATE
);
GO

--Inserting Data

INSERT INTO dbo.Orders (ShipCountry, EmployeeID, OrderDate)
SELECT TOP (1000000)
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 20 = 0 THEN 'USA'
        WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 20 = 1 THEN 'UK'
        ELSE 'Germany'
    END,
    ABS(CHECKSUM(NEWID())) % 50 + 1,   -- EmployeeID
    DATEADD(DAY, -(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 730), GETDATE())
FROM master..spt_values a
CROSS JOIN master..spt_values b;
GO



--wrong Index:
DROP INDEX IF EXISTS IX_Wrong ON dbo.Orders;
GO
CREATE NONCLUSTERED INDEX IX_Wrong
ON dbo.Orders (ShipCountry, EmployeeID);
GO

SET STATISTICS IO,TIME ON;
DBCC DROPCLEANBUFFERS;
GO

--Repititive Query:
SELECT *
FROM dbo.Orders
WHERE ShipCountry = 'USA'
AND EmployeeID = 5;
GO

DROP INDEX IF EXISTS IX_Right ON dbo.Orders;
GO
CREATE NONCLUSTERED INDEX IX_Right
ON dbo.Orders (EmployeeID, ShipCountry);
GO

SET STATISTICS IO,TIME OFF;
GO
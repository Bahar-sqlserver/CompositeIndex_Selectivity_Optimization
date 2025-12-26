# CompositeIndex_Selectivity_Optimization
###**Analyzing the impact of composite index order on query performance using columns with different selectivity levels in SQL Server**
Fullscript:[script]()


**Table Design:**
```sql
CREATE TABLE dbo.Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    ShipCountry NVARCHAR(50),
    EmployeeID INT,
    OrderDate DATE
);
GO

--Inserting Data

DECLARE @i INT = 1;

WHILE @i <= 1000000
BEGIN
    INSERT INTO dbo.Orders
    VALUES (
        CASE 
            WHEN @i % 20 = 0 THEN 'USA'
            WHEN @i % 20 = 1 THEN 'UK'
            ELSE 'Germany'
        END,
        ABS(CHECKSUM(NEWID())) % 50 + 1,   -- EmployeeID
        DATEADD(DAY, -(@i % 730), GETDATE())
    );
    SET @i += 1;
END
GO
```
1,000,000 records to simulate real-world conditions
ShipCountry → Low selectivity ('USA', 'UK', 'Germany')
EmployeeID → High selectivity (50 unique values)

--Repititive Query:

SELECT *
FROM dbo.Orders
WHERE ShipCountry = 'USA'
AND EmployeeID = 5;
GO

--wrong Index:
DROP INDEX IF EXISTS IX_Wrong ON dbo.Orders;
GO
CREATE NONCLUSTERED INDEX IX_Wrong
ON dbo.Orders (ShipCountry, EmployeeID);
GO

Key Takeaways
Column order in composite indexes > order of WHERE predicates
High-selectivity columns first = better filtering & lower I/O
Composite indexes can cover queries entirely → avoid lookups
Execution plans reveal the dramatic impact of proper indexing
Always analyze cardinality & selectivity before designing indexes



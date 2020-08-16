--*************************************************************************--
-- Title: Assignment05
-- Author: AMGibbs
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2020-08-09,AMG,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_AMGibbs')
 Begin 
  Alter Database [Assignment05DB_AMGibbs] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_AMGibbs;
 End
go

Create Database Assignment05DB_AMGibbs;
go

Use Assignment05DB_AMGibbs;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go


Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?

-- 1) I want a list of Category and Product names so here are my columns
-- CategoryName  ProductName UnitPrice

-- 2) List the tables that have those columns
-- Categories Products

-- 3) List how those these columns are connected
-- Categories.CategoryID  Products.CategoryID

-- 4) Use these ingredients to create your SQL Join!

Select CategoryName, ProductName, UnitPrice
 From Categories Inner Join Products 
   On Categories.CategoryID = Products.CategoryID;

-- Order the result by the Category and Product!

Select CategoryName, ProductName, UnitPrice
 From Categories Inner Join Products 
   On Categories.CategoryID = Products.CategoryID
Order By CategoryName, ProductName;

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?

-- 1) I want a list of Product name and Inventory Counts on each Inventory Date so here are my columns
-- ProductName InventoryDate Count 

-- 2) List the tables that have those columns
-- Products Inventories

-- 3) List how those these columns are connected
-- Products.ProductID Inventories.ProductID 

-- 4) Use these ingredients to create your SQL Join!

Select ProductName, InventoryDate, [Count] 
 From Inventories Inner Join Products 
   On Products.ProductID = Inventories.ProductID;


-- Order the results by the Product, Date, and Count!

Select ProductName, InventoryDate, [Count] 
 From Inventories Inner Join Products 
   On Products.ProductID = Inventories.ProductID
ORDER BY InventoryDate, ProductName,  [Count];

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- 1) I want a list of Inventory Dates and the Employee that took the count so here are my columns
-- InverntoryDate EmployeeName 

-- 2) List the tables that have those columns
-- Inventories Employees

-- 3) List how those these columns are connected
-- Inventories.EmployeeID Employees.EmployeeID

-- 4) Use these ingredients to create your SQL Join!
Select Distinct InventoryDate, [EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName)
 From Inventories Inner Join Employees 
   On Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- 1) I want a list of CategoryName, Product Name, InventortyDate, and Count so here are my columns
--  CategoryName, ProductName, InventortyDate, and Count

-- 2) List the tables that have those columns
-- Inventories Products Catergories

-- 3) List how those these columns are connected
-- Inventories.ProductID, Products.ProductID
-- Products.CaterforyID, Catergories.CategoryID

-- 4) Use these ingredients to create your SQL Join!

Select CategoryName, ProductName, InventoryDate, [Count] 
 From Inventories 
  Inner Join Products 
   On Products.ProductID = Inventories.ProductID
  Inner Join Categories
   On Products.CategoryID = Categories.CategoryID
Order By CategoryName,ProductName,InventoryDate,[Count]


-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- 1) I want a list of CategoryName, Product Name, InventortyDate, Count, Employee so here are my columns
--  CategoryName, ProductName, InventortyDate, Count, EmplyoeeName

-- 2) List the tables that have those columns
-- Inventories Products Catergories Employees

-- 3) List how those these columns are connected
-- Inventories.ProductID, Products.ProductID
-- Products.CaterforyID, Catergories.CategoryID
-- Inventories.EmployeeID Employees.EmployeeID

-- 4) Use these ingredients to create your SQL Join!

Select CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName)
 From Inventories 
  Inner Join Products 
   On Products.ProductID = Inventories.ProductID
  Inner Join Categories
   On Products.CategoryID = Categories.CategoryID
  Inner Join Employees
   On Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate,CategoryName,ProductName,EmployeeName

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

-- 1) I want a list of CategoryName, Product Name, InventortyDate, Count, Employee so here are my columns
--  CategoryName, ProductName, InventortyDate, Count, EmplyoeeName

-- 2) List the tables that have those columns
-- Inventories Products Catergories Employees

-- 3) List how those these columns are connected
-- Inventories.ProductID, Products.ProductID
-- Products.CaterforyID, Catergories.CategoryID
-- Inventories.EmployeeID Employees.EmployeeID

-- 4) Use these ingredients to create your SQL Join!

Select CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName)
 From Inventories 
  Inner Join Products 
   On Products.ProductID = Inventories.ProductID
  Inner Join Categories
   On Products.CategoryID = Categories.CategoryID
  Inner Join Employees
   On Inventories.EmployeeID = Employees.EmployeeID
Where Products.ProductID IN (Select ProductID From Products Where ProductName = 'Chai' OR ProductName = 'Chang')
Order By InventoryDate,CategoryName,ProductName

-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- 1) I want a list of list of Employees and the Manager who manages themso here are my columns
--  Manager Emplyoee

-- 2) List the tables that have those columns
-- Employees

-- 3) List how those these columns are connected
--  Employees.EmployeeID Employees.ManagerID

-- 4) Use these ingredients to create your SQL Join!

Select [Manager] = (Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName), [Employee] = (Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName)
 From Employees as Mgr Inner Join Employees Emp
   On  Mgr.EmployeeID = Emp.ManagerID 
Order By Manager


/***************************************************************************************/
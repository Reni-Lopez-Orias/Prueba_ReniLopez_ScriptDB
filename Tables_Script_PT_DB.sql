CREATE DATABASE PT_DB;
GO

USE PT_DB;
GO

IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Users'
)
BEGIN
    CREATE TABLE Users (
        IdUser INT PRIMARY KEY IDENTITY(1,1),
        Email VARCHAR(50) NOT NULL,
        Hash VARCHAR(250) NOT NULL,
        Name VARCHAR(50) NOT NULL,
        LastName VARCHAR(50) NOT NULL
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Products'
)
BEGIN
    CREATE TABLE Products (
        IdProduct INT PRIMARY KEY IDENTITY(1,1),
		Tax BIT DEFAULT 0,
        Name VARCHAR(100) NOT NULL,
        Details VARCHAR(250),
        Code VARCHAR(250) NOT NULL,
        Price DECIMAL(18, 2) NOT NULL,
		ACTIVE BIT DEFAULT 1,
        TotalPrice DECIMAL(18, 2) NOT NULL,
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Invoices'
)
BEGIN
    CREATE TABLE Invoices (
        IdInvoice INT PRIMARY KEY IDENTITY(1,1),
        IdUser INT NOT NULL,
        ClientName VARCHAR(250) NOT NULL,
        RegisterDate VARCHAR(250) NOT NULL,
        TotalTax DECIMAL(18, 2),
        SubTotal DECIMAL(18, 2),
        Total DECIMAL(18, 2),
        FOREIGN KEY (IdUser) REFERENCES Users(IdUser)
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Details_Invoices'
)
BEGIN
    CREATE TABLE Details_Invoices (
        IdDetailsInvoices INT PRIMARY KEY IDENTITY(1,1),
        IdInvoice INT NOT NULL,
        IdProduct INT NOT NULL,
        Amount INT NOT NULL,
		TotalTax DECIMAL(18, 2) NOT NULL,
        SubTotal DECIMAL(18, 2) NOT NULL,
        Total DECIMAL(18, 2) NOT NULL,
        FOREIGN KEY (IdInvoice) REFERENCES Invoices(IdInvoice),
        FOREIGN KEY (IdProduct) REFERENCES Products(IdProduct)
    );
END
GO
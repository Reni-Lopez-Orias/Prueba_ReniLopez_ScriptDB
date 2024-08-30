USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ValidateLoginUser]
    @prmEmail VARCHAR(50),
    @prmHash VARCHAR(50),
    @prmIsValid BIT OUTPUT 
AS
	BEGIN

		SET @prmIsValid = 0;
        
		IF EXISTS (SELECT 1 FROM [Users] WHERE Email = @prmEmail AND Hash = @prmHash)
		BEGIN
			SET @prmIsValid = 1;
		END

	END;
GO


USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RegisterUser]
    @prmEmail VARCHAR(50),
    @prmHash VARCHAR(250),
    @prmName VARCHAR(50),
    @prmLastName VARCHAR(50),
    @prmMessageResponse VARCHAR(255) OUTPUT,
	@prmIsValid BIT OUTPUT 
AS
    BEGIN

		set @prmIsValid = 0;

        IF EXISTS (SELECT 1 FROM [Users] WHERE Email = @prmEmail)
            BEGIN
                SET @prmMessageResponse = 'El email ya se encuentra registrado!';
            END
        ELSE
            BEGIN
                INSERT INTO [Users] (Email, Hash, Name, LastName) 
                VALUES (@prmEmail, @prmHash, @prmName, @prmLastName)
				set @prmIsValid = 1;
                SET @prmMessageResponse = 'Usuario agregado!';
            END

    END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUserByEmail]
    @prmEmail VARCHAR(50)
AS
    BEGIN
        SELECT * FROM [Users] WHERE Email = @prmEmail;
    END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[CreateProduct]
    @prmTax BIT,
    @prmName VARCHAR(100),
    @prmDetails VARCHAR(250),
    @prmCode VARCHAR(250),
    @prmPrice DECIMAL(18, 2),
    @prmMessageResponse VARCHAR(255) OUTPUT,
    @prmIsValid BIT OUTPUT
AS
	BEGIN

		SET @prmIsValid = 0;

		IF NOT EXISTS (SELECT 1 FROM [Products] WHERE Code = @prmCode)
		BEGIN
			DECLARE @TotalPrice DECIMAL(18, 2);

			IF @prmTax = 1
			BEGIN
				SET @TotalPrice = @prmPrice * 1.13;
			END
			ELSE
			BEGIN
				SET @TotalPrice = @prmPrice;
			END

			INSERT INTO [Products] (Tax, Name, Details, Code, Price, TotalPrice) 
			VALUES (@prmTax, @prmName, @prmDetails, @prmCode, @prmPrice, @TotalPrice);

			SET @prmMessageResponse = 'Producto agregado!';
			SET @prmIsValid = 1;
		END
		ELSE
		BEGIN
			SET @prmMessageResponse = 'El producto ya existe!';
		END

	END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EditProduct]
    @prmIdProduct INT,
    @prmTax INT,
    @prmName VARCHAR(100),
    @prmDetails VARCHAR(250),
    @prmCode VARCHAR(250),
    @prmPrice DECIMAL(18, 2),
    @prmMessageResponse VARCHAR(255) OUTPUT,
    @prmIsValid BIT OUTPUT
AS
	BEGIN

		SET @prmIsValid = 0;

		IF EXISTS (SELECT 1 FROM [Products] WHERE IdProduct = @prmIdProduct)
		BEGIN

			DECLARE @TotalPrice DECIMAL(18, 2);

			IF @prmTax = 1
			BEGIN
				DECLARE @TaxRate DECIMAL(5, 2) = 13.00;
				SET @TotalPrice = @prmPrice + (@prmPrice * @TaxRate / 100);
			END
			ELSE
			BEGIN
				SET @TotalPrice = @prmPrice;
			END

			UPDATE [Products] 
			SET Tax = @prmTax, 
				Name = @prmName, 
				Details = @prmDetails, 
				Code = @prmCode, 
				Price = @prmPrice, 
				TotalPrice = @TotalPrice
			WHERE IdProduct = @prmIdProduct;

			SET @prmIsValid = 1;
			SET @prmMessageResponse = 'Producto actualizado!';
		END
		ELSE
		BEGIN
			SET @prmMessageResponse = 'El producto no existe!';
		END
END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProductByCode]
    @prmCode VARCHAR(250)
AS
    BEGIN
        SELECT * FROM [Products] WHERE Code = @prmCode;
    END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProducts]
AS
    BEGIN
        SELECT * FROM [Products] WHERE ACTIVE = 1
    END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteProduct]
    @prmCode VARCHAR(255),
    @prmMessageResponse VARCHAR(255) OUTPUT,
	@prmIsValid BIT OUTPUT
AS
	BEGIN
			SET  @prmIsValid = 0;

			IF EXISTS (SELECT 1 FROM [Products] WHERE Code = @prmCode)
			BEGIN
				UPDATE [Products]
				SET ACTIVE = 0
				WHERE Code = @prmCode;
				--DELETE FROM [Products] WHERE Code = @prmCode
				set @prmIsValid = 1;
				SET @prmMessageResponse = 'Producto eliminado!';
			END
			ELSE
				BEGIN
					SET @prmMessageResponse = 'El producto no existe!';
				END

	END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateInvoice]
    @prmIdUser INT,
    @prmClientName VARCHAR(255),
    @prmRegisterDate VARCHAR(255),
    @prmIdInvoice INT OUTPUT
AS
	BEGIN

		SET @prmIdInvoice = 0;

		INSERT INTO Invoices (IdUser, ClientName, RegisterDate)
		VALUES (@prmIdUser, @prmClientName, @prmRegisterDate);

		SET @prmIdInvoice = SCOPE_IDENTITY();

	END;
GO


USE PT_DB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[CreateDetailsInvoice]
    @prmIdInvoice INT,
    @prmIdProduct INT,
    @prmAmount DECIMAL(18, 2),
    @prmTotalTax DECIMAL(18, 2),
    @prmSubTotal DECIMAL(18, 2),
    @prmTotal DECIMAL(18, 2),
    @prmIsValid BIT OUTPUT
AS
	BEGIN

		SET @prmIsValid = 0;

		BEGIN TRY
        
			BEGIN TRANSACTION;

			INSERT INTO Details_Invoices (IdInvoice, IdProduct, Amount, TotalTax, SubTotal, Total) 
			VALUES (@prmIdInvoice, @prmIdProduct, @prmAmount, @prmTotalTax, @prmSubTotal, @prmTotal);

			DECLARE @existingTotalTax DECIMAL(18, 2);
			DECLARE @existingSubTotal DECIMAL(18, 2);
			DECLARE @existingTotal DECIMAL(18, 2);

			SELECT 
				@existingTotalTax = ISNULL(TotalTax, 0),
				@existingSubTotal = ISNULL(SubTotal, 0),
				@existingTotal = ISNULL(Total, 0)
			FROM Invoices
			WHERE IdInvoice = @prmIdInvoice;

			-- Actualiza los valores en la tabla Invoices
			UPDATE Invoices
			SET 
				TotalTax = @existingTotalTax + @prmTotalTax,
				SubTotal = @existingSubTotal + @prmSubTotal,
				Total = @existingTotal + @prmTotal + @prmTotalTax
			WHERE IdInvoice = @prmIdInvoice;

			COMMIT TRANSACTION;

			SET @prmIsValid = 1;

		END TRY
		BEGIN CATCH
			DELETE FROM Invoices WHERE IdInvoice = @prmIdInvoice;
			ROLLBACK TRANSACTION;
		END CATCH;
	END;
GO

USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetInvoices]
AS
    BEGIN
        SELECT * FROM Invoices;
    END;
GO


USE PT_DB;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProductInvoice]
    @prmIdInvoice INT
AS
BEGIN
    SELECT 
        details.IdProduct AS idProduct,
        details.TotalTax AS tax,
        p.Name AS name,
        p.Code AS code,
        details.SubTotal AS price,
        details.Total AS totalPrice,
        details.SubTotal AS subTotal,
        details.Amount AS amount,
        details.Total AS totalInvoice,
		details.TotalTax AS totalTax
    FROM 
        Details_Invoices details
    INNER JOIN 
        Products p ON details.IdProduct = p.IdProduct
    WHERE 
        details.IdInvoice = @prmIdInvoice
    ORDER BY 
        details.IdProduct ASC;
END;
GO

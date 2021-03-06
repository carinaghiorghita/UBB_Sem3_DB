SELECT * FROM Tests
SELECT * FROM Tables
SELECT * FROM TestTables
SELECT * FROM Views 
SELECT * FROM TestViews 
SELECT * FROM TestRuns
SELECT * FROM TestRunTables 
SELECT * FROM TestRunViews
GO

CREATE OR ALTER VIEW ViewOneTable
AS
	SELECT * FROM Waiter
GO

CREATE OR ALTER VIEW ViewTwoTables
AS
	SELECT O.orderID,D.itemID,D.quantity,M.name
	FROM Order_DineIn O
	INNER JOIN Order_Details D
	ON D.orderID=O.orderID
	INNER JOIN MenuItem M
	ON D.itemID=M.itemID

GO

CREATE OR ALTER VIEW ViewGroupBy
AS
	SELECT COUNT(O.orderID) as NoOfOrders,O.waiterID
	FROM Order_DineIn O
	GROUP BY O.waiterID
	HAVING O.waiterID IN (SELECT W.waiterID FROM Waiter W)

GO

CREATE OR ALTER PROCEDURE delete_table
	@no_of_rows INT,
	@table_name VARCHAR(30)
AS
BEGIN
	DECLARE @last_row INT

	IF @table_name='Waiter'
	BEGIN
	IF (SELECT COUNT(*) FROM Waiter)<@no_of_rows
	BEGIN
		PRINT ('Too many rows to delete')
		RETURN 1
	END
	ELSE
	BEGIN
		SET @last_row = (SELECT MAX(waiterID) FROM Waiter) - @no_of_rows

		DELETE FROM Waiter
		WHERE waiterID>@last_row
	END
	END

	ELSE IF @table_name='MenuItem'
	BEGIN
	IF (SELECT COUNT(*) FROM MenuItem)<@no_of_rows
	BEGIN
		PRINT ('Too many rows to delete')
		RETURN 1
	END
	ELSE
	BEGIN
		SET @last_row = (SELECT MAX(itemID) FROM MenuItem) - @no_of_rows

		DELETE FROM MenuItem
		WHERE itemID>@last_row
	END
	END

	ELSE IF @table_name='Order_DineIn'
	BEGIN
	IF (SELECT COUNT(*) FROM Order_DineIn)<@no_of_rows
	BEGIN
		PRINT ('Too many rows to delete')
		RETURN 1
	END
	ELSE
	BEGIN
		SET @last_row = (SELECT MAX(orderID) FROM Order_DineIn) - @no_of_rows

		DELETE FROM Order_DineIn
		WHERE orderID>@last_row
	END
	END

	ELSE IF @table_name='Order_Details'
	BEGIN	
	IF (SELECT COUNT(*) FROM Order_Details)<@no_of_rows
	BEGIN
		PRINT ('Too many rows to delete')
		RETURN 1
	END

	ELSE
	BEGIN
		DELETE FROM Order_Details
		WHERE orderID>=@no_of_rows
	
	END
	END

	ELSE
	BEGIN
		PRINT('Not a valid table name')
		RETURN 1
	END
END
GO

CREATE OR ALTER PROCEDURE insert_table
	@no_of_rows INT,
	@table_name VARCHAR(30)
AS
BEGIN
	DECLARE @input_id INT
	IF @table_name='Waiter'
	BEGIN
		SET @input_id = @no_of_rows
		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO Waiter(waiterID,name) VALUES(@input_id,'John Doe')

			SET @input_id=@input_id+1
			SET @no_of_rows=@no_of_rows-1
		END
	END

	ELSE IF @table_name='MenuItem'
	BEGIN
		SET @input_id = @no_of_rows
		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO MenuItem(itemID,name,price,quantity) VALUES(@input_id,'New Item',0.0,0.0)

			SET @input_id=@input_id+1
			SET @no_of_rows=@no_of_rows-1
		END
	END

	ELSE IF @table_name='Order_DineIn'
	BEGIN
	SET @input_id = @no_of_rows

	DECLARE @fk1 INT
	SET @fk1=(SELECT TOP 1 customerID FROM Customer)

	DECLARE @fk2 INT
	SET @fk2=(SELECT TOP 1 waiterID FROM Waiter)

	DECLARE @fk3 INT
	SET @fk3=(SELECT TOP 1 chefID FROM Chef)

		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price) VALUES(@input_id,@fk1,@fk2,@fk3,1,0.0)

			SET @input_id=@input_id+1
			SET @no_of_rows=@no_of_rows-1
		END
	END

	ELSE IF @table_name='Order_Details'
	BEGIN
	SET @input_id = @no_of_rows
	PRINT(@input_id)
	DECLARE @fk INT
	SET @fk=(SELECT TOP 1 itemID FROM MenuItem)
		WHILE @no_of_rows > 0
		BEGIN
			INSERT INTO Order_Details(orderID,itemID,quantity) VALUES(@input_id,@fk,0.0)

			SET @input_id = @input_id+1
			SET @no_of_rows=@no_of_rows-1
			
			PRINT(@input_id)

		END
	END

	ELSE
	BEGIN
		PRINT('Not a valid table name')
		RETURN 1
	END
END
GO

CREATE OR ALTER PROCEDURE select_view
	@view_name VARCHAR(30)
AS
BEGIN
	IF @view_name='ViewOneTable'
	BEGIN 
		SELECT * FROM ViewOneTable
	END

	ELSE IF @view_name='ViewTwoTables'
	BEGIN 
		SELECT * FROM ViewTwoTables
	END

	ELSE IF @view_name='ViewGroupBy'
	BEGIN 
		SELECT * FROM ViewGroupBy
	END

	ELSE
	BEGIN 
		PRINT('Not a valid view name')
		RETURN 1
	END
END
GO

DELETE FROM Tables
INSERT INTO Tables VALUES ('Waiter'),('MenuItem'),('Order_DineIn'),('Order_Details')
GO

DELETE FROM Views
INSERT INTO Views VALUES ('ViewOneTable'),('ViewTwoTables'),('ViewGroupBy')
GO

DELETE FROM Tests
INSERT INTO Tests VALUES ('test_10'),('test_100'),('test_1000'),('test_5000')
GO

DELETE FROM TestViews
INSERT INTO TestViews(TestID,ViewID) VALUES (1,1)
INSERT INTO TestViews(TestID,ViewID) VALUES (1,2)
INSERT INTO TestViews(TestID,ViewID) VALUES (1,3)
INSERT INTO TestViews(TestID,ViewID) VALUES (2,1)
INSERT INTO TestViews(TestID,ViewID) VALUES (2,2)
INSERT INTO TestViews(TestID,ViewID) VALUES (2,3)
INSERT INTO TestViews(TestID,ViewID) VALUES (3,1)
INSERT INTO TestViews(TestID,ViewID) VALUES (3,2)
INSERT INTO TestViews(TestID,ViewID) VALUES (3,3)
INSERT INTO TestViews(TestID,ViewID) VALUES (4,1)
INSERT INTO TestViews(TestID,ViewID) VALUES (4,2)
INSERT INTO TestViews(TestID,ViewID) VALUES (4,3)
GO

DELETE FROM TestTables
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (1,1,10,1)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (1,2,10,2)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (1,3,10,3)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (1,4,10,4)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (2,1,100,1)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (2,2,100,2)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (2,3,100,3)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (2,4,100,4)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (3,1,1000,1)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (3,2,1000,2)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (3,3,1000,3)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (3,4,1000,4)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (4,1,5000,1)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (4,2,5000,2)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (4,3,5000,3)
INSERT INTO TestTables(TestId, TableID, NoOfRows, Position) VALUES (4,4,5000,4)

GO

DELETE FROM TestRuns
DELETE FROM TestRunTables
DELETE FROM TestRunViews
GO
/*
CREATE OR ALTER PROCEDURE mainTest 
	@testID INT
AS
BEGIN
	DECLARE @tableID INT
	DECLARE @noOfRows INT
	DECLARE @newID INT
	SET @newID=1

	DECLARE @insertProc VARCHAR(30)
	SET @insertProc=(SELECT Name FROM Tests WHERE TestID=1)

	DECLARE testInsertCursor CURSOR FOR
	SELECT TableID,NoOfRows
	FROM TestTables
	WHERE TestID=1
	ORDER BY Position

	OPEN testInsertCursor

	FETCH NEXT
	FROM testInsertCursor
	INTO @tableID,@noOfRows

	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE @startAt DATETIME
		DECLARE @endAt DATETIME
		DECLARE @tableName VARCHAR(30)
		SET @tableName=(SELECT Name FROM Tables WHERE TableID=@tableID)

		SET @startAt=GETDATE()
		EXEC @insertProc @tableName,@noOfRows
		SET @endAt=GETDATE()

		DECLARE @description VARCHAR(500)
		SET @description='Test no.'+CONVERT(VARCHAR(3),@newID)+' on table '+@tableName+', insert/view/delete on '+CONVERT(VARCHAR(5),@noOfRows)+' rows'

		INSERT INTO TestRunTables VALUES (@newID,@tableID,@startAt,@endAt)
		INSERT INTO TestRuns VALUES (@description

		SET @newID=@newID+1

		FETCH NEXT
		FROM testInsertCursor
		INTO @tableID,@noOfRows
	END
END 
GO
*/

CREATE OR ALTER PROCEDURE mainTest
	@testID INT
AS
BEGIN
	INSERT INTO TestRuns VALUES ((SELECT Name FROM Tests WHERE TestID=@testID),GETDATE(),GETDATE())
	DECLARE @testRunID INT
	SET @testRunID=(SELECT MAX(TestRunID) FROM TestRuns)

	DECLARE @noOfRows INT
	DECLARE @tableID INT
	DECLARE @tableName VARCHAR(30)
	DECLARE @startAt DATETIME
	DECLARE @endAt DATETIME
	DECLARE @viewID INT
	DECLARE @viewName VARCHAR(30)

	DECLARE testDeleteCursor CURSOR FOR
	SELECT TableID,NoOfRows
	FROM TestTables
	WHERE TestID=@testID
	ORDER BY Position DESC

	OPEN testDeleteCursor

	FETCH NEXT 
	FROM testDeleteCursor
	INTO @tableID,@noOfRows

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @tableName=(SELECT Name FROM Tables WHERE TableID=@tableID)

		EXEC delete_table @noOfRows,@tableName

		FETCH NEXT 
		FROM testDeleteCursor
		INTO @tableID,@noOfRows
	END

	CLOSE testDeleteCursor
	DEALLOCATE testDeleteCursor

	DECLARE testInsertCursor CURSOR FOR
	SELECT TableID,NoOfRows
	FROM TestTables
	WHERE TestID=@testID
	ORDER BY Position ASC

	OPEN testInsertCursor

	FETCH NEXT 
	FROM testInsertCursor
	INTO @tableID,@noOfRows

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @tableName=(SELECT Name FROM Tables WHERE TableID=@tableID)

		SET @startAt=GETDATE()
		EXEC insert_table @noOfRows,@tableName
		SET @endAt=GETDATE()

		INSERT INTO TestRunTables VALUES (@testRunID,@tableID,@startAt,@endAt)

		FETCH NEXT 
		FROM testInsertCursor
		INTO @tableID,@noOfRows
	END

	CLOSE testInsertCursor
	DEALLOCATE testInsertCursor

	DECLARE testViewCursor CURSOR FOR
	SELECT ViewID
	FROM TestViews
	WHERE TestID=@testID

	OPEN testViewCursor

	FETCH NEXT 
	FROM testViewCursor
	INTO @viewID

	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @viewName=(SELECT Name FROM Views WHERE ViewID=@viewID)

		SET @startAt=GETDATE()
		EXEC select_view @viewName
		SET @endAt=GETDATE()

		INSERT INTO TestRunViews VALUES (@testRunID,@viewID,@startAt,@endAt)

		FETCH NEXT 
		FROM testViewCursor
		INTO @viewID
	END

	CLOSE testViewCursor
	DEALLOCATE testViewCursor

	UPDATE TestRuns
	SET EndAt=GETDATE()
	WHERE TestRunID=@testRunID

END
GO

EXEC mainTest 1
EXEC mainTest 2
EXEC mainTest 3
EXEC mainTest 4

/*
EXEC insert_table 10,Waiter
EXEC insert_table 10,MenuItem
EXEC insert_table 10,Order_DineIn
EXEC insert_table 10,Order_Details

select count(*) from Waiter

select count(*) from MenuItem
select count(*) from Order_DineIn
select count(*) from Order_Details

EXEC delete_table 5000,Order_Details
EXEC delete_table 5000,Order_DineIn
EXEC delete_table 5000,MenuItem
EXEC delete_table 5000,Waiter
*/
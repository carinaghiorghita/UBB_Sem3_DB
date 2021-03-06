
--Database Version Table implementation

--table1: procedure_name versionFrom versionTo

CREATE TABLE Previous_Versions
(
	storedProcedure VARCHAR(50),
	versionFrom INT,
	versionTo INT,
	PRIMARY KEY(versionFrom,versionTo)
)
GO

INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('changeCustomerRatingType',0,1)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('removeColumnPhoneNumberDeliveryPeople',1,2)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('addDefaultConstraintWaiterRating',2,3)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('dropPrimaryKeyQuickTestID',3,4)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('addCandidateKeyReservationIDTable',4,5)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('removeForeignKeyOrderDeliveryChefID',5,6)
INSERT INTO Previous_Versions(storedProcedure,versionFrom,versionTo) VALUES ('createTestTable',6,7)


--table2: keeps only the current version

CREATE TABLE Current_Version
(
	currentVersion INT DEFAULT 0
)
GO

--procedure that modifies version

CREATE OR ALTER PROCEDURE modifyVersion (@version INT)
AS
BEGIN

	DECLARE @current INT;
	SET @current=(SELECT currentVersion FROM Current_Version)

	
		BEGIN
	
		IF @version<0 OR @version>7
		BEGIN
			DECLARE @errorMsg VARCHAR(200)
			SET @errorMsg='Version has to be between 0 and 7'
			PRINT @errorMsg
			RETURN 
		END

		ELSE
		IF @version=@current
		BEGIN
			PRINT 'Already on this version!'
			RETURN 
		END	

		ELSE

		IF @version<@current
		BEGIN
			DECLARE @query VARCHAR(200)
			DECLARE @proc VARCHAR(50)
			DECLARE @vTo INT

			DECLARE versionCursor CURSOR SCROLL FOR
			SELECT storedProcedure,versionTo
			FROM Previous_Versions

			OPEN versionCursor
			PRINT 'Cursor opened'

			FETCH LAST
			FROM versionCursor
			INTO @proc,@vTo
			PRINT 'Fetched last'

			WHILE @vTo>@version AND @@FETCH_STATUS=0
			BEGIN
				IF @vTo<=@current
					BEGIN
					SET @query='undo_'+@proc
					EXEC @query
					PRINT 'Undo executed'
				
					UPDATE Current_Version SET currentVersion=@vTo-1
					PRINT 'Updated version'
				END
			
				FETCH PRIOR
				FROM versionCursor
				INTO @proc,@vTo
				PRINT 'Fetched prior'

			END

			IF(@version=0)
			BEGIN
				SET @query='undo_'+(SELECT storedProcedure FROM Previous_Versions WHERE versionFrom=0)
				EXEC @query
			END

			CLOSE versionCursor
			DEALLOCATE versionCursor
			PRINT 'Cursor deallocated'
		END
			
		ELSE
		BEGIN
			DECLARE @query2 VARCHAR(200)
			DECLARE @proc2 VARCHAR(50)
			DECLARE @vTo2 INT
			DECLARE @vFrom2 INT

			DECLARE versionCursor2 CURSOR FOR
			SELECT storedProcedure,versionTo,versionFrom
			FROM Previous_Versions

			OPEN versionCursor2
			PRINT 'Cursor opened'

			FETCH NEXT
			FROM versionCursor2
			INTO @proc2,@vTo2,@vFrom2
			PRINT 'Fetched first'

			WHILE @vFrom2<@version AND @@FETCH_STATUS=0
			BEGIN
				IF @vFrom2>=@current
					BEGIN
					SET @query2=@proc2
					EXEC @query2
					PRINT 'Do executed'
				
					UPDATE Current_Version SET currentVersion=@vFrom2+1
					PRINT 'Updated version'
				END
			
				FETCH NEXT
				FROM versionCursor2
				INTO @proc2,@vTo2,@vFrom2
				PRINT 'Fetched next'

			END

			

			CLOSE versionCursor2
			DEALLOCATE versionCursor2
			PRINT 'Cursor deallocated'
		END
	END
END
GO

EXEC modifyVersion 0
GO

SELECT * FROM Previous_Versions
SELECT * FROM Current_Version
GO

--a. modify the type of a column

CREATE OR ALTER PROCEDURE changeCustomerRatingType
AS 
BEGIN 
	ALTER TABLE Customer
	ALTER COLUMN rating INT
END
GO

EXEC changeCustomerRatingType
GO

--undo
CREATE OR ALTER PROCEDURE undo_changeCustomerRatingType
AS 
BEGIN 
	ALTER TABLE Customer
	ALTER COLUMN rating DECIMAL(6,2)
END
GO

--EXEC undo_changeCustomerRatingType


--b. add / remove a column

CREATE OR ALTER PROCEDURE removeColumnPhoneNumberDeliveryPeople
AS
BEGIN
	ALTER TABLE Delivery_People
	DROP COLUMN phoneNumber


END
GO

EXEC removeColumnPhoneNumberDeliveryPeople
GO

--undo

CREATE OR ALTER PROCEDURE undo_removeColumnPhoneNumberDeliveryPeople
AS
BEGIN
	ALTER TABLE Delivery_People
	ADD phoneNumber CHAR(10)
END
GO

--EXEC undo_removeColumnPhoneNumberDeliveryPeople



--c. add / remove a DEFAULT constraint

CREATE OR ALTER PROCEDURE addDefaultConstraintWaiterRating
AS
BEGIN
	ALTER TABLE Waiter
	ADD CONSTRAINT rating_default
	DEFAULT 1.0 FOR rating
END
GO

EXEC addDefaultConstraintWaiterRating
GO

--insert into Waiter(waiterID,name,salary, phoneNumber) values (6,'Doru Servitoru',1300,0765487324)

--undo

CREATE OR ALTER PROCEDURE undo_addDefaultConstraintWaiterRating
AS
BEGIN
	ALTER TABLE Waiter
	DROP CONSTRAINT rating_default
END
GO

--EXEC undo_addDefaultConstraintWaiterRating


--select * from sys.default_constraints

--d. add / remove a primary key

CREATE OR ALTER PROCEDURE dropPrimaryKeyQuickTestID
AS
BEGIN
	ALTER TABLE QuickTest
	DROP CONSTRAINT PK_QuickTest

END
GO

EXEC dropPrimaryKeyQuickTestID
GO

--undo

CREATE OR ALTER PROCEDURE undo_dropPrimaryKeyQuickTestID
AS
BEGIN
	ALTER TABLE QuickTest
	ADD CONSTRAINT PK_QuickTest PRIMARY KEY (ID)
END
GO

--EXEC undo_dropPrimaryKeyQuickTestID


--e. add / remove a candidate key
CREATE OR ALTER PROCEDURE addCandidateKeyReservationIDTable
AS
BEGIN
	ALTER TABLE Reservations
	ADD CONSTRAINT UQ_ID_Table UNIQUE(reservID,tableID)


END
GO

EXEC addCandidateKeyReservationIDTable
GO

--undo 

CREATE OR ALTER PROCEDURE undo_addCandidateKeyReservationIDTable
AS
BEGIN
	ALTER TABLE Reservations
	DROP CONSTRAINT UQ_ID_Table
END
GO

--EXEC undo_addCandidateKeyReservationIDTable


--f. add / remove a foreign key

CREATE OR ALTER PROCEDURE removeForeignKeyOrderDeliveryChefID
AS
BEGIN
	ALTER TABLE Order_Delivery
	DROP CONSTRAINT FK_ChefID
END
GO

EXEC removeForeignKeyOrderDeliveryChefID
GO 

--undo

CREATE OR ALTER PROCEDURE undo_removeForeignKeyOrderDeliveryChefID
AS
BEGIN
	ALTER TABLE Order_Delivery
	ADD CONSTRAINT FK_ChefID FOREIGN KEY (chefID) REFERENCES Chef(chefID)
END
GO

--EXEC undo_removeForeignKeyOrderDeliveryChefID


--g. create / drop a table

CREATE OR ALTER PROCEDURE createTestTable
AS 
BEGIN 
	CREATE TABLE Test_Table
	(
		testID SMALLINT NOT NULL PRIMARY KEY,
		testMessage VARCHAR(30)
	)
END
GO

EXEC createTestTable
GO

--undo

CREATE OR ALTER PROCEDURE undo_createTestTable
AS
BEGIN
	DROP TABLE IF EXISTS Test_Table
END
GO

--EXEC undo_createTestTable


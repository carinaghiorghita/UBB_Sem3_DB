USE [CrazyTrotineta]
GO

--a
DROP TABLE Ride
DROP TABLE Rider
DROP TABLE Scooter
DROP TABLE ScModel
DROP TABLE ScProvider

--for all tables created, except Ride, with the composite primary key, and Scooter, for which we have the serial number, 
--we will add one more column with an unique ID, which will be the primary key

CREATE TABLE ScProvider
(
	provID INT PRIMARY KEY NOT NULL,
	name VARCHAR(20),
	turnover INT,
	foundDate DATE
)

--the provider will be referenced from the ScProvider table
CREATE TABLE ScModel
(
	modelID INT PRIMARY KEY NOT NULL,
	name VARCHAR(20),
	price INT,
	weight INT,
	speed INT,
	provID INT REFERENCES ScProvider(provID)
)

--serial numbers are supposed to be unique for each product, so we will use it as the primary key for this field
--the model will be referenced from the ScModel table
CREATE TABLE Scooter
(
	serialNr INT PRIMARY KEY NOT NULL,
	modelID INT REFERENCES ScModel(modelID)
)

--we make sure that the year is valid by adding a check constraint
CREATE TABLE Rider
(
	riderID INT PRIMARY KEY NOT NULL,
	fName VARCHAR(20),
	lName VARCHAR(20),
	yob INT CHECK (yob>=1900 AND yob<=2021)
)

--table for the many to many relationship between riders and scooters, as more than one rider can ride a single scooter across multiple rides, 
--and one rider can ride more than one scooter across multiple rides 
--thus, we will have a composite primary key as created below
CREATE TABLE Ride
(
	scooterID INT REFERENCES Scooter(serialNr),
	riderID INT REFERENCES Rider(riderID),
	startT DATETIME,
	endT DATETIME,
	nrIncidents INT,
	PRIMARY KEY(scooterID,riderID)
)

SELECT * FROM ScProvider
SELECT * FROM ScModel
SELECT * FROM Scooter
SELECT * FROM Rider
SELECT * FROM Ride

--INSERT INTO Rider VALUES (1,'fName1','lName1',3000) fails on the check constraint for yob
INSERT INTO ScProvider VALUES (1,'prov1',5000,'2019-10-20'),(2,'prov2',6000,'2019-10-21'),(3,'prov3',7000,'2019-10-22')
INSERT INTO ScModel VALUES (1,'model1',50,10,80,1),(2,'model2',40,10,75,1),(3,'model3',50,10,80,2),(4,'model4',50,10,80,3)
INSERT INTO Scooter VALUES (1,1),(2,2),(3,2),(4,3)
INSERT INTO Rider VALUES (1,'fName1','lName1',2000),(2,'fName2','lName2',1980),(3,'fName3','lName3',1997)
INSERT INTO Ride VALUES (1,1,'2020-10-09 20:00:00','2020-10-09 20:10:00',0),(2,1,'2020-10-10 20:00:00','2020-10-10 20:10:00',3),(1,2,'2020-10-11 20:00:00','2020-10-11 20:10:00',1)
INSERT INTO Ride VALUES (3,3,'2020-10-09 20:00:00','2020-10-09 20:10:00',0)
INSERT INTO Ride VALUES (4,2,'2020-10-09 20:00:00','2020-10-09 20:10:00',0)
INSERT INTO Ride VALUES (3,2,'2020-10-09 20:00:00','2020-10-09 20:10:00',0)

GO

--b
CREATE OR ALTER PROCEDURE uspDeleteRider (@S1 VARCHAR(20),@S2 VARCHAR(20))
AS
BEGIN
	--before deleting, check if the rider exists in the database
	IF NOT EXISTS (SELECT * FROM Rider WHERE fName=@S1 AND lName=@S2)
	BEGIN
		RAISERROR('Nothing to delete (rider does not exist in database)',16,1)
		RETURN
	END

	--we get the id of the rider based on the first name and last name given
	DECLARE @rid INT
	SET @rid=(SELECT riderID FROM Rider WHERE fName=@S1 AND lName=@S2)

	--first we delete the rides of this rider, as this table contains a foreign key referencing the table Rider
	DELETE FROM Ride
	WHERE riderID=@rid

	--after we delete from the table Ride (which contains the foreign keys referencing this table), we delete the rider
	DELETE FROM Rider
	WHERE riderID=@rid
END
GO

--first three execs will give as an error, as no rider with those first and last names exist
--the fourth one will delete the third rider's rides, then the rider
EXEC uspDeleteRider @S1='fName10',@S2='lName1'
EXEC uspDeleteRider @S1='fName1',@S2='lName10'
EXEC uspDeleteRider @S1='fName1',@S2='lName2'
EXEC uspDeleteRider @S1='fName3',@S2='lName3'
GO

--c

CREATE OR ALTER VIEW vProviderLargestNrRides
AS
	--we will also select the number of rides, even if not specified in the problem statement, so we can truly see that the provider has the max number of rides
	SELECT P.name,P.turnover,COUNT(*) nrRides
	--we inner join these tables on the foreign keys that reference each other, in order to have one table that contains both the providers and the rides
	FROM ScProvider P
	INNER JOIN ScModel M ON P.provID=M.provID
	INNER JOIN Scooter S ON M.modelID=S.modelID
	INNER JOIN Ride R ON S.serialNr=R.scooterID
	--we group by the provider, as well as the fields we are selecting
	GROUP BY P.provID,P.name,P.turnover
	--we check whether each provider has the maximum number of rides
	HAVING COUNT(*)=
	--we select the maximum number of rides for a provider from the inner joins 
	(SELECT MAX(countProvs) 
	FROM 
	(SELECT COUNT(*) countProvs 
	FROM ScProvider P
	INNER JOIN ScModel M ON P.provID=M.provID
	INNER JOIN Scooter S ON M.modelID=S.modelID
	INNER JOIN Ride R ON S.serialNr=R.scooterID
	GROUP BY P.provID) 
	AS myCount)
GO

SELECT * FROM vProviderLargestNrRides
GO

--d

CREATE OR ALTER FUNCTION ufRidersAtLeastRRides (@R INT)
RETURNS TABLE
RETURN 
	--we'll also show the number of rides here as well, so we see that there are at least @R rides
	SELECT Rdr.fName,Rdr.lName,COUNT(*) nrRides
	--we inner join the two tables, as they are referencing on the riderID field
	FROM Rider Rdr
	INNER JOIN Ride R ON R.riderID=Rdr.riderID
	--we group by each rider
	GROUP BY Rdr.fName,Rdr.lName
	--we check whether the total number of rider is greater than @R
	HAVING COUNT(*)>=@R
GO

SELECT * FROM ufRidersAtLeastRRides(0)
SELECT * FROM ufRidersAtLeastRRides(2)
SELECT * FROM ufRidersAtLeastRRides(3)
SELECT * FROM ufRidersAtLeastRRides(4)

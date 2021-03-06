USE RESTAURANT

DROP TABLE TableC
DROP TABLE TableB
DROP TABLE TableA
GO

CREATE TABLE TableA
(
	aid INT PRIMARY KEY,
	a2 INT UNIQUE,
	name VARCHAR(20)
)
GO

CREATE TABLE TableB
(
	bid INT PRIMARY KEY,
	b2 INT
)
GO

CREATE TABLE TableC
(
	cid INT PRIMARY KEY,
	aid INT FOREIGN KEY REFERENCES TableA(aid),
	bid INT FOREIGN KEY REFERENCES TableB(bid)
)
GO

SELECT * FROM TableA
SELECT * FROM TableB
SELECT * FROM TableC
GO

SELECT name FROM sys.indexes WHERE name LIKE 'TA%' OR name LIKE 'TB%' OR name LIKE 'TC%'

DELETE FROM TableC
DELETE FROM TableB
DELETE FROM TableA

DECLARE @i INT=0
DECLARE @fk1 INT
DECLARE @fk2 INT
WHILE @i<100
BEGIN
	INSERT INTO TableA VALUES (@i,@i*2,CONCAT('test',RAND()*@i))
	INSERT INTO TableB VALUES (@i,RAND()*@i)

	SET @fk1=(SELECT TOP 1 aid FROM TableA ORDER BY NEWID())
	SET @fk2=(SELECT TOP 1 bid FROM TableB ORDER BY NEWID())

	INSERT INTO TableC VALUES (@i,@fk1,@fk2)

	SET @i=@i+1
END
GO

--a.
--clustered index scan
SELECT * FROM TableA ORDER BY aid

--clustered index seek
SELECT * FROM TableA WHERE aid < 7

DROP INDEX TA_name_index ON TableA
CREATE NONCLUSTERED INDEX TA_name_index ON TableA(name) INCLUDE (a2) 

--nonclustered index scan
SELECT name FROM TableA ORDER BY a2

--nonclustered index seek
SELECT name FROM TableA WHERE name LIKE 'test6%'

--key lookup
SELECT name,a2 FROM TableA WHERE a2=22
GO


--b.
SELECT * FROM TableB WHERE b2=0

DROP INDEX TB_b2_index ON TableB
CREATE NONCLUSTERED INDEX TB_b2_index ON TableB(b2) 

--after the creation of the index we go from a clustered index scan to a nonclustered index seek, which is more efficient 

GO


--c.
/*
DROP INDEX TC_bid_index ON TableC
CREATE NONCLUSTERED INDEX TC_bid_index ON TableC(bid)
GO
*/

CREATE OR ALTER VIEW tableView
AS
	SELECT C.cid,C.bid,B.b2
	FROM TableB B
	INNER JOIN TableC C ON C.bid=B.bid
GO

SELECT * FROM tableView
GO


CREATE OR ALTER VIEW allTablesView as 
	SELECT C.cid,A.aid,B.bid FROM TableC C 
	INNER JOIN TableA A on C.aid = A.aid 
	INNER JOIN TableB B on C.bid = B.bid
GO

SELECT * FROM allTablesView
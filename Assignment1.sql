CREATE DATABASE RESTAURANT

CREATE TABLE MenuItem
(
	itemID SMALLINT NOT NULL,
	name VARCHAR(30) NOT NULL,
	price DECIMAL(6,2) NOT NULL,
	quantity DECIMAL(6,2) NOT NULL,
	PRIMARY KEY(itemID)
)

select * from MenuItem
INSERT INTO MenuItem(itemID,name,price,quantity) VALUES (1,'Spaghetti Carbonara',20.5,500)
INSERT INTO MenuItem(itemID,name,price,quantity) VALUES (2,'Pizza Margherita',32.0,400)
INSERT INTO MenuItem(itemID,name,price,quantity) VALUES (3,'Coca-Cola',3.5,330)
INSERT INTO MenuItem(itemID,name,price,quantity) VALUES (4,'Ursus',5.0,500)
INSERT INTO MenuItem(itemID,name,price,quantity) VALUES (5,'Crispy Strips',14.0,600)

CREATE TABLE Chef
(
	chefID SMALLINT NOT NULL,
	name VARCHAR(30) NOT NULL,
	rating DECIMAL(3,2),
	salary DECIMAL(6,2),
	phoneNumber CHAR(10),
	PRIMARY KEY(chefID)
)
select * from Waiter
INSERT INTO Chef(chefID,name,rating,salary,phoneNumber) VALUES (1,'Popescu Ionut',3.5,1500.0,'0745345678')
INSERT INTO Chef(chefID,name,rating,salary,phoneNumber) VALUES (2,'Martino Giuseppe',4.8,2600.75,'0732539815')
INSERT INTO Chef(chefID,name,rating,salary,phoneNumber) VALUES (3,'John Smith',4.2,1850.0,'0745341228')
INSERT INTO Chef(chefID,name) VALUES (4,'Ionescu Costica')
INSERT INTO Chef(chefID,name) VALUES (5,'Georgescu Marian')
INSERT INTO Chef(chefID,name) VALUES (6,'Scarlatescu Monica')

CREATE TABLE Waiter
(
	waiterID SMALLINT NOT NULL,
	name VARCHAR(30) NOT NULL,
	rating DECIMAL(3,2),
	salary DECIMAL(6,2),
	phoneNumber CHAR(10),
	PRIMARY KEY(waiterID)
)

INSERT INTO Waiter(waiterID,name,rating,salary,phoneNumber) VALUES (1,'Gheorghiu Mihai',4.5,1200.0,'0749376287')
INSERT INTO Waiter(waiterID,name,rating,salary,phoneNumber) VALUES (2,'Bradescu Cosmina',4.8,1350.0,'0765234287')
INSERT INTO Waiter(waiterID,name,rating,salary,phoneNumber) VALUES (3,'Chelaru Dorina',3.2,1075.5,'0749372987')
INSERT INTO Waiter(waiterID,name) VALUES (4,'Badescu Nelu')
INSERT INTO Waiter(waiterID,name) VALUES (5,'Nemtescu Marian')

CREATE TABLE Delivery_People
(
	deliverID SMALLINT NOT NULL,
	name VARCHAR(30) NOT NULL,
	rating DECIMAL(3,2),
	salary DECIMAL(6,2),
	phoneNumber CHAR(10),
	PRIMARY KEY(deliverID)
)

INSERT INTO Delivery_People(deliverID,name,rating,salary,phoneNumber) VALUES (1,'Popa Andrei',4.5,1200.0,'0734542091')
INSERT INTO Delivery_People(deliverID,name,rating,salary,phoneNumber) VALUES (2,'Petrescu Paul',4.8,1350.0,'0723047239')
INSERT INTO Delivery_People(deliverID,name,rating,salary,phoneNumber) VALUES (3,'Enescu Bogdan',3.2,1075.5,'0745309802')
INSERT INTO Delivery_People(deliverID,name) VALUES (4,'Vranceanu Alex')
INSERT INTO Delivery_People(deliverID,name) VALUES (5,'Morar Maria')
INSERT INTO Delivery_People(deliverID,name) VALUES (6,'Doru Livratoru')

CREATE TABLE Customer
(
	customerID SMALLINT NOT NULL,
	name VARCHAR(30) NOT NULL,
	rating DECIMAL(3,2),
	address VARCHAR(50),
	phoneNumber CHAR(10),
	PRIMARY KEY(customerID)
)

INSERT INTO Customer(customerID,name,rating,address,phoneNumber) VALUES (1,'Lovinescu Dorin',4.5,'Fabricii de Zahar 14',0745690021)
INSERT INTO Customer(customerID,name,rating,address,phoneNumber) VALUES (2,'Prisacaru Teodora',3.7,'Nicolae Grigorescu 4',0722759407)
INSERT INTO Customer(customerID,name,rating,address,phoneNumber) VALUES (3,'Andone Roxana',4.3,'Dumbrava Rosie 8',0729504102)
INSERT INTO Customer(customerID,name,rating,address,phoneNumber) VALUES (4,'Marin George',4.8,'Dunarii 20',0734257007)
INSERT INTO Customer(customerID,name,rating,address) VALUES (5,'Dornescu Vasile',2.1,'Intre Lacuri 16')

CREATE TABLE Order_Details
(
	orderID SMALLINT NOT NULL,
	itemID SMALLINT NOT NULL,
	quantity SMALLINT NOT NULL,
	PRIMARY KEY(orderID,itemID),
	FOREIGN KEY(itemID) REFERENCES MenuItem(itemID)
		ON DELETE CASCADE
)

INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (1,3,2);
INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (1,2,2);
INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (2,5,4);
INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (2,4,3);
INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (3,1,1);


CREATE TABLE Reservations
(
	reservID SMALLINT NOT NULL,
	customerID SMALLINT NOT NULL,
	date DATETIME NOT NULL,
	tableID SMALLINT,
	PRIMARY KEY(reservID),
	FOREIGN KEY(customerID) REFERENCES Customer(customerID)
		ON DELETE CASCADE
)

INSERT INTO Reservations(reservID,customerID,date,tableID) VALUES (1,2,'2020-09-20 20:00',1)
INSERT INTO Reservations(reservID,customerID,date,tableID) VALUES (2,2,'2020-10-18 20:30',2)
INSERT INTO Reservations(reservID,customerID,date,tableID) VALUES (3,3,'2020-09-20 16:00',6)
INSERT INTO Reservations(reservID,customerID,date) VALUES (4,1,'2020-11-08 17:45')
INSERT INTO Reservations(reservID,customerID,date) VALUES (5,2,'2020-04-10 22:30')

SELECT * FROM Reservations
/*
CREATE TABLE Bill
(
	billID SMALLINT NOT NULL,
	customerID SMALLINT NOT NULL,
	chefID SMALLINT NOT NULL,
	price SMALLINT NOT NULL,
	tips SMALLINT,
	paymentMethod VARCHAR(20) NOT NULL,
	PRIMARY KEY(billID),
	FOREIGN KEY(customerID) REFERENCES Customer(customerID)
		ON DELETE CASCADE,
	FOREIGN KEY(chefID) REFERENCES Chef(chefID)
)
*/

CREATE TABLE Allergens
(
	allergID SMALLINT NOT NULL PRIMARY KEY,
	name VARCHAR(30) NOT NULL
)
select * from Allergens
SELECT allergID,name FROM Allergens
INSERT INTO Allergens(allergID,name) VALUES (1,'eggs')
INSERT INTO Allergens(allergID,name) VALUES (2,'milk')
INSERT INTO Allergens(allergID,name) VALUES (3,'nuts')
INSERT INTO Allergens(allergID,name) VALUES (4,'seafood')
INSERT INTO Allergens(allergID,name) VALUES (5,'soy')

CREATE TABLE Allergens_MenuItem
(
	allergID SMALLINT NOT NULL,
	itemID SMALLINT NOT NULL,
	PRIMARY KEY(allergID,itemID),
	FOREIGN KEY(allergID) REFERENCES Allergens(allergID)
		ON DELETE CASCADE,
	FOREIGN KEY(itemID) REFERENCES MenuItem(itemID)
		ON DELETE CASCADE
)

INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (1,1)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (1,2)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (2,1)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (2,2)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (3,5)

CREATE TABLE Order_DineIn
(
	orderID SMALLINT NOT NULL PRIMARY KEY,
	customerID SMALLINT NOT NULL,
	waiterID SMALLINT NOT NULL,
	chefID SMALLINT NOT NULL,
	tableID SMALLINT,
	price SMALLINT NOT NULL,
	tips SMALLINT,
	paymentMethod VARCHAR(30),
	FOREIGN KEY(customerID) REFERENCES Customer(customerID)
		ON DELETE CASCADE,
	FOREIGN KEY(waiterID) REFERENCES Waiter(waiterID)
		ON DELETE CASCADE,
	FOREIGN KEY(chefID) REFERENCES Chef(chefID)
		ON DELETE CASCADE
)

ALTER TABLE Order_DineIn ALTER COLUMN price DECIMAL(6,2) NOT NULL
ALTER TABLE Order_DineIn ALTER COLUMN tips DECIMAL(6,2) 

INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (1,1,1,1,1,30.50,5.0,'cash')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (2,2,3,4,1,100.75,20.25,'card')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,paymentMethod) VALUES (3,1,3,1,3,5.50,'cash')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (4,1,1,1,1,230.50,45.0,'cash')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,paymentMethod) VALUES (5,2,2,2,5,18.25,'voucher')

SELECT * FROM Order_DineIn

CREATE TABLE Order_Delivery
(
	orderID SMALLINT NOT NULL PRIMARY KEY,
	customerID SMALLINT NOT NULL,
	deliverID SMALLINT NOT NULL,
	chefID SMALLINT NOT NULL,
	price DECIMAL(6,2) NOT NULL,
	tips DECIMAL(6,2),
	paymentMethod VARCHAR(30),
	FOREIGN KEY(customerID) REFERENCES Customer(customerID)
		ON DELETE CASCADE,
	FOREIGN KEY(deliverID) REFERENCES Delivery_People(deliverID)
		ON DELETE CASCADE,
	FOREIGN KEY(chefID) REFERENCES Chef(chefID)
		ON DELETE CASCADE
)

INSERT INTO Order_Delivery(orderID,customerID,deliverID,chefID,price,tips,paymentMethod) VALUES (1,2,2,2,30.50,2.0,'cash')
INSERT INTO Order_Delivery(orderID,customerID,deliverID,chefID,price,paymentMethod) VALUES (2,2,2,2,15.0,'cash')
INSERT INTO Order_Delivery(orderID,customerID,deliverID,chefID,price,tips,paymentMethod) VALUES (3,1,6,5,56.30,7.50,'card')
INSERT INTO Order_Delivery(orderID,customerID,deliverID,chefID,price,paymentMethod) VALUES (4,5,1,6,30.50,'card')
INSERT INTO Order_Delivery(orderID,customerID,deliverID,chefID,price,tips,paymentMethod) VALUES (5,4,3,1,45.0,12.0,'cash')

ALTER TABLE Order_Details ADD CONSTRAINT FK_Order FOREIGN KEY(orderID) REFERENCES Order_DineIn(orderID)
ALTER TABLE Order_Details ADD CONSTRAINT FK_Order2 FOREIGN KEY(orderID) REFERENCES Order_Delivery(orderID)

create table TestInsertTable
(
	id int,
	name varchar(20)
)

select * from TestInsertTable
INSERT INTO TestInsertTable(id,name) VALUES (1,'name1')
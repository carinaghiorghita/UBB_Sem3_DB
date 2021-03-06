ALTER TABLE Order_Details DROP CONSTRAINT FK_Order2

CREATE TABLE Order_Details2
(
	orderID SMALLINT NOT NULL,
	itemID SMALLINT NOT NULL,
	quantity SMALLINT NOT NULL,
	PRIMARY KEY(orderID,itemID),
	FOREIGN KEY(itemID) REFERENCES MenuItem(itemID)
		ON DELETE CASCADE,
	FOREIGN KEY(orderID) REFERENCES Order_Delivery(orderID)
		ON DELETE CASCADE
)

INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (1,3,2)
INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (1,2,2)
INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (2,5,4)
INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (2,4,3)
INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (3,1,1)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (1,5)
INSERT INTO Allergens_MenuItem(allergID,itemID) VALUES (2,4)
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,paymentMethod) VALUES (6,2,3,1,3,5.50,'cash')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (7,1,1,1,1,240.50,45.0,'cash')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (8,1,1,1,3,240.50,45.0,'card')
INSERT INTO Order_DineIn(orderID,customerID,waiterID,chefID,tableID,price,tips,paymentMethod) VALUES (9,1,1,1,3,240.50,4.0,'card')
INSERT INTO Customer(customerID,name,rating,address) VALUES (6,'Gradinaru Viorel',2.1,'Bucuresti 20')
INSERT INTO Order_Details(orderID,itemID,quantity) VALUES (5,2,1)

--insert that violates the referential integrity constraints
INSERT INTO Order_Details2(orderID,itemID,quantity) VALUES (6,7,6)

UPDATE Waiter
SET salary=1000
WHERE salary IS NULL

UPDATE Customer
SET rating=NULL
WHERE rating<4.0

UPDATE Reservations
SET tableID=10
WHERE tableID BETWEEN 2 AND 7

DELETE FROM Delivery_People
WHERE name LIKE '%_Paul%'

DELETE FROM MenuItem
WHERE itemID IN (1,3)

--UNION with OR: select all the allergens that appear in Pizza Margherita or Crispy Strips
SELECT DISTINCT A.name
FROM Allergens_MenuItem AM, MenuItem M, Allergens A
WHERE A.allergID=AM.allergID AND AM.itemID=M.itemID AND (M.name='Pizza Margherita' OR M.name='Crispy Strips')

--UNION with UNION: select all menu items that are in dine-in orders paid by card or voucher
SELECT M.name
FROM Order_DineIn D, Order_Details O, MenuItem M
WHERE M.itemID=O.itemID AND O.orderID=D.orderID AND D.paymentMethod='card'
UNION
SELECT M2.name
FROM Order_DineIn D2, Order_Details O2, MenuItem M2
WHERE M2.itemID=O2.itemID AND O2.orderID=D2.orderID AND D2.paymentMethod='voucher'


--INTERSECTION with INTERSECT: select all allergens that appear in both Pizza Margherita and Crispy Strips
SELECT A.name
FROM Allergens A, MenuItem M, Allergens_MenuItem AM
WHERE A.allergID=AM.allergID AND AM.itemID=M.itemID AND M.name='Pizza Margherita'
INTERSECT
SELECT A2.name
FROM Allergens A2, MenuItem M2, Allergens_MenuItem AM2
WHERE A2.allergID=AM2.allergID AND AM2.itemID=M2.itemID AND M2.name='Crispy Strips'

--INTERSECTION with INTERSECT: select all customers who have paid dine-in orders with both cash and card, as well as the total sum paid (price+tips) (arithmetic expression)
SELECT DISTINCT C.name,O.price+O.tips as totalPaid
FROM Customer C, Order_DineIn O
WHERE C.customerID=O.customerID AND O.paymentMethod='card' AND O.customerID IN
(
SELECT O2.customerID
FROM Order_DineIn O2
WHERE O2.paymentMethod='cash'
)

--DIFFERENCE with EXCEPT: select all chefs that have cooked for dine-in orders, but not delivery orders
SELECT C.name
FROM Chef C, Order_DineIn D
WHERE C.chefID=D.chefID
EXCEPT
SELECT C2.name
FROM Chef C2, Order_Delivery D2
WHERE C2.chefID=D2.chefID

--DIFFERENCE with NOT IN: select all allergens that are in Crispy Strips, but not in Pizza Margherita
SELECT A.name
FROM Allergens A, MenuItem M, Allergens_MenuItem AM
WHERE A.allergID=AM.allergID AND AM.itemID=M.itemID AND M.name='Crispy Strips' AND A.allergID NOT IN
(
SELECT A2.allergID
FROM Allergens A2, MenuItem M2, Allergens_MenuItem AM2
WHERE A2.allergID=AM2.allergID AND AM2.itemID=M2.itemID AND M2.name='Pizza Margherita'
)

--INNER JOIN: select top 5 waiters that serve all allergens,as well as their absolute rating (=rating/salary) (two m:n relationships used + arithmetic expression)
SELECT TOP 5 W.name,M.name,A.name,W.rating/W.salary AS absRating
FROM Waiter W
INNER JOIN Order_DineIn O ON W.waiterID=O.waiterID
INNER JOIN Order_Details D ON O.orderID=D.orderID
INNER JOIN MenuItem M ON D.itemID=M.itemID
INNER JOIN Allergens_MenuItem AM ON M.itemID=AM.itemID
INNER JOIN Allergens A ON AM.allergID=A.allergID

--LEFT JOIN: select all delivery people and the menu items delivered, including those with no orders
SELECT P.name,M.name,M.quantity
FROM Delivery_People P
LEFT JOIN Order_Delivery D ON P.deliverID=D.deliverID
LEFT JOIN Order_Details OD ON D.orderID=OD.orderID
LEFT JOIN MenuItem M ON OD.itemID=M.itemID

--RIGHT JOIN: select all customers and the tables they reserved, including those with no tables reserved, where the curstomer is either Prisacaru Teodora or Lovinescu Dorin (condition with OR)
SELECT R.tableID,C.name
FROM Reservations R
RIGHT JOIN Customer C ON C.customerID=R.customerID
WHERE C.name='Prisacaru Teodora' OR C.name='Lovinescu Dorin'

--FULL JOIN: select top 3 allergens that appear in all menu items, including allergens that don't appear in menu items and menu items without allergens (three tables used)
SELECT TOP 3 A.name, A.allergID, M.name
FROM Allergens A
FULL JOIN Allergens_MenuItem AM ON A.allergID=AM.allergID
FULL JOIN MenuItem M ON AM.itemID=M.itemID

--IN operator in WHERE clause and a subclause: select all delivery people that have delivered orders
SELECT TOP 3 D.name
FROM Delivery_People D
WHERE D.deliverID IN 
(
SELECT O.deliverID
FROM Order_Delivery O
)
ORDER BY D.name

--IN operator in WHERE clause and two subclauses: select all allergens that appear in menu items that cost more than 10 or less than 5
SELECT A.name
FROM Allergens A
WHERE A.allergID IN
(
SELECT AM.itemID
FROM Allergens_MenuItem AM
WHERE AM.itemID IN
(
SELECT M.itemID
FROM MenuItem M
WHERE M.price>=10 OR M.price<=5
)
)

--EXISTS operator and a subquery in the WHERE clause: select customers with reservations before 2020-10-01 00:00:00 (condition with AND)
SELECT DISTINCT C.name
FROM Customer C
WHERE EXISTS 
(
SELECT *
FROM Reservations R
WHERE R.customerID=C.customerID AND R.date<='2020-10-01 00:00:00'
)

--EXISTS operator and a subquery in the WHERE clause: select waiters who have served orders where the price was greater than 100 (condition with AND)
SELECT W.name
FROM Waiter W
WHERE EXISTS
(
SELECT *
FROM Order_DineIn O
WHERE O.waiterID=W.waiterID AND O.price>=100
)
--subquery in the FROM clause: select all menu items whose prices are higher than the average of all menu items, as well as the difference between their price and the average (arithmetic expression)
SELECT M.name, M.price, M.price-AveragePrice AS diffAvg
FROM (SELECT AVG(price) AS AveragePrice FROM MenuItem) AS A, MenuItem M
WHERE M.price>=AveragePrice

--subquery in the FROM clause: select all chefs whose phone numbers end in 8
SELECT C.name,C.phoneNumber
FROM (SELECT * FROM Chef WHERE phoneNumber LIKE '%8') AS CP, Chef C
WHERE C.chefID=CP.chefID

--GROUP BY: select the minimum price of a dine-in order, where the orders have been grouped by their payment method
SELECT MIN(O.price) AS minPrice,O.paymentMethod
FROM Order_DineIn O
GROUP BY O.paymentMethod

--GROUP BY and HAVING: select the number of dine-in orders at each table, where the table has been used for at least 2 orders
SELECT COUNT(*) AS timesUsed,O.tableID
FROM Order_DineIn O
GROUP BY O.tableID
HAVING COUNT(*)>=2

--GROUP BY and HAVING with subquery: select the sum of the prices of all delivery orders grouped by the delivery person, where the deliverID is valid (there exists a delivery person with that ID)
SELECT O.deliverID,SUM(O.price) AS sumPrice
FROM Order_Delivery O
GROUP BY O.deliverID
HAVING O.deliverID in (SELECT deliverID FROM Delivery_People)

--GROUP BY and HAVING with subquery: select the maximum price for a dine-in order grouped by the table, where each table has been reserved before
SELECT MAX(O.price) AS maxPrice,O.tableID
FROM Order_DineIn O
GROUP BY O.tableID
HAVING O.tableID IN (SELECT DISTINCT tableID FROM Reservations)

/*
--ANY introduces subquery in WHERE clause: select all waiters whose salary is smaller than any of the delivery people's
SELECT W.name,W.salary
FROM Waiter W
WHERE W.salary < ANY (SELECT salary FROM Delivery_People)
ORDER BY W.salary

--rewritten with NOT IN
SELECT W.name,W.salary
FROM Waiter W
WHERE W.salary NOT IN (SELECT salary FROM Waiter WHERE salary>(SELECT MIN(salary) FROM Delivery_People))
ORDER BY W.salary
*/

--ANY introduces subquery in WHERE clause: select all delivery people whose rating is smaller than any rating of any waiter
SELECT D.name,D.rating
FROM Delivery_People D
WHERE D.rating < ANY (SELECT rating FROM Waiter)
ORDER BY D.rating

--rewritten with aggregation operator MAX
SELECT D.name,D.rating
FROM Delivery_People D
WHERE D.rating < (SELECT MAX(rating) FROM Waiter)
ORDER BY D.rating

/*
--ALL introduces subquery in WHERE clause: select all dine-in orders IDs that received tips greater than all tips received for delivery orders
SELECT O.orderID,O.tips
FROM Order_DineIn O
WHERE O.tips < ALL (SELECT tips FROM Order_Delivery WHERE tips IS NOT NULL)
ORDER BY O.orderID

--rewritten with IN
SELECT O.orderID,O.tips
FROM Order_DineIn O
WHERE O.tips IN (SELECT tips FROM Order_DineIn WHERE tips<(SELECT MIN(tips) FROM Order_Delivery WHERE tips IS NOT NULL))
ORDER BY O.orderID
*/

--ALL introduces subquery in WHERE clause: select all customers whose rating is smaller than all ratings of all chefs
SELECT C.name,C.rating
FROM Customer C
WHERE C.rating < ALL (SELECT rating FROM Chef WHERE rating IS NOT NULL)
ORDER BY C.rating

--rewritten with aggregation operator
SELECT C.name,C.rating
FROM Customer C
WHERE C.rating < (SELECT MIN(rating) FROM Chef WHERE rating IS NOT NULL)
ORDER BY C.rating

--ANY introduces subquery in WHERE clause: select all customers that have reservations
SELECT C.name
FROM Customer C
WHERE C.customerID = ANY (SELECT R.customerID FROM Reservations R)

--rewritten with IN:
SELECT C.name
FROM Customer C
WHERE C.customerID IN (SELECT R.customerID FROM Reservations R)

--ALL introduces subquery in WHERE clause: select all chefs that don't cook for dine-in orders
SELECT C.name
FROM Chef C
WHERE C.chefID <> ALL (SELECT O.chefID FROM Order_DineIn O)

--rewritten with NOT IN:
SELECT C.name
FROM Chef C
WHERE C.chefID NOT IN (SELECT O.chefID FROM Order_DineIn O)
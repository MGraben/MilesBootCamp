/*
The system should also be able to track Supplies. Supplies should have a unit and a name for instance “ounce” and “strong ale” 
There should also be a way to track counts. That is to say- inventory. It should have a supply Id, tavern id, 
and the date it was updated as well as the current count for that supply. 
There also needs to be a way to show what the tavern received. This will include supply id, tavern id, cost, the amount received, 
	and date.
		(Note: Supplies table and tavern IDs must exist in their respective tables)
Taverns should also provide services. Services should have a name (ie. Pool or Weapon sharpening). 
They should also have a status which should be a manageable list of values (stored in another table). 
	For instance, ‘active’, ‘inactive’  but we may also want to add others down the line. Such as out of stock or discontinued. 
 The database should also keep track of it with a sales table. This table will track 
 service, guest, price, date purchased, amount purchased, and the tavern it belongs to

Seed all tables with at least 5-10 rows of data each. Add some repeated fields to show normalization
*/

CREATE TABLE dbo.Supplies
(
	supplyID int Identity(1,1) NOT NULL, 
	supplyName varchar(100) NOT NULL, 
	supplyDescription  varchar(max) NULL,
	supplyUnitID int NOT NULL,									-- FK to Units
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_supplyID PRIMARY KEY CLUSTERED (supplyID ASC)
)
GO

CREATE TABLE dbo.Units
(
	unitID int Identity(1,1) NOT NULL, 
	unitName varchar(100) NOT NULL, 
	unitDescription  varchar(max) NULL,
    CONSTRAINT PK_unitID PRIMARY KEY CLUSTERED (unitID ASC)
)
GO

CREATE TABLE dbo.Inventory
(
	inventoryID int Identity(1,1) NOT NULL, 
	supplyID int NOT NULL,										-- FK to Supplies
	tavernID int NOT NULL,										--FK to Tavern
--	amountReceived int NULL,
--	dateReceived datetime NULL,
	amtInInventory int NULL,
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_inventoryID PRIMARY KEY CLUSTERED (inventoryID ASC)
)
GO

CREATE TABLE dbo.Receipts
(
	receiptID int Identity(1,1) NOT NULL, 
	supplyID int NOT NULL,										-- FK to Supplies
	tavernID int NOT NULL,										--FK to Tavern
	cost float NULL,
	amountReceived int NULL,
	dateReceived datetime NULL,
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_receiptID PRIMARY KEY CLUSTERED (receiptID ASC)
)
GO


CREATE TABLE dbo.TavernServices
(
	serviceID int Identity(1,1) NOT NULL, 
--	tavernID int NOT NULL,										--FK to Tavern
	serviceName varchar(max) NULL,
	statusID int NOT NULL,										--FK to ServiceStatus
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_serviceID PRIMARY KEY CLUSTERED (serviceID ASC)
)
GO

CREATE TABLE dbo.ServiceStatus
(
	statusID int Identity(1,1) NOT NULL, 
	statusName varchar(100) NOT NULL, 
	statusDescription  varchar(max) NULL,
    CONSTRAINT PK_statusID PRIMARY KEY CLUSTERED (statusID ASC)
)
GO

CREATE TABLE dbo.Sales
(
	salesID int Identity(1,1) NOT NULL, 
	serviceID int NOT NULL,										-- FK to TavernServices
	tavernID int NOT NULL,										--FK to Tavern
	guestName varchar(max) NULL,
	price float NULL,
	amountPurchased int NULL,
	datePurchased datetime NULL,
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_salesID PRIMARY KEY CLUSTERED (salesID ASC)
)
GO


-- add constraints

--Supplies
ALTER TABLE [dbo].[Supplies]  WITH CHECK ADD  CONSTRAINT [FK_Supplies_Units] FOREIGN KEY([supplyUnitID])
REFERENCES [dbo].[Units] ([unitID])
GO

ALTER TABLE [dbo].[Supplies] CHECK CONSTRAINT [FK_Supplies_Units]
GO
-------------------------------
-- Inventory
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_Supplies] FOREIGN KEY([supplyID])
REFERENCES [dbo].[Supplies] ([supplyID])
GO

ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_Supplies]
GO

ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_Tavern] FOREIGN KEY([tavernID])
REFERENCES [dbo].[Tavern] ([tavernID])
GO

ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_Tavern]
GO
----------------------------------
--Receipts
ALTER TABLE [dbo].[Receipts]  WITH CHECK ADD  CONSTRAINT [FK_Receipts_Supplies] FOREIGN KEY([supplyID])
REFERENCES [dbo].[Supplies] ([supplyID])
GO

ALTER TABLE [dbo].[Receipts] CHECK CONSTRAINT [FK_Receipts_Supplies]
GO

ALTER TABLE [dbo].[Receipts]  WITH CHECK ADD  CONSTRAINT [FK_Receipts_Tavern] FOREIGN KEY([tavernID])
REFERENCES [dbo].[Tavern] ([tavernID])
GO

ALTER TABLE [dbo].[Receipts] CHECK CONSTRAINT [FK_Receipts_Tavern]
GO
----------------------------------
--TavernServices
ALTER TABLE [dbo].[TavernServices]  WITH CHECK ADD  CONSTRAINT [FK_TavernServices_ServiceStatus] FOREIGN KEY([statusID])
REFERENCES [dbo].[ServiceStatus] ([statusID])
GO

ALTER TABLE [dbo].[TavernServices] CHECK CONSTRAINT [FK_TavernServices_ServiceStatus]
GO

--ALTER TABLE [dbo].[TavernServices]  WITH CHECK ADD  CONSTRAINT [FK_TavernServices_Tavern] FOREIGN KEY([tavernID])
--REFERENCES [dbo].[Tavern] ([tavernID])
--GO

--ALTER TABLE [dbo].[TavernServices] CHECK CONSTRAINT [FK_TavernServices_Tavern]
--GO
----------------------------------
--Sales
ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [FK_Sales_TavernServices] FOREIGN KEY([serviceID])
REFERENCES [dbo].[TavernServices] ([serviceID])
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_TavernServices]
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Tavern] FOREIGN KEY([tavernID])
REFERENCES [dbo].[Tavern] ([tavernID])
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_Tavern]
GO


--**********************************************************************************************************

-- Load some data

Begin tran 
insert into [dbo].[Units] ([unitName],unitDescription)
values ('oz','fluid ounces')
	, ('lb', 'pounds dry')
	,( 'carton', 'Boxed good')
	,( 'can', 'number 10')
	,( 'keg', 'half barrel')
	,( 'sack', '50 #')

Go
rollback commit


Begin tran 
insert into [dbo].[Supplies] (supplyName,supplyDescription,supplyUnitID)
values ('strong ale','beer on tap', 1)
	, ('napkins','for dining room', 3)
	,( 'pretzels','for the bar', 2)
	,( 'potatoes','russet', 6)
	,( 'olives','stuffed', 4)
	,( 'sauce','marinara', 4)
	,( 'tonic','Bottled', 1)
	,( 'plates','dinner', 3)

Go
rollback commit

Begin tran 
insert into [dbo].ServiceStatus (statusName,statusDescription)
values ('active','available')
,( 'inactive','no longer available')
GO
rollback commit

--Taverns should also provide services. Services should have a name (ie. Pool or Weapon sharpening). 
--They should also have a status which should be a manageable list of values
Begin tran 
insert into [dbo].TavernServices(serviceName,statusID)	--,tavernID)
values ('Pool',1) --,2)
	,('Pool',2) --,3)
	--,('Pool',1,1)
	,('Weapon sharpening',1) --,1)
	,('Weapon sharpening',2) --,2)
	--,('Weapon sharpening',2,3)
	,('Darts',1) --,1)
	,('Darts',2) --,1)		
	,('Private Room',1) --,1)
	,('Private Room',1) --,3)
	,('Food',1) --,1)
	,('Food',2) --,1)	
Go
rollback commit

Begin tran 
insert into [dbo].Inventory(supplyID,tavernID,amtInInventory)
values (1,1,2)
	,(2,1,3)
	,(5,1,10)
	,(7,2,21)
	,(8,2,2)
	,(1,2,3)
	,(4,1,1)
	,(4,2,3)		
	,(3,1,15)
	,(1,3,3)
Go
rollback commit

Begin tran 
insert into [dbo].Receipts(supplyID,tavernID,cost,amountReceived,dateReceived)
values (1,1,230.50,1,cast('1/4/2019' as datetime))
	,(2,1,15.99,1,cast('1/4/2019' as datetime))
	,(5,1,11.25,3,cast('1/4/2019' as datetime))
	,(7,2,.75,12,cast('5/24/2019' as datetime))
	,(8,2,57.40,2,cast('5/24/2019' as datetime))
	,(1,2,230.50,20,cast('3/18/2019' as datetime))
	,(4,1,30,1,cast('8/4/2019' as datetime))
	,(4,2,33,1,cast('8/4/2019' as datetime))		
	,(3,1,15,3,cast('7/28/2019' as datetime))
	,(1,3,250,1,cast('9/4/2019' as datetime))
Go
rollback commit

--service, guest, price, date purchased, amount purchased, and the tavern
Begin tran 
insert into [dbo].Sales(tavernID,serviceID,guestName,price,amountPurchased,datePurchased)
values (1,1,'Tom',3.50,7,cast('1/4/2019' as datetime))
	,(1,1,'Joe',3.50,14,cast('3/14/2019' as datetime))
	,(1,9,'Tom',17.50,17.50,cast('8/4/2019' as datetime))
	,(1,1,'Sally',3.50,3.5,cast('5/22/2019' as datetime))
	,(2,3,'Bertha',10.50,21,cast('2/14/2019' as datetime))
	,(2,9,'Harry',13.50,15.97,cast('7/4/2019' as datetime))
	,(3,1,'Bud',3.50,7,cast('1/4/2019' as datetime))
	,(3,1,'Mary',3.50,7,cast('3/30/2019' as datetime))		
	,(3,1,'Mary',3.50,7,cast('4/1/2019' as datetime))
	,(1,1,'Tom',3.50,10.5,cast('5/25/2019' as datetime))
Go
rollback commit

select @@TRANCOUNT
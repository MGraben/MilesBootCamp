/*
Complete the User story: There should be a way to track guests- their names, notes about them, birthdays, cakedays, 
and status - which can be any kind. Such as sick, fine, hangry, raging, placid. 
The guests should have classes and should have levels related to them. Ex. lvl 2 mage, lvl 3 fighter. ((linking table)). 

Also I no longer want to track rats.

Finish up our Schema with missing information - We need to link Supplies and have them be used in sales. 
Create a Supply Sales table to give us a way to make use of received supplies. 
(You can alternatively create a ServiceSupplies table or even a SaleSupplies table 
and make use of the supplies in Services that Taverns sell)
Add Foreign Keys and Primary Keys to our tables. Take care when creating the primary keys for the many-to-many relationships
Instead of Adding Foreign Keys and Primary keys to a table on creation, 
Use an Alter Table command to modify the table to add them to the Tavern table and the User Table
Show that there are constraints by making insertions or queries that will fail due to foreign key constraints 
(you can comment these out so that your script still runs)

*/

USE [MGrabenstein_2019]
GO

-- based on this requirement, I should go back and modify Sales to replace column guestName (varchar)
-- with guestID below. Then create a FK constraint on Sales for guestID
CREATE TABLE dbo.Guests
(
	guestID int Identity(1,1) NOT NULL, 
	guestName varchar(100) NOT NULL, 
	notes  varchar(max) NULL,
	birthday date NULL,
	cakeday date NULL,
	guestStatusID int NOT NULL,					--FK to Status table
	clID int NOT NULL,						--FK to ClassLevel table					
    CONSTRAINT PK_guest PRIMARY KEY CLUSTERED (guestID ASC)
)
GO


CREATE TABLE dbo.GuestStatus
(
	statusID int Identity(1,1) NOT NULL, 
	statusName varchar(100) NOT NULL, 
	statusDescription  varchar(max) NULL,
    CONSTRAINT PK_status PRIMARY KEY CLUSTERED (statusID ASC)
)
GO

CREATE TABLE dbo.ClassLevel
(
	clID int Identity(1,1) NOT NULL, 
	guestLevel varchar(100) NOT NULL, 
	guestClass  varchar(100) NOT NULL,
    CONSTRAINT PK_ClassLevel PRIMARY KEY CLUSTERED (clID ASC)
)
GO

------------------------------------------------------------
--set up foreign keys on Guests
ALTER TABLE [dbo].[Guests]  WITH CHECK ADD  CONSTRAINT [FK_Guests_GuestStatus] FOREIGN KEY([guestStatusID])
REFERENCES [dbo].[GuestStatus] ([statusID])
GO

ALTER TABLE [dbo].[Guests] CHECK CONSTRAINT [FK_Guests_GuestStatus]
GO


ALTER TABLE [dbo].[Guests]  WITH CHECK ADD  CONSTRAINT [FK_Guests_ClassLevel] FOREIGN KEY([clID])
REFERENCES [dbo].[ClassLevel] ([clID])
GO

ALTER TABLE [dbo].[Guests] CHECK CONSTRAINT [FK_Guests_ClassLevel]
GO

--------------------------------------------------------------------------------------
-- Drop Rats table now

ALTER TABLE [dbo].[Tavern] DROP CONSTRAINT [FK_Tavern_Rats]
GO

IF OBJECT_ID('dbo.Rats', 'U') IS NOT NULL
  DROP TABLE dbo.Rats
GO

----------------------------------------------------------------------------------
-- link supplies and sales

CREATE TABLE dbo.SupplySales
(
	supplySalesID int Identity(1,1) NOT NULL, 
	[supplyID] int NOT NULL,					-- FK to Supply
	[salesID] int NOT NULL,						-- FK to Sales
	saleDate datetime NULL,								
	lastModfiedDate datetime NOT NULL Default getdate(),

    CONSTRAINT PK_supplySalesID PRIMARY KEY CLUSTERED (supplySalesID ASC)
)
GO

----------------------------------
--Set up foreign keys on SupplySales
ALTER TABLE [dbo].[SupplySales]  WITH CHECK ADD  CONSTRAINT [FK_SupplySales_Sales] FOREIGN KEY([salesID])
REFERENCES [dbo].[Sales] ([salesID])
GO

ALTER TABLE [dbo].[SupplySales] CHECK CONSTRAINT [FK_SupplySales_Sales]
GO

ALTER TABLE [dbo].[SupplySales]  WITH CHECK ADD  CONSTRAINT [FK_SupplySales_Supplies] FOREIGN KEY([supplyID])
REFERENCES [dbo].[Supplies] ([supplyID])
GO

ALTER TABLE [dbo].[SupplySales] CHECK CONSTRAINT [FK_SupplySales_Supplies]
GO

--**********************************************************************************************************

-- Load some data

--sick, fine, hangry, raging, placid
--Begin tran 
insert into [dbo].[GuestStatus] (statusName,statusDescription)
values ('fine','normal guest')
,( 'hangry','get them food fast!')
,( 'raging','alert the manager')
,( 'placid','bring coffee')
,( 'sick','get the mop!')
GO
--rollback commit

--lvl 2 mage, lvl 3 fighter
--Begin tran 
insert into [dbo].[ClassLevel] (guestClass,guestLevel)
values ('mage','2')
,( 'fighter','3')
,( 'knight','2')
,( 'monk','1')
,( 'mage','2')
,( 'mage','1')
GO
--rollback commit

--Begin tran 
insert into [dbo].[Guests] (guestName, notes,birthday ,	cakeday ,guestStatusID ,clID )
values ('Elvis','Costello, not Presely',cast('10/4/1954' as date), cast('1/4/2019' as date),1, 5)
	, ('Bono','U2',cast('10/4/1954' as date), cast('1/4/2019' as date),1, 3)
	,( 'Cher','still rockin',cast('10/4/1954' as date), cast('1/4/2019' as date),1, 2)
	,( 'Madonna','first album still the best',cast('10/4/1954' as date), cast('1/4/2019' as date),1, 1)
	,( 'Sting','quick, call the Police',cast('10/4/1954' as date), cast('1/4/2019' as date),3, 1)
	,( 'Morrisey','see: Smiths',cast('10/4/1954' as date), cast('1/4/2019' as date),4, 4)
	,( 'Beyonce','without Jay-Z',cast('10/4/1984' as date), cast('1/4/2019' as date),2, 2)

Go
--rollback commit



select @@TRANCOUNT
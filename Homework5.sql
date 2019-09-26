/*
Homework Assignment 5

1. Write a query to return a “report” of all users and their roles
2. Write a query to return all classes and the count of guests that hold those classes
3. Write a query that returns all guests ordered by name (ascending) and their classes and corresponding levels. Add a column that labels them beginner (lvl 1-5), intermediate (5-10) and expert (10+) for their classes (Don’t alter the table for this)
4. Write a function that takes a level and returns a “grouping” from question 3 (e.g. 1-5, 5-10, 10+, etc)
5. Write a function that returns a report of all open rooms (not used) on a particular day (input) and which tavern they belong to 
6. Modify the same function from 5 to instead return a report of prices in a range (min and max prices) - Return Rooms and their taverns based on price inputs
7. Write a command that uses the result from 6 to Create a Room in another tavern that undercuts (is less than) the cheapest room by a penny - thereby making the new room the cheapest one


*/
--1. Write a query to return a “report” of all users and their roles
select u.userName, r.roleName, r.roleDescription from Users u inner join Roles r on
u.roleID = r.roleID


--2. Write a query to return all classes and the count of guests that hold those classes

select distinct a.clid,a.className,count(clid) GuestCount from 
(select l.guestID,c.clid,c.className from [dbo].[Guests] g left outer join [dbo].[Levels] l on
g.guestID = l.guestID
left outer join [dbo].[Class] c on
l.classID = c.clid
where c.clid is not null
)a 
group by a.clid,a.className


--3. Write a query that returns all guests ordered by name (ascending) and their classes and corresponding levels. 
	--Add a column that labels them beginner (lvl 1-5), intermediate (5-10) and expert (10+) for their classes 
	--(Don’t alter the table for this)

select g.guestName,c.className
,case when l.lid < 5 then 'Beginner'
	when l.lid >= 5 and l.lid < 10 then 'Intermediate'
	when l.lid > 10 then 'Expert' end as LevelLabel
--,* 
from [dbo].[Guests] g left outer join [dbo].[Levels] l on
g.guestID = l.guestID
left outer join [dbo].[Class] c on
l.classID = c.clid


--4. Write a function that takes a level and returns a “grouping” from question 3 (e.g. 1-5, 5-10, 10+, etc)

IF OBJECT_ID (N'dbo.getLevel', N'FN') IS NOT NULL  
    DROP FUNCTION getLevel;  
GO    
CREATE FUNCTION dbo.getLevel(@levelID int)  
RETURNS varchar(50)   
AS   
BEGIN  
    DECLARE @ret varchar(50);  
    SELECT	@ret = (
    select case when l.lid < 5 then 'Beginner'
			when l.lid >= 5 and l.lid < 10 then 'Intermediate'
			when l.lid > 10 then 'Expert' end as LevelLabel
		--,* 
		from [dbo].[Guests] g left outer join [dbo].[Levels] l on
		g.guestID = l.guestID
		left outer join [dbo].[Class] c on
		l.classID = c.clid
		where l.lid = @levelID)
    RETURN ISNULL(@ret,'n/a');  
END; 
GO

-- testing	1,6,19
declare @levelID int = 8
select dbo.getLevel(@levelID)


--5. Write a function that returns a report of all open rooms (not used) on a particular day (input) and which tavern they belong to 
  
IF OBJECT_ID (N'dbo.EmptyRooms', N'IF') IS NOT NULL  
    DROP FUNCTION dbo.EmptyRooms;  
GO  
CREATE FUNCTION dbo.EmptyRooms(@date date)  
RETURNS Table   
AS   
Return(    
	select t.tavernName,r.roomName	--,rs.statusDescription
	--,* 
	from [dbo].[Rooms] r inner join [dbo].[RoomStatus] rs on
	r.statusID = rs.statusID
	inner join [dbo].[RoomStays] rms on
	r.roomID = rms.roomID
	inner join [dbo].[Tavern] t on
	r.tavernID = t.tavernID
	where rs.statusID in (12,13,14,15)  -- not in use
	and CONVERT(char(10), rms.dateOfStay, 120) = @date
)
Go

--testing
Declare @date date = cast('2/2/2019' as date)		--2019-02-14 00:00:00.000
select * from dbo.EmptyRooms(@date)

--6. Modify the same function from 5 to instead return a report of prices in a range (min and max prices) 
--- Return Rooms and their taverns based on price inputs

  
IF OBJECT_ID (N'dbo.RoomPrices', N'IF') IS NOT NULL  
    DROP FUNCTION dbo.RoomPrices;  
GO  
CREATE FUNCTION dbo.RoomPrices(@min int, @max int)  
RETURNS Table   
AS   
Return(    
	select t.tavernID, t.tavernName,r.roomName,rms.rate
	--,  select * 
	from [dbo].[Rooms] r --inner join [dbo].[RoomStatus] rs on
	--r.statusID = rs.statusID
	inner join [dbo].[RoomStays] rms on
	r.roomID = rms.roomID
	inner join [dbo].[Tavern] t on
	r.tavernID = t.tavernID
	where rms.rate between @min and @max
)
Go

--testing
Declare  @min int = 100 , @max int = 200
select * from  dbo.RoomPrices (@min , @max )


--7. Write a command that uses the result from 6 to Create a Room in another tavern that undercuts (is less than) 
-- the cheapest room by a penny - thereby making the new room the cheapest one

Declare  @min int = 0 , @max int = 2000
,@newRate decimal(18,2), @newTavernid int
select @newRate = (Select SUM(rate - .01) from (
select top 1 rate,roomName,tavernName,tavernID from  dbo.RoomPrices (@min , @max )
Group by rate,roomName,tavernName ,tavernID
Having rate = min(rate)
)a
)
print @newRate


Select CONCAT(
'Insert into dbo.Rooms (', (Select top 1 tavernID from [dbo].[Tavern] where tavernID <> (Select top 1 tavernID from dbo.RoomPrices (@min , @max )Group by rate,roomName,tavernName ,tavernID
Having rate = min(rate))),',')
Union all
Select Concat( '''CheapRoom''', ',')
Union all
Select '1'
Union all
Select ')'

--so the rate is in my RoomStays table; not sure how to best get the new rate into this table attached to the new room


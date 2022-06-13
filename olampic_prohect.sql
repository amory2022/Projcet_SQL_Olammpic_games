create database OlampicGaymes
use OlampicGaymes

--Importing data from Excel file

--########################______Cleaning Data_______#####################################
select *
from athlete_events
---------------------------------------------------------------------------------------------
---- Standardize Numbers Format

select ID,Age,Height,Weight,Year
from athlete_events



update athlete_events
set ID=convert(int,ID)


update athlete_events
set Age=convert(int,Age)

update athlete_events
set Height=convert(int,Height)


update athlete_events
set Weight=convert(int,Weight)

update athlete_events
set Year=convert(int,Year)


---------------------------------------------------------------------------------
---- Standardize Text Format
select *
from athlete_events

--break down the name to first name and last name
select Name,SUBSTRING(Name,1,CHARINDEX(' ',Name)) as First_Name
,SUBSTRING(Name,CHARINDEX(' ',Name) +1, len(Name))as Last_Name
From athlete_events


ALTER TABLE athlete_events
Add First_Name Nvarchar(255);

Update athlete_events
SET First_Name =SUBSTRING(Name,1,CHARINDEX(' ',Name)) 


ALTER TABLE athlete_events
Add Last_Name Nvarchar(255);

Update athlete_events
SET Last_Name =SUBSTRING(Name,CHARINDEX(' ',Name) +1, len(Name))

select * FROM athlete_events


select Sex
from athlete_events


----------------------------------------------------------------
-- Change M and F to Male and Female in "Sex" field

select Sex,
	case when Sex='M' then'Male'
		 when Sex='F' then 'Female'	
		 else Sex
	end as gender
from athlete_events

Update athlete_events
SET Sex = case when Sex='M' then'Male'
		       when Sex='F' then 'Female'	
		       else Sex
		  end 
select Sex
from athlete_events


--------------------------------------------------------------------------
-- Remove Duplicates

select *
from athlete_events


with row_numCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY Event,
				Last_Name
				order by ID) row_num
from athlete_events )
select *
from row_numCTE
where row_num>1
order by Event


----------------------------------------------------------------------------------
-- Delete Unused Columns
select *
from athlete_events


alter table  athlete_events
drop column Name






-------####################______List of SQL Queries_________#########################


--1) How many olympics games have been held?

select count(distinct Games) as total_olympic_games
from athlete_events
---------------------------------------------------------

--2)List down all Olympics games held so far.

select distinct( year),season
    from athlete_events 
    order by year;
------------------------------------------------------------------------------------------------------------
--3)Mention the total no of nations who participated in each olympics game?

 with all_countries as
        (select oh.Games, nr.region
        from athlete_events oh
        join nocregion nr ON nr.noc = oh.noc
        group by Games, nr.region)
    select Games, count(region) as total_countries
    from all_countries
    group by games
    order by games;

-----------------------------------------------------------------------------------------------
--4)Which year saw the highest and lowest no of countries participating in olympics?

 with all_countries as
              (select games, nr.region
              from athlete_events oh
              join nocregion nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;

-----------------------------------------------------------------------------------
--5)Which nation has participated in all of the olympic games?

with tot_games as
(select count( distinct Games) as total_games
from athlete_events), countries as
(select oh.Games,nr.region as country 
from athlete_events oh join nocregion nr ON nr.noc=oh.noc
group by games, nr.region),countries_participated as
(select country,count(1) as total_participated_games
from countries
group by country)
select cp.*
from countries_participated cp join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;

-------------------------------------------------------------------------
--6)Identify the sport which was played in all summer olympics?

      with t1 as
          	(select count(distinct games) as total_summer_games
          	from athlete_events where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from athlete_events where season = 'Summer'),
          t3 as
          	(select sport, count(1) as number_of_games
          	from t2
          	group by sport)
      select *
      from t3 join t1 on t1.total_summer_games = t3.number_of_games;

---------------------------------------------------------------
--7)Which Sports were just played only once in the olympics?
      with t1 as
          	(select distinct games, sport
          	from athlete_events),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;
---------------------------------------------------------------------------
--8)Fetch the total no of sports played in each olympic games?

with 
t1 as (
	select distinct Games,Sport
	from athlete_events ),
t2 as(
	select Games,COUNT(Sport) as no_of_sports
	from t1
	group by Games)
select * from t2
order by no_of_sports desc;


--------------------------------------------------------------------

		
		
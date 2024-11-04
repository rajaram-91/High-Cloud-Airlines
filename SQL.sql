-- CREATE DATABASE HIGHCLOUD_AIRLINE;
USE HIGHCLOUD_AIRLINE;
SHOW TABLES;
DESCRIBE MAINDATA;

SELECT * FROM MAINDATA;
ALTER TABLE MAINDATA RENAME COLUMN `%AIRLINE ID` TO `Airline_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%CARRIER GROUP ID` TO `Carrier_Group_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Unique Carrier Code` TO `Unique_Carrier_Code`;
ALTER TABLE MAINDATA RENAME COLUMN `%Unique Carrier Entity Code` TO `Unique_Carrier_Entity_Code`;
ALTER TABLE MAINDATA RENAME COLUMN `%Region Code` TO `Region_Code`;
ALTER TABLE MAINDATA RENAME COLUMN `%Origin Airport ID` TO `Origin_Airport_ID`; 
ALTER TABLE MAINDATA RENAME COLUMN `%Origin Airport Sequence ID` TO `Origin_Airport_Sequence_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Origin Airport Market ID` TO `Origin_Airport_Market_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Origin World Area Code` TO `Origin_World_Area_Code`;
ALTER TABLE MAINDATA RENAME COLUMN `%Destination Airport ID` TO `Destination_Airport_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Destination Airport Sequence ID` TO `Destination_Airport_Sequence_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Destination Airport Market ID` TO `Destination_Airport_Market_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Destination World Area Code` TO `Destination_World_Area_Code`;
ALTER TABLE MAINDATA RENAME COLUMN `%Aircraft Group ID` TO `Aircraft_Group_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Aircraft Type ID` TO `Aircraft_Type_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Aircraft Configuration ID` TO `Aircraft_Configuration_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Distance Group ID` TO `Distance_Group_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Service Class ID` TO `Service_Class_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `%Datasource ID` TO `Datasource_ID`;
ALTER TABLE MAINDATA RENAME COLUMN `# Departures Scheduled` TO `Departures_Scheduled`;
ALTER TABLE MAINDATA RENAME COLUMN `# Departures Performed` TO `Departures_Performed`;
ALTER TABLE MAINDATA RENAME COLUMN `# Payload` TO `Payload`;
ALTER TABLE MAINDATA RENAME COLUMN `# Available Seats` TO `Available_Seats`;
ALTER TABLE MAINDATA RENAME COLUMN `# Transported Passengers` TO `Transported_Passengers`;
ALTER TABLE MAINDATA RENAME COLUMN `# Transported Freight` TO `Transported_Freight`;
ALTER TABLE MAINDATA RENAME COLUMN `# Transported Mail` TO `Transported_Mail`;
ALTER TABLE MAINDATA RENAME COLUMN `# Ramp-To-Ramp Time` TO `Ramp-To-Ramp_Time`;
ALTER TABLE MAINDATA RENAME COLUMN `# Air Time` TO `Air_Time`;
ALTER TABLE MAINDATA RENAME COLUMN `Month (#)` TO `Month`;

SELECT * FROM MAINDATA;
SET SQL_SAFE_UPDATES = 0;

# Q1)Calcuate the following fields from the Year Month (#) Day fields ( First Create a Date Field from Year , Month , Day fields)

-- Date --
ALTER TABLE MAINDATA ADD COLUMN Date DATE;
UPDATE MAINDATA 
SET Date = STR_TO_DATE(CONCAT(YEAR, '-', MONTH, '-', DAY),'%Y-%m-%d');
SELECT Date FROM MAINDATA;


-- MonthNo --
ALTER TABLE MAINDATA ADD COLUMN MonthNo INT;
UPDATE MAINDATA 
SET MonthNo = MONTH(Date);
SELECT MonthNo FROM MAINDATA;



-- MonthName -- 
ALTER TABLE MAINDATA ADD COLUMN Month_Name CHAR(20);
UPDATE MAINDATA 
SET Month_Name = MONTHNAME(Date);
SELECT Month_Name FROM MAINDATA;



-- Quarter -- 
ALTER TABLE MAINDATA ADD COLUMN Quarters VARCHAR(9);
UPDATE MAINDATA
SET Quarters =
CASE
    WHEN Quarter(Date) = 1 then 'Q1'
    WHEN Quarter(Date) = 2 then 'Q2'
    WHEN Quarter(Date) = 3 then 'Q3'
    ELSE 'Q4'
    END;
SELECT QUARTERS FROM MAINDATA;


-- Year-Month --  
ALTER TABLE MAINDATA ADD COLUMN YearMonth VARCHAR(25);
UPDATE MAINDATA
SET YearMonth = date_format(date,'%Y-%m');
SELECT YearMonth FROM MAINDATA;

-- WeekDayNo --
ALTER TABLE MAINDATA ADD COLUMN WeekDayNo INT;
UPDATE MAINDATA
SET WeekDayNo = weekday(date);
SELECT WeekDayNo FROM MAINDATA;

-- WeekDayName --
ALTER TABLE MAINDATA ADD COLUMN WeekDayName VARCHAR(25);
UPDATE MAINDATA
SET WeekDayName = dayname(date);
SELECT WeekDayName FROM MAINDATA;

-- Financial Month Date -- 
ALTER TABLE MAINDATA ADD COLUMN Financial_Month_Date VARCHAR(25);
UPDATE MAINDATA
SET Financial_Month_Date = Adddate((date),interval '-3' Month);
SELECT Financial_Month_Date FROM MAINDATA;


SELECT * FROM MAINDATA;

-- Financial Month --
ALTER TABLE MAINDATA ADD COLUMN Financial_Month VARCHAR(25);
UPDATE MAINDATA
SET Financial_Month =  MONTH(Financial_Month_Date);
SELECT Financial_Month FROM MAINDATA;


-- Financial Quarter -- 
ALTER TABLE MAINDATA ADD COLUMN Financial_Quarter VARCHAR(25);
UPDATE MAINDATA
SET Financial_Quarter =
CASE
    WHEN Month(Financial_Month_Date) < 4 then 'Q1'
    WHEN Month(Financial_Month_Date) < 8 then 'Q2'
    WHEN Month(Financial_Month_Date) < 12 then'Q3'
    ELSE 'Q4'
END;
SELECT Financial_Quarter FROM MAINDATA;



-- Weekday VS Weekend --
ALTER TABLE MAINDATA
ADD COLUMN WeekDay_VS_Weekend VARCHAR(25);

UPDATE MAINDATA
SET WeekDay_VS_Weekend = 
  CASE
  WHEN DAYNAME(date) IN ('Saturday', 'Sunday') THEN 'Weekend'
    ELSE 'Weekday'
    END;
    SELECT WeekDay_VS_Weekend FROM MAINDATA;


-- DATE VIEW --
CREATE VIEW DATE_FIELD AS
SELECT `Date`,`MonthNo`,`Month_Name`,`Quarters`,`YearMonth`,`WeekDayNo`,`WeekDayName`,`Financial_Month`,`Financial_Quarter`
FROM MAINDATA;

SELECT * FROM DATE_FIELD;
----------------------------------------------------------------------------------------------------------------------------------------------------------
# Q2) Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

SELECT Year,SUM(Transported_Passengers),SUM(Available_Seats), 
(SUM(Transported_Passengers)/SUM(Available_Seats)*100) 
AS "Load_Factor" FROM MAINDATA GROUP BY Year;

SELECT Quarters,SUM(Transported_Passengers),SUM(Available_Seats), 
(SUM(Transported_Passengers)/SUM(Available_Seats)*100) 
AS "Load_Factor" FROM MAINDATA GROUP BY Quarters ORDER BY Quarters;

SELECT MonthNO ,SUM(Transported_Passengers),SUM(Available_Seats), 
(SUM(Transported_Passengers)/SUM(Available_Seats)*100) 
AS "Load_Factor" FROM MAINDATA GROUP BY MonthNo;

CREATE VIEW `load_factor_view` AS 
SELECT
    YEAR(maindata.Date) AS `Year`,
    QUARTER(maindata.Date) AS `Quarters`,
    MONTH(maindata.Date) AS `MonthNo`,
    SUM(maindata.Transported_Passengers) AS `Total_Transported_Passengers`,
    SUM(maindata.Available_Seats) AS `Total_Available_Seats`,
    ROUND((SUM(maindata.Transported_Passengers) / SUM(maindata.Available_Seats) * 100), 2) AS `Load_Factor`
FROM maindata GROUP BY YEAR(maindata.Date), QUARTER(maindata.Date), MONTH(maindata.Date)
ORDER BY YEAR(maindata.Date), QUARTER(maindata.Date), MONTH(maindata.Date);
select * from load_factor_view;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Q3) Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)


SELECT `Carrier Name`,SUM(Transported_Passengers),SUM(Available_Seats), 
(SUM(Transported_Passengers)/SUM(Available_Seats)*100) 
AS "Load_Factor" FROM MAINDATA GROUP BY `Carrier Name`;

--------------------------------------------------------------------------------------------------------------------------------------------------------
# 4. Identify Top 10 Carrier Names based passengers preference 

SELECT `Carrier Name`,SUM(Transported_Passengers)
FROM MAINDATA GROUP BY `Carrier Name` ORDER BY SUM(Transported_Passengers) DESC LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------------------------
# 5) Display top Routes ( from-to City) based on Number of Flights 

SELECT `From - To City`, COUNT(`From - To City`) FROM MAINDATA 
GROUP BY `From - To City` ORDER BY COUNT(`From - To City`) DESC LIMIT 10;

---------------------------------------------------------------------------------------------------------------------------------------------------
# 6) Identify the how much load factor is occupied on Weekend vs Weekdays.

SELECT WeekDay_VS_Weekend,SUM(Transported_Passengers),SUM(Available_Seats), 
(SUM(Transported_Passengers)/SUM(Available_Seats)*100) 
AS "Load_Factor" FROM MAINDATA GROUP BY WeekDay_VS_Weekend;

------------------------------------------------------------------------------------------------------------------------------------------------------
# 7) Identify number of flights based on Distance group

SELECT `Distance_Group_ID`, Count(`Departures_Performed`) AS No_of_flights
FROM MAINDATA
GROUP BY `Distance_Group_ID`
Order BY No_of_flights DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------
# 8) Use the filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City

CREATE VIEW Capability_To_Find_Flights AS
SELECT `Airline_ID`,`Datasource_ID`,`Region_Code`,`Carrier Name`,`Origin Country`,
`Destination Country`,`Origin State`,`Destination State`,`Origin City`,`Destination City`
FROM MAINDATA;
SELECT * FROM Capability_To_Find_Flights;



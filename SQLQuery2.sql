SELECT *
FROM road_accident;
-------------------------------------------------------------

SELECT 
SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
where YEAR(accident_date)='2022';
------------------------------------------------------------------
SELECT 
count (distinct accident_index) AS CY_Accident
FROM road_accident
where YEAR(accident_date)='2022';
-----------------------------------------------------------------------
SELECT 
SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM road_accident
where YEAR(accident_date)='2022' AND accident_severity='Fatal';

------------------------------------------------------------------------------
SELECT 
SUM(number_of_casualties) AS  Serious_Casualties
FROM road_accident
where YEAR(accident_date)='2022' AND accident_severity='Serious';
-------------------------------------------------------------------------------------

SELECT 
SUM(number_of_casualties) AS  Slight_Casualties
FROM road_accident
where YEAR(accident_date)='2022' AND accident_severity='Slight';

---------------------------------------------------------------------------------------------


SELECT 
CAST (SUM(number_of_casualties) AS decimal(10,2))/
(SELECT CAST (SUM(number_of_casualties) AS decimal(10,2) )FROM road_accident) *100
FROM road_accident
where accident_severity='Slight';
---------------------------------------------------------------------------------------------------------
SELECT 
CAST (SUM(number_of_casualties) AS decimal(10,2))/
(SELECT CAST (SUM(number_of_casualties) AS decimal(10,2) )FROM road_accident) *100
FROM road_accident
where accident_severity='Serious';

---------------------------------------------------------------------------------------------------------------------


SELECT 
CAST (SUM(number_of_casualties) AS decimal(10,2))/
(SELECT CAST (SUM(number_of_casualties) AS decimal(10,2) )FROM road_accident) *100
FROM road_accident
where accident_severity='Fatal';
--------------------------------------------------------------------------------------------------------------------------------

SELECT 
CASE WHEN vehicle_type in('Car','Taxi/Private hire car') THEN 'Car'
    WHEN vehicle_type in('Agricultural vehicle') THEN 'Agricultural'
	  WHEN vehicle_type in('Motorcycle 50cc and under','Motorcycle over 500cc','Motorcycle over 125cc and up to 500cc','Motorcycle 125cc and under') THEN 'Bike'
	   WHEN vehicle_type in('Minibus (8 - 16 passenger seats)','Bus or coach (17 or more pass seats)') THEN 'Bus'
	   WHEN vehicle_type in('Van / Goods 3.5 tonnes mgw or under','Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t') THEN 'Van'
	  ELSE  'Others'
	  END  AS vehicle_group,
	  SUM(number_of_casualties) CY_Casualties
FROM road_accident
WHERE  YEAR(accident_date)= '2022'
GROUP BY CASE WHEN vehicle_type in('Car','Taxi/Private hire car') THEN 'Car'
    WHEN vehicle_type in('Agricultural vehicle') THEN 'Agricultural'
	  WHEN vehicle_type in('Motorcycle 50cc and under','Motorcycle over 500cc','Motorcycle over 125cc and up to 500cc','Motorcycle 125cc and under') THEN 'Bike'
	  WHEN  vehicle_type in('Minibus (8 - 16 passenger seats)','Bus or coach (17 or more pass seats)') THEN 'Bus'
	  WHEN vehicle_type in('Van / Goods 3.5 tonnes mgw or under','Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t') THEN 'Van'
	  ELSE  'Others'
	  END;
	
----------------------------------------------------------------------------------------------------------------------------------------------------------



select 
DATENAME(MONTH,accident_date) AS Month_name,
SUM(number_of_casualties) AS CY_casualties
from road_accident
WHERE YEAR(accident_date)='2022'
GROUP BY DATENAME(MONTH,accident_date) ;

--------------------------------------------------------------------------------------------------------------------------------------------------------




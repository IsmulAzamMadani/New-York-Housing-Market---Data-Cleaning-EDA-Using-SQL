
--New York Housing Price

select *
from NYHouse

------------------------------------------------------------------------------------------------------------------

-- CLEANING DATASET

-- 1. Simplify BROKERTITLE COLUMN ------------------------------------------------------------------------------
-- Delete 'Brokered by ', 'BUY FOR ' and 'Built by ' substrings in BROKERTITLE Column

-- Querying solution
SELECT BROKERTITLE,
		REPLACE(REPLACE(REPLACE (BROKERTITLE,'Brokered by ', ''),'BUY FOR ',''),'Built by ','') AS NEW_BROKERTITLE
FROM NYHouse

-- Applying solution
ALTER TABLE NYHouse
Add BROKERTITLENEW Nvarchar(255)

UPDATE NYHouse
SET BROKERTITLENEW = REPLACE(REPLACE(REPLACE (BROKERTITLE,'Brokered by ', ''),'BUY FOR ',''),'Built by ','')
FROM NYHouse

-- 2. Simplify SUBLOCALITY -----------------------------------------------------------------------------------
-- group some values into a values

--Checking Values
SELECT DISTINCT(SUBLOCALITY)
FROM NYHouse

--Querying Solution
SELECT	DISTINCT(SUBLOCALITY),
(CASE	WHEN SUBLOCALITY = 'New York County' THEN 'Manhattan'
		WHEN SUBLOCALITY = 'New York' THEN 'Manhattan'
		WHEN SUBLOCALITY = 'Kings County' THEN 'Brooklyn'
		WHEN SUBLOCALITY = 'Brooklyn Heights' THEN 'Brooklyn'
		WHEN SUBLOCALITY = 'Bronx County' THEN 'The Bronx'
		WHEN SUBLOCALITY = 'Richmond County' THEN 'Staten Island'
		WHEN SUBLOCALITY = 'Queens County' THEN 'Queens'
		ELSE SUBLOCALITY
		END) AS BOROUGHS
FROM NYHouse

--Applying Solution
ALTER TABLE NYHouse
ADD BOROUGHS Nvarchar(255)

UPDATE NYHouse
SET BOROUGHS = CASE		WHEN SUBLOCALITY = 'New York County' THEN 'Manhattan'
						WHEN SUBLOCALITY = 'New York' THEN 'Manhattan'
						WHEN SUBLOCALITY = 'Kings County' THEN 'Brooklyn'
						WHEN SUBLOCALITY = 'Brooklyn Heights' THEN 'Brooklyn'
						WHEN SUBLOCALITY = 'Bronx County' THEN 'The Bronx'
						WHEN SUBLOCALITY = 'Richmond County' THEN 'Staten Island'
						WHEN SUBLOCALITY = 'Queens County' THEN 'Queens'
						ELSE SUBLOCALITY
						END
				FROM NYHouse

-- 3. Exclude boroughs that's not in New York City
--Checking values
SELECT BOROUGHS
FROM NYHouse
WHERE BOROUGHS NOT IN ('Manhattan','Queens','Brooklyn','Staten Island','The Bronx')

--Delete Values
DELETE FROM NYHouse
WHERE BOROUGHS NOT IN ('Manhattan','Queens','Brooklyn','Staten Island','The Bronx')

-- 4. Changing BATH Column Data Type to Int------------------------------------------------------------------

UPDATE NYHouse
SET BATH = CAST(BATH  AS INT)
	FROM NYHouse


-- 5. Simplify TYPE column..................................................................................
--querying solution
SELECT	DISTINCT([TYPE]),
		REPLACE([TYPE],' for sale','') as NEWTYPE
FROM NYHouse
--Applying solution
UPDATE NYHouse
SET [TYPE] = REPLACE([TYPE],' for sale','')

-- 6. Detecting and Deleting Duplicate Values
--Detecting Duplicate values using ROW_NUMBERS
--Any Row_Number > 1 is a duplicate values 
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY BROKERTITLENEW,
				 BOROUGHS,
				 PRICE,
				 BEDS,
				 BATH,
				 LATITUDE,
				 LONGITUDE
				 ORDER BY
					BROKERTITLENEW
					) row_num
From Projects.dbo.NYHouse
order by BROKERTITLENEW

--Showing Duplicate Values using CTE and ROW_NUMBERS
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY BROKERTITLENEW,
				 BOROUGHS,
				 PRICE,
				 BEDS,
				 BATH,
				 LATITUDE,
				 LONGITUDE
				 ORDER BY
					BROKERTITLENEW
					) row_num
From Projects.dbo.NYHouse

)
Select *
From RowNumCTE
Where row_num > 1
order by BROKERTITLENEW

--Deleting Duplicate Values using  DELETE, CTE and ROW_NUMBERS
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY BROKERTITLENEW,
				 BOROUGHS,
				 PRICE,
				 BEDS,
				 BATH,
				 LATITUDE,
				 LONGITUDE
				 ORDER BY
					BROKERTITLENEW
					) row_num
From Projects.dbo.NYHouse

)
DELETE
From RowNumCTE
Where row_num > 1

------------------------------------------------------------------------------------------------------------------


-- DATA EXPLORATION

-- 1. What is the distribution and average of house prices and wide scale by borough?
SELECT	BOROUGHS,
		COUNT(BOROUGHS) AS NumOfHouse,
		ROUND(AVG(PRICE),0) AS AvgBoroughsPrice,
		ROUND(AVG(PROPERTYSQFT),0) AS AvgSqft
FROM NYHouse
GROUP BY BOROUGHS
ORDER BY 3  DESC

-- 2. What is the distribution and average of house prices and wide scale by house type?
SELECT	[TYPE],
		COUNT([TYPE]) AS NumOfHouse,
		ROUND(AVG(PRICE),0) AS AvgTypePrice,
		ROUND(AVG(PROPERTYSQFT),0) AS AvgSqftPerType
FROM NYHouse
GROUP BY [TYPE]
ORDER BY 3  DESC

-- 3. What is the distribution and average price and wide scale of house types in each Borough?
SELECT	BOROUGHS, 
		[TYPE],
		COUNT(BOROUGHS) AS NumBoroughs,
		ROUND(AVG(PRICE),0) AS AvgTypePrice,
		ROUND(AVG(PROPERTYSQFT),0) AS AvgSqftPerType
FROM NYHouse
GROUP BY BOROUGHS,[TYPE]
ORDER BY 2 DESC ,4  DESC

-- 4. What is the distribution of house by house wide scale?

SELECT  
	CASE 
		WHEN PROPERTYSQFT >= 230 AND PROPERTYSQFT <1000 THEN '0-999'
		WHEN PROPERTYSQFT >= 1000 AND PROPERTYSQFT <2000 THEN '1000-1999'
		WHEN PROPERTYSQFT >= 2000 AND PROPERTYSQFT <3000 THEN '2000-2999'
		WHEN PROPERTYSQFT >= 3000 AND PROPERTYSQFT <4000 THEN '3000-3999'
		WHEN PROPERTYSQFT >= 4000 AND PROPERTYSQFT <5000 THEN '4000-4999'
		ELSE '5000-5999'
		END AS PropSqft,
	count(*) NumOfHouse,
	ROUND(AVG(PRICE),0) AS AvgPrice
FROM NYHouse
GROUP BY (CASE 
		WHEN PROPERTYSQFT >= 230 AND PROPERTYSQFT <1000 THEN '0-999'
		WHEN PROPERTYSQFT >= 1000 AND PROPERTYSQFT <2000 THEN '1000-1999'
		WHEN PROPERTYSQFT >= 2000 AND PROPERTYSQFT <3000 THEN '2000-2999'
		WHEN PROPERTYSQFT >= 3000 AND PROPERTYSQFT <4000 THEN '3000-3999'
		WHEN PROPERTYSQFT >= 4000 AND PROPERTYSQFT <5000 THEN '4000-4999'
		ELSE '5000-5999'
		END)
ORDER BY PropSqft

-- 5. Who is the most popular house broker in each borough?

SELECT	BROKERTITLENEW AS Broker,
		BOROUGHS,
		COUNT(BOROUGHS) NumOfHouse,
		PopularityRank = ROW_NUMBER() OVER (PARTITION BY BOROUGHS ORDER BY COUNT(BOROUGHS) DESC)
FROM NYHouse
GROUP BY BROKERTITLENEW, BOROUGHS
ORDER BY BOROUGHS, NumOfHouse DESC

--Extracting top 5 Rank of each borough
SELECT
    Broker,
    BOROUGHS,
    NumOfHouse,
    PopularityRank
FROM (
    SELECT
        BROKERTITLENEW AS Broker,
        BOROUGHS,
        COUNT(*) AS NumOfHouse,
        ROW_NUMBER() OVER (PARTITION BY BOROUGHS ORDER BY COUNT(*) DESC) AS PopularityRank
    FROM
        NYHouse
    GROUP BY
        BROKERTITLENEW, BOROUGHS
) AS RankedBrokers
WHERE
    PopularityRank < 6
ORDER BY
    BOROUGHS, NumOfHouse DESC;


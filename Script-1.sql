/*Data Cleaning */
/*------------------------------------------*/

SELECT * FROM Portfolio.Housing_Data ;

/*Convert SaleDate Format*/

SELECT SaleDate FROM Portfolio.Housing_Data ;

ALTER TABLE Portfolio.Housing_Data ADD COLUMN DateofSale DATE;

UPDATE Portfolio.Housing_Data 
SET DateofSale= STR_TO_DATE(SaleDate , '%d-%b-%y');

ALTER TABLE Portfolio.Housing_Data
DROP COLUMN SaleDate;

ALTER TABLE Portfolio.Housing_Data
MODIFY COLUMN DateofSale DATE AFTER PropertyAddress;

/*-----------------------------------------------*/

/*Property Address Data*/

SELECT * FROM Portfolio.Housing_Data WHERE  PropertyAddress = '' ;

SELECT * FROM Portfolio.Housing_Data order by ParcelID ;


SELECT a.`U-IDS`, a.ParcelID,a.PropertyAddress,b.`U-IDS` ,b.ParcelID,b.PropertyAddress,
 COALESCE(NULLIF(a.PropertyAddress, ''), b.PropertyAddress)FROM Portfolio.Housing_Data a JOIN
Portfolio.Housing_Data b on a.ParcelID = b.ParcelID AND a.`U-IDS`<> b.`U-IDS` 
WHERE a.PropertyAddress = '' ;


UPDATE Portfolio.Housing_Data a
JOIN Portfolio.Housing_Data b 
    ON a.ParcelID = b.ParcelID 
    AND a.`U-IDS` <> b.`U-IDS`
SET a.PropertyAddress = COALESCE(NULLIF(a.PropertyAddress, ''), b.PropertyAddress)
WHERE a.PropertyAddress = '';


/*-----------------------------------------------*/

/*Splitting Address  */


SELECT PropertyAddress FROM  Portfolio.Housing_Data 

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) AS Address
FROM 
    Portfolio.Housing_Data;
   

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) AS Address,
    SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress) +1,LENGTH(PropertyAddress) ) AS Address
    FROM Portfolio.Housing_Data;

   /*Adding address column to table */
   
ALTER TABLE Portfolio.Housing_Data ADD COLUMN PropertyAddressExtracted NVARCHAR(255);

UPDATE Portfolio.Housing_Data 
SET PropertyAddressExtracted= SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );

  /*Adding city column to table */
ALTER TABLE Portfolio.Housing_Data ADD COLUMN City NVARCHAR(255);

UPDATE Portfolio.Housing_Data 
SET City =  SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress) +1,LENGTH(PropertyAddress) );

SELECT * FROM Portfolio.Housing_Data hd ;

/*-------------------------------------------------*/

/*Moving on to Owner Address*/


SELECT OwnerAddress FROM  Portfolio.Housing_Data 


SELECT SUBSTRING_INDEX(OwnerAddress ,',', 1),SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress , ',', 2), ',', -1) ,
SUBSTRING_INDEX(OwnerAddress ,',', -1)
FROM Portfolio.Housing_Data  ;



ALTER TABLE Portfolio.Housing_Data ADD COLUMN OwnerAddressExtracted NVARCHAR(255);

UPDATE Portfolio.Housing_Data 
SET OwnerAddressExtracted= SUBSTRING_INDEX(OwnerAddress ,',', 1);

  /*Adding city column to table */
ALTER TABLE Portfolio.Housing_Data ADD COLUMN OwnerCity NVARCHAR(255);

UPDATE Portfolio.Housing_Data 
SET OwnerCity =  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress , ',', 2), ',', -1);

ALTER TABLE Portfolio.Housing_Data ADD COLUMN OwnerState NVARCHAR(255);

UPDATE Portfolio.Housing_Data 
SET OwnerState =  SUBSTRING_INDEX(OwnerAddress ,',', -1);

SELECT * FROM  Portfolio.Housing_Data ;

/*-------------------------------------------------*/

/*Change to Yes/No in SoldAsVacant*/

SELECT DISTINCT(SoldAsVacant) FROM  Portfolio.Housing_Data ;

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) FROM  Portfolio.Housing_Data 
 group by SoldAsVacant ;


SELECT SoldAsVacant, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant
END
FROM  Portfolio.Housing_Data ;


UPDATE Portfolio.Housing_Data SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant
END;


/*-------------------------------------------------*/

/*Removing Duplicate Rows*/

SELECT * FROM portfolio.Housing_Data;

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, ` SalesPrices` , DateofSale, LegalReference
           ORDER BY `U-IDS` 
       ) AS Row_num
FROM Portfolio.Housing_Data
ORDER BY ParcelID ;


WITH RowCTE AS(

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, ` SalesPrices` , DateofSale, LegalReference
           ORDER BY `U-IDS` 
       ) AS Row_num
FROM Portfolio.Housing_Data
)

SELECT * FROM  RowCTE WHERE Row_num >1 ORDER by DateofSale;

/*Deleting Duplicates*/


WITH RowCTE AS (
    SELECT `U-IDS`,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress,` SalesPrices`, DateofSale, LegalReference
               ORDER BY `U-IDS` 
           ) AS Row_num
    FROM Portfolio.Housing_Data
)
DELETE FROM Portfolio.Housing_Data
WHERE `U-IDS` IN (
    SELECT `U-IDS`
    FROM RowCTE
    WHERE Row_num > 1
);


/*-------------------------------------------------*/

/*Removing Unused Columns*/


SELECT * FROM portfolio.Housing_Data;

ALTER TABLE portfolio.Housing_Data
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict;











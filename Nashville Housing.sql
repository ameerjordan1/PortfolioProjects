/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM `Portfolio Project`.NashvilleHousing;


-- ---------------------------------------------------------------------------------------------

-- Standardize Date Format 

SELECT SaleDateConverted, CONVERT(SaleDate, date)
FROM `Portfolio Project`.NashvilleHousing;


UPDATE NashvilleHousing
SET SaleDate = Convert(SaleDate, date);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate, date);



-- ---------------------------------------------------------------------------------------------

-- Populate Property Address date

SELECT *
FROM `Portfolio Project`.NashvilleHousing
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `Portfolio Project`.NashvilleHousing a
JOIN `Portfolio Project`.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE `Portfolio Project`.NashvilleHousing a
JOIN `Portfolio Project`.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress is NULL
	AND b.PropertyAddress is NOT NULL;



-- ---------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State) 


SELECT PropertyAddress
FROM `Portfolio Project`.NashvilleHousing;
-- WHERE PropertyAddress is NULL
-- ORDER BY ParcelID;


SELECT 
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 ) AS Address
, SUBSTRING(PropertyAddress,  INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress)) AS Address


FROM `Portfolio Project`.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 ) ;

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress,  INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress)) ;

SELECT * 
FROM `Portfolio Project`.NashvilleHousing;


SELECT OwnerAddress
FROM `Portfolio Project`.NashvilleHousing;


SELECT 
TRIM(SUBSTRING_INDEX(OwnerAddress,',', 1)) ,
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
TRIM(SUBSTRING_INDEX(OwnerAddress,',', -1)) 
FROM `Portfolio Project`.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress,',', 1));

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity =  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) ;


ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress,',', -1))  ;


SELECT * 
FROM `Portfolio Project`.NashvilleHousing;






-- ---------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Solid as Vacant" field


SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
From `Portfolio Project`.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM `Portfolio Project`.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;


-- ---------------------------------------------------------------------------------------------


-- Remove Duplicates 


-- MySQL doesn't support DELETE directly from a CTE 
-- Used this query to identify the duplicates

WITH RowNumCTE AS(
SELECT * ,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
			PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY
				UniqueID
                ) row_num


FROM `Portfolio Project`.NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

-- New query to support the DELTE function in SQL. Create a subquery to identify duplicates

DELETE nh
FROM `Portfolio Project`.NashvilleHousing nh
JOIN (
  SELECT 
    MIN(UniqueID) AS keep_id,
    ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
  FROM `Portfolio Project`.NashvilleHousing
  GROUP BY 
    ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
) AS duplicates
  ON nh.ParcelID = duplicates.ParcelID
  AND nh.PropertyAddress = duplicates.PropertyAddress
  AND nh.SalePrice = duplicates.SalePrice
  AND nh.SaleDate = duplicates.SaleDate
  AND nh.LegalReference = duplicates.LegalReference
  AND nh.UniqueID <> duplicates.keep_id;




SELECT * 
FROM `Portfolio Project`.NashvilleHousing;


-- ---------------------------------------------------------------------------------------------


-- Delete Unused Columns 


SELECT * 
FROM `Portfolio Project`.NashvilleHousing;

ALTER TABLE `Portfolio Project`.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;

ALTER TABLE `Portfolio Project`.NashvilleHousing
DROP COLUMN SaleDate;




-- ---------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------

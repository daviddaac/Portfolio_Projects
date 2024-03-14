/* 

Cleaning Data Process

*/

SELECT *

FROM 
  PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
  SaleDate, CONVERT(date, SaleDate)

FROM
  PortfolioProject..NashvilleHousing

-- Update column SaleDate with date format instade datetime

ALTER TABLE  PortfolioProject..NashvilleHousing
ADD  SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing

SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT 
  SaleDateConverted
FROM 
  PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

/*

In this data base  if the ParcelID  are the same, they will have the same PropertyAddress.
Then we will fill up the null values with in the PropertyAddress that have the same ParcelID.

We are going to join the table with itself to be able to visualize a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
and we can be fill up the null values. Watchout to avoid that UniqueID be diferent. 

*/

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/* Now we will update the vaues in the column */

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
  PropertyAddress,
  SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
  SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, CHARINDEX(',',PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress VARCHAR (225)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity  VARCHAR (225)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, CHARINDEX(',',PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing

/* Use of PARSENAME() for split a text sepatae by . */
SELECT OwnerAddress

FROM PortfolioProject..NashvilleHousing

SELECT
  OwnerAddress,
  PARSENAME(REPLACE(OwnerAddress,',','.'),3),
  PARSENAME(REPLACE(OwnerAddress,',','.'),2),
  PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnersSplitAddress VARCHAR (225)

UPDATE PortfolioProject..NashvilleHousing
SET OwnersSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnersSplitCity  VARCHAR (225)

UPDATE PortfolioProject..NashvilleHousing
SET OwnersSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnersSplitState VARCHAR (225)

UPDATE PortfolioProject..NashvilleHousing
SET OwnersSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT * 
FROM PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
  SoldAsVacant,
  CASE 
    WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant 
	END
FROM PortfolioProject..NashvilleHousing

 UPDATE PortfolioProject..NashvilleHousing
 SET SoldAsVacant =   
    CASE 
    WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant 
	END



-------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate

WITH RowNumCTE AS(
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID                  
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

/*
Now we will delete the duplicate rows
*/

WITH RowNumCTE AS(
  SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID                  
)
DELETE
FROM RowNumCTE
WHERE row_num >1


-------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate





-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

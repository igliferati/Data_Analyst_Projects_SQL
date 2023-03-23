/* Cleaning Data in SQL Queries | Data Cleaning Project */

Select *
From [Nashville Housing].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

/* Standardize Date Format */

Select SaleDate, CONVERT(date,SaleDate)
From [Nashville Housing].dbo.NashvilleHousing -- SaleDate must be in shorter way so we convert it below in a new column

Update NashvilleHousing
SET Saledate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From [Nashville Housing].dbo.NashvilleHousing -- We can see that now the column is converted

--------------------------------------------------------------------------------------------------------------------------

/* Populate Property Address data */

Select *
From [Nashville Housing].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

/* With code below we will fill NULL at A Property Address from B Property Address */

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.NashvilleHousing a -- We will create a SELF JOIN to look at equal rows between columns
JOIN [Nashville Housing].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

/* Update the table to display the addresses instead of NULL */

UPDATE a -- We will use the specific table since we are doing a SELF JOIN to update rows
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.NashvilleHousing a 
JOIN [Nashville Housing].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

/* Breaking out Address into Individual Columns (Address, City, State) */
-- We will seperate in 2 different columns the city from the address

Select PropertyAddress
From [Nashville Housing].dbo.NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City -- We use SUBSTRING to seperate address from city and CHARINDEX to set after what character we will do it
FROM [Nashville Housing].dbo.NashvilleHousing

-- We proceed with changes on table to update them 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from [Nashville Housing].dbo.NashvilleHousing

-- We will use PARSENAME this time to seperate in 23 columns the data, instead of SUBSTRING. We will replace ',' with '.' so the function PARSENAME can read it and make the seperation.

Select 
PARSENAME(REPLACE(OwnerAddress,',' , ' .'),3),
PARSENAME(REPLACE(OwnerAddress,',' , ' .'),2),
PARSENAME(REPLACE(OwnerAddress,',' , ' .'),1)
from [Nashville Housing].dbo.NashvilleHousing

ALTER TABLE [Nashville Housing].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , ' .'),3)

ALTER TABLE [Nashville Housing].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , ' .'),2)

ALTER TABLE [Nashville Housing].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , ' .'),1)

-- we verify that we added the new columns
Select *
from [Nashville Housing].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM [Nashville Housing].dbo.NashvilleHousing

UPDATE NashvilleHousing  -- We use UPDATE directly since we are not creatin a new table, but modifying the existing one.
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM [Nashville Housing].dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- We create a temporary table to identify only the duplicated values, then we perform a delete action under that to remove duplicated. 

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (               -- We will use ROW_NUMBER to identify same values on table. 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
						) row_num
FROM [Nashville Housing].dbo.NashvilleHousing
)
SELECT *  -- We used DELETE function before SELECT to delete duplicated
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM [Nashville Housing].dbo.NashvilleHousing

ALTER TABLE [Nashville Housing].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing].dbo.NashvilleHousing
DROP COLUMN SaleDate

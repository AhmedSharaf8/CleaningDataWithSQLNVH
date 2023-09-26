--Show the data
SELECT *
FROM dbo.NVHousing

--Standrize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) AS StandrizedDate
FROM dbo.NVHousing

UPDATE NVHousing
SET SaleDate = CONVERT(Date, SaleDate)


--The previous query didn't work so we are going to add a new column and then set the values to the new format
ALTER TABLE NVHousing
ADD SaleDateConverted Date;

UPDATE NVHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
FROM dbo.NVHousing

--Populate Property Address data
SELECT *
FROM dbo.NVHousing
--WHERE PropertyAddress IS NULL
ORDER BY parcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NVHousing AS a
JOIN dbo.NVHousing AS b ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NVHousing AS a
JOIN dbo.NVHousing AS b ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]

--Breaking out Address Into Indiviaual Columns (Address, City, State)
SELECT PropertyAddress
FROM dbo.NVHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.NVHousing

ALTER TABLE NVHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NVHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NVHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NVHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * FROM NVHousing

--Another way to seperate the address used on the owner address
SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM NVHousing

ALTER TABLE NVHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NVHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NVHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NVHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NVHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NVHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--Change Y and N to Yes and No on SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NVHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM dbo.NVHousing

UPDATE NVHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, legalReference 
		ORDER BY UniqueID
		) Row_num
FROM dbo.NVHousing
)

--SELECT *
DELETE
FROM RowNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress

--Delete Unused Columns
ALTER TABLE dbo.NVHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * FROM dbo.NVHousing
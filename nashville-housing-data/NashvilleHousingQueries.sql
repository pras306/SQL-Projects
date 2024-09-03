USE PortfolioProject
GO

/*

CLEANING DATA IN SQL

*/

SELECT *
FROM NashvilleHousing

/*

UPDATE TABLE TO STORE NEW COLUMN TO STORE DATE OF SALE ALONE

*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing

/*

POPULATE PROPERT ADDRESS DATA

*/

-- STEP 1: GET DATA WHERE PROPERTY ADDRESS IS NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- STEP 2: CHECK IF THERE ARE OTHER ADDRESSES WITH SAME ParcelID's

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- STEP 3: UPDATE THE ADDRESS WHERE EVER THERE IS A NULL IF THE PARCEL ID HAS ANOTHER ADDRESS LINKED WITH IT

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/*

BREAK ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)

*/

-- STEP 1: GET SUBSTRING OF PROPERTY ADDRESS SPLIT BY COMMAS

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS State
FROM NashvilleHousing

-- STEP 2: ADD COLUMNS FOR ADDRESS AND CITY

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

-- STEP 3: SPLIT THE PROPERTY ADDRESS COLUMN AND UPDATE DATE INTO THE RESPECTIVE COLUMNS

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



-- STEP 4: REPEAT THE SAME FOR OWNER ADDRESS (SAME CAN BE DONE USING PARSENAME)

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


/*

CHANGE Y AND N TO YES AND NO IN COLUMNS

*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



/*

REMOVE DUPLICATES

*/

WITH RowNumCTE AS 
(
	SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
	) row_number
	FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_number > 1
ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_number > 1


/*

DELETE UNUSED COLUMNS

*/

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

SELECT * 
FROM NashvilleHousing
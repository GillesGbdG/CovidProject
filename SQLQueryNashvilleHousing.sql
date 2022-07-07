
/*CLEANING DATA IN SQL QUERIES */
select*
From NashvilleHousing

/* personal note: hard refresh= Ctrl+Shift+R */

-- STANDARDIZE DATE FORMAT

select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing


/*Create new Column named SaleDateConverted, with date as type */

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

/*insert the converted SaleDate values into the new column*/

UPDATE Nashvillehousing
SET SaleDateConverted = CONVERT( Date, SaleDate)

Select SaleDate, SaleDateConverted
From NashvilleHousing

-------------------------------------------------------------------

--Populate property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

/*Join the table to itself and populate the Propertyaddress column with null values by replacing the null values with the address in the rows, which have the same parcelID but different unique ID*/

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

/*Replacing the NULL values in the b.propertyAddress with the a.propertyAddress column*/

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ] 
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns( Address, City, State)


Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

/* Search for the first value in the PropertyAddress column up to the first comma*/

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address
From NashvilleHousing

-- delete the comma
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address
From NashvilleHousing

--
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as CityName
From NashvilleHousing

-- Create the split address columns

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-----------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO in Sold as vacant field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
 Case When SoldAsVacant ='Y' THEN 'Yes'
      When SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
	  End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant ='Y' THEN 'Yes'
      When SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
	  End

------------------------------------------------------------------------------------

-- Remove Duplicates

WITH  RowNumCTE As(
Select *,
     ROW_NUMBER() over (
	 PARTITION BY ParcelID,
	 PropertyAddress,
	 SalePrice,
	 SaleDate,
	 LegalReference
	 Order BY
	   UniqueID
	   ) row_num
From NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1
Order by PropertyAddress

--------------------------------------------------------------------------------------

-- Delete Unused Columns 


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

Select*
From NashvilleHousing



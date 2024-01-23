/*

Cleaning Data in SQL Quesries 

 THE MAIN PURPOSE OF THIS PROJECT IS TO CLEAN THE DATA AND MAKE IT MORE USEFUL.

-------------------------------------------------------------------------------------------------------------------

*/

select * 
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------


-- Standardize SaleDate Format


select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




-------------------------------------------------------------------------------------------------------------------


-- Population Property Address Data


select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddress
From PortfolioProject.dbo.NashvilleHousing  a
join PortfolioProject.dbo.NashvilleHousing  b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing  a
join PortfolioProject.dbo.NashvilleHousing  b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]

  -- Checking if its updating or not

select * 
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null




-------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual	Columns (Address, City, States)

-- Using Char Index & SUBSTRING


select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID


-- Here the charindex is specifying the position of the (,) and by putting -1, it elases one step back from the position. 
-- Since we removed the (,) in first statement, second one adds the remaining address or characters from the total length of the column(PropertyAddress) in separate Column.
-- we will make Alter Table and combine both tables.
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address

From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- Using Replace command to replace ',' with '.' and using parse instead of Substring, adding columns and combining them.

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing




-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field


select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
  Case 
       When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
  Else SoldAsVacant
End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =   Case 
       When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
  Else SoldAsVacant
End





-------------------------------------------------------------------------------------------------------------------

-- Removing Dublicates
-- Checking number of rows that are dublicate using CTE

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) Row_Num
from NashvilleHousing
--Order by ParcelID
)
--DELETE                                                                   -- (USED TO DELETE DUBLICATES)
Select *
From RowNumCTE
where Row_Num > 1
order by PropertyAddress



-------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from NashvilleHousing


Alter Table NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

Alter Table NashvilleHousing
DROP COLUMN SaleDate
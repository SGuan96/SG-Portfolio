/*

Cleaning Data in SQL Queries

*/

Select * 
From [Portfolio Project]..NHousing 

-- Standardize Date Format

Select SaleDateConverted, convert(Date,SaleDate)
from [Portfolio Project]..NHousing

Update [Portfolio Project]..NHousing
Set SaleDate = Convert(Date,SaleDate)

alter table [Portfolio Project]..NHousing
add SaleDateConverted Date; 

Update [Portfolio Project]..NHousing
Set SaleDateConverted = Convert(Date,SaleDate)

----
--Populate Property Address data

Select *
from [Portfolio Project]..NHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NHousing a
join [Portfolio Project]..NHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NHousing a
join [Portfolio Project]..NHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from [Portfolio Project]..NHousing
--Where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address

from [Portfolio Project]..NHousing

alter table [Portfolio Project]..NHousing
add PropertySplitAddress Nvarchar(255); 

Update [Portfolio Project]..NHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [Portfolio Project]..NHousing
add PropertySplitCity Nvarchar(255); 

Update [Portfolio Project]..NHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
from [Portfolio Project]..NHousing




Select OwnerAddress
from [Portfolio Project]..NHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from [Portfolio Project]..NHousing


alter table [Portfolio Project]..NHousing
add OwnerSplitAddress Nvarchar(255); 

Update [Portfolio Project]..NHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table [Portfolio Project]..NHousing
add OwnerSplitCity Nvarchar(255); 

Update [Portfolio Project]..NHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table [Portfolio Project]..NHousing
add OwnerSplitState Nvarchar(255); 

Update [Portfolio Project]..NHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--note, should add all columns first, then update and execute all at once

Select *
from [Portfolio Project]..NHousing

--

--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
from [Portfolio Project]..NHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Portfolio Project]..NHousing

Update [Portfolio Project]..NHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Portfolio Project]..NHousing

--
--Remove Duplicates

with RowNumCTE as(
Select *,
ROW_NUMBER() over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by
				UniqueID) row_num


from [Portfolio Project]..NHousing)
--order by ParcelID


Select *
from RowNumCTE
where row_num> 1
--note: Delete from RowNumCTE before Select to alter table



-- Delete Unused Columns


Select *
from [Portfolio Project]..NHousing

Alter table [Portfolio Project]..NHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table [Portfolio Project]..NHousing
drop column SaleDate

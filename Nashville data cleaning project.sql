/*
Data Cleaning
*/

select * 
from PortfolioProject.dbo.NashvilleHousing

----standardising date format----

select saledate
from PortfolioProject.dbo.NashvilleHousing 

select SaleDate, convert(date, saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, saledate)

alter table nashvillehousing
add SaleDateconverted date

update NashvilleHousing
set SaleDateconverted = convert(date, saledate)

select saledateconverted
from PortfolioProject.dbo.NashvilleHousing 


----populating the null values in the property address---

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

--parcelID is unique for each address so we can copy the address from parcelID where it is mentioned

select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b  --self join to see where and what value is missing and to compare if can get the missing address from different unique ID and same the parcelID.
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) --we can use isnull to use the data from b.propertyAdress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b  
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b  --self join to see where and what value is missing
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----Breaking address into individual columns(street, city, state)------

-- Breaking PropertyAddress
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)) as address
from PortfolioProject.dbo.NashvilleHousing

select 
CHARINDEX(',', propertyaddress) --to get the index of the string that we are searching
from PortfolioProject.dbo.NashvilleHousing

select 
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as address --to remove the , from the output we use -1 
from PortfolioProject.dbo.NashvilleHousing

Select 
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
substring(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyAddress)) as address
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousing
set propertySplitAddress = substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

Alter table NashvilleHousing
add PropertySplitCity NVARCHAR(255)

Update NashvilleHousing
set propertySplitCity = substring(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyAddress))

Select propertyaddress, propertysplitaddress, propertysplitcity
from PortfolioProject.dbo.NashvilleHousing

-- Breaking OwnerAddress

select ownerAddress
from PortfolioProject.dbo.NashvilleHousing

select PARSENAME(owneraddress,1)  --by default it uses '.' as delimiter
from PortfolioProject.dbo.NashvilleHousing

--select replace(owneraddress, ',', '!')
--from PortfolioProject.dbo.NashvilleHousing


select PARSENAME(replace(owneraddress, ',', '.'),1)  --1 gives the last splited value
from PortfolioProject.dbo.NashvilleHousing

select PARSENAME(replace(owneraddress, ',', '.'),3), 
PARSENAME(replace(owneraddress, ',', '.'),2), 
PARSENAME(replace(owneraddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnersplitAddress NVARCHAR(255)

update NashvilleHousing
set OwnersplitAddress = PARSENAME(replace(owneraddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity NVARCHAR(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitstate NVARCHAR(255)

update NashvilleHousing
set OwnerSplitstate = PARSENAME(replace(owneraddress, ',', '.'),1)

Select *
from PortfolioProject.dbo.NashvilleHousing

-------- change Y and N with Yes and No in "soldasVacant" ------------

select distinct Soldasvacant, count(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by soldasvacant
order by 2


select Soldasvacant,
case when soldasvacant = 'N' then 'No'
	 When soldasvacant = 'Y' then 'Yes'
	 Else soldasvacant
End
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when soldasvacant = 'N' then 'No'
	 When soldasvacant = 'Y' then 'Yes'
	 Else soldasvacant
End
from PortfolioProject.dbo.NashvilleHousing


----Remove Duplicate------


select *,
	row_number() over(
	Partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 Legalreference
				 order by UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
order by parcelID
--we have created a row in the last column which signifies how many repetions are there


with rownumCTE As(
select *,
	row_number() over(
	Partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 Legalreference
				 order by UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select * 
from rownumCTE
where row_num >1 --if more than 1 then its duplicate


with rownumCTE As(
select *,
	row_number() over(
	Partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 Legalreference
				 order by UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete   --just replaced select with delete to delete these duplicate
from rownumCTE
where row_num >1 

------------------------------------------
---delete unused column-----

select *
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, saledate, ownerAddress, TaxDistrict
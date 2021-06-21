SELECT *
FROM Portifolio_Project..Nashville_Housing

--Standardized date format
SELECT Sale_date_converted, CONVERT(Date, saledate) 
FROM Portifolio_Project..Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,saledate)

ALTER TABLE Nashville_Housing
Add sale_date_converted Date;

Update Nashville_Housing 
SET Sale_date_converted = CONVERT(Date,SaleDate)

-- Populate property adress data

SELECT *
FROM Portifolio_Project..Nashville_Housing

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portifolio_Project..Nashville_Housing AS a
JOIN Portifolio_Project..Nashville_Housing AS b
 ON  a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE  a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portifolio_Project..Nashville_Housing AS a
JOIN Portifolio_Project..Nashville_Housing AS b
 ON  a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE  a.PropertyAddress IS NULL

-- Breaking out adress into individual columns (Adress, City, state)

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(Propertyaddress)) AS Address
FROM Portifolio_Project..Nashville_Housing

ALTER TABLE Nashville_Housing
Add Property_Split_Address nvarchar(255);

Update Nashville_Housing 
SET Property_Split_Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing
Add Property_Split_City nvarchar(255);

Update Nashville_Housing 
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(Propertyaddress))

SELECT *
FROM Portifolio_Project..Nashville_Housing

Select OwnerAddress
From [portifolio_Project]..Nashville_Housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portifolio_Project.dbo.Nashville_Housing



ALTER TABLE Nashville_Housing
Add Owner_Split_Address Nvarchar(255);

Update Nashville_Housing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing
Add Owner_Split_City Nvarchar(255);

Update Nashville_Housing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_Housing
Add Owner_Split_State Nvarchar(255);

Update Nashville_Housing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Portifolio_Project..Nashville_Housing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(Soldasvacant)
FROM Portifolio_Project..Nashville_Housing

SELECT SoldAsVacant
, CASE WHEN Soldasvacant= 'Y' THEN 'Yes'
  WHEN Soldasvacant= 'N' THEN 'No'
  ELSE Soldasvacant
  END
FROM Portifolio_Project..Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN Soldasvacant= 'Y' THEN 'Yes'
  WHEN Soldasvacant= 'N' THEN 'No'
  ELSE Soldasvacant
  END

-- Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portifolio_Project.dbo.Nashville_Housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns



Select *
From Portifolio_Project.dbo.Nashville_Housing


ALTER TABLE Portifolio_Project.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

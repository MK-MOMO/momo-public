@AbapCatalog.sqlViewName: 'ZTESTKCDS17'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW17'
define view ZTESTK_CDS17 as select from I_Material
{
key Material,
MaterialType,
MaterialGroup,
MaterialBaseUnit,
MaterialGrossWeight,
MaterialNetWeight,
MaterialWeightUnit,
MaterialManufacturerNumber,
MaterialManufacturerPartNumber,
AuthorizationGroup,
IsBatchManagementRequired,
CrossPlantConfigurableProduct,
ProductCategory,
ProductCharacteristic1,
ProductCharacteristic2,
ProductCharacteristic3,
ProdCharc1InternalNumber,
ProdCharc2InternalNumber,
ProdCharc3InternalNumber,
/* Associations */
_BaseUnit,
_MaterialGroup,
_MaterialPlant,
_MaterialType,
_Text,
_WeightUnit    
}

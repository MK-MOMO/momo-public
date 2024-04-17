@AbapCatalog.sqlViewName: 'ZTESTK_CSD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW02'
define view ZTESTK_CSD01 as select from mara
// Joins, associations
{
  key matnr
}
// where condition

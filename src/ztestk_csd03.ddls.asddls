@AbapCatalog.sqlViewName: 'ZTESTK_MK003'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW03'
define view ZTESTK_CSD03 as select from ZTESTK_CSD02(p_vbeln:'0000000001',p_posnr:'000010')
{
    key vbeln,
    key posnr,
    matnr
}

@AbapCatalog.sqlViewName: 'ZTESTK_MK002'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW02'
define view ZTESTK_CSD02
    with parameters p_vbeln : vbeln, p_posnr : posnr
as select from vbap
{
    key vbeln,
    key posnr,
        matnr    
}where vbeln = :p_vbeln
   and posnr = :p_posnr

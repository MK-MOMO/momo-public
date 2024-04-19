@AbapCatalog.sqlViewName: 'ZTESTKCDS02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW02'
//パラメータ＆WHERE条件の定義
define view ZTESTK_CDS02
    with parameters p_vbeln : vbeln, p_posnr : posnr
as select from vbap
{
    key vbeln,
    key posnr,
        matnr,
        erdat    
}where vbeln = :p_vbeln
   and posnr = :p_posnr

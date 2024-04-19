@AbapCatalog.sqlViewName: 'ZTESTKCDS06'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW06'
define view ZTESTK_CDS06
with parameters p_vbeln : vbeln
as select from ZTESTK_CDS02(p_vbeln: $parameters.p_vbeln ,p_posnr:'000010')
//パラメータの応用
 {
    key vbeln,
    key posnr,
    ltrim(matnr,'0') as matnr,
    erdat
}

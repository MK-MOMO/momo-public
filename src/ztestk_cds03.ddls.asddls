@AbapCatalog.sqlViewName: 'ZTESTKCDS03'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW03'
//別のCDSVIEWの参照とパラメータを事前に設定
define view ZTESTK_CDS03 as select from ZTESTK_CDS02(p_vbeln:'0000000001',p_posnr:'000010')
{
    key vbeln,
    key posnr,
    matnr
}

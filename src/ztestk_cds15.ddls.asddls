@AbapCatalog.sqlViewName: 'ZTESTKCDS15'
// COMPOSITEビュー
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #CUBE
//
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW15'
define view ZTESTK_CDS15 as select from ZTESTK_CDS14 as _vbak
association[1..1] to ZTESTK_CDS13 as _mara on _mara.matnr = _vbak.matnr
association[1..1] to ZTESTK_CDS12 as _kna1 on _kna1.kunnr = _vbak.kunnr
{
key _vbak.vbeln,
_vbak.posnr,
_vbak.kunnr,
_vbak.matnr,
// association public
 _kna1,
 _mara
}

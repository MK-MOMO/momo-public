@AbapCatalog.sqlViewName: 'ZTESTKCDS14'
// マスタ参照のBASICビュー
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
//
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW14'
define view ZTESTK_CDS14 as select from vbak as _vbak
                                   inner join vbap as _vbap
                                      on _vbap.vbeln = _vbak.vbeln
{
 key _vbak.vbeln,
     _vbap.posnr,
     _vbak.kunnr,
     _vbap.matnr
}

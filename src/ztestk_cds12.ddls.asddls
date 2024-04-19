@AbapCatalog.sqlViewName: 'ZTESTKCDS12'
// マスタ参照のBASICビュー
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
//
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW12'
define view ZTESTK_CDS12 as select from kna1 {
key kunnr,
    name1,
    land1
}

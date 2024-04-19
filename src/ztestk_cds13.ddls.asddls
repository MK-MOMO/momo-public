@AbapCatalog.sqlViewName: 'ZTESTKCDS13'
// マスタ参照のBASICビュー
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
//
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW13'
define view ZTESTK_CDS13 as select from mara as _mara 
                             inner join makt as _makt
                                on _makt.matnr = _mara.matnr
                               and _makt.spras = 'J'                       
{
key _mara.matnr as matnr,
    _mara.mtart as mtart,
    _makt.maktx as maktx
}

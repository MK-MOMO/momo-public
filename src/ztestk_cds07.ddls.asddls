@AbapCatalog.sqlViewName: 'ZTESTKCDS07'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW07'
define view ZTESTK_CDS07 as select from vbak as _VBAK
inner join vbap as _vbap
        on _VBAK.vbeln = _vbap.vbeln 
left outer join I_Material as _mara
        on _mara.Material = _vbap.matnr
//CDSVIEWの結合
{
    _VBAK.vbeln,
    _vbap.posnr,
    _VBAK.auart,
    _vbap.matnr,
    _mara.Material 
    
}

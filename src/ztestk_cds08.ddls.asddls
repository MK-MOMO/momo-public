@AbapCatalog.sqlViewName: 'ZTESTKCDS08'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW08'
// association定義
define view ZTESTK_CDS08 as select from vbak as _vbak
inner join vbap as _vbap
        on _vbap.vbeln = _vbak.vbeln
association [1..*] to vbpa as _vbpa
         on _vbpa.vbeln = _vbak.vbeln
        and _vbpa.posnr = '000000'        
association [1..1] to I_Material as _mara
         on _mara.Material = _vbap.matnr
association [1..1] to mara as _mara2
         on _mara2.matnr = _vbap.matnr

{
    key _vbak.vbeln,
        _vbak.auart,
        _vbap.posnr,
        _vbap.matnr,

//    _vbap.posnr,
//    _vbap.matnr,
//    _mara.Material
// Assocation as public
   _mara,
   _vbpa,
   _mara2
}

@AbapCatalog.sqlViewName: 'ZTESTKCDS18'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW18'
define view ZTESTK_CDS18 as select from vbap as _VBAP
association [1..1] to I_Material as _mara
         on _mara.Material = _VBAP.matnr
{
  key _VBAP.vbeln,
  key _VBAP.posnr,
      _VBAP.matnr,
  _mara.Material,
  _mara
    
}

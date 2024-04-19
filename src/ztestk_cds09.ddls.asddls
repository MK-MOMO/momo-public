@AbapCatalog.sqlViewName: 'ZTESTKCDS09'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW09'
//associationの内部結合と外部結合
define view ZTESTK_CDS09 as select from ZTESTK_CDS08
{
     key vbeln,
     auart,
     posnr,
     matnr,
     /* Associations */
     _mara[inner].MaterialGroup,
     _vbpa.kunnr
}

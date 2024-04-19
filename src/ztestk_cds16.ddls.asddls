@AbapCatalog.sqlViewName: 'ZTESTKCDS16'
// CONSUMPTIONビュー ODATA true
@VDM.viewType: #CONSUMPTION
@OData.publish: true
//
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW16'
define view ZTESTK_CDS16 as select from ZTESTK_CDS15 {
key vbeln,
posnr,
kunnr,
matnr,
/* Associations */
_kna1,
_mara    
}

@AbapCatalog.sqlViewName: 'ZTESTKCDS05'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW05'
//システム変数参照方法　$session.
define view ZTESTK_CDS05 as select from vbap {
  key vbeln,
  key posnr,
      matnr
}where mandt = $session.client
   and erdat < $session.system_date

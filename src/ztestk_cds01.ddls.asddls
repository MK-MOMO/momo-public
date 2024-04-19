@AbapCatalog.sqlViewName: 'ZTESTKCDS01'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW01'
//CDSVIEWの基本定義
define view ZTESTK_CDS01 as select from mara
// Joins, associations
{
  key matnr,
 //   trim 
      ltrim(matnr,'0') as trim_matnr,

 //   case
      case mtart
      when 'FERT' then '製品'
      else 'その他'
      end as case_mtart,

//    計算
      ( brgew - 1 ) as BRGEW 
  
}
// where condition

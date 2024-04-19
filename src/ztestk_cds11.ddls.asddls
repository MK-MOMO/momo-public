@AbapCatalog.sqlViewName: 'ZTESTKCDS11'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW11'
//テーブルファンクションをコールしたCDSビュー
define view ZTESTK_CDS11 as 
select from ZTESTK_CDS10 (p_prod_order:'RM01') as _a
{
 prod_order,
 order_type,
 routing,
 counter,
 // 数量や金額は型を参照する必要がある
 cast('MIN' as vgwrteh) as uom,
 @Semantics.amount.currencyCode: 'UOM' 
 std_value1,
 @Semantics.amount.currencyCode: 'UOM' 
 std_value2

}

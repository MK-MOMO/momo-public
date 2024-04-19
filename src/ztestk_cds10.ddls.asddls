@EndUserText.label: 'CDSVIEW10'
//テーブルファンクション クラスにてデータを色々編集することができる
define table function ZTESTK_CDS10
with parameters p_prod_order : aufnr
returns {
  client     : abap.clnt;
  prod_order : aufnr;
  order_type : auart;
  routing    : co_aufpl;
  counter    : co_aplzl;
  std_value1 : vgwrt;
  std_value2 : vgwrt;
  char_1      : char10;
  date_1      : char10;
  when_1      : char10;
 
}
implemented by method ZTESTK_CALSS_CDS01=>get_order_details;

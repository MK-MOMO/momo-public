CLASS ztestk_calss_cds01 DEFINITION PUBLIC.
  PUBLIC SECTION.
  INTERFACES IF_AMDP_MARKER_HDB.
  class-METHODS get_order_details for table function ZTESTK_CDS10.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ztestk_calss_cds01 IMPLEMENTATION.
METHOD get_order_details BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
                         OPTIONS READ-ONLY
                         USING AUFK afko afvc afvv.

  DECLARE w_date date;
  SELECT add_days( CURRENT_DATE , 10 )
    INTO w_date
    FROM dummy;

  it_aufk = select mandt,
                   aufnr,
                   auart
              from aufk;

  it_afko = select aufnr,
                   aufpl
              from afko
             where aufnr in ( select aufnr from :it_aufk );

  it_hours = select afvv.aufpl,
                    afvv.aplzl,
                    afvv.vgw01,
                    afvv.vgw02,
                    afvv.iedd,
                    afvc.vornr
               from afvv as afvv
              inner join afvc as afvc
                 on afvv.aufpl = afvc.aufpl
                and afvv.aplzl = afvc.aplzl;

    RETURN select hdr.mandt as client,
                  hdr.aufnr as prod_order,
                  hdr.auart as order_type,
                  oper.aufpl as routing,
                  hrs.aplzl as counter,
                  hrs.vgw01 as std_value1,
                  hrs.vgw02 as std_value2,
                  'TESTK' as char_1,
                  to_varchar( :w_date,'YYYYMMDD' ) as date_1,
                  case when hdr.mandt = '531' then '531' else '500' end as when_1
             from :it_aufk as hdr
            inner join :it_afko as oper
               on hdr.aufnr = oper.aufnr
             left outer join :it_hours as hrs
               on oper.aufpl = hrs.aufpl
            where hdr.auart = :p_prod_order;

*  RETURN SELECT MANDT AS CLIENT,
*                AUFNR AS PROD_ORDER,
*                AUART AS ORDER_TYPE
*           FROM AUFK
*          WHERE auart = p_prod_order;

* if　sample
 if :w_date > '2023/01/01' then


 elseif :w_date <= '2023/01/01' then


 else

 end if;




ENDMETHOD.


ENDCLASS.

REPORT ZTESTK0008.
TABLES:KNA1,T001L,MSEG,PLAF.
TYPE-POOLS col.

*---------------------------------------------------------------------*
*       CONSTANTS定義
*---------------------------------------------------------------------*
CONSTANTS:CNS_FIRSTDAY TYPE STRING     VALUE '01',    "月初01日
          CNS_AG       TYPE VBPA-PARVW VALUE 'AG',    "取引先機能-受注先
          CNS_WE       TYPE VBPA-PARVW VALUE 'WE',    "取引先機能-出荷先
          CNS_1        TYPE VBEP-ABART VALUE '1',     "承認タイプ-予定納入日程
          CNS_5        TYPE VBEP-ABART VALUE '5',     "承認タイプ-納入日程計画
          CNS_CHKMNG   TYPE ZMMS0001-MENG01 VALUE '10000000000',"桁数チェック用
          CNS_HDR      TYPE VBPA-POSNR VALUE '000000',"ヘッダ
          CNS_STR      TYPE DD02L-TABNAME VALUE 'ZMMS0001',"ALV構造
          CNS_SAVE     TYPE char01     VALUE 'A',      "ALVバリアント
*--- ALVソート順序定義
         BEGIN OF CNS_SORTCT,
            HSM    TYPE C VALUE '0100000000000' LENGTH 13, "出庫見込ヘッダ
            VBEP_H TYPE C VALUE '02' LENGTH 2,             "得意先内示＆内示平準化
            VBEP_1 TYPE C VALUE '1'  LENGTH 1,             "得意先内示（旧）
            VBEP_2 TYPE C VALUE '2'  LENGTH 1,             "内示平準化（旧）
            VBEP_3 TYPE C VALUE '3'  LENGTH 1,             "得意先内示（最新）
            VBEP_4 TYPE C VALUE '4'  LENGTH 1,             "内示平準化（最新）
            VBEP_5 TYPE C VALUE '5'  LENGTH 1,             "内示平準化（変更モード）
            VBEP_6 TYPE C VALUE '6'  LENGTH 1,             "JIT指示
            VBEP_7 TYPE C VALUE '7'  LENGTH 1,             "出荷計画
            VBEP_8 TYPE C VALUE '8'  LENGTH 1,             "出荷実績
            REBS   TYPE C VALUE '0300000000000' LENGTH 13, "従属所要量
            JIT1   TYPE C VALUE '04'            LENGTH 2,  "JIT指示
            LIPS   TYPE C VALUE '0500000000000' LENGTH 13, "出荷計画
            SYUKKA TYPE C VALUE '0600000000000' LENGTH 13, "出荷実績
            HSM_S  TYPE C VALUE '0700000000000' LENGTH 13, "出庫見込(SimMRP)
            VBEP_S TYPE C VALUE '0800000000000' LENGTH 13, "Sim内示平準化
            RESB_S TYPE C VALUE '0900000000000' LENGTH 13, "Sim所要量
            SYUKKO TYPE C VALUE '1000000000000' LENGTH 13, "出庫実績
            HNM    TYPE C VALUE '1100000000000' LENGTH 13, "入庫見込ヘッダ
            PLAF   TYPE C VALUE '1200000000000' LENGTH 13, "計画手配
            EKET   TYPE C VALUE '1300000000000' LENGTH 13, "購買分納契約
            HNM_S  TYPE C VALUE '1400000000000' LENGTH 13, "入庫見込(SimMRP)
            PLAF_S TYPE C VALUE '1500000000000' LENGTH 13, "Sim計画手配
            NYUUKO TYPE C VALUE '1600000000000' LENGTH 13, "入庫実績
            HZM    TYPE C VALUE '1700000000000' LENGTH 13, "在庫見込
            HZM_S  TYPE C VALUE '1800000000000' LENGTH 13, "在庫見込(SimMRP)
            HZJ    TYPE C VALUE '1900000000000' LENGTH 13, "在庫実績
         END OF CNS_SORTCT .

*---------------------------------------------------------------------*
*       TYPE定義
*---------------------------------------------------------------------*
*--- ALV出力用
TYPES:BEGIN OF  TYP_OUTALV.
  INCLUDE   TYPE ZMMS0001.  "ALV出力構造
  TYPES:
    SORTCT  TYPE CHAR13,    "ソートカテゴリ
    VBELN   TYPE VBEP-VBELN,"販売伝票番号
    POSNR   TYPE VBEP-POSNR,"販売伝票明細
    EBELN   TYPE EKET-EBELN,"購買伝票明細
    EBELP   TYPE EKET-EBELP,"購買伝票明細
    FSTYLE  TYPE LVC_T_STYL,"フィールドスタイル
    FSCOL   TYPE LVC_T_SCOL,"フィールドカラー
END OF TYP_OUTALV.

*--- 対象品目取得用
TYPES:BEGIN OF  TYP_MARC,
  MATNR   TYPE MARC-MATNR,  "品目コード
  BACKNO  TYPE MARC-ZZ1_BACKNO_PLT,"背番号
  MAKTX   TYPE MAKT-MAKTX,  "品目テキスト
  WERKS   TYPE MARC-WERKS,  "プラント
  MEINS   TYPE MARA-MEINS,  "基本数量単位
  EISBE   TYPE MARC-EISBE,  "安全在庫
  BESKZ   TYPE MARC-BESKZ,  "調達タイプ
  BWKEY   TYPE T001W-BWKEY, "評価レベル
  FABKL   TYPE T001W-FABKL, "稼動日カレンダ
  LFGJA   TYPE MBEW-LFGJA,  "当会計年度
  LFMON   TYPE MBEW-LFMON,  "当期
  LABST   TYPE MBEW-LBKUM,  "利用可能在庫
END OF TYP_MARC.

*--- 販売分納契約取得用
TYPES:BEGIN OF  TYP_VBEP,
  ABART     TYPE VBEP-ABART,  "承認タイプ
  VBELN     TYPE VBAK-VBELN,  "販売伝票番号
  POSNR     TYPE VBAP-POSNR,  "販売伝票明細
  ABGRU     TYPE VBAP-ABGRU,  "拒否理由
  MATNR     TYPE VBAP-MATNR,  "品目コード
  WERKS     TYPE VBAP-WERKS,  "プラント
  LGORT     TYPE VBAP-LGORT,  "保管場所
  VKORG     TYPE VBAK-VKORG,  "販売組織
  VKORG_BEZ TYPE ZMMS0001-VKORG_BEZ,
  VTWEG     TYPE VBAK-VTWEG,  "流通チャネル
  VTWEG_BEZ TYPE ZMMS0001-VTWEG_BEZ,"流通チャネル名
  SPART     TYPE VBAK-SPART,  "製品部門
  SPART_BEZ TYPE ZMMS0001-SPART_BEZ,"製品部門名
  KUNAG     TYPE VBPA-KUNNR,  "受注先
  KUNAGT    TYPE ZMMS0001-KUNAGT,"受注先名
  KUNWE     TYPE VBPA-KUNNR,  "出荷先
  KUNWET    TYPE ZMMS0001-KUNWET,"出荷先名
  KDMAT     TYPE VBAP-KDMAT,  "得意先品目
  VSTEL     TYPE VBAP-VSTEL,     "出荷ポイント
  VSTELT    TYPE ZMMS0001-VSTELT,"出荷ポイント名称
  ABRVW     TYPE ZMMS0001-ABRVW,  "用途区分(ヘッダ)
  ABRVWIT   TYPE ZMMS0001-ABRVWIT,"用途区分(明細)
  KNREF     TYPE ZMMS0001-KNREF,"納入先/工区/受入
  KVERM     TYPE ZMMS0001-KVERM,"旧得意先
  ABRLI     TYPE VBLB-ABRLI,  "承認タイプ
  LABNK     TYPE VBLB-LABNK,  "納入日程の現在のキー
  EDATU     TYPE VBEP-EDATU,  "納入日付
  VMENG     TYPE VBEP-WMENG,  "数量
END OF TYP_VBEP.

*--- 対象の販売分納契約
TYPES:BEGIN OF  TYP_VBEP_SUB,
  VBELN     TYPE VBAK-VBELN,  "販売伝票番号
  POSNR     TYPE VBAP-POSNR,  "販売伝票明細
END OF TYP_VBEP_SUB.

*--- 販売分納契約存在チェック用
TYPES:BEGIN OF  TYP_VBEP_CHK,
  VBELN     TYPE VBAK-VBELN,  "販売伝票番号
  POSNR     TYPE VBAP-POSNR,  "販売伝票明細
  ABGRU     TYPE VBAP-ABGRU,  "拒否理由
  MATNR     TYPE VBAP-MATNR,  "品目コード
  WERKS     TYPE VBAP-WERKS,  "プラント
  LGORT     TYPE VBAP-LGORT,  "保管場所
  VKORG     TYPE VBAK-VKORG,  "販売組織
  VKORG_BEZ TYPE ZMMS0001-VKORG_BEZ,
  VTWEG     TYPE VBAK-VTWEG,  "流通チャネル
  VTWEG_BEZ TYPE ZMMS0001-VTWEG_BEZ,"流通チャネル名
  SPART     TYPE VBAK-SPART,  "製品部門
  SPART_BEZ TYPE ZMMS0001-SPART_BEZ,"製品部門名
  KUNAG     TYPE VBPA-KUNNR,  "受注先
  KUNAGT    TYPE ZMMS0001-KUNAGT,"受注先名
  KUNWE     TYPE VBPA-KUNNR,  "出荷先
  KUNWET    TYPE ZMMS0001-KUNWET,"出荷先名
  KDMAT     TYPE VBAP-KDMAT,  "得意先品目
  VSTEL     TYPE VBAP-VSTEL,     "出荷ポイント
  VSTELT    TYPE ZMMS0001-VSTELT,"出荷ポイント名称
  ABRVW     TYPE ZMMS0001-ABRVW,  "用途区分(ヘッダ)
  ABRVWIT   TYPE ZMMS0001-ABRVWIT,"用途区分(明細)
  KNREF     TYPE ZMMS0001-KNREF,"納入先/工区/受入
  KVERM     TYPE ZMMS0001-KVERM,"旧得意先
  LABNK     TYPE VBLB-LABNK,  "納入日程の現在のキー
END OF TYP_VBEP_CHK.

*--- JIT伝票取得用
TYPES:BEGIN OF  TYP_JIT1,
  VBELN     TYPE VBAK-VBELN,  "販売伝票番号
  POSNR     TYPE VBAP-POSNR,  "販売伝票明細
  ABGRU     TYPE VBAP-ABGRU,  "拒否理由
  MATNR     TYPE VBAP-MATNR,  "品目コード
  WERKS     TYPE VBAP-WERKS,  "プラント
  LGORT     TYPE VBAP-LGORT,  "保管場所
  VKORG     TYPE VBAK-VKORG,  "販売組織
  VKORG_BEZ TYPE ZMMS0001-VKORG_BEZ,
  VTWEG     TYPE VBAK-VTWEG,  "流通チャネル
  VTWEG_BEZ TYPE ZMMS0001-VTWEG_BEZ,"流通チャネル名
  SPART     TYPE VBAK-SPART,  "製品部門
  SPART_BEZ TYPE ZMMS0001-SPART_BEZ,"製品部門名
  KUNAG     TYPE VBPA-KUNNR,  "受注先
  KUNAGT    TYPE ZMMS0001-KUNAGT,"受注先名
  KUNWE     TYPE VBPA-KUNNR,  "出荷先
  KUNWET    TYPE ZMMS0001-KUNWET,"出荷先名
  KDMAT     TYPE VBAP-KDMAT,  "得意先品目
  VSTEL     TYPE VBAP-VSTEL,     "出荷ポイント
  VSTELT    TYPE ZMMS0001-VSTELT,"出荷ポイント名称
  ABRVW     TYPE ZMMS0001-ABRVW,  "用途区分(ヘッダ)
  ABRVWIT   TYPE ZMMS0001-ABRVWIT,"用途区分(明細)
  KNREF     TYPE ZMMS0001-KNREF,"納入先/工区/受入
  KVERM     TYPE ZMMS0001-KVERM,"旧得意先
  RDATE     TYPE JITIT-RDATE,   "納入日（タイムスタンプ）
  VMENG     TYPE JITCO-QUANT,   "数量
  PICKLO    TYPE ZMMS0001-PICKLO, "置き場
  SHIPPINGRO TYPE ZMMS0001-SHIPPINGRO, "出荷ルート
  SUPPLYRO  TYPE ZMMS0001-SUPPLYRO, "納入ルート
  SUPPLYFIN TYPE ZMMS0001-SUPPLYFIN,"最終納入ルート
  CARTONRTN TYPE ZMMS0001-CARTONRTN,"通い箱リターン区分
  CARTONDAY TYPE ZMMS0001-CARTONDAY,"通い箱回転日数
  SUPPLYCNT TYPE ZMMS0001-SUPPLYCNT,"納入回数
  MILKRUN   TYPE ZMMS0001-MILKRUN,  "ミルクラン区分
  LFDAT     TYPE SY-DATUM,          "納入日
  LFTIME    TYPE SY-UZEIT,          "納入時刻
END OF TYP_JIT1.

*--- JIT伝票取得用
TYPES:BEGIN OF  TYP_JIT1_CHK,
  VBELN     TYPE VBAK-VBELN,  "販売伝票番号
  POSNR     TYPE VBAP-POSNR,  "販売伝票明細
  ABGRU     TYPE VBAP-ABGRU,  "拒否理由
  MATNR     TYPE VBAP-MATNR,  "品目コード
  WERKS     TYPE VBAP-WERKS,  "プラント
  LGORT     TYPE VBAP-LGORT,  "保管場所
  VKORG     TYPE VBAK-VKORG,  "販売組織
  VKORG_BEZ TYPE ZMMS0001-VKORG_BEZ,
  VTWEG     TYPE VBAK-VTWEG,  "流通チャネル
  VTWEG_BEZ TYPE ZMMS0001-VTWEG_BEZ,"流通チャネル名
  SPART     TYPE VBAK-SPART,  "製品部門
  SPART_BEZ TYPE ZMMS0001-SPART_BEZ,"製品部門名
  KUNAG     TYPE VBPA-KUNNR,  "受注先
  KUNAGT    TYPE ZMMS0001-KUNAGT,"受注先名
  KUNWE     TYPE VBPA-KUNNR,  "出荷先
  KUNWET    TYPE ZMMS0001-KUNWET,"出荷先名
  KDMAT     TYPE VBAP-KDMAT,  "得意先品目
  VSTEL     TYPE VBAP-VSTEL,     "出荷ポイント
  VSTELT    TYPE ZMMS0001-VSTELT,"出荷ポイント名称
  ABRVW     TYPE ZMMS0001-ABRVW,  "用途区分(ヘッダ)
  ABRVWIT   TYPE ZMMS0001-ABRVWIT,"用途区分(明細)
  KNREF     TYPE ZMMS0001-KNREF,"納入先/工区/受入
  KVERM     TYPE ZMMS0001-KVERM,"旧得意先
  PICKLO    TYPE ZMMS0001-PICKLO, "置き場
  SHIPPINGRO TYPE ZMMS0001-SHIPPINGRO, "出荷ルート
  SUPPLYRO  TYPE ZMMS0001-SUPPLYRO, "納入ルート
  SUPPLYFIN TYPE ZMMS0001-SUPPLYFIN,"最終納入ルート
  CARTONRTN TYPE ZMMS0001-CARTONRTN,"通い箱リターン区分
  CARTONDAY TYPE ZMMS0001-CARTONDAY,"通い箱回転日数
  SUPPLYCNT TYPE ZMMS0001-SUPPLYCNT,"納入回数
  MILKRUN   TYPE ZMMS0001-MILKRUN,  "ミルクラン区分
END OF TYP_JIT1_CHK.

*--- 入出庫予定/従属所要量取得用
TYPES:BEGIN OF  TYP_RESB,
  MATNR   TYPE RESB-MATNR,  "品目コード
  WERKS   TYPE RESB-WERKS,  "プラント
  LGORT   TYPE RESB-LGORT,  "保管場所
  BAUGR   TYPE RESB-BAUGR,  "上位レベル組立品目
  BDTER   TYPE RESB-BDTER,  "構成品目の所要日付
  BDMNG   TYPE RESB-BDMNG,  "所要量
  RSNUM   TYPE RESB-RSNUM,  "入出庫予定/従属所要量の番号
  RSPOS   TYPE RESB-RSPOS,  "入出庫予定/従属所要量の明細
END OF TYP_RESB.

*--- 出荷伝票取得用
TYPES:BEGIN OF  TYP_LIPS,
  VBELN_VA TYPE VBAK-VBELN,  "販売伝票番号
  POSNR_VA TYPE VBAP-POSNR,  "販売伝票明細
  MATNR   TYPE LIPS-MATNR,  "品目コード
  WERKS   TYPE LIPS-WERKS,  "プラント
  LGORT   TYPE LIPS-LGORT,  "保管場所
  VKORG   TYPE VBAK-VKORG,  "販売組織
  VTWEG   TYPE VBAK-VTWEG,  "流通チャネル
  SPART   TYPE VBAK-SPART,  "製品部門
  LFDAT   TYPE LIKP-LFDAT,  "納入日付
  LGMNG   TYPE LIPS-LGMNG,  "数量
  VBELN   TYPE LIKP-VBELN,  "出荷伝票番号
  POSNR   TYPE LIPS-POSNR,  "出荷伝票明細
END OF TYP_LIPS.

*--- 計画手配取得用
TYPES:BEGIN OF  TYP_PLAF_WK,
  PLSCN   TYPE PLAF-PLSCN,  "長期計画の計画シナリオ
  MATNR   TYPE PLAF-MATNR,  "品目コード
  WERKS   TYPE PLAF-PLWRK,  "プラント
  LGORT   TYPE PLAF-LGORT,  "保管場所
  DISPO   TYPE PLAF-DISPO,  "MRP 管理者
  PLGRP   TYPE PLAF-PLGRP,  "製造責任者
  PERTR   TYPE PLAF-PERTR,  "計画手配の計画開始日
  GSMNG   TYPE PLAF-GSMNG,  "数量
  PLNUM   TYPE PLAF-PLNUM,  "計画手配
  VERID   TYPE PLAF-VERID,  "製造バージョン
END OF TYP_PLAF_WK.

TYPES:BEGIN OF  TYP_PLAF,
  PLSCN   TYPE PLAF-PLSCN,  "長期計画の計画シナリオ
  MATNR   TYPE PLAF-MATNR,  "品目コード
  WERKS   TYPE PLAF-PLWRK,  "プラント
  LGORT   TYPE PLAF-LGORT,  "保管場所
  DISPO   TYPE PLAF-DISPO,  "MRP 管理者
  PLGRP   TYPE PLAF-PLGRP,  "製造責任者
  PERTR   TYPE PLAF-PERTR,  "計画手配の計画開始日
  GSMNG   TYPE PLAF-GSMNG,  "数量
  KOSTL   TYPE CRCO-KOSTL,  "原価センタ
  BEZKS   TYPE ZMMS0001-BEZKS,"原価センタ名
  PLNUM   TYPE PLAF-PLNUM,  "計画手配
END OF TYP_PLAF.

TYPES:BEGIN OF  TYP_KOSTL,
  KOSTL   TYPE CRCO-KOSTL,  "原価センタ
  BEZKS   TYPE ZMMS0001-BEZKS,"原価センタ名
END OF TYP_KOSTL.

*--- 購買分納契約取得用
TYPES:BEGIN OF  TYP_EKET,
  EBELN   TYPE EKPO-EBELN,  "購買伝票番号
  EBELP   TYPE EKPO-EBELP,  "購買伝票明細
  MATNR   TYPE EKPO-MATNR,  "品目
  WERKS   TYPE EKPO-WERKS,  "プラント
  LGORT   TYPE EKPO-LGORT,  "保管場所
  EKORG   TYPE EKKO-EKORG,  "購買組織
  EKOTX   TYPE ZMMS0001-EKOTX,"購買組織テキスト
  EKGRP   TYPE EKKO-EKGRP,  "購買グループ
  LIFNR   TYPE EKKO-LIFNR,  "仕入先
  NAME1_LI TYPE ZMMS0001-NAME1_LI,"仕入先名
  EINDT   TYPE EKET-EINDT,  "納入日
  MENGE   TYPE EKET-MENGE,  "数量
  WEMNG   TYPE EKET-WEMNG,  "入庫数量
END OF TYP_EKET.

*--- 購買分納契約ヘッダテキスト取得用
TYPES:BEGIN OF  TYP_EBTXT,
  EBELN   TYPE EKPO-EBELN,  "購買伝票番号
  TDLINE  TYPE TLINE-TDLINE,"テキスト行
END OF TYP_EBTXT.

*--- 出荷実績取得用
TYPES:BEGIN OF  TYP_SYUKKA,
  VBELN   TYPE VBAP-VBELN,    "販売伝票番号
  POSNR   TYPE VBAP-POSNR,    "販売明細番号
  MATNR   TYPE MATDOC-MATNR,  "品目コード
  WERKS   TYPE MATDOC-WERKS,  "プラント
  LGORT   TYPE MATDOC-LGORT,  "保管場所
  BUDAT   TYPE MATDOC-BUDAT,  "転記日
  MENGE   TYPE MATDOC-MENGE,  "数量
  SHKZG   TYPE MATDOC-SHKZG,  "貸借
  BWART   TYPE MATDOC-BWART,  "移動タイプ
END OF TYP_SYUKKA.

*--- 入出庫実績取得用
TYPES:BEGIN OF  TYP_MATDOC,
  MATNR   TYPE MATDOC-MATNR,  "品目コード
  WERKS   TYPE MATDOC-WERKS,  "プラント
  LGORT   TYPE MATDOC-LGORT,  "保管場所
  BUDAT   TYPE MATDOC-BUDAT,  "転記日
  MENGE   TYPE MATDOC-MENGE,  "数量
  SHKZG   TYPE MATDOC-SHKZG,  "貸借
  BWART   TYPE MATDOC-BWART,  "移動タイプ
END OF TYP_MATDOC.

*--- 履歴在庫取得用
TYPES:BEGIN OF  TYP_MARDH,
  MATNR   TYPE MARDH-MATNR,  "品目コード
  WERKS   TYPE MARDH-WERKS,  "プラント
  LGORT   TYPE MARDH-LGORT,  "保管場所
  LFGJA   TYPE MARDH-LFGJA,  "会計年度
  LFMON   TYPE MARDH-LFMON,  "当期
  LABST   TYPE MARDH-LABST,  "利用可能在庫
END OF TYP_MARDH.

TYPES:BEGIN OF  TYP_MBEWH,
  MATNR   TYPE MBEWH-MATNR,  "品目コード
  WERKS   TYPE MBEWH-BWKEY,  "プラント
  LFGJA   TYPE MBEWH-LFGJA,  "会計年度
  LFMON   TYPE MBEWH-LFMON,  "当期
  LABST   TYPE MBEWH-LBKUM,  "利用可能在庫
END OF TYP_MBEWH.


*--- 会社コード、カレンダ取得用
TYPES:BEGIN OF  TYP_T001W,
  BWKEY   TYPE T001W-BWKEY,  "評価レベル
  FABKL   TYPE T001W-FABKL,  "稼働日カレンダ
END OF TYP_T001W.

*--- 伝票ロック用
TYPES:BEGIN OF  TYP_LOCK,
  VBELN   TYPE VBEP-VBELN,  "販売伝票番号
END OF TYP_LOCK.

*--- かんばん収容数取得用
TYPES:BEGIN OF  TYP_EBELN,
  MATNR   TYPE EKPO-MATNR,  "品目コード
  WERKS   TYPE EKPO-WERKS,  "プラント
  LGORT   TYPE EKPO-LGORT,  "保管場所
  EBELN   TYPE EKPO-EBELN,  "購買伝票番号
  EBELP   TYPE EKPO-EBELP,  "購買伝票明細
END OF TYP_EBELN.

TYPES:BEGIN OF  TYP_KANBAN,
  MATNR   TYPE EKPO-MATNR,  "品目コード
  WERKS   TYPE EKPO-WERKS,  "プラント
  PKNUM   TYPE PKHD-PKNUM,  "管理周期
  BEHMG   TYPE PKHD-BEHMG,  "数量
END OF TYP_KANBAN.

*--- 出荷計画変換表
TYPES:BEGIN OF TYP_KEIKAKU,
  COUNT   TYPE N LENGTH 2,  "カウント
  TEXT    TYPE C LENGTH 1,  "テキスト
END OF TYP_KEIKAKU.

*--- 納入日程行全データ取得用
TYPES:BEGIN OF  TYP_VBEP_ALL,
  EDATU   TYPE VBEP-EDATU,  "納入日付
  WMENG   TYPE VBEP-WMENG,  "数量
END OF TYP_VBEP_ALL.

*--- 販売分納契約ロック用
TYPES:BEGIN OF  TYP_VBEP_LK,
  VBELN   TYPE VBEP-VBELN,  "販売伝票番号
END OF TYP_VBEP_LK.

*---------------------------------------------------------------------*
*       データ定義
*---------------------------------------------------------------------*
*--- 内部テーブル定義
DATA:TD_OUTALV   TYPE STANDARD TABLE OF TYP_OUTALV, "ALV出力用
     TD_BKALV    TYPE STANDARD TABLE OF TYP_OUTALV, "退避テーブル
     TD_BKEDIT   TYPE STANDARD TABLE OF TYP_OUTALV, "退避テーブル
     TD_HSM      TYPE STANDARD TABLE OF TYP_OUTALV, "出庫見込集計用
     TD_HSM_S    TYPE STANDARD TABLE OF TYP_OUTALV, "Sim出庫見込集計用
     TD_HNM      TYPE STANDARD TABLE OF TYP_OUTALV, "入庫見込集計用
     TD_HNM_S    TYPE STANDARD TABLE OF TYP_OUTALV, "Sim入庫見込集計用
     TD_MARC     TYPE SORTED   TABLE OF TYP_MARC    "対象品目取得用
                      WITH UNIQUE KEY  MATNR BACKNO MAKTX WERKS,
     TD_CM_MARA  TYPE ZCL_RETRIEVE_MATERIALS=>TYP_TD_DATA, "品目共通部品取得
     TD_VBEP_N   TYPE STANDARD TABLE OF TYP_VBEP,   "販売分納契約取得用（最新）
     TD_VBEP_SUB TYPE STANDARD TABLE OF TYP_VBEP_SUB,"販売分納契約取得用（最新）
     TD_VBEP_O   TYPE STANDARD TABLE OF TYP_VBEP,   "販売分納契約取得用（前回）
     TD_VBEP_CHK TYPE STANDARD TABLE OF TYP_VBEP_CHK,"販売分納契約存在チェック用
     TD_JIT1     TYPE STANDARD TABLE OF TYP_JIT1,   "JIT伝票取得用
     TD_JIT1_CHK TYPE STANDARD TABLE OF TYP_JIT1_CHK,"JIT伝票取得用
     TD_RESB     TYPE STANDARD TABLE OF TYP_RESB,   "入出庫予定/従属所要量取得用
     TD_LIPS     TYPE STANDARD TABLE OF TYP_LIPS,   "出荷伝票取得用
     TD_PLAF     TYPE STANDARD TABLE OF TYP_PLAF,   "計画手配取得用
     TD_PLAF_WK  TYPE STANDARD TABLE OF TYP_PLAF_WK,"計画手配取得用（作業用）
     TD_EKET     TYPE STANDARD TABLE OF TYP_EKET,   "購買分納契約取得用
     TD_EBTXT    TYPE STANDARD TABLE OF TYP_EBTXT,  "購買分納契約ヘッダテキスト取得用
     TD_SYUKKA   TYPE STANDARD TABLE OF TYP_SYUKKA, "出荷実績取得用
     TD_SYUKKO   TYPE STANDARD TABLE OF TYP_MATDOC, "出庫実績取得用
     TD_NYUUKO   TYPE STANDARD TABLE OF TYP_MATDOC, "入庫実績取得用
     TD_MARDH    TYPE STANDARD TABLE OF TYP_MARDH,  "履歴在庫取得用
     TD_MBEWH    TYPE STANDARD TABLE OF TYP_MBEWH,  "履歴在庫取得用
     TD_FIELDCAT TYPE LVC_T_FCAT,          "ALVフィールドカテゴリ用
     TD_SORTINFO TYPE LVC_T_SORT,          "ALVソート定義用
     TD_BDCDATA  TYPE STANDARD TABLE OF BDCDATA,
     TD_LOCK     TYPE STANDARD TABLE OF TYP_LOCK,   "伝票ロック用
     TD_EBELN    TYPE STANDARD TABLE OF TYP_EBELN,  "かんばん取得用
     TD_KANBAN   TYPE STANDARD TABLE OF TYP_KANBAN, "かんばん取得用
     TD_KEIKAKU  TYPE STANDARD TABLE OF TYP_KEIKAKU,"出荷計画変換表
     TD_VBEP_LK  TYPE STANDARD TABLE OF TYP_VBEP_LK."販売分納契約ロック用

*--- 作業領域定義
DATA:TH_OUTALV   LIKE LINE  OF TD_OUTALV, "ALV出力用
     TH_HSM      LIKE LINE  OF TD_OUTALV, "出庫見込集計用
     TH_HSM_S    LIKE LINE  OF TD_OUTALV, "Sim出庫見込集計用
     TH_HNM      LIKE LINE  OF TD_OUTALV, "入庫見込集計用
     TH_HNM_S    LIKE LINE  OF TD_OUTALV, "Sim入庫見込集計用
     TH_SYUKKA   LIKE LINE  OF TD_SYUKKA, "出荷実績取得用
     TH_T001W    TYPE TYP_T001W,          "会社コード、カレンダ取得用
     TH_SORTINFO TYPE LVC_S_SORT,         "ALVソート定義用
     TH_LAYOUT   TYPE LVC_S_LAYO,         "ALVレイアウト定義用
     TH_BDCDATA  TYPE BDCDATA,            "BDCテーブル編集用
     TH_DISVARIANT TYPE DISVARIANT,       "レイアウト編集用
     TH_LOCK     LIKE LINE  OF TD_LOCK,   "伝票ロック用
     TH_KEIKAKU  LIKE LINE OF TD_KEIKAKU, "出荷計画変換表
     TH_EBTXT    LIKE LINE OF TD_EBTXT.   "購買分納契約ヘッダテキスト取得用

*--- レンジテーブル・作業領域定義
DATA:RD_DAY      TYPE RANGE OF NUMC2,
     RH_DAY      LIKE LINE  OF RD_DAY,
     RD_AUART    TYPE RANGE OF AUART,
     RD_BDART    TYPE RANGE OF BDART,
     RD_LFART    TYPE RANGE OF LFART,
     RD_BSART    TYPE RANGE OF BSART.

*--- 変数定義
DATA:W_FDATE_ML  TYPE D,                  "前月月初日
     W_FDATE_M0  TYPE D,                  "当月月初日
     W_LDATE_M0  TYPE D,                  "当月月末日
     W_KDATE_M0  TYPE D,                  "当月開始日
     W_SDATE_M0  TYPE D,                  "当月終了日
     W_KDATE_M1  TYPE D,                  "来月開始日
     W_SDATE_M1  TYPE D,                  "来月終了日
     W_KDATE_M2  TYPE D,                  "再来月開始日
     W_SDATE_M2  TYPE D,                  "再来月終了日
     W_KDATE_M3  TYPE D,                  "再々来月開始日
     W_FIELD1    TYPE FIELDNAME,          "動的変数１
     W_FIELD2    TYPE FIELDNAME,          "動的変数２
     W_FIELD3    TYPE FIELDNAME,          "動的変数３
     W_EDITMD    TYPE FLAG,               "変更モード
     W_RETURN    TYPE FLAG,               "リターンフラグ
     W_TABIX     TYPE slis_selfield-tabindex,"ALV選択行
     W_YM        TYPE VDM_YEARMONTH,      "年月編集
     W_UCOMM     TYPE SY-UCOMM,           "ユーザーコマンド
     W_DISPLAY   TYPE C LENGTH 1.         "ディスプレイモード経由判定

*--- フィールドシンボル定義
FIELD-SYMBOLS:
  <FS_FLD1>  TYPE ANY,
  <FS_FLD2>  TYPE ANY,
  <FS_FLD3>  TYPE ANY.

*--- Interace
DATA :
  go_interface_factory TYPE REF TO ZCL_Interface_FACTORY.

*---------------------------------------------------------------------*
*       選択画面定義
*---------------------------------------------------------------------*

*--- 出荷計画ブロック
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_SEIHIN AS CHECKBOX USER-COMMAND USR01.
    SELECT-OPTIONS: S_VKORG FOR TH_OUTALV-VKORG MEMORY ID VKO,  "販売組織
                    S_VTWEG FOR TH_OUTALV-VTWEG MEMORY ID VTW,  "流通チャネル
                    S_SPART FOR TH_OUTALV-SPART MEMORY ID SPA,  "製品部門
                    S_KUNAG FOR KNA1-KUNNR,       "受注先
                    S_KUNWE FOR KNA1-KUNNR,       "出荷先
                    S_KDMAT FOR TH_OUTALV-KDMAT,  "得意先品目
                    S_SEISB FOR MSEG-BWART.       "出荷実績移動タイプ
SELECTION-SCREEN END OF BLOCK B1.

*--- 生産計画ブロック
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: P_NAISEI AS CHECKBOX USER-COMMAND USR01.
  SELECT-OPTIONS: S_PLGRP FOR PLAF-PLGRP,       "製造責任者
                  S_NAISB FOR MSEG-BWART,       "出庫実績移動タイプ
                  S_NAINB FOR MSEG-BWART.       "入庫実績移動タイプ
SELECTION-SCREEN END OF BLOCK B2.

*--- 調達計画ブロック
SELECTION-SCREEN BEGIN OF BLOCK B4 WITH FRAME TITLE TEXT-004.
  PARAMETERS: P_GAISEI AS CHECKBOX USER-COMMAND USR01.
  SELECT-OPTIONS: S_EKORG FOR TH_OUTALV-EKORG MEMORY ID EKO,  "購買組織
                  S_EKGRP FOR TH_OUTALV-EKGRP MEMORY ID EKG,  "購買グループ
                  S_LIFNR FOR TH_OUTALV-LIFNR,  "仕入先
                  S_GAISB FOR MSEG-BWART,       "出庫実績移動タイプ
                  S_GAINB FOR MSEG-BWART.       "入庫実績移動タイプ
SELECTION-SCREEN END OF BLOCK B4.

*--- 長期計画ブロック
SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: P_TYOUKI AS CHECKBOX USER-COMMAND USR01,
              P_PLSCN TYPE PLAF-PLSCN.  "LET計画シナリオ
SELECTION-SCREEN END OF BLOCK B3.


SELECT-OPTIONS: S_MATNR  FOR TH_OUTALV-MATNR,   "品目コード
                S_BACKNO FOR TH_OUTALV-BACKNO,  "背番号
                S_WERKS  FOR TH_OUTALV-WERKS OBLIGATORY MEMORY ID WRK,  "プラント
                S_LGORT  FOR T001L-LGORT,       "保管場所
                S_DISPO  FOR TH_OUTALV-DISPO.   "MRP管理者
PARAMETERS: P_YM    TYPE VDM_YEARMONTH OBLIGATORY,  "対象年月
            P_KIKAN TYPE VBEP-EDATU    OBLIGATORY.  "対象年月開始日

*--- レイアウトブロック
SELECTION-SCREEN BEGIN OF BLOCK B5 WITH FRAME TITLE TEXT-024.
  PARAMETERS: P_VARIAN TYPE LTDX-VARIANT. "レイアウト
SELECTION-SCREEN END OF BLOCK B5.

*---------------------------------------------------------------------*
*       INITIALIZATION
*---------------------------------------------------------------------*
INITIALIZATION .
*--- 変数初期化処理
  PERFORM FRM_INITFORM.

*--- オブジェクト生成
  CREATE OBJECT go_interface_factory .

*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN
*---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

**--- 出荷計画の必須処理
*  IF P_SEIHIN = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'S_VKORG-LOW' OR
*         SCREEN-NAME = 'S_VTWEG-LOW' OR
*         SCREEN-NAME = 'S_SPART-LOW' OR
*         SCREEN-NAME = 'S_SEISB-LOW'.
*        SCREEN-REQUIRED = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

**--- 生産計画の必須処理
*  IF P_NAISEI = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'S_DISPO-LOW' OR
*         SCREEN-NAME = 'S_NAISB-LOW' OR
*         SCREEN-NAME = 'S_NAINB-LOW'.
*        SCREEN-REQUIRED = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

**--- 長期計画の必須処理
*  IF P_TYOUKI = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'P_PLSCN'.
*        SCREEN-REQUIRED = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
**--- 計画期間範囲の必須処理
*  IF P_GAISEI = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'S_EKORG-LOW' OR
*         SCREEN-NAME = 'S_EKGRP-LOW' OR
*         SCREEN-NAME = 'S_GAISB-LOW' OR
*         SCREEN-NAME = 'S_GAINB-LOW'.
*        SCREEN-REQUIRED = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
**--- 調達計画の必須処理
*  LOOP AT SCREEN.
*    IF SCREEN-NAME = 'S_KIKAN-HIGH'.
*      SCREEN-REQUIRED = 1.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.

*---
  IF P_YM IS INITIAL.
    IF SY-DATUM+4(2) = '12'.
      P_YM = SY-DATUM+0(6) + 89.
      W_YM = P_YM.
    ELSE.
      P_YM = SY-DATUM+0(6) + 1.
      W_YM = P_YM.
    ENDIF.
  ENDIF.

  IF P_KIKAN IS INITIAL.
    CONCATENATE P_YM '01' INTO P_KIKAN.
  ENDIF.

*---------------------------------------------------------------------*
*       AT SELECTION-SCREEN
*---------------------------------------------------------------------*
AT SELECTION-SCREEN .
*--- 選択画面チェック処理
  PERFORM FRM_CHKSCREEN.

*--- ALVレイアウトの検索ヘルプ
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARIAN.
  PERFORM frm_help_alv.

*---------------------------------------------------------------------*
*       START-OF-SELECTION.
*---------------------------------------------------------------------*
START-OF-SELECTION.

*--- 選択画面必須チェック処理
  PERFORM FRM_CHK_MASTSCREEN CHANGING W_RETURN.
  IF W_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*--- 月初日、月末日の取得
  PERFORM FRM_FLDATE CHANGING W_RETURN.
  IF W_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*--- データ取得
  PERFORM FRM_GETMAINDATA CHANGING W_RETURN.
  IF W_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.
*--- ALV関連定義
  PERFORM FRM_ALVDIFINITION CHANGING W_RETURN.
  IF W_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*-- ALV出力
  PERFORM FRM_OUTPUTALV.

*&---------------------------------------------------------------------*
*& Form FRM_INITFORM
*&---------------------------------------------------------------------*
*& 変数初期化
*&---------------------------------------------------------------------*
FORM FRM_INITFORM .

*--- 変数初期化
  CLEAR:TD_OUTALV,
        TD_BKALV,
        TD_HSM,
        TD_HSM_S,
        TD_HNM,
        TD_HNM_S,
        TD_MARC,
        TD_CM_MARA,
        TD_VBEP_N,
        TD_VBEP_O,
        TD_VBEP_CHK,
        TD_RESB,
        TD_LIPS,
        TD_PLAF,
        TD_EKET,
        TD_SYUKKA,
        TD_SYUKKO,
        TD_NYUUKO,
        TD_MARDH,
        TD_FIELDCAT,
        TD_SORTINFO,
        TD_BDCDATA,
        TD_LOCK,
        TD_EBELN,
        TD_KANBAN,
        TD_KEIKAKU,
        TH_OUTALV,
        TH_HSM,
        TH_HSM_S,
        TH_HNM,
        TH_HNM_S,
        TH_T001W,
        TH_SORTINFO,
        TH_LAYOUT,
        TH_BDCDATA,
        TH_DISVARIANT,
        TH_LOCK,
        RD_DAY,
        RH_DAY,
        W_FDATE_ML,
        W_FDATE_M0,
        W_LDATE_M0,
        W_KDATE_M0,
        W_SDATE_M0,
        W_KDATE_M1,
        W_SDATE_M1,
        W_KDATE_M2,
        W_SDATE_M2,
        W_FIELD1,
        W_FIELD2,
        W_FIELD3,
        W_EDITMD,
        W_RETURN,
        W_TABIX,
        W_UCOMM,
        W_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CHKSCREEN
*&---------------------------------------------------------------------*
*& 選択画面必須チェック処理
*&---------------------------------------------------------------------*
FORM FRM_CHK_MASTSCREEN CHANGING OW_RETURN TYPE FLAG.

*--- 出荷計画の必須処理
  IF P_SEIHIN = 'X'.
    IF S_VKORG IS INITIAL.
      MESSAGE S076(ZMM001) DISPLAY LIKE 'E'. "販売組織は必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_VTWEG IS INITIAL.
      MESSAGE S077(ZMM001) DISPLAY LIKE 'E'. "流通チャネルは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_SPART IS INITIAL.
      MESSAGE S078(ZMM001) DISPLAY LIKE 'E'. "製品部門は必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_SEISB IS INITIAL.
      MESSAGE S079(ZMM001) DISPLAY LIKE 'E'. "出荷実績移動タイプは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

*--- 生産計画の必須処理
  IF P_NAISEI = 'X'.
    IF S_DISPO IS INITIAL.
      MESSAGE S080(ZMM001) DISPLAY LIKE 'E'. "MRP管理者は必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_NAISB IS INITIAL.
      MESSAGE S081(ZMM001) DISPLAY LIKE 'E'. "出庫実績移動タイプは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_NAINB IS INITIAL.
      MESSAGE S082(ZMM001) DISPLAY LIKE 'E'. "入庫実績移動タイプは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

*--- 長期計画の必須処理
  IF P_TYOUKI = 'X'.
    IF P_PLSCN IS INITIAL.
      MESSAGE S083(ZMM001) DISPLAY LIKE 'E'. "LET計画シナリオは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

*--- 計画期間範囲の必須処理
  IF P_GAISEI = 'X'.
    IF S_EKORG IS INITIAL.
      MESSAGE S084(ZMM001) DISPLAY LIKE 'E'. "購買組織は必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_EKGRP IS INITIAL.
      MESSAGE S085(ZMM001) DISPLAY LIKE 'E'. "購買グループは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_GAISB IS INITIAL.
      MESSAGE S086(ZMM001) DISPLAY LIKE 'E'. "出庫実績移動タイプは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
    IF S_GAINB IS INITIAL.
      MESSAGE S087(ZMM001) DISPLAY LIKE 'E'. "入庫実績移動タイプは必須項目です
      OW_RETURN = 'X'.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CHKSCREEN
*&---------------------------------------------------------------------*
*& 選択画面チェック処理
*&---------------------------------------------------------------------*
FORM FRM_CHKSCREEN .

  DATA:LW_DATE_L  TYPE D,
       LW_DATE_H  TYPE D.

*--- 処理年月チェック
  CONCATENATE P_YM CNS_FIRSTDAY INTO W_FDATE_M0.

* 日付妥当性チェック
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      DATE                            = W_FDATE_M0
    EXCEPTIONS
      PLAUSIBILITY_CHECK_FAILED       = 1
      OTHERS                          = 2
            .
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZMM001). "年月(YYYYMM)を指定してください
  ENDIF.

*--- チェックボックスチェック
  IF P_SEIHIN = 'X' AND P_NAISEI = '' AND P_GAISEI = ''  OR
     P_SEIHIN = ''  AND P_NAISEI = 'X' AND P_GAISEI = ''  OR
     P_SEIHIN = ''  AND P_NAISEI = ''  AND P_GAISEI = 'X'.
  ELSE.
    MESSAGE E002(ZMM001). "出荷計画、生産計画、調達計画のチェックボックスは、いずれか一つをONにしてください
  ENDIF.

*--- ALVレイアウトチェック
  IF P_VARIAN IS NOT INITIAL.

    TH_DISVARIANT-REPORT = SY-REPID.
    TH_DISVARIANT-VARIANT = P_VARIAN.

    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      CHANGING
        cs_variant          = TH_DISVARIANT
      EXCEPTIONS
        WRONG_INPUT         = 1
        NOT_FOUND           = 2
        PROGRAM_ERROR       = 3
        OTHERS              = 4.

    IF SY-SUBRC = 0.
      TH_DISVARIANT-REPORT = SY-REPID.
    ELSE.
      MESSAGE E015(ZMM001) WITH P_VARIAN. "レイアウト XXX は登録されていません
    ENDIF.
  ENDIF.

*--- 対象年月開始日チェック
  LW_DATE_L = W_FDATE_M0 - 15.
  LW_DATE_H = W_FDATE_M0 + 15.

  IF P_KIKAN >= LW_DATE_L AND P_KIKAN <= LW_DATE_H.
  ELSE.
    MESSAGE E021(ZMM001) WITH LW_DATE_L LW_DATE_H. "対象年月開始日は &1 ～ &2 の間で指定可能です
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_HELP_ALV
*&---------------------------------------------------------------------*
*& ALVレイアウトの検索ヘルプ
*&---------------------------------------------------------------------*
FORM frm_help_alv.
  DATA:
    lth_vari    TYPE disvariant.

  lth_vari-report = sy-repid.
  lth_vari-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = lth_vari
      i_save        = cns_save
    IMPORTING
      es_variant    = lth_vari
    EXCEPTIONS
      not_found     = 0
      program_error = 0
      OTHERS        = 0.

  p_varian = lth_vari-variant.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FLDATE
*&---------------------------------------------------------------------*
*& 月初日、月末日の取得
*&---------------------------------------------------------------------*
*&      <-- W_RETURN リターンフラグ
*&---------------------------------------------------------------------*
FORM FRM_FLDATE CHANGING OW_RETURN TYPE FLAG.

  DATA:LW_MONTH  TYPE VDM_YEARMONTH,
       LW_MONTHL TYPE VDM_YEARMONTH.

  LW_MONTH = P_YM.

  IF P_YM+4(2) = '01'.
    LW_MONTHL = P_YM - 89.
  ELSE.
    LW_MONTHL = P_YM - 1.
  ENDIF.
*--- 前月月初日の取得
  CONCATENATE LW_MONTHL CNS_FIRSTDAY INTO W_FDATE_ML.

*--- 当月の月初日、月末日の取得
  CONCATENATE LW_MONTH CNS_FIRSTDAY INTO W_FDATE_M0.

  CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
    EXPORTING
      iv_date                   = P_KIKAN
    IMPORTING
      EV_MONTH_END_DATE         = W_LDATE_M0.

*--- 当月開始日・終了日の取得
  W_KDATE_M0 = P_KIKAN.
  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      MONTHS          = 1
      OLDDATE         = W_KDATE_M0
    IMPORTING
      NEWDATE         = W_KDATE_M1.

  W_SDATE_M0 = W_KDATE_M1 - 1.

*--- 来月開始日・終了日の取得
  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      MONTHS          = 2
      OLDDATE         = W_KDATE_M0
    IMPORTING
      NEWDATE         = W_KDATE_M2.

  W_SDATE_M1 = W_KDATE_M2 - 1.

*--- 再来月開始日・終了日の取得
  CALL FUNCTION 'MONTH_PLUS_DETERMINE'
    EXPORTING
      MONTHS          = 3
      OLDDATE         = W_KDATE_M0
    IMPORTING
      NEWDATE         = W_KDATE_M3.

  W_SDATE_M2 = W_KDATE_M3 - 1.

  IF W_LDATE_M0 IS INITIAL OR
     W_KDATE_M0 IS INITIAL OR
     W_SDATE_M0 IS INITIAL OR
     W_KDATE_M1 IS INITIAL OR
     W_SDATE_M1 IS INITIAL OR
     W_KDATE_M2 IS INITIAL OR
     W_SDATE_M2 IS INITIAL .
    MESSAGE S003(ZMM001) DISPLAY LIKE 'E'. "処理日の取得に失敗しました
    OW_RETURN = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETDATA
*&---------------------------------------------------------------------*
*& データ取得
*&---------------------------------------------------------------------*
*&      <-- W_RETURN リターンフラグ
*&---------------------------------------------------------------------*
FORM FRM_GETMAINDATA CHANGING OW_RETURN TYPE FLAG.

*--- 対象品目取得
  PERFORM FRM_GETMARD CHANGING OW_RETURN
                               TD_MARC.
  IF OW_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*--- TVARV取得
  PERFORM FRM_GETTVARV CHANGING OW_RETURN.
  IF OW_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*--- 出庫見込データ取得
  PERFORM FRM_GETSMIKOMI CHANGING TD_MARC TD_VBEP_N  TD_VBEP_O
                                  TD_VBEP_CHK TD_RESB TD_JIT1 TD_JIT1_CHK.

*--- 出荷データ取得
*   出荷計画がONの場合のみ実施
  IF  P_SEIHIN IS NOT INITIAL.
    PERFORM FRM_GETDELI USING    TD_MARC
                        CHANGING TD_LIPS.
  ENDIF.

*--- 入庫見込データ取得
  PERFORM FRM_GETNMIKOMI USING    TD_MARC
                         CHANGING TD_PLAF TD_EKET.

*--- 出荷実績データ取得
* 出荷計画がONの場合のみ実施
  IF  P_SEIHIN IS NOT INITIAL.
    PERFORM FRM_GETSYUKKA USING    TD_MARC
                          CHANGING TD_SYUKKA.
  ENDIF.

*--- 出庫実績データ取得
* 生産計画 OR 調達計画がONの場合のみ実施
  IF P_NAISEI IS NOT INITIAL OR
     P_GAISEI IS NOT INITIAL.
    PERFORM FRM_GETSYUKKO USING    TD_MARC
                          CHANGING TD_SYUKKO.
  ENDIF.


*--- 入庫実績データ取得
* 生産計画 OR 調達計画がONの場合のみ実施
  IF P_NAISEI IS NOT INITIAL OR
     P_GAISEI IS NOT INITIAL.
    PERFORM FRM_GETNYUUKO USING    TD_MARC
                          CHANGING TD_NYUUKO.
  ENDIF.

*--- 前月末在庫の取得
* 生産計画 OR 調達計画がONの場合のみ実施
  IF P_NAISEI IS NOT INITIAL OR
     P_GAISEI IS NOT INITIAL.
    PERFORM FRM_GETMARDH CHANGING TD_MARC
                                  OW_RETURN.
  ENDIF.

*--- かんばん収容数取得
  PERFORM FRM_GETKANBAN  USING    TD_MARC
                         CHANGING TD_KANBAN.

*--- ALV出力データ編集処理
  PERFORM FRM_EDITALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETMARD
*&---------------------------------------------------------------------*
*& 対象品目取得
*&---------------------------------------------------------------------*
*&      <-- W_RETURN　リターンフラグ
*&      <-- TD_MARC 　対象品目
*&---------------------------------------------------------------------*
FORM FRM_GETMARD  CHANGING OW_RETURN TYPE FLAG
                           OTD_MARC   LIKE TD_MARC.

*--- 品目共通項目取得
  DATA:
    lref_mat TYPE REF TO zcl_retrieve_materials.

  CREATE OBJECT lref_mat.

** 容積は立方センチメートル
*  lref_mat->set_unit(
*    iw_voleh = 'CCM'  ).

* 品目データを検索
  lref_mat->set_material_from_range(
    ird_werks = s_werks[]
    ird_matnr = s_matnr[]
  ).

* 品目データを取得
  TD_CM_MARA = lref_mat->edit_material_data( ).


*--- 対象品目・プラントの取得
  SELECT MARC~MATNR
         MARC~ZZ1_BACKNO_PLT
         MAKT~MAKTX
         MARC~WERKS
         MARA~MEINS
         MARC~EISBE
         MARC~BESKZ
         T001W~BWKEY
         T001W~FABKL
         MBEW~LFGJA
         MBEW~LFMON
         MBEW~LBKUM
    INTO TABLE OTD_MARC
    FROM MARA
    INNER JOIN MARC ON
          MARA~MATNR = MARC~MATNR
    INNER JOIN MBEW ON
          MARC~MATNR = MBEW~MATNR
      AND MARC~WERKS = MBEW~BWKEY
      AND MBEW~BWTAR = ''
    INNER JOIN MAKT ON
          MARA~MATNR = MAKT~MATNR
    INNER JOIN T001W ON
          MARC~WERKS = T001W~WERKS
    WHERE MARC~MATNR IN S_MATNR
      AND MARC~WERKS IN S_WERKS
      AND MARC~ZZ1_BACKNO_PLT IN S_BACKNO
      AND MAKT~SPRAS = SY-LANGU
      AND MARC~DISPO IN S_DISPO
   ORDER BY MARC~MATNR MARC~WERKS .

  IF SY-SUBRC <> 0.
    MESSAGE S004(ZMM001). "対象データがありません
    OW_RETURN = 'X'.
  ENDIF.

*--- 会社コード、稼働日カレンダ取得
  SELECT BWKEY
         FABKL
    UP TO 1 ROWS
    INTO TH_T001W
    FROM T001W
    WHERE WERKS IN S_WERKS.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETSMIKOMI
*&---------------------------------------------------------------------*
*& 出庫見込データ取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC 　対象品目
*&      <-- TD_VBEP_N 販売分納契約取得(最新)
*&      <-- TD_VBEP_O 販売分納契約取得(前回)
*&      <-- TD_VBEP_CHK 販売分納契約存在チェック
*&      <-- TD_RESB   入出庫予定/従属所要量
*&---------------------------------------------------------------------*
FORM FRM_GETSMIKOMI  CHANGING OTD_MARC    LIKE TD_MARC
                              OTD_VBEP_N   LIKE TD_VBEP_N
                              OTD_VBEP_O   LIKE TD_VBEP_O
                              OTD_VBEP_CHK LIKE TD_VBEP_CHK
                              OTD_RESB     LIKE TD_RESB
                              OTD_JIT1     LIKE TD_JIT1
                              OTD_JIT1_CHK LIKE TD_JIT1_CHK.

*--- 販売分納契約取得
  PERFORM FRM_GETVBEP CHANGING OTD_MARC
                               OTD_VBEP_N
                               OTD_VBEP_O
                               OTD_VBEP_CHK.

*--- JIT伝票取得
  PERFORM FRM_GETJIT1 USING    OTD_MARC
                      CHANGING OTD_JIT1
                               OTD_JIT1_CHK.

*--- 入出庫予定/従属所要量取得
  PERFORM FRM_GETRESB USING    OTD_MARC
                      CHANGING OTD_RESB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETVBEP
*&---------------------------------------------------------------------*
*& 販売分納契約取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC 　対象品目
*&      <-- TD_VBEP_N 販売分納契約取得(最新)
*&      <-- TD_VBEP_O 販売分納契約取得(前回)
*&      <-- TD_VBEP_CHK 販売分納契約存在チェック用
*&---------------------------------------------------------------------*
FORM FRM_GETVBEP  CHANGING OTD_MARC     LIKE TD_MARC
                           OTD_VBEP_N   LIKE TD_VBEP_N
                           OTD_VBEP_O   LIKE TD_VBEP_O
                           OTD_VBEP_CHK LIKE TD_VBEP_CHK.

  DATA :
    LW_ABART  TYPE VBEP-ABART,
    LW_VBELN  TYPE VBLB-VBELN,
    LW_POSNR  TYPE VBLB-POSNR,
    LW_ABRLI  TYPE VBLB-ABRLI,
    LH_VBEP_O TYPE STANDARD TABLE OF TYP_VBEP.

  CLEAR OTD_VBEP_O.

*--- 販売分納契約取得(最新)
  SELECT VBEP~ABART,
         VBAK~VBELN,
         VBAP~POSNR,
         VBAP~ABGRU,
         VBAP~MATNR,
         VBAP~WERKS,
         VBAP~LGORT,
         VBAK~VKORG,
         TVKOT~VTEXT,
         VBAK~VTWEG,
         TVTWT~VTEXT,
         VBAK~SPART,
         TSPAT~VTEXT,
         AG~KUNNR,
         ADAG~NAME1,
         WE~KUNNR,
         ADWE~NAME1,
         VBAP~KDMAT,
         VBAP~VSTEL,
         TVSTT~VTEXT,
         VBAK~ABRVW,
         VBAP~VKAUS,
         WE~KNREF,
         KNB1~KVERM,
         VBLB~ABRLI,
         VBLB~LABNK,
         VBEP~EDATU,
         VBEP~WMENG
    INTO TABLE @OTD_VBEP_N
    FROM VBAK
   INNER JOIN VBAP ON
         VBAP~VBELN = VBAK~VBELN
   INNER JOIN VBEP ON
         VBEP~VBELN = VBAP~VBELN
     AND VBEP~POSNR = VBAP~POSNR
   INNER JOIN VBPA AS AG ON
         AG~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADAG ON
         ADAG~ADDRNUMBER = AG~ADRNR
   INNER JOIN VBPA AS WE ON
         WE~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADWE ON
         ADWE~ADDRNUMBER = WE~ADRNR
   INNER JOIN VBLB ON
         VBLB~VBELN = VBEP~VBELN
     AND VBLB~POSNR = VBEP~POSNR
     AND VBLB~ABART = VBEP~ABART
   INNER JOIN TVKO ON
         TVKO~VKORG = VBAK~VKORG
   INNER JOIN TVKOT ON
         TVKOT~SPRAS = @SY-LANGU
     AND TVKOT~VKORG = VBAK~VKORG
   INNER JOIN TVTWT ON
         TVTWT~SPRAS = @SY-LANGU
     AND TVTWT~VTWEG = VBAK~VTWEG
   INNER JOIN TSPAT ON
         TSPAT~SPRAS = @SY-LANGU
     AND TSPAT~SPART = VBAK~SPART
   INNER JOIN KNVP ON
         KNVP~KUNNR = AG~KUNNR
     AND KNVP~VKORG = VBAK~VKORG
     AND KNVP~VTWEG = VBAK~VTWEG
     AND KNVP~SPART = VBAK~SPART
     AND KNVP~PARVW = @CNS_WE
     AND KNVP~KUNN2 = WE~KUNNR
   INNER JOIN KNB1 ON
         KNB1~KUNNR = AG~KUNNR
     AND KNB1~BUKRS = TVKO~BUKRS
   INNER JOIN TVSTT ON
         TVSTT~SPRAS = @SY-LANGU
     AND TVSTT~VSTEL = VBAP~VSTEL
     FOR ALL ENTRIES IN @OTD_MARC
   WHERE VBAK~AUART IN @RD_AUART
     AND VBAK~VKORG IN @S_VKORG
     AND VBAK~VTWEG IN @S_VTWEG
     AND VBAK~SPART IN @S_SPART
     AND VBAP~MATNR = @OTD_MARC-MATNR
     AND VBAP~KDMAT IN @S_KDMAT
     AND VBAP~WERKS = @OTD_MARC-WERKS
     AND VBAP~LGORT IN @S_LGORT
*     AND VBAP~ABGRU = ''
     AND ( VBEP~EDATU >= @W_KDATE_M0 AND
           VBEP~EDATU <= @W_SDATE_M2 )
     AND VBEP~WMENG <> 0
     AND ( VBEP~ABART = @CNS_1 OR
           VBEP~ABART = @CNS_5 )
     AND AG~POSNR = @CNS_HDR
     AND AG~PARVW = @CNS_AG
     AND AG~KUNNR IN @S_KUNAG
     AND ADAG~DATE_FROM  <= @SY-DATUM
     AND ADAG~DATE_TO    >= @SY-DATUM
     AND ADAG~NATION     = ''
     AND WE~POSNR = @CNS_HDR
     AND WE~PARVW = @CNS_WE
     AND WE~KUNNR IN @S_KUNWE
     AND ADWE~DATE_FROM  <= @SY-DATUM
     AND ADWE~DATE_TO    >= @SY-DATUM
     AND ADWE~NATION     = ''
     AND VBLB~ABRLI = ''.

  SORT OTD_VBEP_N BY ABART VBELN POSNR MATNR WERKS LGORT
                   VKORG VTWEG SPART KUNAG KUNWE KDMAT ABRLI LABNK EDATU .

  DATA:LTH_VBEP_SUB LIKE LINE OF TD_VBEP_SUB.

  LOOP AT OTD_VBEP_N ASSIGNING FIELD-SYMBOL(<FS_N>).
    AT NEW POSNR.
      LTH_VBEP_SUB-VBELN = <FS_N>-VBELN.
      LTH_VBEP_SUB-POSNR = <FS_N>-POSNR.
      APPEND LTH_VBEP_SUB TO TD_VBEP_SUB.
    ENDAT.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM TD_VBEP_SUB.

*--- 販売分納契約取得(旧)
  IF OTD_VBEP_N IS NOT INITIAL.

    SELECT VBLB~ABART,
           VBAK~VBELN,
           VBAP~POSNR,
           VBAP~ABGRU,
           VBAP~MATNR,
           VBAP~WERKS,
           VBAP~LGORT,
           VBAK~VKORG,
           TVKOT~VTEXT,
           VBAK~VTWEG,
           TVTWT~VTEXT,
           VBAK~SPART,
           TSPAT~VTEXT,
           AG~KUNNR,
           ADAG~NAME1,
           WE~KUNNR,
           ADWE~NAME1,
           VBAP~KDMAT,
           VBAP~VSTEL,
           TVSTT~VTEXT,
           VBAK~ABRVW,
           VBAP~VKAUS,
           WE~KNREF,
           KNB1~KVERM,
           VBLB~ABRLI,
           VBLB~LABNK,
           VBEH~EDATU,
           VBEH~WMENG
      INTO TABLE @LH_VBEP_O
      FROM VBAK
     INNER JOIN VBAP ON
           VBAK~VBELN = VBAP~VBELN
     INNER JOIN VBPA AS AG ON
           AG~VBELN = VBAK~VBELN
     INNER JOIN ADRC AS ADAG ON
           ADAG~ADDRNUMBER = AG~ADRNR
     INNER JOIN VBPA AS WE ON
           WE~VBELN = VBAK~VBELN
     INNER JOIN ADRC AS ADWE ON
           ADWE~ADDRNUMBER = WE~ADRNR
     INNER JOIN VBLB ON
           VBAP~VBELN = VBLB~VBELN
       AND VBAP~POSNR = VBLB~POSNR
     INNER JOIN VBEH ON
           VBLB~VBELN = VBEH~VBELN
       AND VBLB~POSNR = VBEH~POSNR
       AND VBLB~ABRLI = VBEH~ABRLI
       AND VBLB~ABART = VBEH~ABART
     INNER JOIN TVKO ON
           TVKO~VKORG = VBAK~VKORG
     INNER JOIN TVKOT ON
           TVKOT~SPRAS = @SY-LANGU
       AND TVKOT~VKORG = VBAK~VKORG
     INNER JOIN TVTWT ON
           TVTWT~SPRAS = @SY-LANGU
       AND TVTWT~VTWEG = VBAK~VTWEG
     INNER JOIN TSPAT ON
           TSPAT~SPRAS = @SY-LANGU
       AND TSPAT~SPART = VBAK~SPART
     INNER JOIN KNVP ON
           KNVP~KUNNR = AG~KUNNR
       AND KNVP~VKORG = VBAK~VKORG
       AND KNVP~VTWEG = VBAK~VTWEG
       AND KNVP~SPART = VBAK~SPART
       AND KNVP~PARVW = @CNS_WE
       AND KNVP~KUNN2 = WE~KUNNR
     INNER JOIN KNB1 ON
           KNB1~KUNNR = AG~KUNNR
       AND KNB1~BUKRS = TVKO~BUKRS
     INNER JOIN TVSTT ON
           TVSTT~SPRAS = @SY-LANGU
       AND TVSTT~VSTEL = VBAP~VSTEL
       FOR ALL ENTRIES IN @TD_VBEP_SUB
     WHERE VBAP~VBELN = @TD_VBEP_SUB-VBELN
       AND VBAP~POSNR = @TD_VBEP_SUB-POSNR
*       AND VBAP~ABGRU = ''
       AND AG~POSNR = @CNS_HDR
       AND AG~PARVW = @CNS_AG
       AND AG~KUNNR IN @S_KUNAG
       AND ADAG~DATE_FROM  <= @SY-DATUM
       AND ADAG~DATE_TO    >= @SY-DATUM
       AND ADAG~NATION     = ''
       AND WE~POSNR = @CNS_HDR
       AND WE~PARVW = @CNS_WE
       AND WE~KUNNR IN @S_KUNWE
       AND ADWE~DATE_FROM  <= @SY-DATUM
       AND ADWE~DATE_TO    >= @SY-DATUM
       AND ADWE~NATION     = ''
       AND VBLB~ABRLI <> ''.

    SORT LH_VBEP_O BY ABART VBELN POSNR MATNR WERKS LGORT
                     VKORG VTWEG SPART KUNAG KUNWE KDMAT ABRLI LABNK EDATU .

*--- 必要なデータのみを書き込み
*   販売伝票、販売伝票明細、承認タイプ単位で、内部納入日程番号が最も若い番号(前バージョン)のデータが前回バージョンとなる
    LOOP AT LH_VBEP_O ASSIGNING FIELD-SYMBOL(<FS_VBEP>).
      AT NEW POSNR.
       LW_ABART = <FS_VBEP>-ABART.
       LW_VBELN = <FS_VBEP>-VBELN .
       LW_POSNR = <FS_VBEP>-POSNR.
       LW_ABRLI = <FS_VBEP>-ABRLI.
      ENDAT.

      IF LW_ABART = <FS_VBEP>-ABART AND
         LW_VBELN = <FS_VBEP>-VBELN AND
         LW_POSNR = <FS_VBEP>-POSNR AND
         LW_ABRLI = <FS_VBEP>-ABRLI.
        APPEND <FS_VBEP> TO OTD_VBEP_O.
      ENDIF.

    ENDLOOP.

    SORT OTD_VBEP_O BY ABART VBELN POSNR MATNR WERKS LGORT
                     VKORG VTWEG SPART KUNAG KUNWE KDMAT ABRLI LABNK EDATU .
  ENDIF.

*--- 販売分納契約存在チェック用(納入日程ありパターン)
  SELECT VBAK~VBELN,
         VBAP~POSNR,
         VBAP~ABGRU,
         VBAP~MATNR,
         VBAP~WERKS,
         VBAP~LGORT,
         VBAK~VKORG,
         TVKOT~VTEXT,
         VBAK~VTWEG,
         TVTWT~VTEXT,
         VBAK~SPART,
         TSPAT~VTEXT,
         AG~KUNNR,
         ADAG~NAME1,
         WE~KUNNR,
         ADWE~NAME1,
         VBAP~KDMAT,
         VBAP~VSTEL,
         TVSTT~VTEXT,
         VBAK~ABRVW,
         VBAP~VKAUS,
         WE~KNREF,
         KNB1~KVERM,
         VBLB~LABNK
    INTO TABLE @OTD_VBEP_CHK
    FROM VBAK
   INNER JOIN VBAP ON
         VBAK~VBELN = VBAP~VBELN
   INNER JOIN VBEP ON
         VBEP~VBELN = VBAP~VBELN
     AND VBEP~POSNR = VBAP~POSNR
   INNER JOIN VBLB ON
         VBLB~VBELN = VBEP~VBELN
     AND VBLB~POSNR = VBEP~POSNR
     AND VBLB~ABART = VBEP~ABART
   INNER JOIN VBPA AS AG ON
         AG~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADAG ON
         ADAG~ADDRNUMBER = AG~ADRNR
   INNER JOIN VBPA AS WE ON
         WE~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADWE ON
         ADWE~ADDRNUMBER = WE~ADRNR
   INNER JOIN TVKO ON
         TVKO~VKORG = VBAK~VKORG
   INNER JOIN TVKOT ON
         TVKOT~SPRAS = @SY-LANGU
     AND TVKOT~VKORG = VBAK~VKORG
   INNER JOIN TVTWT ON
         TVTWT~SPRAS = @SY-LANGU
     AND TVTWT~VTWEG = VBAK~VTWEG
   INNER JOIN TSPAT ON
         TSPAT~SPRAS = @SY-LANGU
     AND TSPAT~SPART = VBAK~SPART
   INNER JOIN KNVP ON
         KNVP~KUNNR = AG~KUNNR
     AND KNVP~VKORG = VBAK~VKORG
     AND KNVP~VTWEG = VBAK~VTWEG
     AND KNVP~SPART = VBAK~SPART
     AND KNVP~PARVW = @CNS_WE
     AND KNVP~KUNN2 = WE~KUNNR
   INNER JOIN KNB1 ON
         KNB1~KUNNR = AG~KUNNR
     AND KNB1~BUKRS = TVKO~BUKRS
   INNER JOIN TVSTT ON
         TVSTT~SPRAS = @SY-LANGU
     AND TVSTT~VSTEL = VBAP~VSTEL
     FOR ALL ENTRIES IN @OTD_MARC
   WHERE VBAK~AUART IN @RD_AUART
     AND VBAK~VKORG IN @S_VKORG
     AND VBAK~VTWEG IN @S_VTWEG
     AND VBAK~SPART IN @S_SPART
     AND VBAK~KUNNR IN @S_KUNAG
     AND VBAP~MATNR = @OTD_MARC-MATNR
     AND VBAP~KDMAT IN @S_KDMAT
     AND VBAP~WERKS = @OTD_MARC-WERKS
     AND VBAP~LGORT IN @S_LGORT
*     AND VBAP~ABGRU = ''
     AND ( VBEP~ABART = @CNS_1 OR
           VBEP~ABART = @CNS_5 )
     AND AG~POSNR = @CNS_HDR
     AND AG~PARVW = @CNS_AG
     AND AG~KUNNR IN @S_KUNAG
     AND ADAG~DATE_FROM  <= @SY-DATUM
     AND ADAG~DATE_TO    >= @SY-DATUM
     AND ADAG~NATION     = ''
     AND WE~POSNR = @CNS_HDR
     AND WE~PARVW = @CNS_WE
     AND WE~KUNNR IN @S_KUNWE
     AND ADWE~DATE_FROM  <= @SY-DATUM
     AND ADWE~DATE_TO    >= @SY-DATUM
     AND ADWE~NATION     = ''
     AND VBLB~ABRLI = ''.

*--- 販売分納契約存在チェック用(納入日程なしパターン)
  SELECT
    FROM VBAK
   INNER JOIN VBAP ON
         VBAK~VBELN = VBAP~VBELN
   INNER JOIN VBPA AS AG ON
         AG~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADAG ON
         ADAG~ADDRNUMBER = AG~ADRNR
   INNER JOIN VBPA AS WE ON
         WE~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADWE ON
         ADWE~ADDRNUMBER = WE~ADRNR
   INNER JOIN TVKO ON
         TVKO~VKORG = VBAK~VKORG
   INNER JOIN TVKOT ON
         TVKOT~SPRAS = @SY-LANGU
     AND TVKOT~VKORG = VBAK~VKORG
   INNER JOIN TVTWT ON
         TVTWT~SPRAS = @SY-LANGU
     AND TVTWT~VTWEG = VBAK~VTWEG
   INNER JOIN TSPAT ON
         TSPAT~SPRAS = @SY-LANGU
     AND TSPAT~SPART = VBAK~SPART
   INNER JOIN KNVP ON
         KNVP~KUNNR = AG~KUNNR
     AND KNVP~VKORG = VBAK~VKORG
     AND KNVP~VTWEG = VBAK~VTWEG
     AND KNVP~SPART = VBAK~SPART
     AND KNVP~PARVW = @CNS_WE
     AND KNVP~KUNN2 = WE~KUNNR
   INNER JOIN KNB1 ON
         KNB1~KUNNR = AG~KUNNR
     AND KNB1~BUKRS = TVKO~BUKRS
   INNER JOIN TVSTT ON
         TVSTT~SPRAS = @SY-LANGU
     AND TVSTT~VSTEL = VBAP~VSTEL
   INNER JOIN @OTD_MARC AS TMARC ON
         TMARC~MATNR = VBAP~MATNR
     AND TMARC~WERKS = VBAP~WERKS
   LEFT OUTER JOIN VBEP ON
         VBEP~VBELN = VBAP~VBELN
     AND VBEP~POSNR = VBAP~POSNR
   FIELDS
         VBAK~VBELN,
         VBAP~POSNR,
         VBAP~ABGRU,
         VBAP~MATNR,
         VBAP~WERKS,
         VBAP~LGORT,
         VBAK~VKORG,
         TVKOT~VTEXT,
         VBAK~VTWEG,
         TVTWT~VTEXT,
         VBAK~SPART,
         TSPAT~VTEXT,
         AG~KUNNR,
         ADAG~NAME1,
         WE~KUNNR,
         ADWE~NAME1,
         VBAP~KDMAT,
         VBAP~VSTEL,
         TVSTT~VTEXT,
         VBAK~ABRVW,
         VBAP~VKAUS,
         WE~KNREF,
         KNB1~KVERM,
         ' '
   WHERE VBAK~AUART IN @RD_AUART
     AND VBAK~VKORG IN @S_VKORG
     AND VBAK~VTWEG IN @S_VTWEG
     AND VBAK~SPART IN @S_SPART
     AND VBAP~KDMAT IN @S_KDMAT
*     AND VBAP~ABGRU = ''
     AND VBAP~LGORT IN @S_LGORT
     AND AG~POSNR = @CNS_HDR
     AND AG~PARVW = @CNS_AG
     AND AG~KUNNR IN @S_KUNAG
     AND ADAG~DATE_FROM  <= @SY-DATUM
     AND ADAG~DATE_TO    >= @SY-DATUM
     AND ADAG~NATION     = ''
     AND WE~POSNR = @CNS_HDR
     AND WE~PARVW = @CNS_WE
     AND WE~KUNNR IN @S_KUNWE
     AND ADWE~DATE_FROM  <= @SY-DATUM
     AND ADWE~DATE_TO    >= @SY-DATUM
     AND ADWE~NATION     = ''
     AND VBEP~VBELN      IS NULL
    APPENDING TABLE @OTD_VBEP_CHK.

  SORT OTD_VBEP_CHK.
  DELETE ADJACENT DUPLICATES FROM OTD_VBEP_CHK COMPARING VBELN POSNR.

  IF P_SEIHIN = 'X'.
    LOOP AT OTD_MARC ASSIGNING FIELD-SYMBOL(<FS_MARC>).
      READ TABLE OTD_VBEP_CHK ASSIGNING FIELD-SYMBOL(<FS_VBEP_CHK>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                             WERKS = <FS_MARC>-WERKS.
      IF SY-SUBRC <> 0.
*       販売分納契約が存在しない場合、出力対象外
        DELETE OTD_MARC.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETJIT1
*&---------------------------------------------------------------------*
*& JIT伝票取得取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC 　対象品目
*&      <-- OTD_JIT1　JIT伝票
*&---------------------------------------------------------------------*
FORM FRM_GETJIT1  USING    ITD_MARC LIKE TD_MARC
                  CHANGING OTD_JIT1 LIKE TD_JIT1
                           OTD_JIT1_CHK LIKE TD_JIT1_CHK.

  DATA:LW_TIMES_F TYPE TZONREF-TSTAMPS,"タイムスタンプFROM
       LW_TIMES_T TYPE TZONREF-TSTAMPS,"タイムスタンプTO
       LW_TIME    TYPE SY-UZEIT.

*--- タイムスタンプ変換
  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      i_datlo           = W_KDATE_M0
      I_TIMLO           = LW_TIME
   IMPORTING
      E_TIMESTAMP       = LW_TIMES_F.

  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      i_datlo           = W_SDATE_M2
      I_TIMLO           = LW_TIME
   IMPORTING
      E_TIMESTAMP       = LW_TIMES_T.

*--- JIT指示の取得(期間内のデータ)
  SELECT
    FROM JITMA
   INNER JOIN JITCO
      ON JITCO~MATID = JITMA~MATID
   INNER JOIN JITIT
      ON JITIT~POSID = JITCO~POSID
   INNER JOIN JITHD
      ON JITHD~JINUM = JITIT~JINUM
   INNER JOIN VBAK
      ON VBAK~VBELN = JITMA~VBELN
   INNER JOIN VBAP
      ON VBAP~VBELN = JITMA~VBELN
     AND VBAP~POSNR = JITMA~POSNR
   INNER JOIN VBPA AS AG ON
         AG~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADAG ON
         ADAG~ADDRNUMBER = AG~ADRNR
   INNER JOIN VBPA AS WE ON
         WE~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADWE ON
         ADWE~ADDRNUMBER = WE~ADRNR
   INNER JOIN TVKO ON
         TVKO~VKORG = VBAK~VKORG
   INNER JOIN TVKOT ON
         TVKOT~SPRAS = @SY-LANGU
     AND TVKOT~VKORG = VBAK~VKORG
   INNER JOIN TVTWT ON
         TVTWT~SPRAS = @SY-LANGU
     AND TVTWT~VTWEG = VBAK~VTWEG
   INNER JOIN TSPAT ON
         TSPAT~SPRAS = @SY-LANGU
     AND TSPAT~SPART = VBAK~SPART
   INNER JOIN KNVP ON
         KNVP~KUNNR = AG~KUNNR
     AND KNVP~VKORG = VBAK~VKORG
     AND KNVP~VTWEG = VBAK~VTWEG
     AND KNVP~SPART = VBAK~SPART
     AND KNVP~PARVW = @CNS_WE
     AND KNVP~KUNN2 = WE~KUNNR
   INNER JOIN KNB1 ON
         KNB1~KUNNR = AG~KUNNR
     AND KNB1~BUKRS = TVKO~BUKRS
   INNER JOIN TVSTT ON
         TVSTT~SPRAS = @SY-LANGU
     AND TVSTT~VSTEL = VBAP~VSTEL
   INNER JOIN @ITD_MARC AS TMARC ON
         TMARC~MATNR = VBAP~MATNR
     AND TMARC~WERKS = VBAP~WERKS
   FIELDS
         VBAK~VBELN,
         VBAP~POSNR,
         VBAP~ABGRU,
         VBAP~MATNR,
         VBAP~WERKS,
         VBAP~LGORT,
         VBAK~VKORG,
         TVKOT~VTEXT,
         VBAK~VTWEG,
         TVTWT~VTEXT,
         VBAK~SPART,
         TSPAT~VTEXT,
         AG~KUNNR,
         ADAG~NAME1,
         WE~KUNNR,
         ADWE~NAME1,
         VBAP~KDMAT,
         VBAP~VSTEL,
         TVSTT~VTEXT,
         VBAK~ABRVW,
         VBAP~VKAUS,
         WE~KNREF,
         KNB1~KVERM,
         JITIT~RDATE,
         JITCO~QUANT
   WHERE VBAK~AUART IN @RD_AUART
     AND VBAK~VKORG IN @S_VKORG
     AND VBAK~VTWEG IN @S_VTWEG
     AND VBAK~SPART IN @S_SPART
     AND VBAP~KDMAT IN @S_KDMAT
     AND VBAP~LGORT IN @S_LGORT
*     AND VBAP~ABGRU = ''
     AND AG~POSNR = @CNS_HDR
     AND AG~PARVW = @CNS_AG
     AND AG~KUNNR IN @S_KUNAG
     AND ADAG~DATE_FROM  <= @SY-DATUM
     AND ADAG~DATE_TO    >= @SY-DATUM
     AND ADAG~NATION     = ''
     AND WE~POSNR = @CNS_HDR
     AND WE~PARVW = @CNS_WE
     AND WE~KUNNR IN @S_KUNWE
     AND ADWE~DATE_FROM  <= @SY-DATUM
     AND ADWE~DATE_TO    >= @SY-DATUM
     AND ADWE~NATION     = ''
     AND JITIT~RDATE     >= @LW_TIMES_F
     AND JITIT~RDATE     <= @LW_TIMES_T
    INTO TABLE @OTD_JIT1.

*--- タイプスタンプの変換、置き場データの取得
  LOOP AT OTD_JIT1 ASSIGNING FIELD-SYMBOL(<FS_JIT1>).
*   予定所要時刻（タイムスタンプ）の日時変換→納入日
    CALL FUNCTION 'IB_CONVERT_FROM_TIMESTAMP'
      EXPORTING
        i_timestamp       = <FS_JIT1>-RDATE
      IMPORTING
        E_DATLO           = <FS_JIT1>-LFDAT
        E_TIMLO           = <FS_JIT1>-LFTIME.

   PERFORM FRM_GETSDT0003 USING    <FS_JIT1>-KUNWE     <FS_JIT1>-MATNR
                          CHANGING <FS_JIT1>-PICKLO    <FS_JIT1>-SHIPPINGRO
                                   <FS_JIT1>-SUPPLYRO  <FS_JIT1>-SUPPLYFIN
                                   <FS_JIT1>-CARTONRTN <FS_JIT1>-CARTONDAY
                                   <FS_JIT1>-SUPPLYCNT <FS_JIT1>-MILKRUN.
  ENDLOOP.

*--- JIT指示の取得(全データ)
  SELECT
    FROM JITMA
   INNER JOIN JITCO
      ON JITCO~MATID = JITMA~MATID
   INNER JOIN JITIT
      ON JITIT~POSID = JITCO~POSID
   INNER JOIN JITHD
      ON JITHD~JINUM = JITIT~JINUM
   INNER JOIN VBAK
      ON VBAK~VBELN = JITMA~VBELN
   INNER JOIN VBAP
      ON VBAP~VBELN = JITMA~VBELN
     AND VBAP~POSNR = JITMA~POSNR
   INNER JOIN VBPA AS AG ON
         AG~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADAG ON
         ADAG~ADDRNUMBER = AG~ADRNR
   INNER JOIN VBPA AS WE ON
         WE~VBELN = VBAK~VBELN
   INNER JOIN ADRC AS ADWE ON
         ADWE~ADDRNUMBER = WE~ADRNR
   INNER JOIN TVKO ON
         TVKO~VKORG = VBAK~VKORG
   INNER JOIN TVKOT ON
         TVKOT~SPRAS = @SY-LANGU
     AND TVKOT~VKORG = VBAK~VKORG
   INNER JOIN TVTWT ON
         TVTWT~SPRAS = @SY-LANGU
     AND TVTWT~VTWEG = VBAK~VTWEG
   INNER JOIN TSPAT ON
         TSPAT~SPRAS = @SY-LANGU
     AND TSPAT~SPART = VBAK~SPART
   INNER JOIN KNVP ON
         KNVP~KUNNR = AG~KUNNR
     AND KNVP~VKORG = VBAK~VKORG
     AND KNVP~VTWEG = VBAK~VTWEG
     AND KNVP~SPART = VBAK~SPART
     AND KNVP~PARVW = @CNS_WE
     AND KNVP~KUNN2 = WE~KUNNR
   INNER JOIN KNB1 ON
         KNB1~KUNNR = AG~KUNNR
     AND KNB1~BUKRS = TVKO~BUKRS
   INNER JOIN TVSTT ON
         TVSTT~SPRAS = @SY-LANGU
     AND TVSTT~VSTEL = VBAP~VSTEL
   INNER JOIN @ITD_MARC AS TMARC ON
         TMARC~MATNR = VBAP~MATNR
     AND TMARC~WERKS = VBAP~WERKS
   FIELDS
         VBAK~VBELN,
         VBAP~POSNR,
         VBAP~ABGRU,
         VBAP~MATNR,
         VBAP~WERKS,
         VBAP~LGORT,
         VBAK~VKORG,
         TVKOT~VTEXT,
         VBAK~VTWEG,
         TVTWT~VTEXT,
         VBAK~SPART,
         TSPAT~VTEXT,
         AG~KUNNR,
         ADAG~NAME1,
         WE~KUNNR,
         ADWE~NAME1,
         VBAP~KDMAT,
         VBAP~VSTEL,
         TVSTT~VTEXT,
         VBAK~ABRVW,
         VBAP~VKAUS,
         WE~KNREF,
         KNB1~KVERM
   WHERE VBAK~AUART IN @RD_AUART
     AND VBAK~VKORG IN @S_VKORG
     AND VBAK~VTWEG IN @S_VTWEG
     AND VBAK~SPART IN @S_SPART
     AND VBAK~KUNNR IN @S_KUNAG
     AND VBAP~KDMAT IN @S_KDMAT
*     AND VBAP~ABGRU = ''
     AND VBAP~LGORT IN @S_LGORT
     AND AG~POSNR = @CNS_HDR
     AND AG~PARVW = @CNS_AG
     AND AG~KUNNR IN @S_KUNAG
     AND ADAG~DATE_FROM  <= @SY-DATUM
     AND ADAG~DATE_TO    >= @SY-DATUM
     AND ADAG~NATION     = ''
     AND WE~POSNR = @CNS_HDR
     AND WE~PARVW = @CNS_WE
     AND WE~KUNNR IN @S_KUNWE
     AND ADWE~DATE_FROM  <= @SY-DATUM
     AND ADWE~DATE_TO    >= @SY-DATUM
     AND ADWE~NATION     = ''
     AND JITIT~RDATE     >= @LW_TIMES_F
     AND JITIT~RDATE     <= @LW_TIMES_T
    INTO TABLE @OTD_JIT1_CHK.

  SORT OTD_JIT1_CHK.
  DELETE ADJACENT DUPLICATES FROM OTD_JIT1_CHK COMPARING VBELN POSNR.

*--- 置き場データの取得
  LOOP AT OTD_JIT1_CHK ASSIGNING FIELD-SYMBOL(<FS_JIT1_CHK>).

   PERFORM FRM_GETSDT0003 USING    <FS_JIT1_CHK>-KUNWE     <FS_JIT1_CHK>-MATNR
                          CHANGING <FS_JIT1_CHK>-PICKLO    <FS_JIT1_CHK>-SHIPPINGRO
                                   <FS_JIT1_CHK>-SUPPLYRO  <FS_JIT1_CHK>-SUPPLYFIN
                                   <FS_JIT1_CHK>-CARTONRTN <FS_JIT1_CHK>-CARTONDAY
                                   <FS_JIT1_CHK>-SUPPLYCNT <FS_JIT1_CHK>-MILKRUN.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETSDT0003
*&---------------------------------------------------------------------*
*& 置き場データの取得
*&---------------------------------------------------------------------*
FORM FRM_GETSDT0003  USING    IW_KUNWE TYPE ZSDT0003-KUNWE
                              IW_MATNR TYPE ZSDT0003-MATNR
                     CHANGING OW_PICKLO TYPE ZSDT0003-ZZ1_PICKLO
                              OW_SHIPPINGRO TYPE ZSDT0003-ZZ1_SHIPPINGRO
                              OW_SUPPLYRO  TYPE ZSDT0003-ZZ1_SUPPLYRO
                              OW_SUPPLYFIN TYPE ZSDT0003-ZZ1_SUPPLYFIN
                              OW_CARTONRTN TYPE ZSDT0003-CARTONRTN
                              OW_CARTONDAY TYPE ZSDT0003-CARTONDAY
                              OW_SUPPLYCNT TYPE ZSDT0003-SUPPLYCNT
                              OW_MILKRUN   TYPE ZSDT0003-ZZ1_MILKRUN.

*--- 置き場データの取得
    SELECT
      FROM ZSDT0003
     FIELDS
           ZZ1_PICKLO,
           ZZ1_SHIPPINGRO,
           ZZ1_SUPPLYRO,
           ZZ1_SUPPLYFIN,
           CARTONRTN,
           CARTONDAY,
           SUPPLYCNT,
           ZZ1_MILKRUN
     WHERE KUNWE = @IW_KUNWE
       AND MATNR = @IW_MATNR
       AND DATAB <= @W_FDATE_M0
*       AND DEBIN = '01'
     ORDER BY DEBIN ASCENDING ,DATAB DESCENDING
      INTO ( @OW_PICKLO, @OW_SHIPPINGRO, @OW_SUPPLYRO ,
             @OW_SUPPLYFIN ,@OW_CARTONRTN , @OW_CARTONDAY,@OW_SUPPLYCNT,@OW_MILKRUN )
        UP TO 1 ROWS.
     ENDSELECT.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form FRM_GETRESB
*&---------------------------------------------------------------------*
*& 入出庫予定/従属所要量取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC 　対象品目
*&      <-- OTD_RESB　入出庫予定/従属所要量
*&---------------------------------------------------------------------*
FORM FRM_GETRESB  USING    ITD_MARC LIKE TD_MARC
                  CHANGING OTD_RESB LIKE TD_RESB.

*--- 入出庫予定/従属所要量の取得
  SELECT MATNR
         WERKS
         LGORT
         BAUGR
         BDTER
         BDMNG
         RSNUM
         RSPOS
    INTO TABLE OTD_RESB
    FROM RESB
     FOR ALL ENTRIES IN ITD_MARC
   WHERE MATNR = ITD_MARC-MATNR
     AND WERKS = ITD_MARC-WERKS
     AND BDART IN RD_BDART
     AND ( BDTER >= W_KDATE_M0 AND
           BDTER <= W_SDATE_M0 ).

  SORT OTD_RESB BY MATNR WERKS LGORT BAUGR BDTER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETDELI
*&---------------------------------------------------------------------*
*& 出荷伝票取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　対象品目
*&      <-- TD_LIPS　出荷伝票
*&---------------------------------------------------------------------*
FORM FRM_GETDELI  USING    ITD_MARC LIKE TD_MARC
                  CHANGING OTD_LIPS LIKE TD_LIPS.

*-- 出荷伝票取得
  SELECT LIPS~VGBEL
         LIPS~VGPOS
         LIPS~MATNR
         LIPS~WERKS
         LIPS~LGORT
         VBAK~VKORG
         VBAK~VTWEG
         VBAK~SPART
         LIKP~LFDAT
         LIPS~LGMNG
         LIKP~VBELN
         LIPS~POSNR
    INTO TABLE OTD_LIPS
    FROM LIKP
   INNER JOIN LIPS ON
         LIKP~VBELN = LIPS~VBELN
   INNER JOIN VBAK ON
         LIPS~VGBEL = VBAK~VBELN
     FOR ALL ENTRIES IN ITD_MARC
   WHERE LIKP~LFART IN RD_LFART
     AND ( LIKP~LFDAT >= W_KDATE_M0 AND
           LIKP~LFDAT <= W_SDATE_M0 )
     AND LIKP~KUNAG IN S_KUNAG
     AND LIKP~KUNNR IN S_KUNWE
     AND LIPS~MATNR = ITD_MARC-MATNR
     AND LIPS~WERKS = ITD_MARC-WERKS
     AND LIPS~LGORT IN S_LGORT
     AND LIPS~KDMAT IN S_KDMAT
     AND LIPS~LGMNG <> 0
     AND VBAK~VKORG IN S_VKORG
     AND VBAK~VTWEG IN S_VTWEG
     AND VBAK~SPART IN S_SPART.

  SORT OTD_LIPS BY VBELN_VA POSNR_VA MATNR WERKS LGORT VKORG VTWEG SPART LFDAT VBELN POSNR.


ENDFORM.
*& Form FRM_GETNMIKOMI
*&---------------------------------------------------------------------*
*& 入庫見込取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- TD_PLAF　　計画手配
*&      <-- TD_EKET　　購買分納契約
*&---------------------------------------------------------------------*
FORM FRM_GETNMIKOMI  USING    ITD_MARC   LIKE TD_MARC
                     CHANGING OTD_PLAF   LIKE TD_PLAF
                              OTD_EKET   LIKE TD_EKET.

*--- 計画手配取得
* 生産計画 OR 調達計画がONの場合のみ実施
  IF P_NAISEI IS NOT INITIAL OR
     P_GAISEI IS NOT INITIAL.
    PERFORM FRM_GETPLAF USING    ITD_MARC
                        CHANGING OTD_PLAF.
  ENDIF.

*--- 購買分納契約取得
* 調達計画がONの場合のみ実施
  IF P_GAISEI IS NOT INITIAL.
    PERFORM FRM_GETEKET USING    ITD_MARC
                        CHANGING OTD_EKET.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_GETPLAF
*&---------------------------------------------------------------------*
*& 計画手配取得
*&---------------------------------------------------------------------*
*&      --> ITD_MARD　対象品目
*&      <-- OTD_PLAF　計画手配
*&---------------------------------------------------------------------*
FORM FRM_GETPLAF  USING    ITD_MARC LIKE TD_MARC
                  CHANGING OTD_PLAF LIKE TD_PLAF.

  CLEAR TD_PLAF.
  DATA :
    LRD_PLSCN TYPE RANGE OF PLSCN,
    LRH_PLSCN LIKE LINE  OF LRD_PLSCN,
    LTH_PLAF  LIKE LINE  OF TD_PLAF,
    LTD_KOSTL TYPE TYP_KOSTL.

  LRH_PLSCN-SIGN   = 'I'.
  LRH_PLSCN-OPTION = 'EQ'.
  LRH_PLSCN-LOW    = ''.
  APPEND LRH_PLSCN TO LRD_PLSCN.

* 長期計画がONの場合、LTP計画シナリオを検索条件に入れる
  IF P_TYOUKI IS NOT INITIAL.
    LRH_PLSCN-SIGN   = 'I'.
    LRH_PLSCN-OPTION = 'EQ'.
    LRH_PLSCN-LOW    = P_PLSCN.
    APPEND LRH_PLSCN TO LRD_PLSCN.
  ENDIF.

  SELECT PLSCN
         MATNR
         PLWRK
         LGORT
         DISPO
         PLGRP
         PERTR
         GSMNG
         PLNUM
         VERID
    INTO TABLE TD_PLAF_WK
    FROM PLAF
     FOR ALL ENTRIES IN ITD_MARC
   WHERE MATNR = ITD_MARC-MATNR
     AND PLWRK = ITD_MARC-WERKS
     AND DISPO IN S_DISPO
     AND PLGRP IN S_PLGRP
     AND PLSCN IN LRD_PLSCN
     AND ( PERTR >= W_KDATE_M0 AND
           PERTR <= W_SDATE_M0 ).

  SORT TD_PLAF_WK BY PLSCN MATNR WERKS LGORT PERTR GSMNG PLNUM.

* 原価センタの取得
  LOOP AT TD_PLAF_WK ASSIGNING FIELD-SYMBOL(<FS_PLAF_WK>).
    SELECT CRCO~KOSTL
            CSKT~KTEXT
        UP TO 1 ROWS
      INTO LTD_KOSTL
      FROM MKAL
     INNER JOIN MAPL
        ON MAPL~MATNR = MKAL~MATNR
       AND MAPL~WERKS = MKAL~WERKS
       AND MAPL~PLNTY = 'N'
       AND MAPL~PLNNR = MKAL~PLNNR
       AND MAPL~PLNAL = MKAL~ALNAL
     INNER JOIN PLFL
        ON PLFL~PLNTY = MAPL~PLNTY
       AND PLFL~PLNNR = MAPL~PLNNR
       AND PLFL~PLNAL = MAPL~PLNAL
     INNER JOIN PLAS
        ON PLAS~PLNTY = PLFL~PLNTY
       AND PLAS~PLNNR = PLFL~PLNNR
       AND PLAS~PLNAL = PLFL~PLNAL
       AND PLAS~PLNFL = PLFL~PLNFL
     INNER JOIN PLPO
        ON PLPO~PLNTY = PLAS~PLNTY
       AND PLPO~PLNNR = PLAS~PLNNR
       AND PLPO~PLNKN = PLAS~PLNKN
       AND PLPO~ZAEHL = PLAS~ZAEHL
     INNER JOIN CRCO
        ON CRCO~OBJTY = 'A'
       AND CRCO~OBJID = PLPO~ARBID
     INNER JOIN CSKT
        ON CSKT~KOSTL = CRCO~KOSTL
       AND CSKT~KOKRS = CRCO~KOKRS
     WHERE MKAL~MATNR = <FS_PLAF_WK>-MATNR
       AND MKAL~WERKS = <FS_PLAF_WK>-WERKS
       AND MKAL~VERID = <FS_PLAF_WK>-VERID
       AND CRCO~BEGDA <= SY-DATUM
       AND CRCO~ENDDA >= SY-DATUM
       AND CSKT~SPRAS = SY-LANGU
       AND CSKT~DATBI >= SY-DATUM.
    ENDSELECT.

    LTH_PLAF-PLSCN = <FS_PLAF_WK>-PLSCN.
    LTH_PLAF-MATNR = <FS_PLAF_WK>-MATNR.
    LTH_PLAF-WERKS = <FS_PLAF_WK>-WERKS.
    LTH_PLAF-LGORT = <FS_PLAF_WK>-LGORT.
    LTH_PLAF-DISPO = <FS_PLAF_WK>-DISPO.
    LTH_PLAF-PLGRP = <FS_PLAF_WK>-PLGRP.
    LTH_PLAF-PERTR = <FS_PLAF_WK>-PERTR.
    LTH_PLAF-GSMNG = <FS_PLAF_WK>-GSMNG.
    LTH_PLAF-KOSTL = LTD_KOSTL-KOSTL.
    LTH_PLAF-BEZKS = LTD_KOSTL-BEZKS.
    LTH_PLAF-PLNUM = <FS_PLAF_WK>-PLNUM.
    APPEND LTH_PLAF TO OTD_PLAF.
  ENDLOOP.

  SORT OTD_PLAF BY PLSCN MATNR WERKS LGORT PERTR GSMNG PLNUM.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_GETEKET
*&---------------------------------------------------------------------*
*& 購買分納契約取得
*&---------------------------------------------------------------------*
*&      --> ITD_MARD　対象品目
*&      <-- OTD_EKET　購買分納契約
*&---------------------------------------------------------------------*
FORM FRM_GETEKET  USING    ITD_MARC   LIKE TD_MARC
                  CHANGING OTD_EKET   LIKE TD_EKET.

  DATA:LW_NAME   TYPE THEAD-TDNAME,
       LTD_LINE  TYPE STANDARD TABLE OF TLINE,
       LTH_LINE  LIKE LINE OF LTD_LINE.

*--- 購買分納契約取得
  SELECT EKPO~EBELN,
         EKPO~EBELP,
         EKPO~MATNR,
         EKPO~WERKS,
         EKPO~LGORT,
         EKKO~EKORG,
         T024E~EKOTX,
         EKKO~EKGRP,
         EKKO~LIFNR,
         ADRC~NAME1,
         EKET~EINDT,
         EKET~MENGE,
         EKET~WEMNG
    INTO TABLE @OTD_EKET
    FROM EKKO
   INNER JOIN EKPO ON
         EKPO~EBELN = EKKO~EBELN
   INNER JOIN EKET ON
         EKET~EBELN = EKPO~EBELN
     AND EKET~EBELP = EKPO~EBELP
   INNER JOIN T024E ON
         T024E~EKORG = EKKO~EKORG
   INNER JOIN LFA1 ON
         LFA1~LIFNR = EKKO~LIFNR
   INNER JOIN ADRC ON
         ADRC~ADDRNUMBER = LFA1~ADRNR
     AND ADRC~DATE_FROM  <= @SY-DATUM
     AND ADRC~DATE_TO    >= @SY-DATUM
     AND ADRC~NATION     = ''
     FOR ALL ENTRIES IN @ITD_MARC
   WHERE EKKO~BSART IN @RD_BSART
     AND EKKO~EKORG IN @S_EKORG
     AND EKKO~EKGRP IN @S_EKGRP
     AND EKKO~LIFNR IN @S_LIFNR
     AND EKPO~MATNR = @ITD_MARC-MATNR
     AND EKPO~WERKS = @ITD_MARC-WERKS
     AND ( EKET~EINDT >= @W_KDATE_M0 AND
           EKET~EINDT <= @W_SDATE_M2 ).

  SORT OTD_EKET BY EBELN EBELP MATNR WERKS LGORT EKORG EKGRP LIFNR EINDT.

*--- ヘッダテキストの取得
  LOOP AT OTD_EKET ASSIGNING FIELD-SYMBOL(<FS_EKET>).
    AT NEW EBELN.
      LW_NAME = <FS_EKET>-EBELN.
*     ヘッダテキスト
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                            = 'L02'
          language                      = SY-LANGU
          NAME                          = LW_NAME
          OBJECT                        = 'EKKO'
        TABLES
          lines                         = LTD_LINE
        EXCEPTIONS
          ID                            = 1
          LANGUAGE                      = 2
          NAME                          = 3
          NOT_FOUND                     = 4
          OBJECT                        = 5
          REFERENCE_CHECK               = 6
          WRONG_ACCESS_TO_ARCHIVE       = 7
          OTHERS                        = 8
                .
      IF sy-subrc = 0.
        READ TABLE LTD_LINE INTO LTH_LINE INDEX 1.
        TH_EBTXT-EBELN  =  <FS_EKET>-EBELN.
        TH_EBTXT-TDLINE =  LTH_LINE-TDLINE.
        APPEND TH_EBTXT TO TD_EBTXT.
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_GETSYUKKA
*&---------------------------------------------------------------------*
*& 出荷実績取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- TD_SYUKK 　出荷実績
*&---------------------------------------------------------------------*
FORM FRM_GETSYUKKA  USING    ITD_MARC LIKE TD_MARC
                    CHANGING OTD_SYUKKA LIKE TD_SYUKKA.

  SELECT KDAUF
         KDPOS
         MATNR
         WERKS
         LGORT
         BUDAT
         MENGE
         SHKZG
         BWART
    INTO TABLE OTD_SYUKKA
    FROM MATDOC
     FOR ALL ENTRIES IN ITD_MARC
   WHERE RECORD_TYPE = 'MDOC'
     AND MATNR = ITD_MARC-MATNR
     AND WERKS = ITD_MARC-WERKS
     AND XAUTO = ''
     AND BWART IN S_SEISB
     AND ( BUDAT >= W_KDATE_M0 AND
           BUDAT <= W_SDATE_M0 ).

  SORT OTD_SYUKKA BY VBELN POSNR MATNR WERKS LGORT BUDAT MENGE SHKZG BWART.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_GETSYUKKO
*&---------------------------------------------------------------------*
*& 出庫実績取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- TD_SYUKKO　出庫実績
*&---------------------------------------------------------------------*
FORM FRM_GETSYUKKO  USING    ITD_MARC LIKE TD_MARC
                    CHANGING OTD_SYUKKO LIKE TD_SYUKKO.

  DATA:LRD_BWART_SB LIKE TABLE OF S_NAISB,
       LRD_BWART_NB LIKE TABLE OF S_NAINB.

  IF P_NAISEI IS NOT INITIAL.
    LRD_BWART_SB[] = S_NAISB[].
  ELSEIF P_GAISEI IS NOT INITIAL.
    LRD_BWART_SB[] = S_GAISB[].
  ENDIF.

  SELECT MATNR
         WERKS
         LGORT
         BUDAT
         MENGE
         SHKZG
         BWART
    INTO TABLE OTD_SYUKKO
    FROM MATDOC
     FOR ALL ENTRIES IN ITD_MARC
   WHERE RECORD_TYPE = 'MDOC'
     AND MATNR = ITD_MARC-MATNR
     AND WERKS = ITD_MARC-WERKS
     AND XAUTO = ''
     AND BWART IN LRD_BWART_SB
     AND ( BUDAT >= W_KDATE_M0 AND
           BUDAT <= W_SDATE_M0 ).

  SORT OTD_SYUKKO BY MATNR WERKS LGORT BUDAT MENGE SHKZG BWART.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_GETNYUUKO
*&---------------------------------------------------------------------*
*& 入庫実績取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- TD_NYUUKO　入庫実績
*&---------------------------------------------------------------------*
FORM FRM_GETNYUUKO  USING    ITD_MARC LIKE TD_MARC
                    CHANGING OTD_NYUUKO LIKE TD_NYUUKO.

  DATA:LRD_BWART_SB LIKE TABLE OF S_NAISB,
       LRD_BWART_NB LIKE TABLE OF S_NAINB.

  IF P_NAISEI IS NOT INITIAL.
    LRD_BWART_NB[] = S_NAINB[].
  ELSEIF P_GAISEI IS NOT INITIAL.
    LRD_BWART_NB[] = S_GAINB[].
  ENDIF.

  SELECT MATNR
         WERKS
         LGORT
         BUDAT
         MENGE
         SHKZG
         BWART
    INTO TABLE OTD_NYUUKO
    FROM MATDOC
     FOR ALL ENTRIES IN ITD_MARC
   WHERE RECORD_TYPE = 'MDOC'
     AND MATNR = ITD_MARC-MATNR
     AND WERKS = ITD_MARC-WERKS
     AND XAUTO = ''
     AND BWART IN LRD_BWART_NB
     AND ( BUDAT >= W_KDATE_M0 AND
           BUDAT <= W_SDATE_M0 ).

  SORT OTD_NYUUKO BY MATNR WERKS LGORT BUDAT MENGE SHKZG BWART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETMARDH
*&---------------------------------------------------------------------*
*& 前月末在庫取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- OW_RETURN　リターンフラグ
*&---------------------------------------------------------------------*
FORM FRM_GETMARDH  CHANGING ITD_MARC LIKE TD_MARC
                            OW_RETURN TYPE FLAG.

  DATA:LW_FISCAL_YEAR   TYPE BAPI0002_4-FISCAL_YEAR,
       LW_FISCAL_PERIOD TYPE BAPI0002_4-FISCAL_PERIOD,
       LW_RETURN        TYPE BAPIRETURN1,
       LTD_MBEWH        LIKE TD_MBEWH.


*--- 前月会計期間取得
  CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
      EXPORTING
        companycodeid       = TH_T001W-BWKEY
        posting_date        = W_FDATE_ML
      IMPORTING
        FISCAL_YEAR         = LW_FISCAL_YEAR
        FISCAL_PERIOD       = LW_FISCAL_PERIOD
        RETURN              = LW_RETURN.

  IF LW_RETURN-TYPE <> 'S' AND  LW_RETURN-TYPE IS NOT INITIAL.
    MESSAGE S005(ZMM001) DISPLAY LIKE 'E'. "会計期間の取得に失敗しました
    OW_RETURN = 'X'.
    RETURN.
  ENDIF.

*--- 履歴テーブル検索
  SELECT MATNR
         BWKEY
         LFGJA
         LFMON
         LBKUM
    INTO TABLE LTD_MBEWH
    FROM MBEWH
     FOR ALL ENTRIES IN ITD_MARC
   WHERE MATNR = ITD_MARC-MATNR
     AND BWKEY = ITD_MARC-WERKS
     AND BWTAR = ''
     AND ( LFGJA <  LW_FISCAL_YEAR  OR
          ( LFGJA =  LW_FISCAL_YEAR  AND
            LFMON <= LW_FISCAL_PERIOD ) ).

* 重複データ削除（期間が最新のデータのみに絞る）
  SORT LTD_MBEWH BY MATNR WERKS LFGJA DESCENDING LFMON DESCENDING.
  DELETE ADJACENT DUPLICATES FROM LTD_MBEWH COMPARING MATNR WERKS .

  LOOP AT ITD_MARC ASSIGNING FIELD-SYMBOL(<FS_MARC>) WHERE LFGJA > LW_FISCAL_YEAR
                                                       OR ( LFGJA = LW_FISCAL_YEAR AND LFMON >= LW_FISCAL_PERIOD ).

**   MBEWより取得した利用可能在庫が前月末在庫に該当しない場合、
**   履歴テーブルより前月末在庫の取得を行う
     READ TABLE LTD_MBEWH ASSIGNING FIELD-SYMBOL(<FS_MBEWH>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                      WERKS = <FS_MARC>-WERKS.
     IF SY-SUBRC = 0.
       <FS_MARC>-LFGJA = <FS_MBEWH>-LFGJA.
       <FS_MARC>-LFMON = <FS_MBEWH>-LFMON.
       <FS_MARC>-LABST = <FS_MBEWH>-LABST.
     ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_ALVDIFINITION
*&---------------------------------------------------------------------*
*& ALV関連定義
*&---------------------------------------------------------------------*
*&      <-- OW_RETURN　リターンフラグ
*&---------------------------------------------------------------------*
FORM FRM_ALVDIFINITION CHANGING OW_RETURN TYPE FLAG.

*--- ALVフィールドカタログ定義
  PERFORM FRM_FIELDCATALOG_ALV CHANGING TD_FIELDCAT
                                        OW_RETURN.
  IF OW_RETURN IS NOT INITIAL.
    RETURN.
  ENDIF.

*-- ALVソート定義
  PERFORM FRM_SORTALV CHANGING TD_SORTINFO.

*-- ALVレイアウト定義
  PERFORM FRM_LAYOUTALV CHANGING TH_LAYOUT.

*-- セル編集可否設定
  PERFORM FRM_EDIT_ALV USING    TD_FIELDCAT
                       CHANGING TD_OUTALV.

*-- セルカラー設定
  PERFORM FRM_COL_ALV USING    TD_FIELDCAT
                      CHANGING TD_OUTALV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FIELDCATALOG_ALV
*&---------------------------------------------------------------------*
*& フィールドカタログ定義
*&---------------------------------------------------------------------*
*& 　　 <-- TD_FIELDCAT フィールドカテゴリ
*&      <-- OW_RETURN　 リターンフラグ
*&---------------------------------------------------------------------*
FORM FRM_FIELDCATALOG_ALV CHANGING OTD_FIELDCAT LIKE TD_FIELDCAT
                                   OW_RETURN TYPE FLAG.

  DATA:LW_DAY   TYPE N LENGTH 2,
       LW_COUNT TYPE N LENGTH 3,
       LTD_FIELDCAT TYPE LVC_T_FCAT.

*--- フィールドカタログの取得
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
   EXPORTING
     I_STRUCTURE_NAME             = CNS_STR
    CHANGING
      ct_fieldcat                 = OTD_FIELDCAT
   EXCEPTIONS
     INCONSISTENT_INTERFACE       = 1
     PROGRAM_ERROR                = 2
     OTHERS                       = 3
            .
  IF sy-subrc <> 0.
    MESSAGE S006(ZMM001) DISPLAY LIKE 'E'. "フィールドカタログの取得に失敗しました
    OW_RETURN = 'X'.
  ENDIF.

*--- 検索ヘルプの設定
  LOOP AT OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_F4HELP>).
    IF <FS_F4HELP>-FIELDNAME = 'KUNAG'
      OR <FS_F4HELP>-FIELDNAME = 'KUNWE'
      OR <FS_F4HELP>-FIELDNAME = 'EKGRP'
      OR <FS_F4HELP>-FIELDNAME = 'LADGR'
      OR <FS_F4HELP>-FIELDNAME = 'VSTEL'
      OR <FS_F4HELP>-FIELDNAME = 'EKORG'
      OR <FS_F4HELP>-FIELDNAME = 'LGORT'
      OR <FS_F4HELP>-FIELDNAME = 'PLSCN'.



      <FS_F4HELP>-F4AVAILABL = 'X'.

    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.



*--- 対象月の日数分のみ設定
  LOOP AT OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT>) WHERE FIELDNAME+0(4) = 'MENG'.
    IF <FS_FIELDCAT>-NO_OUT = 'X'.
      CLEAR <FS_FIELDCAT>-NO_OUT.
    ENDIF.
    IF <FS_FIELDCAT>-FIELDNAME+4(2) > W_LDATE_M0+6(2).
      DELETE OTD_FIELDCAT.
    ENDIF.
  ENDLOOP.

*--- 所要日付の入替処理
  LW_DAY  = P_KIKAN+6(2).

  READ TABLE OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT4>) WITH KEY FIELDNAME = 'MENG01'.
  LW_COUNT = <FS_FIELDCAT4>-COL_POS - 1.

  LOOP AT OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT2>) WHERE FIELDNAME+0(4) = 'MENG'.
    IF <FS_FIELDCAT2>-FIELDNAME+4(2) < LW_DAY.
      APPEND <FS_FIELDCAT2> TO LTD_FIELDCAT.
      DELETE  OTD_FIELDCAT.
    ELSE.
      LW_COUNT = LW_COUNT + 1.
      <FS_FIELDCAT2>-COL_POS = LW_COUNT.
    ENDIF.
  ENDLOOP.

  LOOP AT LTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT3>).
    LW_COUNT = LW_COUNT + 1.
    <FS_FIELDCAT3>-COL_POS = LW_COUNT.
    APPEND <FS_FIELDCAT3> TO OTD_FIELDCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SORTALV
*&---------------------------------------------------------------------*
*& ALVソート定義
*&---------------------------------------------------------------------*
*&      <-- TD_SORTINFO　ソート定義
*&---------------------------------------------------------------------*
FORM FRM_SORTALV  CHANGING O_SORTINFO LIKE TD_SORTINFO.

  CLEAR TH_SORTINFO.
  TH_SORTINFO-SPOS = '1'.
  TH_SORTINFO-FIELDNAME = 'MATNR'.
  TH_SORTINFO-UP = 'X'.
  APPEND TH_SORTINFO TO O_SORTINFO.

  CLEAR TH_SORTINFO.
  TH_SORTINFO-SPOS = '2'.
  TH_SORTINFO-FIELDNAME = 'WERKS'.
  TH_SORTINFO-UP = 'X'.
  APPEND TH_SORTINFO TO O_SORTINFO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_LAYOUTALV
*&---------------------------------------------------------------------*
*& ALVレイアウト定義
*&---------------------------------------------------------------------*
*&      <-- TH_LAYOUT　レイアウト定義
*&---------------------------------------------------------------------*
FORM FRM_LAYOUTALV  CHANGING OTH_LAYOUT LIKE TH_LAYOUT.

  OTH_LAYOUT-EDIT = 'X'.                 "編集モード
  OTH_LAYOUT-STYLEFNAME = 'FSTYLE'.      "スタイル構造
  OTH_LAYOUT-CTAB_FNAME = 'FSCOL'.       "カラー構造
  OTH_LAYOUT-CWIDTH_OPT = 'X'.           "列幅最適化

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_EDITALV
*&---------------------------------------------------------------------*
*& ALV出力データ編集処理
*&---------------------------------------------------------------------*
FORM FRM_EDITALV.

  DATA:LW_COUNT(2) TYPE N,
       LW_MENGE    TYPE ZMMS0001-MENG01,
       LW_PICKLO   TYPE ZSDT0003-ZZ1_PICKLO,
       LW_SHIPPINGRO TYPE ZSDT0003-ZZ1_SHIPPINGRO,
       LW_SUPPLYRO TYPE ZSDT0003-ZZ1_SUPPLYRO,
       LW_SUPPLYFIN TYPE ZSDT0003-ZZ1_SUPPLYFIN,
       LW_CARTONRTN TYPE ZSDT0003-CARTONRTN,
       LW_CARTONDAY TYPE ZSDT0003-CARTONDAY,
       LW_SUPPLYCNT TYPE ZSDT0003-SUPPLYCNT,
       LW_MILKRUN   TYPE ZSDT0003-ZZ1_MILKRUN,
       LW_EISBE    TYPE LABNK,
       LTD_VBEP_1  LIKE TD_VBEP_N,
       LTD_VBEP_5  LIKE TD_VBEP_N,
       LTD_VBEP_O1 LIKE TD_VBEP_O,
       LTD_VBEP_O5 LIKE TD_VBEP_O.

  LOOP AT TD_MARC ASSIGNING FIELD-SYMBOL(<FS_MARC>).

*--- 変数クリア処理
    PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.

*--- 共通項目
    TH_OUTALV-MATNR = <FS_MARC>-MATNR.
    TH_OUTALV-WERKS = <FS_MARC>-WERKS.

*--- 品目共通項目設定
    READ TABLE TD_CM_MARA ASSIGNING FIELD-SYMBOL(<FS_CM_MARA>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                        WERKS = <FS_MARC>-WERKS.

    TH_OUTALV-HINBAN   = <FS_CM_MARA>-HINBAN. "品番
    TH_OUTALV-KOUFU    = <FS_CM_MARA>-KOUFU.  "工程符号
    TH_OUTALV-BESKZ    = <FS_CM_MARA>-BESKZ.  "調達タイプ
    TH_OUTALV-SOBSL    = <FS_CM_MARA>-SOBSL.  "特殊調達タイプ
    TH_OUTALV-MEINS    = <FS_CM_MARA>-MEINS.  "基本数量単位
    TH_OUTALV-GEWEI    = <FS_CM_MARA>-GEWEI.  "重量単位
    TH_OUTALV-GEWEIK   = <FS_CM_MARA>-GEWEIK. "重量単位（１箱）
    TH_OUTALV-VOLEH    = <FS_CM_MARA>-VOLEH.  "容積単位
    TH_OUTALV-BACKNO   = <FS_CM_MARA>-ZZ1_BACKNO_PLT."社内背番号
    TH_OUTALV-PRDHA    = <FS_CM_MARA>-PRDHA.  "車種
    TH_OUTALV-PRCTR    = <FS_CM_MARA>-PRCTR.  "品種中分類
    TH_OUTALV-KTEXT    = <FS_CM_MARA>-KTEXT.  "品種中分類名
    TH_OUTALV-MVGR2    = <FS_CM_MARA>-MVGR2.  "品種小分類
    TH_OUTALV-BEZEI    = <FS_CM_MARA>-BEZEI.  "品種小分類名
    TH_OUTALV-EKGRP    = <FS_CM_MARA>-EKGRP.  "購買担当者コード
    TH_OUTALV-EKNAM    = <FS_CM_MARA>-EKNAM.  "購買担当者名
    TH_OUTALV-MAKTX    = <FS_CM_MARA>-MAKTX.  "品名
    TH_OUTALV-DISPO    = <FS_CM_MARA>-DISPO.  "生管担当者コード
    TH_OUTALV-DSNAM    = <FS_CM_MARA>-DSNAM.  "生管担当者名
    TH_OUTALV-NAME1    = <FS_CM_MARA>-NAME1.  "ソミック会社名
    TH_OUTALV-FEVOR    = <FS_CM_MARA>-FEVOR.  "生産部署
    TH_OUTALV-TXT      = <FS_CM_MARA>-TXT.    "生産部署名
    TH_OUTALV-LADGR    = <FS_CM_MARA>-LADGR.  "出荷工場/出荷場
    TH_OUTALV-VTEXT    = <FS_CM_MARA>-VTEXT.  "出荷工場名/出荷場名
    TH_OUTALV-TRGQTY   = <FS_CM_MARA>-TRGQTY. "収容数
    TH_OUTALV-MATNRP   = <FS_CM_MARA>-MATNRP. "箱種
    TH_OUTALV-GROESP   = <FS_CM_MARA>-GROESP. "箱種サイズ
    TH_OUTALV-MATNRN1  = <FS_CM_MARA>-MATNRN1."内装資材１
    TH_OUTALV-GROESN1  = <FS_CM_MARA>-GROESN1."内装資材１サイズ
    TH_OUTALV-TRGQTYN1 = <FS_CM_MARA>-TRGQTYN1."内装資材名１使用数
    TH_OUTALV-MATNRN2  = <FS_CM_MARA>-MATNRN2."内装資材２
    TH_OUTALV-GROESN2  = <FS_CM_MARA>-GROESN2."内装資材２サイズ
    TH_OUTALV-TRGQTYN2 = <FS_CM_MARA>-TRGQTYN2."内装資材名２使用数
    TH_OUTALV-NTGEW    = <FS_CM_MARA>-NTGEW.  "単重(g)
    TH_OUTALV-NTGEWP   = <FS_CM_MARA>-NTGEWP. "箱重量(g)
    TH_OUTALV-NTGEWK   = <FS_CM_MARA>-NTGEWK. "１箱重量(kg)
    TH_OUTALV-VOLUMK   = <FS_CM_MARA>-VOLUMK. "１箱体積(㎥)

*   箱種名称
    SELECT
      FROM MAKT
    FIELDS MAKTX
     WHERE MATNR = @<FS_CM_MARA>-MATNRP
       AND SPRAS = @SY-LANGU
      INTO @TH_OUTALV-MATNRPNAME
        UP TO 1 ROWS.
    ENDSELECT.

*   かんばん収容数
    READ TABLE TD_KANBAN ASSIGNING FIELD-SYMBOL(<FS_KANBAN>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                      WERKS = <FS_MARC>-WERKS.

    IF SY-SUBRC = 0.
      TH_OUTALV-KANBAN = <FS_KANBAN>-BEHMG.
    ELSE.
      CLEAR TH_OUTALV-KANBAN.
    ENDIF.

    CONCATENATE P_YM+0(4) '/' P_YM+4(2) INTO TH_OUTALV-YEARMONTH.

*--- 内示関連のレコード作成

    CLEAR:LTD_VBEP_1,LTD_VBEP_5,LTD_VBEP_O1,LTD_VBEP_O5.
*   作業用の内部テーブル作成
    LOOP AT TD_VBEP_N ASSIGNING FIELD-SYMBOL(<FS_VBEP_W>) WHERE MATNR = <FS_MARC>-MATNR
                                                            AND WERKS = <FS_MARC>-WERKS.
     IF <FS_VBEP_W>-ABART = CNS_1.
        APPEND <FS_VBEP_W> TO LTD_VBEP_1.
      ELSEIF <FS_VBEP_W>-ABART = CNS_5.
        APPEND <FS_VBEP_W> TO LTD_VBEP_5.
      ENDIF.
    ENDLOOP.

    LOOP AT TD_VBEP_O ASSIGNING FIELD-SYMBOL(<FS_VBEP_OW>) WHERE MATNR = <FS_MARC>-MATNR
                                                             AND WERKS = <FS_MARC>-WERKS.
     IF <FS_VBEP_OW>-ABART = CNS_1.
        APPEND <FS_VBEP_OW> TO LTD_VBEP_O1.
      ELSEIF <FS_VBEP_OW>-ABART = CNS_5.
        APPEND <FS_VBEP_OW> TO LTD_VBEP_O5.
      ENDIF.
    ENDLOOP.

    SORT LTD_VBEP_1  BY VBELN POSNR.
    SORT LTD_VBEP_5  BY VBELN POSNR.
    SORT LTD_VBEP_O1 BY VBELN POSNR.
    SORT LTD_VBEP_O5 BY VBELN POSNR.


    LOOP AT TD_VBEP_CHK ASSIGNING FIELD-SYMBOL(<FS_VBEP_CHK1>) WHERE MATNR = <FS_MARC>-MATNR
                                                                 AND WERKS = <FS_MARC>-WERKS.

      CLEAR:LW_PICKLO,LW_SHIPPINGRO,LW_SUPPLYRO,LW_SUPPLYFIN,LW_CARTONRTN,LW_CARTONDAY,LW_SUPPLYCNT,LW_MILKRUN.

*---  置き場の取得
      PERFORM FRM_GETSDT0003 USING    <FS_VBEP_CHK1>-KUNWE    <FS_VBEP_CHK1>-MATNR
                             CHANGING LW_PICKLO    LW_SHIPPINGRO LW_SUPPLYRO  LW_SUPPLYFIN
                                      LW_CARTONRTN LW_CARTONDAY  LW_SUPPLYCNT LW_MILKRUN.

*---  得意先内示(オリジナル) 最新
      READ TABLE LTD_VBEP_1 ASSIGNING FIELD-SYMBOL(<FS_CHK1>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                       POSNR = <FS_VBEP_CHK1>-POSNR.

      IF SY-SUBRC = 0.
        LOOP AT LTD_VBEP_1 ASSIGNING FIELD-SYMBOL(<FS_VBEP1>).

          IF <FS_VBEP1>-VBELN = <FS_VBEP_CHK1>-VBELN AND
             <FS_VBEP1>-POSNR = <FS_VBEP_CHK1>-POSNR .
          ELSE.
            CONTINUE.
          ENDIF.

          IF <FS_VBEP1>-EDATU >= W_KDATE_M0 AND <FS_VBEP1>-EDATU <= W_SDATE_M0.
*           当月データの編集
            CONCATENATE 'TH_OUTALV-MENG' <FS_VBEP1>-EDATU+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.

            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_VBEP1>-VMENG.
            ENDIF.
            TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_VBEP1>-VMENG.

          ELSEIF <FS_VBEP1>-EDATU >= W_KDATE_M1 AND <FS_VBEP1>-EDATU <= W_SDATE_M1.
*           来月データの編集
            TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_VBEP1>-VMENG.
          ELSEIF <FS_VBEP1>-EDATU >= W_KDATE_M2 AND <FS_VBEP1>-EDATU <= W_SDATE_M2.
*           再来月データの編集
            TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_VBEP1>-VMENG.
          ENDIF.

          AT END OF KDMAT.
            TH_OUTALV-LGORT  = <FS_VBEP1>-LGORT.
            TH_OUTALV-KDMAT  = <FS_VBEP1>-KDMAT.
            TH_OUTALV-VKORG  = <FS_VBEP1>-VKORG.
            TH_OUTALV-VTWEG  = <FS_VBEP1>-VTWEG.
            TH_OUTALV-SPART  = <FS_VBEP1>-SPART.
            TH_OUTALV-KUNAG  = <FS_VBEP1>-KUNAG.
            TH_OUTALV-KUNWE  = <FS_VBEP1>-KUNWE.
            TH_OUTALV-MIKOMI = TEXT-005."得意先内示(オリジナル)   最新
            TH_OUTALV-LABNK  = <FS_VBEP1>-LABNK.
            TH_OUTALV-VBELN  = <FS_VBEP1>-VBELN.
            TH_OUTALV-POSNR  = <FS_VBEP1>-POSNR.
            TH_OUTALV-VBELN_SD  = <FS_VBEP1>-VBELN.
            TH_OUTALV-POSNR_SD  = <FS_VBEP1>-POSNR.
            TH_OUTALV-ABGRU  = <FS_VBEP1>-ABGRU.
            TH_OUTALV-VKORG_BEZ  = <FS_VBEP1>-VKORG_BEZ.
            TH_OUTALV-VTWEG_BEZ  = <FS_VBEP1>-VTWEG_BEZ.
            TH_OUTALV-SPART_BEZ  = <FS_VBEP1>-SPART_BEZ.
            TH_OUTALV-KUNAGT = <FS_VBEP1>-KUNAGT.
            TH_OUTALV-KUNWET = <FS_VBEP1>-KUNWET.
            TH_OUTALV-ABRVW  = <FS_VBEP1>-ABRVW.
            TH_OUTALV-ABRVWIT = <FS_VBEP1>-ABRVWIT.
            TH_OUTALV-KNREF  = <FS_VBEP1>-KNREF.
            TH_OUTALV-KVERM  = <FS_VBEP1>-KVERM.
            TH_OUTALV-PICKLO = LW_PICKLO.
            TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
            TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
            TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
            TH_OUTALV-CARTONRTN = LW_CARTONRTN.
            TH_OUTALV-CARTONDAY = LW_CARTONDAY.
            TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
            TH_OUTALV-MILKRUN   = LW_MILKRUN.
            TH_OUTALV-VSTEL     = <FS_VBEP1>-VSTEL.
            TH_OUTALV-VSTELT    = <FS_VBEP1>-VSTELT.
            CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP1>-VBELN CNS_SORTCT-VBEP_3 INTO TH_OUTALV-SORTCT.
            APPEND TH_OUTALV TO TD_OUTALV.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.
      ELSEIF P_SEIHIN IS NOT INITIAL.
        TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
        TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
        TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
        TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
        TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
        TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
        TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
        TH_OUTALV-MIKOMI = TEXT-005."得意先内示(オリジナル)   最新
        TH_OUTALV-LABNK  = '0'.
        TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
        TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
        TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
        TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
        TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
        TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
        TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
        TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
        TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
        TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
        TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
        TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
        TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
        TH_OUTALV-ABRVWIT  = <FS_VBEP_CHK1>-ABRVWIT.
        TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
        TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
        TH_OUTALV-PICKLO = LW_PICKLO.
        TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
        TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
        TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
        TH_OUTALV-CARTONRTN = LW_CARTONRTN.
        TH_OUTALV-CARTONDAY = LW_CARTONDAY.
        TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
        TH_OUTALV-MILKRUN   = LW_MILKRUN.
        TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
        TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
        CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_3 INTO TH_OUTALV-SORTCT.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.

*---  得意先内示(生管修正)  最新
      READ TABLE LTD_VBEP_5 ASSIGNING FIELD-SYMBOL(<FS_CHK5>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                       POSNR = <FS_VBEP_CHK1>-POSNR.

      IF SY-SUBRC = 0.
        LOOP AT LTD_VBEP_5 ASSIGNING FIELD-SYMBOL(<FS_VBEP2>).

          IF <FS_VBEP2>-VBELN = <FS_VBEP_CHK1>-VBELN AND
             <FS_VBEP2>-POSNR = <FS_VBEP_CHK1>-POSNR .
          ELSE.
            CONTINUE.
          ENDIF.

          IF <FS_VBEP2>-EDATU >= W_KDATE_M0 AND <FS_VBEP2>-EDATU <= W_SDATE_M0.
*           当月データの編集
            CONCATENATE 'TH_OUTALV-MENG' <FS_VBEP2>-EDATU+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.

            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_VBEP2>-VMENG.
            ENDIF.
            TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_VBEP2>-VMENG.

          ELSEIF <FS_VBEP2>-EDATU >= W_KDATE_M1 AND <FS_VBEP2>-EDATU <= W_SDATE_M1.
*           来月データの編集
            TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_VBEP2>-VMENG.
          ELSEIF <FS_VBEP2>-EDATU >= W_KDATE_M2 AND <FS_VBEP2>-EDATU <= W_SDATE_M2.
*           再来月データの編集
            TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_VBEP2>-VMENG.
          ENDIF.

          AT END OF KDMAT.
            TH_OUTALV-LGORT  = <FS_VBEP2>-LGORT.
            TH_OUTALV-KDMAT  = <FS_VBEP2>-KDMAT.
            TH_OUTALV-VKORG  = <FS_VBEP2>-VKORG.
            TH_OUTALV-VTWEG  = <FS_VBEP2>-VTWEG.
            TH_OUTALV-SPART  = <FS_VBEP2>-SPART.
            TH_OUTALV-KUNAG  = <FS_VBEP2>-KUNAG.
            TH_OUTALV-KUNWE  = <FS_VBEP2>-KUNWE.
            TH_OUTALV-MIKOMI = TEXT-006."得意先内示(生管修正)　最新
            TH_OUTALV-LABNK  = <FS_VBEP2>-LABNK.
            TH_OUTALV-VBELN  = <FS_VBEP2>-VBELN.
            TH_OUTALV-POSNR  = <FS_VBEP2>-POSNR.
            TH_OUTALV-VBELN_SD  = <FS_VBEP2>-VBELN.
            TH_OUTALV-POSNR_SD  = <FS_VBEP2>-POSNR.
            TH_OUTALV-ABGRU     = <FS_VBEP2>-ABGRU.
            TH_OUTALV-VKORG_BEZ  = <FS_VBEP2>-VKORG_BEZ.
            TH_OUTALV-VTWEG_BEZ  = <FS_VBEP2>-VTWEG_BEZ.
            TH_OUTALV-SPART_BEZ  = <FS_VBEP2>-SPART_BEZ.
            TH_OUTALV-KUNAGT = <FS_VBEP2>-KUNAGT.
            TH_OUTALV-KUNWET = <FS_VBEP2>-KUNWET.
            TH_OUTALV-ABRVW  = <FS_VBEP2>-ABRVW.
            TH_OUTALV-ABRVWIT  = <FS_VBEP2>-ABRVWIT.
            TH_OUTALV-KNREF  = <FS_VBEP2>-KNREF.
            TH_OUTALV-KVERM  = <FS_VBEP2>-KVERM.
            TH_OUTALV-PICKLO = LW_PICKLO.
            TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
            TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
            TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
            TH_OUTALV-CARTONRTN = LW_CARTONRTN.
            TH_OUTALV-CARTONDAY = LW_CARTONDAY.
            TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
            TH_OUTALV-MILKRUN   = LW_MILKRUN.
            TH_OUTALV-VSTEL     = <FS_VBEP2>-VSTEL.
            TH_OUTALV-VSTELT    = <FS_VBEP2>-VSTELT.
            CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP2>-VBELN CNS_SORTCT-VBEP_4 INTO TH_OUTALV-SORTCT.
            APPEND TH_OUTALV TO TD_OUTALV.
            IF P_NAISEI IS NOT INITIAL OR
               P_GAISEI IS NOT INITIAL.
              CLEAR TH_OUTALV-LGORT.
              APPEND TH_OUTALV TO TD_HSM.
            ENDIF.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.
      ELSEIF P_SEIHIN IS NOT INITIAL.
        TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
        TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
        TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
        TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
        TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
        TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
        TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
        TH_OUTALV-MIKOMI = TEXT-006."得意先内示(生管修正)　最新
        TH_OUTALV-LABNK  = '0'.
        TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
        TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
        TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
        TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
        TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
        TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
        TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
        TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
        TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
        TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
        TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
        TH_OUTALV-ABRVWIT  = <FS_VBEP_CHK1>-ABRVWIT.
        TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
        TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
        TH_OUTALV-PICKLO = LW_PICKLO.
        TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
        TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
        TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
        TH_OUTALV-CARTONRTN = LW_CARTONRTN.
        TH_OUTALV-CARTONDAY = LW_CARTONDAY.
        TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
        TH_OUTALV-MILKRUN   = LW_MILKRUN.
        TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
        TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
        CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_4 INTO TH_OUTALV-SORTCT.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.

      IF P_SEIHIN IS NOT INITIAL.
*---   得意先内示(オリジナル) 前回
        READ TABLE LTD_VBEP_O1 ASSIGNING FIELD-SYMBOL(<FS_CHKO1>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                           POSNR = <FS_VBEP_CHK1>-POSNR.

        IF SY-SUBRC = 0.
          LOOP AT LTD_VBEP_O1 ASSIGNING FIELD-SYMBOL(<FS_VBEP_O>).

            IF <FS_VBEP_O>-VBELN = <FS_VBEP_CHK1>-VBELN AND
               <FS_VBEP_O>-POSNR = <FS_VBEP_CHK1>-POSNR .
            ELSE.
              CONTINUE.
            ENDIF.

            IF <FS_VBEP_O>-EDATU >= W_KDATE_M0 AND <FS_VBEP_O>-EDATU <= W_SDATE_M0.
*             当月データの編集
              CONCATENATE 'TH_OUTALV-MENG' <FS_VBEP_O>-EDATU+6(2) INTO W_FIELD1.
              ASSIGN (W_FIELD1) TO <FS_FLD1>.

              IF SY-SUBRC IS INITIAL.
                <FS_FLD1> = <FS_FLD1> + <FS_VBEP_O>-VMENG.
              ENDIF.
              TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_VBEP_O>-VMENG.

            ELSEIF <FS_VBEP_O>-EDATU >= W_KDATE_M1 AND <FS_VBEP_O>-EDATU <= W_SDATE_M1.
*             来月データの編集
              TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_VBEP_O>-VMENG.
            ELSEIF <FS_VBEP_O>-EDATU >= W_KDATE_M2 AND <FS_VBEP_O>-EDATU <= W_SDATE_M2.
*             再来月データの編集
              TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_VBEP_O>-VMENG.
            ENDIF.

            AT END OF KDMAT.
              TH_OUTALV-LGORT  = <FS_VBEP_O>-LGORT.
              TH_OUTALV-KDMAT  = <FS_VBEP_O>-KDMAT.
              TH_OUTALV-VKORG  = <FS_VBEP_O>-VKORG.
              TH_OUTALV-VTWEG  = <FS_VBEP_O>-VTWEG.
              TH_OUTALV-SPART  = <FS_VBEP_O>-SPART.
              TH_OUTALV-KUNAG  = <FS_VBEP_O>-KUNAG.
              TH_OUTALV-KUNWE  = <FS_VBEP_O>-KUNWE.
              TH_OUTALV-MIKOMI = TEXT-025."得意先内示(オリジナル)   前回
              TH_OUTALV-LABNK  = <FS_VBEP_O>-LABNK.
              TH_OUTALV-VBELN  = <FS_VBEP_O>-VBELN.
              TH_OUTALV-POSNR  = <FS_VBEP_O>-POSNR.
              TH_OUTALV-VBELN_SD  = <FS_VBEP_O>-VBELN.
              TH_OUTALV-POSNR_SD  = <FS_VBEP_O>-POSNR.
              TH_OUTALV-ABGRU     = <FS_VBEP_O>-ABGRU.
              TH_OUTALV-VKORG_BEZ  = <FS_VBEP_O>-VKORG_BEZ.
              TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_O>-VTWEG_BEZ.
              TH_OUTALV-SPART_BEZ  = <FS_VBEP_O>-SPART_BEZ.
              TH_OUTALV-KUNAGT = <FS_VBEP_O>-KUNAGT.
              TH_OUTALV-KUNWET = <FS_VBEP_O>-KUNWET.
              TH_OUTALV-ABRVW     = <FS_VBEP_O>-ABRVW.
              TH_OUTALV-ABRVWIT   = <FS_VBEP_O>-ABRVWIT.
              TH_OUTALV-KNREF     = <FS_VBEP_O>-KNREF.
              TH_OUTALV-KVERM  = <FS_VBEP_O>-KVERM.
              TH_OUTALV-PICKLO = LW_PICKLO.
              TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
              TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
              TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
              TH_OUTALV-CARTONRTN = LW_CARTONRTN.
              TH_OUTALV-CARTONDAY = LW_CARTONDAY.
              TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
              TH_OUTALV-MILKRUN   = LW_MILKRUN.
              TH_OUTALV-VSTEL     = <FS_VBEP_O>-VSTEL.
              TH_OUTALV-VSTELT    = <FS_VBEP_O>-VSTELT.
              CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_O>-VBELN CNS_SORTCT-VBEP_1 INTO TH_OUTALV-SORTCT.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
          TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
          TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
          TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
          TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
          TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
          TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
          TH_OUTALV-MIKOMI = TEXT-025."得意先内示(オリジナル)   前回
          TH_OUTALV-LABNK  = '0'.
          TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
          TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
          TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
          TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
          TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
          TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
          TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
          TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
          TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
          TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
          TH_OUTALV-PICKLO = LW_PICKLO.
          TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
          TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
          TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
          TH_OUTALV-CARTONRTN = LW_CARTONRTN.
          TH_OUTALV-CARTONDAY = LW_CARTONDAY.
          TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
          TH_OUTALV-MILKRUN   = LW_MILKRUN.
          TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
          TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
          CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_1 INTO TH_OUTALV-SORTCT.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.

*--- 得意先内示(生管修正)  前回
        READ TABLE LTD_VBEP_O5 ASSIGNING FIELD-SYMBOL(<FS_CHKO5>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                           POSNR = <FS_VBEP_CHK1>-POSNR.

        IF SY-SUBRC = 0.
          LOOP AT LTD_VBEP_O5 ASSIGNING FIELD-SYMBOL(<FS_VBEP_O2>).

            IF <FS_VBEP_O2>-VBELN = <FS_VBEP_CHK1>-VBELN AND
               <FS_VBEP_O2>-POSNR = <FS_VBEP_CHK1>-POSNR .
            ELSE.
              CONTINUE.
            ENDIF.

            IF <FS_VBEP_O2>-EDATU >= W_KDATE_M0 AND <FS_VBEP_O2>-EDATU <= W_SDATE_M0.
*             当月データの編集
              CONCATENATE 'TH_OUTALV-MENG' <FS_VBEP_O2>-EDATU+6(2) INTO W_FIELD1.
              ASSIGN (W_FIELD1) TO <FS_FLD1>.

              IF SY-SUBRC IS INITIAL.
                <FS_FLD1> = <FS_FLD1> + <FS_VBEP_O2>-VMENG.
              ENDIF.
              TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_VBEP_O2>-VMENG.

            ELSEIF <FS_VBEP_O2>-EDATU >= W_KDATE_M1 AND <FS_VBEP_O2>-EDATU <= W_SDATE_M1.
*             来月データの編集
              TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_VBEP_O2>-VMENG.
            ELSEIF <FS_VBEP_O2>-EDATU >= W_KDATE_M2 AND <FS_VBEP_O2>-EDATU <= W_SDATE_M2.
*             再来月データの編集
              TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_VBEP_O2>-VMENG.
            ENDIF.

            AT END OF KDMAT.
              TH_OUTALV-LGORT  = <FS_VBEP_O2>-LGORT.
              TH_OUTALV-KDMAT  = <FS_VBEP_O2>-KDMAT.
              TH_OUTALV-VKORG  = <FS_VBEP_O2>-VKORG.
              TH_OUTALV-VTWEG  = <FS_VBEP_O2>-VTWEG.
              TH_OUTALV-SPART  = <FS_VBEP_O2>-SPART.
              TH_OUTALV-KUNAG  = <FS_VBEP_O2>-KUNAG.
              TH_OUTALV-KUNWE  = <FS_VBEP_O2>-KUNWE.
              TH_OUTALV-MIKOMI = TEXT-026."得意先内示(生管修正)　前回
              TH_OUTALV-LABNK  = <FS_VBEP_O2>-LABNK.
              TH_OUTALV-VBELN  = <FS_VBEP_O2>-VBELN.
              TH_OUTALV-POSNR  = <FS_VBEP_O2>-POSNR.
              TH_OUTALV-VBELN_SD  = <FS_VBEP_O2>-VBELN.
              TH_OUTALV-POSNR_SD  = <FS_VBEP_O2>-POSNR.
              TH_OUTALV-ABGRU     = <FS_VBEP_O2>-ABGRU.
              TH_OUTALV-VKORG_BEZ  = <FS_VBEP_O2>-VKORG_BEZ.
              TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_O2>-VTWEG_BEZ.
              TH_OUTALV-SPART_BEZ  = <FS_VBEP_O2>-SPART_BEZ.
              TH_OUTALV-KUNAGT = <FS_VBEP_O2>-KUNAGT.
              TH_OUTALV-KUNWET = <FS_VBEP_O2>-KUNWET.
              TH_OUTALV-ABRVW  = <FS_VBEP_O2>-ABRVW.
              TH_OUTALV-ABRVWIT = <FS_VBEP_O2>-ABRVWIT.
              TH_OUTALV-KNREF  = <FS_VBEP_O2>-KNREF.
              TH_OUTALV-KVERM  = <FS_VBEP_O2>-KVERM.
              TH_OUTALV-PICKLO = LW_PICKLO.
              TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
              TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
              TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
              TH_OUTALV-CARTONRTN = LW_CARTONRTN.
              TH_OUTALV-CARTONDAY = LW_CARTONDAY.
              TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
 	            TH_OUTALV-MILKRUN   = LW_MILKRUN.
              TH_OUTALV-VSTEL     = <FS_VBEP_O2>-VSTEL.
              TH_OUTALV-VSTELT    = <FS_VBEP_O2>-VSTELT.
              CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_O2>-VBELN CNS_SORTCT-VBEP_2 INTO TH_OUTALV-SORTCT.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
          TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
          TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
          TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
          TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
          TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
          TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
          TH_OUTALV-MIKOMI = TEXT-026."得意先内示(生管修正)　前回
          TH_OUTALV-LABNK  = '0'.
          TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
          TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
          TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
          TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
          TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
          TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
          TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
          TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
          TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
          TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
          TH_OUTALV-PICKLO = LW_PICKLO.
          TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
          TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
          TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
          TH_OUTALV-CARTONRTN = LW_CARTONRTN.
          TH_OUTALV-CARTONDAY = LW_CARTONDAY.
          TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
          TH_OUTALV-MILKRUN   = LW_MILKRUN.
          TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
          TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
          CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_2 INTO TH_OUTALV-SORTCT.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.

*---    JIT指示の設定
        READ TABLE TD_JIT1_CHK ASSIGNING FIELD-SYMBOL(<FS_JIT1_NO>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                             POSNR = <FS_VBEP_CHK1>-POSNR.

        IF SY-SUBRC = 0.
          LOOP AT TD_JIT1 ASSIGNING FIELD-SYMBOL(<FS_JIT1>).

            IF <FS_JIT1>-VBELN = <FS_VBEP_CHK1>-VBELN AND
               <FS_JIT1>-POSNR = <FS_VBEP_CHK1>-POSNR.
            ELSE.
              CONTINUE.
            ENDIF.

            IF <FS_JIT1>-LFDAT >= W_KDATE_M0 AND <FS_JIT1>-LFDAT <= W_SDATE_M0.
*             当月データの編集
              CONCATENATE 'TH_OUTALV-MENG' <FS_JIT1>-LFDAT+6(2) INTO W_FIELD1.
              ASSIGN (W_FIELD1) TO <FS_FLD1>.

              IF SY-SUBRC IS INITIAL.
                <FS_FLD1> = <FS_FLD1> + <FS_JIT1>-VMENG.
              ENDIF.
              TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_JIT1>-VMENG.

            ELSEIF <FS_JIT1>-LFDAT >= W_KDATE_M1 AND <FS_JIT1>-LFDAT <= W_SDATE_M1.
*             来月データの編集
              TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_JIT1>-VMENG.
            ELSEIF <FS_JIT1>-LFDAT >= W_KDATE_M2 AND <FS_JIT1>-LFDAT <= W_SDATE_M2.
*             再来月データの編集
              TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_JIT1>-VMENG.
            ENDIF.

            AT END OF KDMAT.
              TH_OUTALV-LGORT  = <FS_JIT1>-LGORT.
              TH_OUTALV-KDMAT  = <FS_JIT1>-KDMAT.
              TH_OUTALV-VKORG  = <FS_JIT1>-VKORG.
              TH_OUTALV-VTWEG  = <FS_JIT1>-VTWEG.
              TH_OUTALV-SPART  = <FS_JIT1>-SPART.
              TH_OUTALV-KUNAG  = <FS_JIT1>-KUNAG.
              TH_OUTALV-KUNWE  = <FS_JIT1>-KUNWE.
              TH_OUTALV-MIKOMI = TEXT-028."客先注文　JIT指示
              TH_OUTALV-VBELN  = <FS_JIT1>-VBELN.
              TH_OUTALV-POSNR  = <FS_JIT1>-POSNR.
              TH_OUTALV-VBELN_SD  = <FS_JIT1>-VBELN.
              TH_OUTALV-POSNR_SD  = <FS_JIT1>-POSNR.
              TH_OUTALV-ABGRU     = <FS_JIT1>-ABGRU.
              TH_OUTALV-VKORG_BEZ  = <FS_JIT1>-VKORG_BEZ.
              TH_OUTALV-VTWEG_BEZ  = <FS_JIT1>-VTWEG_BEZ.
              TH_OUTALV-SPART_BEZ  = <FS_JIT1>-SPART_BEZ.
              TH_OUTALV-KUNAGT = <FS_JIT1>-KUNAGT.
              TH_OUTALV-KUNWET = <FS_JIT1>-KUNWET.
              TH_OUTALV-PICKLO = <FS_JIT1>-PICKLO.
              TH_OUTALV-SHIPPINGRO = <FS_JIT1>-SHIPPINGRO.
              TH_OUTALV-SUPPLYRO  = <FS_JIT1>-SUPPLYRO.
              TH_OUTALV-SUPPLYFIN = <FS_JIT1>-SUPPLYFIN.
              TH_OUTALV-CARTONRTN = <FS_JIT1>-CARTONRTN.
              TH_OUTALV-CARTONDAY = <FS_JIT1>-CARTONDAY.
              TH_OUTALV-SUPPLYCNT = <FS_JIT1>-SUPPLYCNT.
              TH_OUTALV-MILKRUN   = <FS_JIT1>-MILKRUN.
              TH_OUTALV-ABRVW     = <FS_JIT1>-ABRVW.
              TH_OUTALV-ABRVWIT   = <FS_JIT1>-ABRVWIT.
              TH_OUTALV-KNREF     = <FS_JIT1>-KNREF.
              TH_OUTALV-KVERM     = <FS_JIT1>-KVERM.
              TH_OUTALV-VSTEL     = <FS_JIT1>-VSTEL.
              TH_OUTALV-VSTELT    = <FS_JIT1>-VSTELT.
              CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_6 INTO TH_OUTALV-SORTCT.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
          TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
          TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
          TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
          TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
          TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
          TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
          TH_OUTALV-MIKOMI = TEXT-028."客先注文　JIT指示
          TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
          TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
          TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
          TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
          TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
          TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
          TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
          TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
          TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
          TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
          TH_OUTALV-PICKLO = LW_PICKLO.
          TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
          TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
          TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
          TH_OUTALV-CARTONRTN = LW_CARTONRTN.
          TH_OUTALV-CARTONDAY = LW_CARTONDAY.
          TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
          TH_OUTALV-MILKRUN   = LW_MILKRUN.
          TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
          TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
          CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_6 INTO TH_OUTALV-SORTCT.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.

*--- 出荷計画の設定
        READ TABLE TD_LIPS ASSIGNING FIELD-SYMBOL(<FS_LIPS_NO>) WITH KEY VBELN_VA = <FS_VBEP_CHK1>-VBELN
                                                                           POSNR_VA = <FS_VBEP_CHK1>-POSNR.

        IF SY-SUBRC = 0.
          LOOP AT TD_LIPS ASSIGNING FIELD-SYMBOL(<FS_LIPS>).

            IF <FS_LIPS>-VBELN_VA = <FS_VBEP_CHK1>-VBELN AND
               <FS_LIPS>-POSNR_VA = <FS_VBEP_CHK1>-POSNR.
            ELSE.
              CONTINUE.
            ENDIF.

            TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
            TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
            TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
            TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
            TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
            TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
            TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
            TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
            TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
            TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
            TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
            TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
            TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
            TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
            TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
            TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
            TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
            TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
            TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
            TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
            TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
            TH_OUTALV-PICKLO = LW_PICKLO.
            TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
            TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
            TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
            TH_OUTALV-CARTONRTN = LW_CARTONRTN.
            TH_OUTALV-CARTONDAY = LW_CARTONDAY.
            TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
            TH_OUTALV-MILKRUN   = LW_MILKRUN.
            TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
            TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.

            CONCATENATE 'TH_OUTALV-MENG' <FS_LIPS>-LFDAT+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.
            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_LIPS>-LGMNG.
            ENDIF.
            TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_LIPS>-LGMNG.

            AT END OF WERKS.
              TH_OUTALV-MIKOMI = TEXT-009."出荷計画
              CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_7 INTO TH_OUTALV-SORTCT.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
          TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
          TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
          TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
          TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
          TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
          TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
          TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-ABGRU  = <FS_VBEP_CHK1>-ABGRU.
          TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
          TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
          TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
          TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
          TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
          TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
          TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
          TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
          TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
          TH_OUTALV-PICKLO = LW_PICKLO.
          TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
          TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
          TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
          TH_OUTALV-CARTONRTN = LW_CARTONRTN.
          TH_OUTALV-CARTONDAY = LW_CARTONDAY.
          TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
          TH_OUTALV-MILKRUN   = LW_MILKRUN.
          TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
          TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
          TH_OUTALV-MIKOMI = TEXT-009."出荷計画
          CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_7 INTO TH_OUTALV-SORTCT.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.

*  --- 出荷実績の設定
         READ TABLE TD_SYUKKA ASSIGNING FIELD-SYMBOL(<FS_SYUKKA2>) WITH KEY VBELN = <FS_VBEP_CHK1>-VBELN
                                                                            POSNR = <FS_VBEP_CHK1>-POSNR.

         IF SY-SUBRC = 0.
           LOOP AT TD_SYUKKA ASSIGNING FIELD-SYMBOL(<FS_SYUKKA>).

            IF <FS_SYUKKA>-VBELN = <FS_VBEP_CHK1>-VBELN AND
               <FS_SYUKKA>-POSNR = <FS_VBEP_CHK1>-POSNR.
            ELSE.
              CONTINUE.
            ENDIF.

            TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
            TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
            TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
            TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
            TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
            TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
            TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
            TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
            TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
            TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
            TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
            TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
            TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
            TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
            TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
            TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
            TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
            TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
            TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
            TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
            TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
            TH_OUTALV-PICKLO = LW_PICKLO.
            TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
            TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
            TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
            TH_OUTALV-CARTONRTN = LW_CARTONRTN.
            TH_OUTALV-CARTONDAY = LW_CARTONDAY.
            TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
            TH_OUTALV-MILKRUN   = LW_MILKRUN.
            TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
            TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.

            CONCATENATE 'TH_OUTALV-MENG' <FS_SYUKKA>-BUDAT+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.
            IF SY-SUBRC IS INITIAL AND <FS_SYUKKA>-SHKZG = 'H'.
              <FS_FLD1> = <FS_FLD1> + <FS_SYUKKA>-MENGE.
              TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_SYUKKA>-MENGE.
            ELSEIF SY-SUBRC IS INITIAL AND <FS_SYUKKA>-SHKZG = 'S'.
              <FS_FLD1> = <FS_FLD1> - <FS_SYUKKA>-MENGE.
              TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI - <FS_SYUKKA>-MENGE.
            ENDIF.

            AT END OF WERKS.
              TH_OUTALV-MIKOMI = TEXT-010."出荷実績
              CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_8 INTO TH_OUTALV-SORTCT.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-LGORT  = <FS_VBEP_CHK1>-LGORT.
          TH_OUTALV-KDMAT  = <FS_VBEP_CHK1>-KDMAT.
          TH_OUTALV-VKORG  = <FS_VBEP_CHK1>-VKORG.
          TH_OUTALV-VTWEG  = <FS_VBEP_CHK1>-VTWEG.
          TH_OUTALV-SPART  = <FS_VBEP_CHK1>-SPART.
          TH_OUTALV-KUNAG  = <FS_VBEP_CHK1>-KUNAG.
          TH_OUTALV-KUNWE  = <FS_VBEP_CHK1>-KUNWE.
          TH_OUTALV-VBELN  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-VBELN_SD  = <FS_VBEP_CHK1>-VBELN.
          TH_OUTALV-POSNR_SD  = <FS_VBEP_CHK1>-POSNR.
          TH_OUTALV-ABGRU     = <FS_VBEP_CHK1>-ABGRU.
          TH_OUTALV-VKORG_BEZ  = <FS_VBEP_CHK1>-VKORG_BEZ.
          TH_OUTALV-VTWEG_BEZ  = <FS_VBEP_CHK1>-VTWEG_BEZ.
          TH_OUTALV-SPART_BEZ  = <FS_VBEP_CHK1>-SPART_BEZ.
          TH_OUTALV-KUNAGT = <FS_VBEP_CHK1>-KUNAGT.
          TH_OUTALV-KUNWET = <FS_VBEP_CHK1>-KUNWET.
          TH_OUTALV-ABRVW  = <FS_VBEP_CHK1>-ABRVW.
          TH_OUTALV-ABRVWIT = <FS_VBEP_CHK1>-ABRVWIT.
          TH_OUTALV-KNREF  = <FS_VBEP_CHK1>-KNREF.
          TH_OUTALV-KVERM  = <FS_VBEP_CHK1>-KVERM.
          TH_OUTALV-PICKLO = LW_PICKLO.
          TH_OUTALV-SHIPPINGRO = LW_SHIPPINGRO.
          TH_OUTALV-SUPPLYRO  = LW_SUPPLYRO.
          TH_OUTALV-SUPPLYFIN = LW_SUPPLYFIN.
          TH_OUTALV-CARTONRTN = LW_CARTONRTN.
          TH_OUTALV-CARTONDAY = LW_CARTONDAY.
          TH_OUTALV-SUPPLYCNT = LW_SUPPLYCNT.
          TH_OUTALV-MILKRUN   = LW_MILKRUN.
          TH_OUTALV-VSTEL     = <FS_VBEP_CHK1>-VSTEL.
          TH_OUTALV-VSTELT    = <FS_VBEP_CHK1>-VSTELT.
          TH_OUTALV-MIKOMI = TEXT-010."出荷実績
          CONCATENATE CNS_SORTCT-VBEP_H <FS_VBEP_CHK1>-VBELN CNS_SORTCT-VBEP_8 INTO TH_OUTALV-SORTCT.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF P_NAISEI IS NOT INITIAL OR
       P_GAISEI IS NOT INITIAL.

*--- 従属所要量の設定
      LOOP AT TD_RESB ASSIGNING FIELD-SYMBOL(<FS_RESB>).

        IF <FS_RESB>-MATNR = <FS_MARC>-MATNR AND
           <FS_RESB>-WERKS = <FS_MARC>-WERKS.
        ELSE.
          CONTINUE.
        ENDIF.

        CONCATENATE 'TH_OUTALV-MENG' <FS_RESB>-BDTER+6(2) INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        IF SY-SUBRC IS INITIAL.
          <FS_FLD1> = <FS_FLD1> + <FS_RESB>-BDMNG.
        ENDIF.
        TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_RESB>-BDMNG.

        AT END OF BAUGR.
          TH_OUTALV-LGORT  = <FS_RESB>-LGORT.
          TH_OUTALV-BAUGR  = <FS_RESB>-BAUGR.
          TH_OUTALV-MIKOMI = TEXT-007."従属所要量
          TH_OUTALV-SORTCT = CNS_SORTCT-REBS.
          APPEND TH_OUTALV TO TD_OUTALV.
          IF P_NAISEI IS NOT INITIAL OR
             P_GAISEI IS NOT INITIAL.
            CLEAR TH_OUTALV-LGORT.
            APPEND TH_OUTALV TO TD_HSM.
          ENDIF.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDAT.
      ENDLOOP.

*--- 出庫見込ヘッダの設定
      IF TD_HSM IS NOT INITIAL.
        LOOP AT TD_HSM ASSIGNING FIELD-SYMBOL(<FS_HSM>).

          IF <FS_HSM>-MATNR = <FS_MARC>-MATNR AND
             <FS_HSM>-WERKS = <FS_MARC>-WERKS.
          ELSE.
            CONTINUE.
          ENDIF.

          TH_OUTALV-GOUKEI  = TH_OUTALV-GOUKEI  + <FS_HSM>-GOUKEI.
          TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_HSM>-GOUKEI1.
          TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_HSM>-GOUKEI2.
          CLEAR LW_COUNT.
          DO.
            IF SY-INDEX > '31'.
              EXIT.
            ENDIF.
            LW_COUNT = LW_COUNT + 1.
            CONCATENATE 'TH_OUTALV-MENG' LW_COUNT INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.
            CONCATENATE '<FS_HSM>-MENG' LW_COUNT INTO W_FIELD2.
            ASSIGN (W_FIELD2) TO <FS_FLD2>.

            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_FLD2>.
            ENDIF.
          ENDDO.
          AT END OF YEARMONTH.
            TH_OUTALV-MIKOMI = TEXT-008."出庫見込
            TH_OUTALV-SORTCT = CNS_SORTCT-HSM.
            APPEND TH_OUTALV TO TD_OUTALV.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.
      ELSE.
        TH_OUTALV-MIKOMI = TEXT-008."出庫見込
        TH_OUTALV-SORTCT = CNS_SORTCT-HSM.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.

*--- 出庫実績の設定
      LOOP AT TD_SYUKKO ASSIGNING FIELD-SYMBOL(<FS_SYUKKO>).

        IF <FS_SYUKKO>-MATNR = <FS_MARC>-MATNR AND
           <FS_SYUKKO>-WERKS = <FS_MARC>-WERKS.
        ELSE.
          CONTINUE.
        ENDIF.

        CONCATENATE 'TH_OUTALV-MENG' <FS_SYUKKO>-BUDAT+6(2) INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        IF SY-SUBRC IS INITIAL AND <FS_SYUKKO>-SHKZG = 'H'.
          <FS_FLD1> = <FS_FLD1> + <FS_SYUKKO>-MENGE.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_SYUKKO>-MENGE.
        ELSEIF SY-SUBRC IS INITIAL AND <FS_SYUKKO>-SHKZG = 'S'.
          <FS_FLD1> = <FS_FLD1> - <FS_SYUKKO>-MENGE.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI - <FS_SYUKKO>-MENGE.
        ENDIF.

        AT END OF WERKS.
          TH_OUTALV-MIKOMI = TEXT-011."出庫実績
          TH_OUTALV-SORTCT = CNS_SORTCT-SYUKKO.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDAT.
      ENDLOOP.

      READ TABLE TD_SYUKKO ASSIGNING FIELD-SYMBOL(<FS_SYUKKO_RE>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                           WERKS = <FS_MARC>-WERKS.
      IF SY-SUBRC <> 0.
        TH_OUTALV-MIKOMI = TEXT-011."出庫実績
        TH_OUTALV-SORTCT = CNS_SORTCT-SYUKKO.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.


*--- 入庫実績の設定
      LOOP AT TD_NYUUKO ASSIGNING FIELD-SYMBOL(<FS_NYUUKO>).

        IF <FS_NYUUKO>-MATNR = <FS_MARC>-MATNR AND
           <FS_NYUUKO>-WERKS = <FS_MARC>-WERKS.
        ELSE.
          CONTINUE.
        ENDIF.

        CONCATENATE 'TH_OUTALV-MENG' <FS_NYUUKO>-BUDAT+6(2) INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        IF SY-SUBRC IS INITIAL AND <FS_NYUUKO>-SHKZG = 'H'.
          <FS_FLD1> = <FS_FLD1> - <FS_NYUUKO>-MENGE.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI - <FS_NYUUKO>-MENGE.
        ELSEIF SY-SUBRC IS INITIAL AND <FS_NYUUKO>-SHKZG = 'S'.
          <FS_FLD1> = <FS_FLD1> + <FS_NYUUKO>-MENGE.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_NYUUKO>-MENGE.
        ENDIF.

        AT END OF WERKS.
          TH_OUTALV-MIKOMI = TEXT-012."入庫実績
          TH_OUTALV-SORTCT = CNS_SORTCT-NYUUKO.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDAT.
      ENDLOOP.

      READ TABLE TD_NYUUKO ASSIGNING FIELD-SYMBOL(<FS_NYUUKO_RE>) WITH KEY MATNR = <FS_MARC>-MATNR
                                                                           WERKS = <FS_MARC>-WERKS.

      IF SY-SUBRC <> 0.
        TH_OUTALV-MIKOMI = TEXT-012."入庫実績
        TH_OUTALV-SORTCT = CNS_SORTCT-NYUUKO.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.

*--- 計画手配の設定
      LOOP AT TD_PLAF ASSIGNING FIELD-SYMBOL(<FS_PLAF>).

        IF <FS_PLAF>-MATNR = <FS_MARC>-MATNR AND
           <FS_PLAF>-WERKS = <FS_MARC>-WERKS AND
           <FS_PLAF>-PLSCN = ''.
        ELSE.
          CONTINUE.
        ENDIF.

        CONCATENATE 'TH_OUTALV-MENG' <FS_PLAF>-PERTR+6(2) INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        IF SY-SUBRC IS INITIAL.
          <FS_FLD1> = <FS_FLD1> + <FS_PLAF>-GSMNG.
        ENDIF.
        TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_PLAF>-GSMNG.

        AT END OF PLGRP.
          TH_OUTALV-LGORT = <FS_PLAF>-LGORT.
          TH_OUTALV-DISPO = <FS_PLAF>-DISPO.
          TH_OUTALV-PLGRP = <FS_PLAF>-PLGRP.
          TH_OUTALV-KOSTL = <FS_PLAF>-KOSTL.
          TH_OUTALV-BEZKS = <FS_PLAF>-BEZKS.
          TH_OUTALV-MIKOMI = TEXT-013."計画手配
          TH_OUTALV-SORTCT = CNS_SORTCT-PLAF.
          APPEND TH_OUTALV TO TD_OUTALV.
          CLEAR TH_OUTALV-LGORT.
          APPEND TH_OUTALV TO TD_HNM.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDAT.
      ENDLOOP.

*--- 購買分納契約の設定
      IF  P_GAISEI IS NOT INITIAL.
        LOOP AT TD_EKET ASSIGNING FIELD-SYMBOL(<FS_EKET>).

          IF <FS_EKET>-MATNR = <FS_MARC>-MATNR AND
             <FS_EKET>-WERKS = <FS_MARC>-WERKS.
          ELSE.
            CONTINUE.
          ENDIF.

          IF <FS_EKET>-EINDT >= W_KDATE_M0 AND <FS_EKET>-EINDT <= W_SDATE_M0.
*           当月データの編集
            CONCATENATE 'TH_OUTALV-MENG' <FS_EKET>-EINDT+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.
            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_EKET>-MENGE - <FS_EKET>-WEMNG.
            ENDIF.
            TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_EKET>-MENGE.
          ELSEIF <FS_EKET>-EINDT >= W_KDATE_M1 AND <FS_EKET>-EINDT <= W_SDATE_M1.
*           来月データの編集
            TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_EKET>-MENGE - <FS_EKET>-WEMNG.
          ELSEIF <FS_EKET>-EINDT >= W_KDATE_M2 AND <FS_EKET>-EINDT <= W_SDATE_M2.
*           再来月データの編集
            TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_EKET>-MENGE - <FS_EKET>-WEMNG.
          ENDIF.

          AT END OF LGORT.

            READ TABLE TD_EBTXT ASSIGNING FIELD-SYMBOL(<FS_EBTXT>) WITH KEY EBELN = <FS_EKET>-EBELN.
            IF SY-SUBRC = 0.
              TH_OUTALV-POHDTXT = <FS_EBTXT>-TDLINE. "ヘッダテキスト
            ENDIF.

            TH_OUTALV-MIKOMI = TEXT-014."購買分納契約
            TH_OUTALV-SORTCT = CNS_SORTCT-EKET.
            TH_OUTALV-EKORG = <FS_EKET>-EKORG.
*            TH_OUTALV-EKGRP = <FS_EKET>-EKGRP.
            TH_OUTALV-LIFNR = <FS_EKET>-LIFNR.
            TH_OUTALV-EBELN = <FS_EKET>-EBELN.
            TH_OUTALV-EBELP = <FS_EKET>-EBELP.
            TH_OUTALV-EBELN_MM = <FS_EKET>-EBELN.
            TH_OUTALV-EBELP_MM = <FS_EKET>-EBELP.
            TH_OUTALV-EKOTX    = <FS_EKET>-EKOTX.
            TH_OUTALV-NAME1_LI = <FS_EKET>-NAME1_LI.
            APPEND TH_OUTALV TO TD_HNM.
            APPEND TH_OUTALV TO TD_OUTALV.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.
      ENDIF.

*--- 入庫見込ヘッダの設定
      IF TD_HNM IS NOT INITIAL.
        LOOP AT TD_HNM ASSIGNING FIELD-SYMBOL(<FS_HNM>).

          IF <FS_HNM>-MATNR = <FS_MARC>-MATNR AND
             <FS_HNM>-WERKS = <FS_MARC>-WERKS.
          ELSE.
            CONTINUE.
          ENDIF.

          TH_OUTALV-GOUKEI  = TH_OUTALV-GOUKEI  + <FS_HNM>-GOUKEI.
          TH_OUTALV-GOUKEI1 = TH_OUTALV-GOUKEI1 + <FS_HNM>-GOUKEI1.
          TH_OUTALV-GOUKEI2 = TH_OUTALV-GOUKEI2 + <FS_HNM>-GOUKEI2.
          CLEAR LW_COUNT.
          DO.
            IF SY-INDEX > '31'.
              EXIT.
            ENDIF.
            LW_COUNT = LW_COUNT + 1.
            CONCATENATE 'TH_OUTALV-MENG' LW_COUNT INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.
            CONCATENATE '<FS_HNM>-MENG' LW_COUNT INTO W_FIELD2.
            ASSIGN (W_FIELD2) TO <FS_FLD2>.

            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_FLD2>.
            ENDIF.
          ENDDO.
          AT END OF YEARMONTH.
            TH_OUTALV-MIKOMI = TEXT-015."入庫見込
            TH_OUTALV-SORTCT = CNS_SORTCT-HNM.
            APPEND TH_OUTALV TO TD_OUTALV.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.
      ELSE.
        TH_OUTALV-MIKOMI = TEXT-015."入庫見込
        TH_OUTALV-SORTCT = CNS_SORTCT-HNM.
        APPEND TH_OUTALV TO TD_OUTALV.
        PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
      ENDIF.

*--- 在庫見込の設定
      CLEAR: LW_COUNT,
             LW_MENGE.
      LW_EISBE = <FS_MARC>-EISBE.
      CONDENSE LW_EISBE.
      READ TABLE TD_OUTALV INTO TH_HSM WITH KEY MATNR = <FS_MARC>-MATNR
                                                WERKS = <FS_MARC>-WERKS
                                                SORTCT = CNS_SORTCT-HSM.

      READ TABLE TD_OUTALV INTO TH_HNM WITH KEY MATNR = <FS_MARC>-MATNR
                                                WERKS = <FS_MARC>-WERKS
                                                SORTCT = CNS_SORTCT-HNM.

*     前月末在庫 - 出庫入庫ヘッダ + 入庫見込ヘッダより算出
      LW_COUNT = P_KIKAN+6(2).
      DO.
        CONCATENATE 'TH_OUTALV-MENG' LW_COUNT INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        CONCATENATE 'TH_HSM-MENG' LW_COUNT INTO W_FIELD2.
        ASSIGN (W_FIELD2) TO <FS_FLD2>.
        CONCATENATE 'TH_HNM-MENG' LW_COUNT INTO W_FIELD3.
        ASSIGN (W_FIELD3) TO <FS_FLD3>.


        IF SY-INDEX = 1.
          <FS_FLD1> = <FS_MARC>-LABST - <FS_FLD2> + <FS_FLD3>.
        ELSE.
          <FS_FLD1> = LW_MENGE - <FS_FLD2> + <FS_FLD3>.
        ENDIF.
        LW_MENGE = <FS_FLD1>.

        IF LW_COUNT = '31'.
          LW_COUNT = '01'.
        ELSE.
          LW_COUNT = LW_COUNT + 1.
        ENDIF.

        IF SY-INDEX = '31'.
          CONCATENATE TEXT-021 LW_EISBE INTO TH_OUTALV-MIKOMI. "在庫見込
          TH_OUTALV-SORTCT = CNS_SORTCT-HZM.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          EXIT.
        ENDIF.
      ENDDO.
      CLEAR:TD_HSM,
            TD_HNM,
            TH_HSM,
            TH_HNM.

*--- 在庫実績の設定
      TH_OUTALV-MIKOMI = TEXT-023 ."在庫実績
      TH_OUTALV-ZENZAIKO = <FS_MARC>-LABST.
      TH_OUTALV-SORTCT = CNS_SORTCT-HZJ.
      APPEND TH_OUTALV TO TD_OUTALV.
      PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.


      IF P_TYOUKI IS NOT INITIAL.
*--- Sim得意先内示(生管修正)の設定
        LOOP AT TD_VBEP_N ASSIGNING FIELD-SYMBOL(<FS_VBEP3>).

            IF <FS_VBEP3>-ABART = CNS_5           AND
               <FS_VBEP3>-MATNR = <FS_MARC>-MATNR AND
               <FS_VBEP3>-WERKS = <FS_MARC>-WERKS AND
               <FS_VBEP3>-EDATU >= W_KDATE_M0     AND
               <FS_VBEP3>-EDATU <= W_SDATE_M0     .
            ELSE.
              CONTINUE.
            ENDIF.

            CONCATENATE 'TH_OUTALV-MENG' <FS_VBEP3>-EDATU+6(2) INTO W_FIELD1.
            ASSIGN (W_FIELD1) TO <FS_FLD1>.

            IF SY-SUBRC IS INITIAL.
              <FS_FLD1> = <FS_FLD1> + <FS_VBEP3>-VMENG.
            ENDIF.
            TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_VBEP3>-VMENG.

          AT END OF KDMAT.
            TH_OUTALV-LGORT  = <FS_VBEP3>-LGORT.
            TH_OUTALV-KDMAT  = <FS_VBEP3>-KDMAT.
            TH_OUTALV-VKORG  = <FS_VBEP3>-VKORG.
            TH_OUTALV-VTWEG  = <FS_VBEP3>-VTWEG.
            TH_OUTALV-SPART  = <FS_VBEP3>-SPART.
            TH_OUTALV-KUNAG  = <FS_VBEP3>-KUNAG.
            TH_OUTALV-KUNWE  = <FS_VBEP3>-KUNWE.
            TH_OUTALV-MIKOMI = TEXT-017."Sim内示平準化
            TH_OUTALV-VBELN  = <FS_VBEP3>-VBELN.
            TH_OUTALV-POSNR  = <FS_VBEP3>-POSNR.
            TH_OUTALV-LABNK  = <FS_VBEP3>-LABNK.
            TH_OUTALV-SORTCT = CNS_SORTCT-VBEP_S.
            APPEND TH_OUTALV TO TD_OUTALV.
            IF P_NAISEI IS NOT INITIAL OR
               P_GAISEI IS NOT INITIAL.
              CLEAR TH_OUTALV-LGORT.
              APPEND TH_OUTALV TO TD_HSM_S.
            ENDIF.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.

*--- Sim所要量の設定
        LOOP AT TD_RESB ASSIGNING FIELD-SYMBOL(<FS_RESB1>).

          IF <FS_RESB1>-MATNR = <FS_MARC>-MATNR AND
             <FS_RESB1>-WERKS = <FS_MARC>-WERKS.
          ELSE.
            CONTINUE.
          ENDIF.

          CONCATENATE 'TH_OUTALV-MENG' <FS_RESB1>-BDTER+6(2) INTO W_FIELD1.
          ASSIGN (W_FIELD1) TO <FS_FLD1>.
          IF SY-SUBRC IS INITIAL.
            <FS_FLD1> = <FS_FLD1> + <FS_RESB1>-BDMNG.
          ENDIF.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_RESB1>-BDMNG.

          AT END OF BAUGR.
            TH_OUTALV-LGORT  = <FS_RESB1>-LGORT.
            TH_OUTALV-BAUGR  = <FS_RESB1>-BAUGR.
            TH_OUTALV-MIKOMI = TEXT-018."Sim所要量
            TH_OUTALV-SORTCT = CNS_SORTCT-RESB_S.
            APPEND TH_OUTALV TO TD_OUTALV.
            IF P_NAISEI IS NOT INITIAL OR
               P_GAISEI IS NOT INITIAL.
              CLEAR TH_OUTALV-LGORT.
              APPEND TH_OUTALV TO TD_HSM_S.
            ENDIF.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.

*--- 出庫見込(SimMRP)ヘッダの設定
        IF TD_HSM_S IS NOT INITIAL.
          LOOP AT TD_HSM_S ASSIGNING FIELD-SYMBOL(<FS_HSM_S>).

            IF <FS_HSM_S>-MATNR = <FS_MARC>-MATNR AND
               <FS_HSM_S>-WERKS = <FS_MARC>-WERKS.
            ELSE.
              CONTINUE.
            ENDIF.

            TH_OUTALV-GOUKEI  = TH_OUTALV-GOUKEI  + <FS_HSM_S>-GOUKEI.
            CLEAR LW_COUNT.
            DO.
              IF SY-INDEX > '31'.
                EXIT.
              ENDIF.
              LW_COUNT = LW_COUNT + 1.
              CONCATENATE 'TH_OUTALV-MENG' LW_COUNT INTO W_FIELD1.
              ASSIGN (W_FIELD1) TO <FS_FLD1>.
              CONCATENATE '<FS_HSM_S>-MENG' LW_COUNT INTO W_FIELD2.
              ASSIGN (W_FIELD2) TO <FS_FLD2>.

              IF SY-SUBRC IS INITIAL.
                <FS_FLD1> = <FS_FLD1> + <FS_FLD2>.
              ENDIF.
            ENDDO.
            AT END OF YEARMONTH.
              TH_OUTALV-MIKOMI = TEXT-016."出庫見込(SimMRP)
              TH_OUTALV-SORTCT = CNS_SORTCT-HSM_S.
              APPEND TH_OUTALV TO TD_OUTALV.
              PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
            ENDAT.
          ENDLOOP.
        ELSE.
          TH_OUTALV-MIKOMI = TEXT-016."出庫見込(SimMRP)
          TH_OUTALV-SORTCT = CNS_SORTCT-HSM_S.
          APPEND TH_OUTALV TO TD_OUTALV.
          PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
        ENDIF.

*--- Sim計画手配の設定
        LOOP AT TD_PLAF ASSIGNING FIELD-SYMBOL(<FS_PLAF1>).

          IF <FS_PLAF1>-MATNR = <FS_MARC>-MATNR AND
             <FS_PLAF1>-WERKS = <FS_MARC>-WERKS AND
             <FS_PLAF1>-PLSCN <> ''.
          ELSE.
            CONTINUE.
          ENDIF.

          CONCATENATE 'TH_OUTALV-MENG' <FS_PLAF1>-PERTR+6(2) INTO W_FIELD1.
          ASSIGN (W_FIELD1) TO <FS_FLD1>.
          IF SY-SUBRC IS INITIAL.
            <FS_FLD1> = <FS_FLD1> + <FS_PLAF1>-GSMNG.
          ENDIF.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_PLAF1>-GSMNG.

          AT END OF PLGRP.
            TH_OUTALV-LGORT = <FS_PLAF1>-LGORT.
            TH_OUTALV-PLSCN = <FS_PLAF1>-PLSCN.
            TH_OUTALV-DISPO = <FS_PLAF1>-DISPO.
            TH_OUTALV-PLGRP = <FS_PLAF1>-PLGRP.
            TH_OUTALV-KOSTL = <FS_PLAF1>-KOSTL.
            TH_OUTALV-BEZKS = <FS_PLAF1>-BEZKS.
          TH_OUTALV-MIKOMI = TEXT-020."Sim計画手配
            TH_OUTALV-SORTCT = CNS_SORTCT-PLAF_S.
            APPEND TH_OUTALV TO TD_OUTALV.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.

*--- 入庫見込(SimMRP)ヘッダの設定
        LOOP AT TD_PLAF ASSIGNING FIELD-SYMBOL(<FS_PLAF2>).

          IF <FS_PLAF2>-MATNR = <FS_MARC>-MATNR AND
             <FS_PLAF2>-WERKS = <FS_MARC>-WERKS AND
             <FS_PLAF2>-PLSCN <> ''.
          ELSE.
            CONTINUE.
          ENDIF.

          CONCATENATE 'TH_OUTALV-MENG' <FS_PLAF2>-PERTR+6(2) INTO W_FIELD1.
          ASSIGN (W_FIELD1) TO <FS_FLD1>.
          IF SY-SUBRC IS INITIAL.
            <FS_FLD1> = <FS_FLD1> + <FS_PLAF2>-GSMNG.
          ENDIF.
          TH_OUTALV-GOUKEI = TH_OUTALV-GOUKEI + <FS_PLAF2>-GSMNG.

          AT END OF WERKS.
            TH_OUTALV-MIKOMI = TEXT-019."入庫見込(SimMRP)
            TH_OUTALV-SORTCT = CNS_SORTCT-HNM_S.
            APPEND TH_OUTALV TO TD_OUTALV.
            APPEND TH_OUTALV TO TD_HNM_S.
            PERFORM FRM_OUTALVCLEAR CHANGING TH_OUTALV.
          ENDAT.
        ENDLOOP.

*       入庫見込(SimMRP)ヘッダが存在しない場合、空の行を作成
        READ TABLE TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_HNM_R>) WITH KEY SORTCT = CNS_SORTCT-HNM_S.
        IF SY-SUBRC <> 0.
          TH_OUTALV-MIKOMI = TEXT-019."入庫見込(SimMRP)
          TH_OUTALV-SORTCT = CNS_SORTCT-HNM_S.
          APPEND TH_OUTALV TO TD_OUTALV.
          APPEND TH_OUTALV TO TD_HNM_S.
        ENDIF.

*--- 在庫見込(SimMRP)
        CLEAR: LW_COUNT,
               LW_MENGE.
        READ TABLE TD_OUTALV INTO TH_HSM_S WITH KEY MATNR = <FS_MARC>-MATNR
                                                    WERKS = <FS_MARC>-WERKS
                                                    SORTCT = CNS_SORTCT-HSM_S.

        READ TABLE TD_OUTALV INTO TH_HNM_S WITH KEY MATNR = <FS_MARC>-MATNR
                                                    WERKS = <FS_MARC>-WERKS
                                                    SORTCT = CNS_SORTCT-HNM_S.

*       前月末在庫 - 出庫入庫ヘッダ + 入庫見込ヘッダより算出
        LW_COUNT = P_KIKAN+6(2).
        DO.
          CONCATENATE 'TH_OUTALV-MENG' LW_COUNT INTO W_FIELD1.
          ASSIGN (W_FIELD1) TO <FS_FLD1>.
          CONCATENATE 'TH_HSM_S-MENG' LW_COUNT INTO W_FIELD2.
          ASSIGN (W_FIELD2) TO <FS_FLD2>.
          CONCATENATE 'TH_HNM_S-MENG' LW_COUNT INTO W_FIELD3.
          ASSIGN (W_FIELD3) TO <FS_FLD3>.

          IF SY-INDEX = 1.
            <FS_FLD1> = <FS_MARC>-LABST - <FS_FLD2> + <FS_FLD3>.
          ELSE.
            <FS_FLD1> = LW_MENGE - <FS_FLD2> + <FS_FLD3>.
          ENDIF.
          LW_MENGE = <FS_FLD1>.

          IF LW_COUNT = '31'.
            LW_COUNT = '01'.
          ELSE.
            LW_COUNT = LW_COUNT + 1.
          ENDIF.
          IF SY-INDEX = '31'.
            TH_OUTALV-MIKOMI = TEXT-022 ."在庫見込(SimMRP)
            TH_OUTALV-SORTCT = CNS_SORTCT-HZM_S.
            APPEND TH_OUTALV TO TD_OUTALV.
            EXIT.
          ENDIF.
        ENDDO.
        CLEAR:TD_HSM_S,
              TD_HNM_S,
              TH_HSM,
              TH_HNM.

      ENDIF.
    ENDIF.

**--- 品目・プラントレベルで合計行が全て0のデータは一覧から削除する
*    IF P_SEIHIN IS INITIAL.
*      LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTLV>) WHERE MATNR = <FS_MARC>-MATNR
*                                                             AND WERKS = <FS_MARC>-WERKS
*                                                             AND GOUKEI <> 0.
*        EXIT.
*      ENDLOOP.
*      IF SY-SUBRC <> 0.
*        DELETE TD_OUTALV WHERE MATNR = <FS_MARC>-MATNR
*                           AND WERKS = <FS_MARC>-WERKS.
*      ENDIF.
*    ENDIF.
  ENDLOOP.

  SORT TD_OUTALV BY MATNR WERKS SORTCT LGORT VBELN_SD POSNR_SD EBELN_MM EBELP_MM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_OUTALVCLEAR
*&---------------------------------------------------------------------*
*& ALV出力用作業領域の変数クリア
*&---------------------------------------------------------------------*
*&      <-- TH_OUTALV　ALV出力用
*&---------------------------------------------------------------------*
FORM FRM_OUTALVCLEAR  CHANGING OTH_OUTALV LIKE TH_OUTALV.

  CLEAR:
    OTH_OUTALV-LGORT,
    OTH_OUTALV-KDMAT,
    OTH_OUTALV-VKORG,
    OTH_OUTALV-VTWEG,
    OTH_OUTALV-SPART,
    OTH_OUTALV-KUNAG,
    OTH_OUTALV-KUNWE,
    OTH_OUTALV-BAUGR,
*    OTH_OUTALV-DISPO,
    OTH_OUTALV-PLGRP,
    OTH_OUTALV-EKORG,
*    OTH_OUTALV-EKGRP,
    OTH_OUTALV-LIFNR,
    OTH_OUTALV-PLSCN,
    OTH_OUTALV-MIKOMI,
    OTH_OUTALV-LABNK,
    OTH_OUTALV-ZENZAIKO,
    OTH_OUTALV-MENG01,
    OTH_OUTALV-MENG02,
    OTH_OUTALV-MENG03,
    OTH_OUTALV-MENG04,
    OTH_OUTALV-MENG05,
    OTH_OUTALV-MENG06,
    OTH_OUTALV-MENG07,
    OTH_OUTALV-MENG08,
    OTH_OUTALV-MENG09,
    OTH_OUTALV-MENG10,
    OTH_OUTALV-MENG11,
    OTH_OUTALV-MENG12,
    OTH_OUTALV-MENG13,
    OTH_OUTALV-MENG14,
    OTH_OUTALV-MENG15,
    OTH_OUTALV-MENG16,
    OTH_OUTALV-MENG17,
    OTH_OUTALV-MENG18,
    OTH_OUTALV-MENG19,
    OTH_OUTALV-MENG20,
    OTH_OUTALV-MENG21,
    OTH_OUTALV-MENG22,
    OTH_OUTALV-MENG23,
    OTH_OUTALV-MENG24,
    OTH_OUTALV-MENG25,
    OTH_OUTALV-MENG26,
    OTH_OUTALV-MENG27,
    OTH_OUTALV-MENG28,
    OTH_OUTALV-MENG29,
    OTH_OUTALV-MENG30,
    OTH_OUTALV-MENG31,
    OTH_OUTALV-GOUKEI,
    OTH_OUTALV-GOUKEI1,
    OTH_OUTALV-GOUKEI2,
    OTH_OUTALV-VBELN_SD,
    OTH_OUTALV-POSNR_SD,
    OTH_OUTALV-EBELN_MM,
    OTH_OUTALV-EBELP_MM,
    OTH_OUTALV-VBELN,
    OTH_OUTALV-POSNR,
    OTH_OUTALV-EBELN,
    OTH_OUTALV-EBELP,
    OTH_OUTALV-KOSTL,
    OTH_OUTALV-VKORG_BEZ,
    OTH_OUTALV-VTWEG_BEZ,
    OTH_OUTALV-SPART_BEZ,
    OTH_OUTALV-KUNAGT,
    OTH_OUTALV-KUNWET,
    OTH_OUTALV-PICKLO,
    OTH_OUTALV-SHIPPINGRO,
    OTH_OUTALV-BEZKS,
    OTH_OUTALV-EKOTX,
    OTH_OUTALV-NAME1_LI,
    OTH_OUTALV-PICKLO,
    OTH_OUTALV-SHIPPINGRO,
    OTH_OUTALV-SUPPLYRO,
    OTH_OUTALV-SUPPLYFIN,
    OTH_OUTALV-CARTONRTN,
    OTH_OUTALV-CARTONDAY,
    OTH_OUTALV-SUPPLYCNT,
    OTH_OUTALV-MILKRUN,
    OTH_OUTALV-ABRVW,
    OTH_OUTALV-KNREF,
    OTH_OUTALV-KVERM,
    OTH_OUTALV-VSTEL,
    OTH_OUTALV-VSTELT,
    OTH_OUTALV-POHDTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_EDIT_ALV
*&---------------------------------------------------------------------*
*& セル編集可否設定
*&---------------------------------------------------------------------*
*&      --> TD_FIELDCA　フィールドカテゴリ
*&      <-- TD_OUTALV　 ALV出力用
*&---------------------------------------------------------------------*
FORM FRM_EDIT_ALV   USING    OTD_FIELDCAT LIKE TD_FIELDCAT
                    CHANGING OTD_OUTALV LIKE TD_OUTALV.

  DATA:LTH_STYLEROW TYPE LVC_S_STYL,
       LTD_STYLETAB TYPE LVC_T_STYL.


  LOOP AT OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT>).
    LTH_STYLEROW-FIELDNAME = <FS_FIELDCAT>-FIELDNAME.
    LTH_STYLEROW-STYLE = cl_gui_alv_grid=>MC_STYLE_DISABLED. "入力不可パターン
    INSERT LTH_STYLEROW INTO TABLE LTD_STYLETAB.
  ENDLOOP.

  LOOP AT OTD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV>).
    <FS_OUTALV>-FSTYLE = LTD_STYLETAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_COL_ALV
*&---------------------------------------------------------------------*
*& セルカラー設定
*&---------------------------------------------------------------------*
*&      --> TD_FIELDCA　フィールドカテゴリ
*&      <-- TD_OUTALV　 ALV出力用
*&---------------------------------------------------------------------*
FORM FRM_COL_ALV  USING    OTD_FIELDCAT LIKE TD_FIELDCAT
                  CHANGING OTD_OUTALV LIKE TD_OUTALV.

  DATA:LTH_STYLEROW TYPE LVC_S_SCOL,
       LTD_STYLETAB TYPE LVC_T_SCOL,
       LW_SYORIDATE TYPE D,
       LW_KADOUDATE TYPE D.

  LW_SYORIDATE = W_KDATE_M0.
  LOOP AT OTD_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT>).
*--- 色の設定(非稼働日の場合、色付けを行う)
    IF <FS_FIELDCAT>-FIELDNAME+0(4) = 'MENG'.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
       EXPORTING
         CORRECT_OPTION                     = '+'
         date                               = LW_SYORIDATE
         factory_calendar_id                = TH_T001W-FABKL
       IMPORTING
         DATE                               = LW_KADOUDATE.

       IF LW_SYORIDATE = LW_KADOUDATE. "稼働日の場合
           LTH_STYLEROW-FNAME = <FS_FIELDCAT>-FIELDNAME.
           LTH_STYLEROW-COLOR-COL = col_normal. "グレー色
       ELSE."非稼働日の場合
           LTH_STYLEROW-FNAME = <FS_FIELDCAT>-FIELDNAME.
           LTH_STYLEROW-COLOR-COL = col_heading. "青色
       ENDIF.
       LW_SYORIDATE = LW_SYORIDATE + 1.
    ELSE.
      LTH_STYLEROW-FNAME = <FS_FIELDCAT>-FIELDNAME.
      LTH_STYLEROW-COLOR-COL = col_normal. "グレー色
    ENDIF.
    INSERT LTH_STYLEROW INTO TABLE LTD_STYLETAB.
*--- 下線の設定
    IF <FS_FIELDCAT>-FIELDNAME = 'MATNR'.
      <FS_FIELDCAT>-HOTSPOT = 'X'.
    ENDIF.
    IF <FS_FIELDCAT>-FIELDNAME = 'VBELN_SD' OR <FS_FIELDCAT>-FIELDNAME = 'EBELN_MM'.
      <FS_FIELDCAT>-HOTSPOT = 'X'.
    ENDIF.
  ENDLOOP.

  LOOP AT OTD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV>).
    <FS_OUTALV>-FSCOL = LTD_STYLETAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_OUTPUTALV
*&---------------------------------------------------------------------*
*& ALV出力
*&---------------------------------------------------------------------*
FORM FRM_OUTPUTALV .

  IF TD_OUTALV IS NOT INITIAL.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
     EXPORTING
       I_CALLBACK_PROGRAM                = SY-REPID
       I_CALLBACK_USER_COMMAND           = 'FRM_UCOM'
       I_CALLBACK_PF_STATUS_SET          = 'FRM_STSET'
       IT_SORT_LVC                       = TD_SORTINFO
       IT_FIELDCAT_LVC                   = TD_FIELDCAT
       IS_LAYOUT_LVC                     = TH_LAYOUT
       IS_VARIANT                        = TH_DISVARIANT
       I_SAVE                            = 'X'
      TABLES
        t_outtab                          = TD_OUTALV
     EXCEPTIONS
       PROGRAM_ERROR                     = 1
       OTHERS                            = 2.

    IF sy-subrc <> 0.
      MESSAGE S019(ZMM001) DISPLAY LIKE 'E'. "一覧画面の出力に失敗しました
    ENDIF.
  ELSE.
    MESSAGE S004(ZMM001). "対象データがありません
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_UCOM
*&---------------------------------------------------------------------*
*& ALVユーザーコマンド処理
*&---------------------------------------------------------------------*
*&      --> a_ucomm　　　 ユーザーコマンド
*&      <-- rs_selfield　 セルフィールド
*&---------------------------------------------------------------------*
FORM FRM_UCOM USING a_ucomm LIKE sy-ucomm
                    rs_selfield TYPE slis_selfield.

  DATA:LTD_OUTALV TYPE STANDARD TABLE OF TYP_OUTALV.

*--- リフレッシュボタン押下時
  IF a_ucomm = '%REFRESH'.
    IF W_EDITMD = 'X' AND P_SEIHIN = 'X'.
      CLEAR TD_BKEDIT.
      LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV2>) WHERE SORTCT+12(1) = CNS_SORTCT-VBEP_5.
        APPEND <FS_OUTALV2> TO TD_BKEDIT.
      ENDLOOP.
    ENDIF.

    CLEAR :TD_OUTALV,
           TH_OUTALV,
           TD_EBTXT.

*   データ再取得
    PERFORM FRM_GETMAINDATA CHANGING W_RETURN.
*   セル編集不可設定
    PERFORM FRM_EDIT_ALV USING    TD_FIELDCAT
                         CHANGING TD_OUTALV.

*   セルカラー設定
    PERFORM FRM_COL_ALV USING    TD_FIELDCAT
                        CHANGING TD_OUTALV.

    IF W_EDITMD = 'X' AND W_DISPLAY IS INITIAL.
      IF P_SEIHIN = 'X'.
        LOOP AT TD_BKEDIT ASSIGNING FIELD-SYMBOL(<FS_BKEDIT>).
          APPEND <FS_BKEDIT> TO TD_OUTALV.
        ENDLOOP.
        SORT TD_OUTALV BY MATNR WERKS SORTCT LGORT.
      ELSE.
*       セル編集可設定
        PERFORM FRM_EDITMODE.
      ENDIF.
    ENDIF.
    MESSAGE S018(ZMM001). "データを再取得しました
    rs_selfield-refresh = 'X'.
  ENDIF.

*--- 変更ボタン押下時
  IF a_ucomm = '%CHANGE'.
    W_UCOMM = a_ucomm.
    PERFORM FRM_CHANGEMODE CHANGING rs_selfield.
  ENDIF.

*--- 照会ボタン押下時
  IF a_ucomm = '%DISPLAY'.
    W_UCOMM = a_ucomm.
    PERFORM FRM_DISPLAYMODE CHANGING rs_selfield.
  ENDIF.

*--- 保存ボタン押下時
  IF a_ucomm = '%SAVE'.
    LTD_OUTALV[] = TD_OUTALV[].
    SORT LTD_OUTALV BY MATNR WERKS SORTCT LGORT GOUKEI GOUKEI1 GOUKEI2.
    SORT TD_BKALV BY MATNR WERKS SORTCT LGORT GOUKEI GOUKEI1 GOUKEI2.

    IF W_EDITMD = 'X' AND TD_BKALV[] <> LTD_OUTALV[].
      PERFORM FRM_UPDATE CHANGING rs_selfield.
    ELSE.
      MESSAGE S013(ZMM001). "何も変更されませんでした
      RETURN.
    ENDIF.
  ENDIF.

*--- 品目セルクリック時
  IF a_ucomm = '&IC1' AND rs_selfield-FIELDNAME = 'MATNR'.
    READ TABLE TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV>) INDEX rs_selfield-TABINDEX.
    SET PARAMETER ID 'MAT' FIELD <FS_OUTALV>-MATNR.
    SET PARAMETER ID 'WRK' FIELD <FS_OUTALV>-WERKS.
    SET PARAMETER ID 'BERID' FIELD <FS_OUTALV>-WERKS.
    CALL TRANSACTION 'MD04' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
    LEAVE TO LIST-PROCESSING.
  ENDIF.

*--- 販売伝票セルクリック時
  IF a_ucomm = '&IC1' AND rs_selfield-FIELDNAME = 'VBELN_SD'.
    READ TABLE TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV1>) INDEX rs_selfield-TABINDEX.
    IF <FS_OUTALV1>-VBELN IS NOT INITIAL.
      SET PARAMETER ID 'LPN' FIELD <FS_OUTALV1>-VBELN.
      CALL TRANSACTION 'VA33' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      LEAVE TO LIST-PROCESSING.
    ENDIF.
  ENDIF.

*--- 購買伝票セルクリック時
  IF a_ucomm = '&IC1' AND rs_selfield-FIELDNAME = 'EBELN_MM'.
    READ TABLE TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV3>) INDEX rs_selfield-TABINDEX.
    IF <FS_OUTALV3>-EBELN_MM IS NOT INITIAL.
      SET PARAMETER ID 'SAG' FIELD <FS_OUTALV3>-EBELN_MM.
      CALL TRANSACTION 'ME39' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.
      LEAVE TO LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_UCOM
*&---------------------------------------------------------------------*
*& ALVステータスセット処理
*&---------------------------------------------------------------------*
*&      --> rt_extab
*&---------------------------------------------------------------------*
FORM FRM_STSET USING rt_extab TYPE slis_t_extab.

  DATA:LTD_FCODE TYPE STANDARD TABLE OF GUI_CODE,
       LW_FCODE  TYPE GUI_CODE.

  IF W_EDITMD IS INITIAL.

**   購買分納契約行が存在しない場合、変更ボタンを無効化する
*    IF P_GAISEI = 'X'.
*      READ TABLE TD_OUTALV INTO TH_OUTALV WITH KEY SORTCT = CNS_SORTCT-EKET. "購買分納契約
*      IF SY-SUBRC <> 0.
*        LW_FCODE = '%CHANGE'.
*        APPEND LW_FCODE TO  LTD_FCODE.
*      ENDIF.
*    ENDIF.

    LW_FCODE = '%DISPLAY'.
  ELSEIF P_GAISEI = 'X'.
    IF W_UCOMM = '%CHANGE'.
      LW_FCODE = '%CHANGE'.
    ELSE.
      LW_FCODE = '%DISPLAY'.
    ENDIF.
  ELSE.
    LW_FCODE = '%DISPLAY'.
  ENDIF.

  APPEND LW_FCODE TO  LTD_FCODE.
  SET PF-STATUS 'Z001' EXCLUDING LTD_FCODE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CHANGEMODE
*&---------------------------------------------------------------------*
*& 変更モード処理
*&---------------------------------------------------------------------*
*&      <-- rs_selfield  セルフィールド
*&---------------------------------------------------------------------*
FORM FRM_CHANGEMODE CHANGING OTH_RS_SELFIELD TYPE slis_selfield.

  IF W_EDITMD = 'X' AND P_GAISEI = 'X' AND W_DISPLAY IS INITIAL.
    MESSAGE S007(ZMM001). "既に変更モードになっています
    RETURN.
  ELSE.
    IF W_SDATE_M0 < SY-DATUM.
      MESSAGE S020(ZMM001). "当月より前のデータは変更モードにできません
      RETURN.
    ENDIF.
    IF P_SEIHIN = 'X'.
      READ TABLE TD_OUTALV INTO TH_OUTALV WITH KEY SORTCT+12(1) = '4'.
      IF SY-SUBRC <> 0.
         MESSAGE S008(ZMM001). "一覧に変更可能なデータが存在しません
         RETURN.
      ENDIF.

      IF OTH_RS_SELFIELD-TABINDEX = 0 OR OTH_RS_SELFIELD-SEL_TAB_FIELD <> '1-'.
         MESSAGE S022(ZMM001). "変更可能行(最新の生管修正)を行選択して変更ボタンを押下してください
         RETURN.
      ELSE.
         READ TABLE TD_OUTALV INTO TH_OUTALV INDEX OTH_RS_SELFIELD-TABINDEX.
         IF SY-SUBRC = 0 AND TH_OUTALV-SORTCT+12(1) <> '4'.
           MESSAGE S022(ZMM001). "変更可能行(最新の生管修正)を行選択して変更ボタンを押下してください
           RETURN.
         ENDIF.
         LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV>) WHERE VBELN = TH_OUTALV-VBELN
                                                                 AND POSNR = TH_OUTALV-POSNR
                                                                 AND SORTCT+12(1) = '5'.
           EXIT.
         ENDLOOP.
         IF SY-SUBRC = 0.
           MESSAGE S023(ZMM001). "選択した行は既に変更モードになっています。
           RETURN.
         ENDIF.
         W_TABIX = OTH_RS_SELFIELD-TABINDEX.
      ENDIF.
    ELSE.
      READ TABLE TD_OUTALV INTO TH_OUTALV WITH KEY SORTCT = CNS_SORTCT-EKET. "購買分納契約
      IF SY-SUBRC <> 0.
        MESSAGE S008(ZMM001). "一覧に変更可能なデータが存在しません
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
  IF W_EDITMD IS INITIAL.
    CLEAR:TD_OUTALV,TD_EBTXT.
*   データ再取得
    PERFORM FRM_GETMAINDATA CHANGING W_RETURN.
  ENDIF.
  OTH_RS_SELFIELD-REFRESH = 'X'.

* 伝票ロック処理
  PERFORM FRM_ORDERLOCK.
  SORT TD_OUTALV BY MATNR WERKS SORTCT LGORT.
  SORT TD_BKALV BY MATNR WERKS SORTCT LGORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_UPDATE
*&---------------------------------------------------------------------*
*& 更新処理
*&---------------------------------------------------------------------*
*&      <-- rs_selfield  セルフィールド
*&---------------------------------------------------------------------*
FORM FRM_UPDATE CHANGING OTH_RS_SELFIELD TYPE slis_selfield.

  DATA:LTD_ITEM      TYPE STANDARD TABLE OF BAPIMEOUTITEM,
       LTD_SCHEDULE  TYPE STANDARD TABLE OF BAPIMEOUTSCHEDULE,
       LTH_SCHEDULE  LIKE LINE  OF LTD_SCHEDULE,
       LTD_SCHEDULEX TYPE STANDARD TABLE OF BAPIMEOUTSCHEDULEX,
       LTD_HEADER_TEXT TYPE STANDARD TABLE OF BAPIMEOUTTEXT,
       LTH_HEADER_TEXT LIKE LINE OF LTD_HEADER_TEXT,
       LTH_SCHEDULEX LIKE LINE  OF LTD_SCHEDULEX,
       LTD_RETURN    TYPE STANDARD TABLE OF BAPIRET2,
       LW_DATE2(10)  TYPE C,
       LW_DATE3(8)   TYPE C,
       LW_DATE4      TYPE D,
       LW_COUNT(2)   TYPE N,
       LW_MAXLINE    TYPE EKET-ETENR,
       LW_ERRFLG     TYPE FLAG,
       LW_BDCFLG     TYPE FLAG,
       LW_WMENG_STR  TYPE STRING,
       LW_WMENG      TYPE VBEP-WMENG,
       LW_COMP       TYPE STANDARD TABLE OF BAPIMEOUTCOMPONENT,
       LW_COMPX      TYPE STANDARD TABLE OF BAPIMEOUTCOMPONENTX,
       LTD_VBEP_ALL  TYPE STANDARD TABLE OF TYP_VBEP_ALL,
       LW_VBELN      TYPE VBLB-VBELN.

*--- 桁数チェック処理
  IF P_GAISEI = 'X'.
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV3>) WHERE SORTCT = CNS_SORTCT-EKET.
      CLEAR <FS_OUTALV3>-GOUKEI.
      OTH_rs_selfield-refresh = 'X'.
      IF W_DISPLAY IS INITIAL.
        LOOP AT <FS_OUTALV3>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL4>).
          IF <FIELD_SCOL4>-COLOR-COL <> col_heading.
            IF <FIELD_SCOL4>-FNAME+0(4) = 'MENG' AND <FIELD_SCOL4>-FNAME+4(2) IN RD_DAY.
              <FIELD_SCOL4>-COLOR-COL = col_background . "白
              <FIELD_SCOL4>-COLOR-INT = 0 .              "通常
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
      DO.
         LW_COUNT = LW_COUNT + 1.
         IF LW_COUNT > '31'.
           CLEAR LW_COUNT.
           EXIT.
         ENDIF.
         CONCATENATE 'MENG' LW_COUNT INTO W_FIELD2.
         CONCATENATE '<FS_OUTALV3>-MENG' LW_COUNT INTO W_FIELD1.
         ASSIGN (W_FIELD1) TO <FS_FLD1>.
*        合計の再計算
         <FS_OUTALV3>-GOUKEI = <FS_OUTALV3>-GOUKEI + <FS_FLD1>.

*        桁数チェック
         IF <FS_FLD1> >= CNS_CHKMNG.
           MESSAGE S016(ZMM001) DISPLAY LIKE 'E'. "整数10桁を超える入力は許可されていません
           LOOP AT <FS_OUTALV3>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL5>).
             IF <FIELD_SCOL5>-FNAME = W_FIELD2.
               <FIELD_SCOL5>-COLOR-COL = col_negative . "赤
               <FIELD_SCOL5>-COLOR-INT = 1 .            "強調
             ENDIF.
           ENDLOOP.

           LW_ERRFLG = 'X'.
         ENDIF.
      ENDDO.
    ENDLOOP.
  ELSE.
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV4>) WHERE SORTCT+12(1) = CNS_SORTCT-VBEP_5.
      CLEAR <FS_OUTALV4>-GOUKEI.
      OTH_rs_selfield-refresh = 'X'.
      LOOP AT <FS_OUTALV4>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL6>).
        IF <FIELD_SCOL6>-FNAME+0(4) = 'MENG' AND <FIELD_SCOL6>-FNAME+4(2) IN RD_DAY.
          <FIELD_SCOL6>-COLOR-COL = col_background . "白
          <FIELD_SCOL6>-COLOR-INT = 0 .              "通常
        ENDIF.
      ENDLOOP.
      DO.
         LW_COUNT = LW_COUNT + 1.
         IF LW_COUNT > '31'.
           CLEAR LW_COUNT.
           EXIT.
         ENDIF.
         CONCATENATE 'MENG' LW_COUNT INTO W_FIELD2.
         CONCATENATE '<FS_OUTALV4>-MENG' LW_COUNT INTO W_FIELD1.
         ASSIGN (W_FIELD1) TO <FS_FLD1>.
*        合計の再計算
         <FS_OUTALV4>-GOUKEI = <FS_OUTALV4>-GOUKEI + <FS_FLD1>.

         IF <FS_FLD1> >= CNS_CHKMNG.
           MESSAGE S016(ZMM001) DISPLAY LIKE 'E'. "整数10桁を超える入力は許可されていません
           LOOP AT <FS_OUTALV4>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL7>).
             IF <FIELD_SCOL7>-FNAME = W_FIELD2.
               <FIELD_SCOL7>-COLOR-COL = col_negative . "赤
               <FIELD_SCOL7>-COLOR-INT = 1 .            "強調
             ENDIF.
           ENDLOOP.

           LW_ERRFLG = 'X'.
         ENDIF.
      ENDDO.
    ENDLOOP.
  ENDIF.
  IF LW_ERRFLG = 'X'.
    RETURN.
  ENDIF.

*--- 購買分納契約更新処理
  IF P_GAISEI = 'X'.

    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV>) WHERE SORTCT = CNS_SORTCT-EKET.
      IF LW_ERRFLG = 'X'.
        EXIT.
      ENDIF.
      OTH_rs_selfield-refresh = 'X'.

*     購買分納契約情報取得
      CALL FUNCTION 'BAPI_SAG_GETDETAIL'
        EXPORTING
          purchasingdocument          = <FS_OUTALV>-EBELN
          ITEM_DATA                   = 'X'
          SCHEDULE_DATA               = 'X'
        TABLES
          ITEM                        = LTD_ITEM
          SCHEDULE                    = LTD_SCHEDULE
          SC_COMPONENT                = LW_COMP
          RETURN                      = LTD_RETURN.

       LW_DATE4 = W_KDATE_M0.
       DO.
          IF LW_DATE4 > W_SDATE_M0.
            EXIT.
          ENDIF.
          CONCATENATE LW_DATE4+0(4) '/' LW_DATE4+4(2) '/' LW_DATE4+6(2) INTO LW_DATE2.
          LW_DATE3 = LW_DATE4.
          CONCATENATE '<FS_OUTALV>-MENG' LW_DATE4+6(2) INTO W_FIELD1.
          CONCATENATE 'MENG' LW_DATE4+6(2) INTO W_FIELD2.
          ASSIGN (W_FIELD1) TO <FS_FLD1>.
          LW_DATE4 = LW_DATE4 + 1.

          IF <FS_FLD1> IS INITIAL.
            READ TABLE LTD_SCHEDULE ASSIGNING FIELD-SYMBOL(<FS_SCHEDULE1>) WITH KEY DELIVERY_DATE = LW_DATE2.
            IF SY-SUBRC = 0.
*             納入日程行があり状態の数量０更新パターン
              <FS_SCHEDULE1>-QUANTITY   = <FS_FLD1>.
              <FS_SCHEDULE1>-DELETE_IND = 'X'.
              LTH_SCHEDULEX-ITEM_NO     = <FS_SCHEDULE1>-ITEM_NO.
              LTH_SCHEDULEX-SCHED_LINE  = <FS_SCHEDULE1>-SCHED_LINE.
              LTH_SCHEDULEX-DELETE_IND  = 'X'.
              LTH_SCHEDULEX-QUANTITY    = 'X'.
              APPEND LTH_SCHEDULEX TO LTD_SCHEDULEX.
            ENDIF.
          ELSE.
            READ TABLE LTD_SCHEDULE ASSIGNING FIELD-SYMBOL(<FS_SCHEDULE2>) WITH KEY DELIVERY_DATE = LW_DATE2.
            IF SY-SUBRC = 0 AND <FS_SCHEDULE2>-QUANTITY <> <FS_FLD1>.
*             納入日程行があり状態の数量更新パターン
              <FS_SCHEDULE2>-QUANTITY   = <FS_FLD1>.
              LTH_SCHEDULEX-ITEM_NO     = <FS_SCHEDULE2>-ITEM_NO.
              LTH_SCHEDULEX-SCHED_LINE  = <FS_SCHEDULE2>-SCHED_LINE.
              LTH_SCHEDULEX-QUANTITY    = 'X'.
              APPEND LTH_SCHEDULEX TO LTD_SCHEDULEX.
            ELSEIF SY-SUBRC <> 0.
*             納入日程行が無し状態の数量更新パターン
              IF LW_MAXLINE IS INITIAL.
                SELECT ETENR
                  UP TO 1 ROWS
                  INTO LW_MAXLINE
                  FROM EKET
                 WHERE EBELN = <FS_OUTALV>-EBELN
                   AND EBELP = <FS_OUTALV>-EBELP
                 ORDER BY ETENR DESCENDING.
                ENDSELECT.
              ENDIF.
              LW_MAXLINE = LW_MAXLINE + 1.

              LTH_SCHEDULE-ITEM_NO         = <FS_OUTALV>-EBELP.
              LTH_SCHEDULE-SCHED_LINE      = LW_MAXLINE.
              LTH_SCHEDULE-DEL_DATCAT_EXT  = 'D'.
              LTH_SCHEDULE-DELIVERY_DATE   = LW_DATE2.
              LTH_SCHEDULE-QUANTITY        = <FS_FLD1>.
              LTH_SCHEDULE-STAT_DATE       = LW_DATE3.
              LTH_SCHEDULE-PO_DATE         = SY-DATUM.

              LTH_SCHEDULEX-ITEM_NO        = <FS_OUTALV>-EBELP.
              LTH_SCHEDULEX-SCHED_LINE     = LW_MAXLINE.
              LTH_SCHEDULEX-DEL_DATCAT_EXT = 'X'.
              LTH_SCHEDULEX-DELIVERY_DATE  = 'X'.
              LTH_SCHEDULEX-QUANTITY       = 'X'.
              LTH_SCHEDULEX-STAT_DATE      = 'X'.
              LTH_SCHEDULEX-PO_DATE        = 'X'.
              APPEND LTH_SCHEDULE  TO LTD_SCHEDULE.
              APPEND LTH_SCHEDULEX TO LTD_SCHEDULEX.
            ELSEIF <FS_SCHEDULE2>-QUANTITY = <FS_FLD1>.
              DELETE LTD_SCHEDULE WHERE  DELIVERY_DATE = LW_DATE2.
            ENDIF.
          ENDIF.
       ENDDO.

      IF LW_ERRFLG IS INITIAL.
        IF LTD_SCHEDULEX IS NOT INITIAL OR <FS_OUTALV>-POHDTXT IS NOT INITIAL.

          IF <FS_OUTALV>-POHDTXT IS NOT INITIAL.
            LTH_HEADER_TEXT-TEXT_ID = 'L02'.
            LTH_HEADER_TEXT-TEXT_FORM = '*'.
            LTH_HEADER_TEXT-TEXT_LINE = <FS_OUTALV>-POHDTXT.
            APPEND LTH_HEADER_TEXT TO LTD_HEADER_TEXT.
          ENDIF.

*         購買分納契約変更
          CALL FUNCTION 'BAPI_SAG_CHANGE'
            EXPORTING
              purchasingdocument           = <FS_OUTALV>-EBELN
            TABLES
              RETURN                       = LTD_RETURN
              SCHEDULE                     = LTD_SCHEDULE
              SCHEDULEX                    = LTD_SCHEDULEX
              HEADER_TEXT                  = LTD_HEADER_TEXT.

           READ TABLE LTD_RETURN WITH KEY TYPE = 'E' ASSIGNING FIELD-SYMBOL(<FS_RETURN>).
           IF SY-SUBRC = 0.
             ROLLBACK WORK .
             LW_ERRFLG = 'X'.
             MESSAGE <FS_RETURN>-MESSAGE TYPE 'S' DISPLAY LIKE 'E'.
             PERFORM FRM_ORDERLOCK.
             EXIT.
           ENDIF.
           CLEAR LTD_HEADER_TEXT.
         ENDIF.
       ELSE.
         EXIT.
       ENDIF.
    ENDLOOP.
    IF LW_ERRFLG IS INITIAL.
      COMMIT WORK.
      PERFORM FRM_ORDERLOCK.
      MESSAGE S014(ZMM001). "データの更新に成功しました
    ENDIF.
  ENDIF.

*--- 販売分納契約更新処理
  IF P_SEIHIN = 'X'.
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV2>) WHERE SORTCT+12(1) = CNS_SORTCT-VBEP_5.
      CLEAR LW_BDCFLG.
      IF LW_ERRFLG = 'X'.
        EXIT.
      ENDIF.

      OTH_rs_selfield-refresh = 'X'.

*    納入日程行の全データ取得
     SELECT EDATU
            WMENG
       INTO TABLE LTD_VBEP_ALL
       FROM VBEP
      WHERE VBELN = <FS_OUTALV2>-VBELN
        AND POSNR = <FS_OUTALV2>-POSNR
        AND ABART = '5'
        AND WMENG <> 0.

*     第一画面
      PERFORM BDC_DYNPRO USING  'SAPMV45A'   '0125'.
      PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=ENT2'.
      PERFORM BDC_FIELD  USING  'VBAK-VBELN' <FS_OUTALV2>-VBELN.
*     明細検索
      PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4001'.
      PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=POPO'.
*     対象の明細を画面一番上に遷移
      PERFORM BDC_DYNPRO USING  'SAPMV45A'   '0251'.
      PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=POSI'.
      PERFORM BDC_FIELD  USING  'RV45A-POSNR' <FS_OUTALV2>-POSNR.
*     納入日程行遷移
      PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4001'.
      PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=PPEI'.
      PERFORM BDC_FIELD  USING  'RV45A-VBAP_SELKZ(01)' 'X'.
*       新規納入日程行(提案無し)ボタン押下
      CLEAR LW_VBELN.
      SELECT SINGLE VBELN
        INTO LW_VBELN
        FROM VBLB
      WHERE VBELN = <FS_OUTALV2>-VBELN
        AND POSNR = <FS_OUTALV2>-POSNR
        AND ABRLI = ''
        AND ABART = '5'
        AND LABNK = <FS_OUTALV2>-LABNK.

      IF SY-SUBRC <> 0.
        PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
        PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=PABN'.
      ENDIF.
*     計画バージョン、計画日をセット
      PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
      PERFORM BDC_FIELD  USING  'BDC_OKCODE' '/00'.
      PERFORM BDC_FIELD  USING  'VBLB-LABNK' <FS_OUTALV2>-LABNK.
      PERFORM BDC_FIELD  USING  'VBLB-ABRDT' SY-DATUM.

*     納入日程行の全データセット
      IF LW_VBELN IS INITIAL.
        LOOP AT LTD_VBEP_ALL ASSIGNING FIELD-SYMBOL(<FS_VBEP_ALL>).
          LW_WMENG_STR = <FS_VBEP_ALL>-WMENG.
*         行追加
          PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
          PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=EIAN'.
*         新規行セット
          PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
          PERFORM BDC_FIELD  USING  'BDC_OKCODE' '/00'.
          PERFORM BDC_FIELD  USING  'RV45A-PRGBZ(02)' 'D'.
          PERFORM BDC_FIELD  USING  'RV45A-ETDAT(02)' <FS_VBEP_ALL>-EDATU.
          PERFORM BDC_FIELD  USING  'VBEP-WMENG(02)'  LW_WMENG_STR.
        ENDLOOP.
      ENDIF.

*     変更内容の反映
      LW_DATE4 = W_KDATE_M0.
      DO.
        IF LW_DATE4 > W_SDATE_M0.
          EXIT.
        ENDIF.
        CONCATENATE '<FS_OUTALV2>-MENG' LW_DATE4+6(2) INTO W_FIELD1.
        CONCATENATE 'MENG' LW_DATE4+6(2) INTO W_FIELD2.
        ASSIGN (W_FIELD1) TO <FS_FLD2>.
        LW_WMENG_STR = <FS_FLD2>.

        IF <FS_FLD2> IS INITIAL.
          READ TABLE TD_VBEP_N ASSIGNING FIELD-SYMBOL(<FS_VBEP1>) WITH KEY ABART = CNS_5
                                                                           VBELN = <FS_OUTALV2>-VBELN
                                                                           POSNR = <FS_OUTALV2>-POSNR
                                                                           EDATU = LW_DATE4.
          IF SY-SUBRC = 0.
*           納入日程行があり状態の数量０更新パターン
*           納入日程行検索にジャンプ
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=EIPO'.
*           納入日程行検索
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '0252'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=POSI'.
            PERFORM BDC_FIELD  USING  'RV45A-PRGBZ' 'D'.
            PERFORM BDC_FIELD  USING  'RV45A-ETDAT' LW_DATE4.
*           所要量セット
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '/00'.
            PERFORM BDC_FIELD  USING  'VBEP-WMENG(01)' LW_WMENG_STR.
            IF LW_ERRFLG = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
        ELSE.
          READ TABLE TD_VBEP_N ASSIGNING FIELD-SYMBOL(<FS_VBEP2>) WITH KEY ABART = CNS_5
                                                                           VBELN = <FS_OUTALV2>-VBELN
                                                                           POSNR = <FS_OUTALV2>-POSNR
                                                                           EDATU = LW_DATE4.
          IF SY-SUBRC = 0 AND <FS_VBEP2>-VMENG <> LW_WMENG.
*           納入日程行があり状態の数量更新パターン
*           納入日程行検索にジャンプ
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=EIPO'.
*           納入日程行検索
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '0252'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=POSI'.
            PERFORM BDC_FIELD  USING  'RV45A-PRGBZ' 'D'.
            PERFORM BDC_FIELD  USING  'RV45A-ETDAT' LW_DATE4.
*           所要量セット
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '/00'.
            PERFORM BDC_FIELD  USING  'VBEP-WMENG(01)' LW_WMENG_STR.
          ELSEIF SY-SUBRC <> 0.
*           納入日程行が無し状態の数量更新パターン
*           行追加
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=EIAN'.
*           新規行セット
            PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
            PERFORM BDC_FIELD  USING  'BDC_OKCODE' '/00'.
            PERFORM BDC_FIELD  USING  'RV45A-PRGBZ(02)' 'D'.
            PERFORM BDC_FIELD  USING  'RV45A-ETDAT(02)' LW_DATE4.
            PERFORM BDC_FIELD  USING  'VBEP-WMENG(02)'  LW_WMENG_STR.
          ENDIF.
        ENDIF.
        LW_DATE4 = LW_DATE4 + 1.
        LW_BDCFLG = 'X'.
      ENDDO.
      IF LW_BDCFLG = 'X'.
*       保存
        PERFORM BDC_DYNPRO USING  'SAPMV45A'   '4003'.
        PERFORM BDC_FIELD  USING  'BDC_OKCODE' '=SICH'.
*       コールトラン
        PERFORM FRM_CALLTRAN USING <FS_OUTALV2>-VBELN
                             CHANGING LW_ERRFLG.
      ENDIF.
      IF LW_ERRFLG = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LW_ERRFLG IS INITIAL.
      COMMIT WORK.
*    データ再取得
      CLEAR TD_OUTALV.
      PERFORM FRM_GETMAINDATA CHANGING W_RETURN.
      LOOP AT TD_VBEP_LK ASSIGNING FIELD-SYMBOL(<FS_VBEP_LK>).
*       ロック解除
        CALL FUNCTION 'DEQUEUE_EVVBAKE'
         EXPORTING
           VBELN                = <FS_VBEP_LK>-VBELN.
      ENDLOOP.
      CLEAR TD_VBEP_LK.
      MESSAGE S014(ZMM001). "データの更新に成功しました
*      PERFORM FRM_ORDERLOCK.
    ENDIF.
  ENDIF.

*--- バックアップの設定
  TD_BKALV[] = TD_OUTALV[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_ORDERLOCK
*&---------------------------------------------------------------------*
*& 伝票ロック処理
*&---------------------------------------------------------------------*
FORM FRM_ORDERLOCK .

  DATA:LW_LOCKERR TYPE FLAG.
  CLEAR TD_LOCK.

  IF P_SEIHIN = 'X'.
*--- 販売分納契約のロック処理

    READ TABLE TD_OUTALV INTO TH_OUTALV INDEX W_TABIX.
    READ TABLE TD_VBEP_LK ASSIGNING FIELD-SYMBOL(<FS_VBEP_LK>) WITH KEY VBELN = TH_OUTALV-VBELN.

    IF SY-SUBRC <> 0.
      CALL FUNCTION 'ENQUEUE_EVVBAKE'
       EXPORTING
         VBELN                = TH_OUTALV-VBELN
         _WAIT                = '0.5'
       EXCEPTIONS
         FOREIGN_LOCK         = 1
         SYSTEM_FAILURE       = 2
         OTHERS               = 3.

      IF sy-subrc <> 0.
        LW_LOCKERR = 'X'.
        MESSAGE S010(ZMM001) WITH TH_OUTALV-VBELN DISPLAY LIKE 'E'. "販売分納契約伝票 &1 のロックに失敗しました。時間を置いてから再実行してください
        EXIT.
      ELSE.
        APPEND TH_OUTALV-VBELN TO TD_VBEP_LK.
      ENDIF.
    ENDIF.
  ELSEIF P_GAISEI = 'X' AND W_DISPLAY IS INITIAL.
*--- 購買分納契約のロック処理
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV2>) WHERE SORTCT = CNS_SORTCT-EKET. "購買分納契約
      TH_LOCK-VBELN = <FS_OUTALV2>-EBELN.
      APPEND TH_LOCK TO TD_LOCK.
    ENDLOOP.
    SORT TD_LOCK BY VBELN.
    DELETE ADJACENT DUPLICATES FROM TD_LOCK.

    LOOP AT TD_LOCK ASSIGNING FIELD-SYMBOL(<TD_LOCK3>).
      CALL FUNCTION 'ENQUEUE_EMEKKOE'
       EXPORTING
         EBELN                = <TD_LOCK3>-VBELN
       EXCEPTIONS
         FOREIGN_LOCK         = 1
         SYSTEM_FAILURE       = 2
         OTHERS               = 3.

      IF sy-subrc <> 0.
        LW_LOCKERR = 'X'.
        MESSAGE S009(ZMM001) WITH <TD_LOCK3>-VBELN DISPLAY LIKE 'E'. "購買分納契約伝票 &1 のロックに失敗しました。時間を置いてから再実行してください
        EXIT.
      ENDIF.
    ENDLOOP.
    IF LW_LOCKERR = 'X'.
      LOOP AT TD_LOCK ASSIGNING FIELD-SYMBOL(<TD_LOCK4>).
        CALL FUNCTION 'DEQUEUE_EMEKKOE'
         EXPORTING
           EBELN                = <TD_LOCK4>-VBELN.
      ENDLOOP.
    ENDIF.
  ENDIF.
  IF LW_LOCKERR IS INITIAL.
**--- プログラムロック処理
*    CALL FUNCTION 'ENQUEUE_E_TABLE'
*     EXPORTING
*       TABNAME              = 'ZMMR0010'
*     EXCEPTIONS
*       FOREIGN_LOCK         = 1
*       SYSTEM_FAILURE       = 2
*       OTHERS               = 3
*              .
*    IF sy-subrc <> 0.
*      MESSAGE S011(ZMM001) DISPLAY LIKE 'E'. "他ユーザーが編集中です。時間を置いてから再実行してください
*      RETURN.
*    ELSE.
*     セル編集可設定
      PERFORM FRM_EDITMODE.
      IF W_EDITMD IS INITIAL OR W_DISPLAY = 'X'.
        MESSAGE S012(ZMM001). "変更モードにしました
      ENDIF.
      W_EDITMD = 'X'.
      CLEAR W_DISPLAY.
*    ENDIF.
  ENDIF.

*--- バックアップの設定
  TD_BKALV[] = TD_OUTALV[].

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       batch input data : new screen
*----------------------------------------------------------------------*
*      -->IW_ROGRAM   Program ID
*      -->IW_DYNPRO   Dynpro number
*----------------------------------------------------------------------*
FORM BDC_DYNPRO  USING IW_PROGRAM TYPE ANY
                       IW_DYNPRO  TYPE ANY.

  CLEAR TH_BDCDATA.
  TH_BDCDATA-PROGRAM  = IW_PROGRAM.
  TH_BDCDATA-DYNPRO   = IW_DYNPRO.
  TH_BDCDATA-DYNBEGIN = 'X'.
  APPEND TH_BDCDATA TO TD_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       batch input data : field
*----------------------------------------------------------------------*
*      -->IW_FNAM   field name
*      -->IW_FVAL   field value
*----------------------------------------------------------------------*
FORM BDC_FIELD  USING IW_FNAM TYPE ANY
                      IW_FVAL TYPE ANY.

  CLEAR TH_BDCDATA.
  TH_BDCDATA-FNAM = IW_FNAM.
  TH_BDCDATA-FVAL = IW_FVAL.
  APPEND TH_BDCDATA TO TD_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CALLTRAN
*&---------------------------------------------------------------------*
*& コールトラン処理
*&---------------------------------------------------------------------*
*&      --> <FS_OUTALV2>-VBELN　販売伝票番号
*&      <-- LW_ERRFLG　　　　　 エラーフラグ
*&---------------------------------------------------------------------*
FORM FRM_CALLTRAN  USING OW_VBELN TYPE VBEP-VBELN
                   CHANGING OW_ERRFLG TYPE FLAG.

  DATA:LW_MODE(1)     TYPE C,
       LTD_BDCMSG     TYPE STANDARD TABLE OF BDCMSGCOLL,
       LW_MSGTXT(200) TYPE C.

* ロック解除
  CALL FUNCTION 'DEQUEUE_EVVBAKE'
   EXPORTING
     VBELN                = OW_VBELN.

  LW_MODE = 'N'.
  WAIT UP TO '0.1' SECONDS.
  CALL TRANSACTION 'VA32' WITH AUTHORITY-CHECK USING TD_BDCDATA MODE LW_MODE MESSAGES INTO LTD_BDCMSG.

  IF SY-SUBRC <> 0.
    ROLLBACK WORK .
    OW_ERRFLG = 'X'.
    READ TABLE LTD_BDCMSG ASSIGNING FIELD-SYMBOL(<FS_BDCMSG>) WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      MESSAGE ID <FS_BDCMSG>-MSGID
            TYPE 'S'
          NUMBER <FS_BDCMSG>-MSGNR
            WITH <FS_BDCMSG>-MSGV1
                 <FS_BDCMSG>-MSGV2
                 <FS_BDCMSG>-MSGV3
                 <FS_BDCMSG>-MSGV4
            INTO LW_MSGTXT .
      MESSAGE LW_MSGTXT TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      MESSAGE S034(ZMM001) DISPLAY LIKE 'E'. "販売分納契約の更新に失敗しました
    ENDIF.
  ENDIF.
  CLEAR:TD_BDCDATA.

* 再ロック
  CALL FUNCTION 'ENQUEUE_EVVBAKE'
   EXPORTING
     VBELN                = OW_VBELN
     _WAIT                = '0.5'
   EXCEPTIONS
     FOREIGN_LOCK         = 1
     SYSTEM_FAILURE       = 2
     OTHERS               = 3.
  IF SY-SUBRC <> 0.
    MESSAGE S010(ZMM001) WITH OW_VBELN DISPLAY LIKE 'E'. "販売分納契約伝票 &1 のロックに失敗しました。時間を置いてから再実行してください
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_EDITMODE
*&---------------------------------------------------------------------*
*& セル編集可設定
*&---------------------------------------------------------------------*
FORM FRM_EDITMODE .

  DATA:LW_STR   TYPE STRING,
       LW_TEXT  TYPE C LENGTH 27,
       LW_COUNT TYPE N LENGTH 2,
       LW_DATE_NE TYPE D,
       LW_INT   TYPE I.

*--- 変更不可期間の作成
   IF ( W_KDATE_M0 <= SY-DATUM ) AND ( W_SDATE_M0 >= SY-DATUM ).
     LW_DATE_NE = W_KDATE_M0.
     DO.
       IF LW_DATE_NE <> SY-DATUM.
         RH_DAY-SIGN   = 'E'.
         RH_DAY-OPTION = 'EQ'.
         RH_DAY-LOW    = LW_DATE_NE+6(2).
         APPEND RH_DAY TO RD_DAY.
         LW_DATE_NE = LW_DATE_NE + 1.
       ELSE.
         EXIT.
       ENDIF.
     ENDDO.
   ENDIF.

  IF P_SEIHIN = 'X'.
*--- 出荷計画の変更処理
    READ TABLE TD_OUTALV INTO TH_OUTALV INDEX W_TABIX.
    TH_OUTALV-SORTCT+12(1) = CNS_SORTCT-VBEP_5.
    TH_OUTALV-MIKOMI = TEXT-027."得意先内示(生管修正)

*   出荷計画変換表作成
    IF TD_KEIKAKU IS INITIAL.
      LW_TEXT = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      DO.
        IF SY-INDEX > '26'.
          EXIT.
        ENDIF.

        LW_COUNT = SY-INDEX .

        CONCATENATE 'LW_TEXT+' LW_COUNT '(1)' INTO W_FIELD1.
        ASSIGN (W_FIELD1) TO <FS_FLD1>.
        TH_KEIKAKU-COUNT =  SY-INDEX.
        TH_KEIKAKU-TEXT  =  <FS_FLD1>.
        APPEND TH_KEIKAKU TO TD_KEIKAKU.
        CLEAR TH_KEIKAKU.
      ENDDO.
    ENDIF.
    CLEAR:LW_COUNT.

*   出荷計画のA～Zの繰り上げをし、行追加
    IF TH_OUTALV-LABNK IS INITIAL.
      TH_OUTALV-LABNK = '-A'.

    ELSEIF TH_OUTALV-LABNK = '0'.
      TH_OUTALV-LABNK = 'M' && SY-DATUM && SY-UZEIT(4) && '-A'.
    ELSE.
      LW_STR = SUBSTRING( val = TH_OUTALV-LABNK  off = strlen( TH_OUTALV-LABNK ) - 1 len = 1 ).
      READ TABLE TD_KEIKAKU INTO TH_KEIKAKU WITH KEY TEXT = LW_STR.

      IF SY-SUBRC <> 0.
        CONCATENATE TH_OUTALV-LABNK '-A' INTO  TH_OUTALV-LABNK.
      ELSEIF TH_KEIKAKU-TEXT = 'Z'.
        LW_STR = SUBSTRING( val = TH_OUTALV-LABNK  off = strlen( TH_OUTALV-LABNK ) - 2 len = 1 ).
        IF LW_STR = 'Z'.
        ELSE.
          READ TABLE TD_KEIKAKU INTO TH_KEIKAKU WITH KEY TEXT = LW_STR.
          LW_COUNT = TH_KEIKAKU-COUNT + 1.
          READ TABLE TD_KEIKAKU INTO TH_KEIKAKU WITH KEY COUNT = LW_COUNT.
          IF SY-SUBRC = 0.
            LW_INT = strlen( TH_OUTALV-LABNK ) - 2.
            CONCATENATE  TH_KEIKAKU-TEXT 'A' INTO TH_OUTALV-LABNK+LW_INT(2).
          ELSE.
            LW_INT = strlen( TH_OUTALV-LABNK ) - 1.
            CONCATENATE  'A' 'A' INTO TH_OUTALV-LABNK+LW_INT(2).
          ENDIF.
        ENDIF.
      ELSE.
        LW_COUNT = TH_KEIKAKU-COUNT + 1.
        READ TABLE TD_KEIKAKU INTO TH_KEIKAKU WITH KEY COUNT = LW_COUNT.
        LW_STR = SUBSTRING( val = TH_OUTALV-LABNK  off = strlen( TH_OUTALV-LABNK ) - 2 len = 1 ).
        LW_INT = strlen( TH_OUTALV-LABNK ) - 1.
        TH_OUTALV-LABNK+LW_INT(1) = TH_KEIKAKU-TEXT.
      ENDIF.
    ENDIF.

    APPEND TH_OUTALV TO TD_OUTALV.

*   セル入力可制御
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV5>) WHERE SORTCT+12(1) = CNS_SORTCT-VBEP_5.
      LOOP AT <FS_OUTALV5>-FSTYLE ASSIGNING FIELD-SYMBOL(<FIELD_STYLE1>).
        IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
          IF <FIELD_STYLE1>-FIELDNAME+0(4) = 'MENG'.
              <FIELD_STYLE1>-STYLE = cl_gui_alv_grid=>MC_STYLE_ENABLED. "入力可パターン
          ENDIF.
        ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
          IF <FIELD_STYLE1>-FIELDNAME+0(4) = 'MENG' AND <FIELD_STYLE1>-FIELDNAME+4(2) IN RD_DAY.
              <FIELD_STYLE1>-STYLE = cl_gui_alv_grid=>MC_STYLE_ENABLED. "入力可パターン
          ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT <FS_OUTALV5>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL1>).
        IF <FIELD_SCOL1>-COLOR-COL <> col_heading.
          IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
            IF <FIELD_SCOL1>-FNAME+0(4) = 'MENG'.
               <FIELD_SCOL1>-COLOR-COL = col_background . "白色
            ENDIF.
          ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
            IF <FIELD_SCOL1>-FNAME+0(4) = 'MENG' AND <FIELD_SCOL1>-FNAME+4(2) IN RD_DAY.
               <FIELD_SCOL1>-COLOR-COL = col_background . "白色
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ELSEIF P_GAISEI = 'X'.
*--- 調達計画の変更処理
*   セル入力可制御
    LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV6>) WHERE SORTCT = CNS_SORTCT-EKET. "購買分納契約
      LOOP AT <FS_OUTALV6>-FSTYLE ASSIGNING FIELD-SYMBOL(<FIELD_STYLE2>).
        IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
          IF <FIELD_STYLE2>-FIELDNAME+0(4) = 'MENG'.
            <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_ENABLED. "入力可パターン
          ENDIF.
        ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
          IF <FIELD_STYLE2>-FIELDNAME+0(4) = 'MENG' AND <FIELD_STYLE2>-FIELDNAME+4(2) IN RD_DAY.
              <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_ENABLED. "入力可パターン
          ENDIF.
        ENDIF.
        IF <FIELD_STYLE2>-FIELDNAME = 'POHDTXT'.
          <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_ENABLED. "入力可パターン
        ENDIF.
      ENDLOOP.
      LOOP AT <FS_OUTALV6>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL2>).
        IF <FIELD_SCOL2>-COLOR-COL <> col_heading.
          IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
            IF <FIELD_SCOL2>-FNAME+0(4) = 'MENG'.
               <FIELD_SCOL2>-COLOR-COL = col_background . "白色
            ENDIF.
          ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
            IF <FIELD_SCOL2>-FNAME+0(4) = 'MENG' AND <FIELD_SCOL2>-FNAME+4(2) IN RD_DAY.
               <FIELD_SCOL2>-COLOR-COL = col_background . "白色
            ENDIF.
          ENDIF.
          IF <FIELD_SCOL2>-FNAME = 'POHDTXT'.
            <FIELD_SCOL2>-COLOR-COL = col_background . "白色
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETKANBAN
*&---------------------------------------------------------------------*
*& かんばん収容数取得
*&---------------------------------------------------------------------*
*&      --> TD_MARC　　対象品目
*&      <-- TD_KANBAN　かんばん
*&---------------------------------------------------------------------*
FORM FRM_GETKANBAN  USING    ITD_MARC  LIKE TD_MARC
                    CHANGING OTD_KANBAN LIKE TD_KANBAN.

*--- かんばん収容数取得
   SELECT EKPO~MATNR
          EKPO~WERKS
          PKHD~PKNUM
          PKHD~BEHMG
     INTO TABLE OTD_KANBAN
     FROM EKKO
    INNER JOIN EKPO ON
          EKKO~EBELN = EKPO~EBELN
    INNER JOIN PKHD ON
          EKPO~EBELN = PKHD~EBELN
      AND EKPO~EBELP = PKHD~EBELP
      FOR ALL ENTRIES IN ITD_MARC
    WHERE EKKO~BSART IN RD_BSART
      AND EKPO~MATNR = ITD_MARC-MATNR
      AND EKPO~WERKS = ITD_MARC-WERKS.

   IF SY-SUBRC = 0.
     SORT OTD_KANBAN BY MATNR WERKS PKNUM DESCENDING.
     DELETE ADJACENT DUPLICATES FROM OTD_KANBAN COMPARING MATNR WERKS.
   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DISPLAYMODE
*&---------------------------------------------------------------------*
*& 照会モード処理
*&---------------------------------------------------------------------*
*&      <-- rs_selfield  セルフィールド
*&---------------------------------------------------------------------*
FORM FRM_DISPLAYMODE CHANGING OTH_RS_SELFIELD TYPE slis_selfield.


  W_DISPLAY = 'X'.
  LOOP AT TD_OUTALV ASSIGNING FIELD-SYMBOL(<FS_OUTALV6>) WHERE SORTCT = CNS_SORTCT-EKET. "購買分納契約
    LOOP AT <FS_OUTALV6>-FSTYLE ASSIGNING FIELD-SYMBOL(<FIELD_STYLE2>).
      IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
        IF <FIELD_STYLE2>-FIELDNAME+0(4) = 'MENG'.
          <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_DISABLED. "入力可パターン
        ENDIF.
      ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
        IF <FIELD_STYLE2>-FIELDNAME+0(4) = 'MENG' AND <FIELD_STYLE2>-FIELDNAME+4(2) IN RD_DAY.
            <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_DISABLED. "入力可パターン
        ENDIF.
      ENDIF.
      IF <FIELD_STYLE2>-FIELDNAME = 'POHDTXT'.
        <FIELD_STYLE2>-STYLE = cl_gui_alv_grid=>MC_STYLE_DISABLED. "入力可パターン
      ENDIF.
   ENDLOOP.
     LOOP AT <FS_OUTALV6>-FSCOL ASSIGNING FIELD-SYMBOL(<FIELD_SCOL2>).
      IF <FIELD_SCOL2>-COLOR-COL <> col_heading.
        IF W_KDATE_M0+0(6) > SY-DATUM+0(6).
          IF <FIELD_SCOL2>-FNAME+0(4) = 'MENG'.
             <FIELD_SCOL2>-COLOR-COL = col_normal. "灰色
          ENDIF.
        ELSEIF ( W_SDATE_M0+0(6) = SY-DATUM+0(6) AND W_SDATE_M0+6(2) >= SY-DATUM+6(2) ) OR ( W_SDATE_M0+0(6) > SY-DATUM+0(6) ).
          IF <FIELD_SCOL2>-FNAME+0(4) = 'MENG' AND <FIELD_SCOL2>-FNAME+4(2) IN RD_DAY.
             <FIELD_SCOL2>-COLOR-COL = col_normal. "灰色
          ENDIF.
        ENDIF.
        IF <FIELD_SCOL2>-FNAME = 'POHDTXT'.
          <FIELD_SCOL2>-COLOR-COL = col_normal. "灰色
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  OTH_RS_SELFIELD-REFRESH = 'X'.
  MESSAGE S033(ZMM001). "照会モードにしました

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GETTVARV
*&---------------------------------------------------------------------*
*& TVATV変数取得
*&---------------------------------------------------------------------*
FORM frm_gettvarv  CHANGING ow_return.

*--- 定数取得
  GO_INTERFACE_FACTORY->GET_TVARVC_VALUE(
     EXPORTING
      I_NAME = 'S_MM_ZMMR0010_AUART'
     IMPORTING
      ET_VALUE = RD_AUART ) .

  IF RD_AUART IS INITIAL.
    ow_return = 'X'.
    RETURN.
  ENDIF.

*--- 定数取得
  GO_INTERFACE_FACTORY->GET_TVARVC_VALUE(
     EXPORTING
      I_NAME = 'S_MM_ZMMR0010_BDART'
     IMPORTING
      ET_VALUE = RD_BDART ) .

  IF RD_BDART IS INITIAL.
    ow_return = 'X'.
    RETURN.
  ENDIF.

*--- 定数取得
  GO_INTERFACE_FACTORY->GET_TVARVC_VALUE(
     EXPORTING
      I_NAME = 'S_MM_ZMMR0010_LFART'
     IMPORTING
      ET_VALUE = RD_LFART ) .

  IF RD_LFART IS INITIAL.
    ow_return = 'X'.
    RETURN.
  ENDIF.

*--- 定数取得
  GO_INTERFACE_FACTORY->GET_TVARVC_VALUE(
     EXPORTING
      I_NAME = 'S_MM_ZMMR0010_BSART'
     IMPORTING
      ET_VALUE = RD_BSART ) .

  IF RD_BSART IS INITIAL.
    ow_return = 'X'.
    RETURN.
  ENDIF.

ENDFORM.

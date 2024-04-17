@AbapCatalog.sqlViewName: 'ZTESTK_MK004'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDSVIEW04'
define view ZTESTK_CSD04 as select from I_SalesDocumentBasic {
key SalesDocument,
SDDocumentCategory,
SalesDocumentType,
SalesDocumentProcessingType,
CreatedByUser,
LastChangedByUser,
CreationDate,
CreationTime,
LastChangeDate,
LastChangeDateTime,
LastCustomerContactDate,
SenderBusinessSystemName,
ExternalDocumentID,
ExternalDocLastChangeDateTime,
SalesOrganization,
DistributionChannel,
OrganizationDivision,
SalesGroup,
SalesOffice,
SoldToParty,
AdditionalCustomerGroup1,
AdditionalCustomerGroup2,
AdditionalCustomerGroup3,
AdditionalCustomerGroup4,
AdditionalCustomerGroup5,
CreditControlArea,
CustomerRebateAgreement,
SalesDocumentDate,
SDDocumentReason,
SDDocumentCollectiveNumber,
CustomerPurchaseOrderType,
CustomerPurchaseOrderDate,
CustomerPurchaseOrderSuplmnt,
StatisticsCurrency,
RetsMgmtProcess,
NextCreditCheckDate,
BindingPeriodValidityStartDate,
BindingPeriodValidityEndDate,
HdrOrderProbabilityInPercent,
SchedulingAgreementProfileCode,
DelivSchedTypeMRPRlvnceCode,
AgrmtValdtyStartDate,
AgrmtValdtyEndDate,
MatlUsageIndicator,
TotalNetAmount,
TransactionCurrency,
SalesDocumentCondition,
SDPricingProcedure,
CustomerTaxClassification1,
CustomerTaxClassification2,
CustomerTaxClassification3,
CustomerTaxClassification4,
CustomerTaxClassification5,
CustomerTaxClassification6,
CustomerTaxClassification7,
CustomerTaxClassification8,
CustomerTaxClassification9,
TaxDepartureCountry,
VATRegistrationCountry,
RequestedDeliveryDate,
ShippingCondition,
CompleteDeliveryIsDefined,
DeliveryBlockReason,
FashionCancelDate,
BillingCompanyCode,
HeaderBillingBlockReason,
SalesDocApprovalReason,
ExchangeRateType,
BusinessArea,
CostCenterBusinessArea,
CostCenter,
ControllingArea,
OrderID,
ControllingObject,
AssignmentReference,
PaymentPlan,
CustomerCreditAccount,
ControllingAreaCurrency,
ReleasedCreditAmount,
CreditBlockReleaseDate,
NextShippingDate,
ReferenceSDDocument,
AccountingDocExternalReference,
MasterSalesContract,
ReferenceSDDocumentCategory,
SalesItemProposalDescription,
CorrespncExternalReference,
BusinessSolutionOrder,
OverallSDProcessStatus,
OverallPurchaseConfStatus,
OverallSDDocumentRejectionSts,
TotalBlockStatus,
OverallDelivConfStatus,
OverallTotalDeliveryStatus,
OverallDeliveryStatus,
OverallDeliveryBlockStatus,
OverallOrdReltdBillgStatus,
OverallBillingBlockStatus,
OverallTotalSDDocRefStatus,
OverallSDDocReferenceStatus,
TotalCreditCheckStatus,
MaxDocValueCreditCheckStatus,
PaymentTermCreditCheckStatus,
FinDocCreditCheckStatus,
ExprtInsurCreditCheckStatus,
PaytAuthsnCreditCheckSts,
CentralCreditCheckStatus,
CentralCreditChkTechErrSts,
HdrGeneralIncompletionStatus,
OverallPricingIncompletionSts,
HeaderDelivIncompletionStatus,
HeaderBillgIncompletionStatus,
OvrlItmGeneralIncompletionSts,
OvrlItmBillingIncompletionSts,
OvrlItmDelivIncompletionSts,
OverallChmlCmplncStatus,
OverallDangerousGoodsStatus,
OverallSafetyDataSheetStatus,
SalesDocApprovalStatus,
ContractManualCompletion,
ContractDownPaymentStatus,
OverallTrdCmplncEmbargoSts,
OvrlTrdCmplncSnctndListChkSts,
OvrlTrdCmplncLegalCtrlChkSts,
DeliveryDateTypeRule,
AlternativePricingDate,
OmniChnlSalesPromotionStatus
/* Associations */
//_AdditionalCustomerGroup1,
//_AdditionalCustomerGroup2,
//_AdditionalCustomerGroup3,
//_AdditionalCustomerGroup4,
//_AdditionalCustomerGroup5,
//_BillingCompanyCode,
//_BusinessArea,
//_BusinessAreaText,
//_CentralCreditCheckStatus,
//_CentralCreditChkTechErrSts,
//_ControllingArea,
//_ControllingAreaCurrency,
//_ControllingObject,
//_CostCenter,
//_CostCenterBusinessArea,
//_CostCenterBusinessAreaText,
//_CreatedByUser,
//_CreditControlArea,
//_CreditControlAreaText,
//_CustomerCreditAccount,
//_CustomerPurchaseOrderType,
//_DeliveryBlockReason,
//_DeliveryDateTypeRule,
//_DelivSchedTypeMRPRlvnceCode,
//_DistributionChannel,
//_DownPaymentStatus,
//_EngagementProjectItem,
//_ExchangeRateType,
//_ExprtInsurCreditCheckStatus,
//_FinDocCreditCheckStatus,
//_HdrGeneralIncompletionStatus,
//_HeaderBillgIncompletionStatus,
//_HeaderBillingBlockReason,
//_HeaderDelivIncompletionStatus,
//_ItemBasic,
//_LastChangedByUser,
//_MaxDocValueCreditCheckStatus,
//_OmniChnlSalesPromotionStatus,
//_OrganizationDivision,
//_OverallBillingBlockStatus,
//_OverallChmlCmplncStatus,
//_OverallDangerousGoodsStatus,
//_OverallDelivConfStatus,
//_OverallDeliveryBlockStatus,
//_OverallDeliveryStatus,
//_OverallOrdReltdBillgStatus,
//_OverallPricingIncompletionSts,
//_OverallPurchaseConfStatus,
//_OverallSDDocReferenceStatus,
//_OverallSDDocumentRejectionSts,
//_OverallSDProcessStatus,
//_OverallTotalDeliveryStatus,
//_OverallTotalSDDocRefStatus,
//_OvrlItmBillingIncompletionSts,
//_OvrlItmDelivIncompletionSts,
//_OvrlItmGeneralIncompletionSts,
//_OvrlSftyDataSheetSts,
//_OvrlTradeCmplncEmbargoStatus,
//_OvrlTrdCmplncLegalCtrlChkSts,
//_OvTrdCmplncSnctndListChkSts,
//_PaymentTermCreditCheckStatus,
//_PaytAuthsnCreditCheckSts,
//_ReferenceSDDocumentCategory,
//_RetsMgmtProcess,
//_SalesArea,
//_SalesDocApprovalReason,
//_SalesDocApprovalStatus,
//_SalesDocumentType,
//_SalesGroup,
//_SalesOffice,
//_SalesOrganization,
//_SDDocumentCategory,
//_SDDocumentReason,
//_SDPricingProcedure,
//_ShippingCondition,
//_SoldToParty,
//_SolutionOrder,
//_StatisticsCurrency,
//_TotalBlockStatus,
//_TotalCreditCheckStatus,
//_TransactionCurrency
}

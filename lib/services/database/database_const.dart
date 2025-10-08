

import '../../config/app_detail.dart';

class DatabaseDetails {
  static String databaseName = AppDetails.appName;
  static int dbVersion = 1;

  ///
  static String clientListTable = "ClientInfo";
  static String companyDBName = "DbName";
  static String companyName = "CompanyName";
  static String ledgerCode = "LedgerCode";
  static String auth = "Auth";
  static String post = "Post";
  static String initial = "Initial";
  static String startDate = "StartDate";
  static String endDate = "EndDate";
  static String companyAddress = "CompanyAddress";
  static String phoneNo = "PhoneNo";
  static String vatNo = "VatNo";
  static String email = "Email";
  static String aliasName = "AliasName";





  //Product List Table
  static String productCreateTable = "ProductCreateTable";
  static String id = "Id";
  static String pCode = "PCode";
  static String pDesc = "PDesc";
  static String pShortName = "PShortName";
  static String grpName = "GroupName";
  static String subGrpName = "SubGroupName";
  static String group1 = "Group1";
  static String group2 = "Group2";
  static String unit = "Unit";
  static String buyRate = "BuyRate";
  static String mrp = "MRP";
  static String tradeRate = "TradeRate";
  static String discountPercent = "Discount Percentage";
  static String imageName = "Image Name";
  static String pImage = "PImage";
  static String imageFolderName = "Image Folder Name";
  static String offerDiscount = "Offer Discount";
  static String salesRate = "SalesRate";
  static String stockStatus = "StockStatus";
  static String stockQty = "StockQty";

  static const String qRDatabaseTable = "QRDatabaseTable";
  static const String destinatary = "destinatary";
  static const String isDynamic = "dynamic";

  //Temp Order List Table
  static String orderListTable = "OrderListTable";
  static String pcode = "Pcode";
  static String productName = "ProductName";
  static String qty = "Qty";
  static String rate = "Rate";
  static String productDescription = "ProductDescription";
  static String totalAmt = "TotalAmt";
  static String images = "Images";

  static String productCode = "ProductCode";
  static String quantity = "Quantity";
  static String total = "Total";


  //Post Order Format Model
  static String orderPostTable = "OrderPostTable";
  static String dbName = "DbName";
  static String glCode = "GlCode";
  static String userCode = "UserCode";
  static String comment = "Comment";

  static String ledgerListTable = "LedgerListTable";
  static String glDesc = "GlDesc";
  static String glCatagory = "GlCatagory";
  static String mobile = "MobileNo";
  static String address = "Address";

  //Order Report Table
  static const String orderProductTableGroup = "orderProductTableGroup";
  static const String salesman = "Salesman";
  static const String route = "Route";
  static const String telNoI = "TelNoI";
  static const String creditLimite = "CreditLimite";
  static const String creditDay = "CreditDay";
  static const String overdays = "Overdays";
  static const String overLimit = "OverLimit";
  static const String currentBalance = "CurrentBalance";
  static const String ageOfOrder = "AgeOfOrder";
  static const String remarks = "Remarks";
  static const String managerRemarks = "ManagerRemarks";
  static const String reconcileDate = "ReconcileDate";
  static const String reconcileBy = "ReconcileBy";
  static const String entryModule = "EntryModule";
  static const String invType = "InvType";
  static const String invDate = "InvDate";
  static const String netAmt = "NetAmt";
  static String mobileNumberOrderReport = "Mobile";

  static String vNo = "VNo";
  static String vDate = "VDate";
  static String vTime = "VTime";
  static String orderBy = "OrderBy";
  static String lat = "Lat";
  static String lng = "lng";
  static String long = "long";



}
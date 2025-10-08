import 'package:sqflite/sqflite.dart';
import 'database_const.dart';

class CreateTable {
  Database db;
  CreateTable(this.db);

  /// Company List Info
  companyListTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseDetails.clientListTable} (
        ${DatabaseDetails.companyDBName} TEXT,
        ${DatabaseDetails.companyName} TEXT,
        ${DatabaseDetails.ledgerCode} TEXT,
        ${DatabaseDetails.auth} TEXT,
        ${DatabaseDetails.post} TEXT,
        ${DatabaseDetails.initial} TEXT,
        ${DatabaseDetails.startDate} TEXT,
        ${DatabaseDetails.endDate} TEXT,
        ${DatabaseDetails.companyAddress} TEXT,
        ${DatabaseDetails.phoneNo} TEXT,
        ${DatabaseDetails.vatNo} TEXT,
        ${DatabaseDetails.email} TEXT,
        ${DatabaseDetails.aliasName} TEXT
      )
    ''');
  }



  productCreateTable() async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${DatabaseDetails.productCreateTable} (
      ${DatabaseDetails.pCode} TEXT,      
                                                ${DatabaseDetails.pDesc} TEXT,      
                                                ${DatabaseDetails.pShortName} TEXT,      
                                                ${DatabaseDetails.grpName} TEXT,      
                                                ${DatabaseDetails.subGrpName} TEXT,      
                                                ${DatabaseDetails.group1} TEXT,      
                                                ${DatabaseDetails.group2} TEXT,      
                                                ${DatabaseDetails.unit} TEXT,
                                                ${DatabaseDetails.buyRate} TEXT,
                                                ${DatabaseDetails.salesRate} TEXT,
                                                ${DatabaseDetails.mrp} TEXT,
                                                ${DatabaseDetails.tradeRate} TEXT,
                                                [${DatabaseDetails.discountPercent}] TEXT,
                                                [${DatabaseDetails.imageName}] TEXT,
                                                ${DatabaseDetails.pImage} TEXT,
                                                [${DatabaseDetails.imageFolderName}] TEXT,
                                                [${DatabaseDetails.offerDiscount}] TEXT,
                                                ${DatabaseDetails.stockStatus} TEXT,
                                                ${DatabaseDetails.stockQty} TEXT
   )
  ''');
  }
  /// Order List Table
  orderListTable() async {
    await db.execute(
        ''' CREATE TABLE if not exists ${DatabaseDetails.orderListTable} (
                                                ${DatabaseDetails.id} TEXT,
                                                ${DatabaseDetails.productCode} TEXT,
                                                ${DatabaseDetails.productName} TEXT,
                                                ${DatabaseDetails.quantity} TEXT,
                                                ${DatabaseDetails.rate} TEXT,
                                                ${DatabaseDetails.productDescription} TEXT,
                                                ${DatabaseDetails.total} TEXT,
                                                ${DatabaseDetails.images} TEXT
                                                ) ''');
  }


  /// Order Post Table
  orderPostTable() async {
    await db.execute(
        ''' CREATE TABLE if not exists ${DatabaseDetails.orderPostTable} (
                                                ${DatabaseDetails.dbName} TEXT,
                                                ${DatabaseDetails.glCode} TEXT,
                                                ${DatabaseDetails.userCode} TEXT,
                                                ${DatabaseDetails.pcode} TEXT,
                                                ${DatabaseDetails.rate} TEXT,
                                                ${DatabaseDetails.qty} TEXT,
                                                ${DatabaseDetails.totalAmt} TEXT,
                                                ${DatabaseDetails.comment} TEXT
                                                ) ''');
  }

  /// Ledger List Table
  ledgerListTable() async {
    await db.execute(
        ''' CREATE TABLE if not exists ${DatabaseDetails.ledgerListTable} (
                                                ${DatabaseDetails.glCode} TEXT,
                                                ${DatabaseDetails.glDesc} TEXT,
                                                ${DatabaseDetails.glCatagory} TEXT,
                                                ${DatabaseDetails.mobile} TEXT,
                                                ${DatabaseDetails.address} TEXT
                                                ) ''');
  }

  orderProductTableGroup() async {
    await db.execute(
        ''' CREATE TABLE if not exists ${DatabaseDetails.orderProductTableGroup} (  
                                                ${DatabaseDetails.glCode} TEXT,  
                                                ${DatabaseDetails.vNo} TEXT,  
                                                ${DatabaseDetails.salesman} TEXT,  
                                                ${DatabaseDetails.glDesc} TEXT ,
                                                ${DatabaseDetails.route} TEXT ,
                                                ${DatabaseDetails.telNoI} TEXT,
                                                ${DatabaseDetails.mobileNumberOrderReport} TEXT,  
                                                ${DatabaseDetails.creditLimite} TEXT,  
                                                ${DatabaseDetails.creditDay} TEXT,  
                                                ${DatabaseDetails.overdays} TEXT ,
                                                ${DatabaseDetails.overLimit} TEXT ,
                                                ${DatabaseDetails.currentBalance} TEXT ,
                                                ${DatabaseDetails.ageOfOrder} TEXT,  
                                                ${DatabaseDetails.qty} TEXT,  
                                                ${DatabaseDetails.vDate} TEXT,  
                                                ${DatabaseDetails.vTime} TEXT ,
                                                ${DatabaseDetails.netAmt} TEXT ,
                                                ${DatabaseDetails.remarks} TEXT ,
                                                ${DatabaseDetails.orderBy} TEXT,  
                                                ${DatabaseDetails.lat} TEXT,  
                                                ${DatabaseDetails.lng} TEXT,  
                                                ${DatabaseDetails.managerRemarks} TEXT ,
                                                ${DatabaseDetails.reconcileDate} TEXT ,
                                                ${DatabaseDetails.reconcileBy} TEXT,
                                                ${DatabaseDetails.entryModule} TEXT,
                                                ${DatabaseDetails.invType} TEXT,
                                                ${DatabaseDetails.invDate} TEXT
                                         )''');
  }

}



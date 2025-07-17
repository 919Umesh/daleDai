import '../../utils/custom_log.dart';
import 'sharepref.dart';

class SetAllPref {
  static baseURL({required String value}) async {
    await SharedPref.setData(
      key: PrefText.apiUrl,
      dValue: value,
      type: "String",
    );
  }

  static baseImageURL({required String value}) async {
    await SharedPref.setData(
      key: PrefText.apiImageUrl,
      dValue: value,
      type: "String",
    );
  }

  static imageURL({required String value}) async {
    CustomLog.warningLog(value: "\n\nIMAGE URL => $value");
    await SharedPref.setData(
      key: PrefText.imageURL,
      dValue: value,
      type: "String",
    );
  }

  static setUserName({required String value}) async {
    await SharedPref.setData(
      key: PrefText.userName,
      dValue: value,
      type: "String",
    );
  }
  static setPassword({required String value}) async {
    await SharedPref.setData(
      key: PrefText.setPassword,
      dValue: value,
      type: "String",
    );
  }

  static setOutLetCode({required String value}) async {
    await SharedPref.setData(
      key: PrefText.outLetCode,
      dValue: value,
      type: "String",
    );
  }
  static setOutLetDesc({required String value}) async {
    await SharedPref.setData(
      key: PrefText.outLetDesc,
      dValue: value,
      type: "String",
    );
  }

  static customerName({required String value}) async {
    await SharedPref.setData(
      key: PrefText.customerName,
      dValue: value,
      type: "String",
    );
  }
  static salePurchaseMap({required String value}) async {
    await SharedPref.setData(
      key: PrefText.salePurchaseMap,
      dValue: value,
      type: "String",
    );
  }

  static setUnitCode({required String value}) async {
    await SharedPref.setData(
      key: PrefText.unitCode,
      dValue: value,
      type: "String",
    );
  }
  static setVoucherNo({required String value}) async {
    await SharedPref.setData(
      key: PrefText.voucherNo,
      dValue: value,
      type: "String",
    );
  }
  static companyInital({required String value}) async {
    await SharedPref.setData(
      key: PrefText.companyInital,
      dValue: value,
      type: "String",
    );
  }

  static isLogin({required bool value}) async {
    await SharedPref.setData(
      key: PrefText.loginSuccess,
      dValue: value,
      type: "bool",
    );
  }

  static companySelected({required bool value}) async {
    await SharedPref.setData(
      key: PrefText.companySelected,
      dValue: value,
      type: "bool",
    );
  }

  static setCompanyDbName({required String value}) async {
    await SharedPref.setData(
      key: PrefText.companyDbNane,
      dValue: value,
      type: "String",
    );
  }
  static setCompanyName({required String value}) async {
    await SharedPref.setData(
      key: PrefText.companyName,
      dValue: value,
      type: "String",
    );
  }

  // static companyDetail({required CompanyDetailsModel value}) async {
  //   await SharedPref.setData(
  //     key: PrefText.companyDetail,
  //     dValue: jsonEncode(value),
  //     type: "String",
  //   );
  // }

  static deviceInfo({required String value}) async {
    await SharedPref.setData(
      key: PrefText.deviceInfo,
      dValue: value,
      type: "String",
    );
  }
  static setTimeCurrent({required String value}) async {
    await SharedPref.setData(
      key: PrefText.settimeCurrent,
      dValue: value,
      type: "String",
    );
  }

  static setStartDate({required String value}) async {
    await SharedPref.setData(
      key: PrefText.setStartDate,
      dValue: value,
      type: "String",
    );
  }
  static setEndDate({required String value}) async {
    await SharedPref.setData(
      key: PrefText.setEndDate,
      dValue: value,
      type: "String",
    );
  }
  static setQRData({required String value}) async {
    await SharedPref.setData(
      key: PrefText.qrData,
      dValue: value,
      type: "String",
    );
  }

  static setOrderReportGl({required String value}) async {
    await SharedPref.setData(
      key: PrefText.orderReportGl,
      dValue: value,
      type: "String",
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'custom_log.dart';

class MyDate {
  static getTodayDate() {
    return NepaliDateTime.now().format("dd MMMM, yyyy");
  }

  static formatDate(String date) {
    return date.toString().substring(0, 10);
  }

  static int nepaliDaysCount(
      {required String fromDate, required String toDate}) {
    NepaliDateTime from = NepaliDateTime.parse(fromDate.replaceAll("/", "-"));
    NepaliDateTime to = NepaliDateTime.parse(toDate.replaceAll("/", "-"));

    ///
    from = NepaliDateTime(from.year, from.month, from.day);
    to = NepaliDateTime(to.year, to.month, to.day);
    int result = (to.difference(from).inHours / 24).round();

    ///
    CustomLog.actionLog(
      value: "$result day(s) is difference from $from to $to ",
    );
    return result;
  }

  static getWeekName({required String weekId}) {
    String weekName = "";
    const map = {
      '1': "Sunday",
      '2': "Monday",
      '3': "Tuesday",
      '4': "Wednesday",
      '5': "Thursday",
      '6': "Friday",
      '7': "Saturday",
    };

    weekName = map[weekId] ?? "Not Found";
    return weekName;
  }
}

class DateConverter {
  static nepaliToEnglish(
      {required int year, required int month, required int day}) {
    DateTime englishDate = NepaliDateTime(year, month, day).toDateTime();
    debugPrint('In AD = $englishDate');
    return englishDate;
  }

  static englishToNepali(
      {required int year, required int month, required int day}) {
    NepaliDateTime nepaliDate = DateTime(year, month, day).toNepaliDateTime();
    debugPrint('In BS = $nepaliDate');
    return nepaliDate;
  }
}

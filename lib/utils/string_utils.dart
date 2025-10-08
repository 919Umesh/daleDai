class StringUtils {
  static String getAccountingPeriodText(String text) {
    return text.replaceAll('_', ' ').split(' ').map((e) => e.replaceFirst(e[0], e[0].toUpperCase())).join(' ');
  }

// static String getReportTypeByText(String text) {
//   return text
//       .replaceFirst(RegExp('^[^_]*_'), '')
//       .replaceAll('___', '-')
//       .replaceAll('__', ' ')
//       .split(' ')
//       .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
//       .join('/')
//       .replaceAll('_', ' ')
//       .split(' ')
//       .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
//       .join(' ');
// }
//
// static String getGroupByText(String text) {
//   return text
//       .replaceFirst(RegExp('^[^_]*_'), '')
//       .replaceAll('__', ' ')
//       .split(' ')
//       .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
//       .join('/')
//       .replaceAll('_', ' ')
//       .split(' ')
//       .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
//       .join(' ');
// }
}

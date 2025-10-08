extension StringCasingExtension on String {
  /// hello world => Hello world
  String toFirstLetterCapital() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// hello world => Hello World
  String toPascalCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toFirstLetterCapital())
      .join(' ');
}

class UnitConverter {
  RegExp ftSpaceFraction = RegExp(r'(\d+) ((\d+)/(\d+))');
  RegExp ftDashInchSpaceFraction = RegExp(r'(\d+)-(\d+) (\d+)/(\d+)');
  RegExp ftDashInch = RegExp(r'(\d+)-(\d+)');
  RegExp ftOnly = RegExp(r'(\d+)');
  RegExp fractionOnly = RegExp(r'(\d+)/(\d+)');
  RegExp decimal = RegExp(r'(\d+)\.(\d+)');

  String toInch(value) {
    double inches = 0.0;

    if (value != null) {
      if (ftSpaceFraction.firstMatch(value) != null && ftSpaceFraction.firstMatch(value)![0]?.length == value.length) {
        int inch = int.parse(ftSpaceFraction.allMatches(value).first.group(1) as String);
        int dividend = int.parse(ftSpaceFraction.allMatches(value).first.group(3) as String);
        int divider = int.parse(ftSpaceFraction.allMatches(value).first.group(4) as String);
        inches = inch + dividend / divider;
        return inches.toStringAsFixed(4);
      } else if (ftDashInchSpaceFraction.firstMatch(value) != null &&
          ftDashInchSpaceFraction.firstMatch(value)![0]?.length == value.length) {
        double ft = double.parse(ftDashInchSpaceFraction.allMatches(value).first.group(1) as String) * 12;

        int inch = int.parse(ftDashInchSpaceFraction.allMatches(value).first.group(2) as String);
        int dividend = int.parse(ftDashInchSpaceFraction.allMatches(value).first.group(3) as String);
        int divider = int.parse(ftDashInchSpaceFraction.allMatches(value).first.group(4) as String);
        inches = ft + inch + dividend / divider;
        return inches.toStringAsFixed(4);
      } else if (ftDashInch.firstMatch(value) != null && ftDashInch.firstMatch(value)![0]?.length == value.length) {
        inches = double.parse(ftDashInch.allMatches(value).first.group(1) as String) * 12 +
            double.parse(ftDashInch.allMatches(value).first.group(2) as String);
        return inches.toStringAsFixed(4);
      } else if (ftOnly.firstMatch(value) != null && ftOnly.firstMatch(value)![0]?.length == value.length) {
        inches = double.parse(value);
        return inches.toStringAsFixed(4);
      } else if (fractionOnly.firstMatch(value) != null && fractionOnly.firstMatch(value)![0]?.length == value.length) {
        inches = double.parse(fractionOnly.allMatches(value).first.group(1) as String) /
            double.parse(fractionOnly.allMatches(value).first.group(2) as String);
        return inches.toStringAsFixed(4);
      } else if (decimal.firstMatch(value) != null && decimal.firstMatch(value)![0]?.length == value.length) {
        inches = double.parse(value);
        return inches.toStringAsFixed(4);
      }
    }
    return value.toString();
  }
}

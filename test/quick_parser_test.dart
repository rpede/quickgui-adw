import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quickgui/infrastructure/quickget_parser.dart';

void main() {
  group("QuickGetParser", () {
    test('parseListCsv', () async {
      final process = await Process.start("cat", ["./test/list.csv"]);
      final actual = await QuickGetParser().parseListCsv(process).toList();
      expect(actual, hasLength(75));
    });
  });
}

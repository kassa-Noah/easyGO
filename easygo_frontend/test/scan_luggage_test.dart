import 'package:easygo_frontend/features/agency/luggage/scan_luggage_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reading the code a scanner reports.
///
/// The camera is the part that cannot be tested here — it needs a device. This
/// is the part that decides what the agency is actually looking up, and getting
/// it wrong means a bag that exists is reported as missing.
void main() {
  group('normalizeScannedCode', () {
    test('accepts the bare tracking number a label carries', () {
      expect(
        normalizeScannedCode('LUG-MUH3YJR1-EY01OL'),
        'LUG-MUH3YJR1-EY01OL',
      );
    });

    test('forgives the spacing and casing a scanner may report', () {
      // Decoders are not consistent about case, and a trailing newline is common.
      expect(
        normalizeScannedCode('  lug-muh3yjr1-ey01ol \n'),
        'LUG-MUH3YJR1-EY01OL',
      );
    });

    test('finds the number inside a link, so a richer code still works', () {
      expect(
        normalizeScannedCode('https://easygo.cm/track/LUG-MUH3YJR1-EY01OL'),
        'LUG-MUH3YJR1-EY01OL',
      );

      expect(normalizeScannedCode('https://easygo.cm/track/LUG-ABC?from=qr'), 'LUG-ABC');
    });

    test('returns nothing for nothing, so an empty read is never looked up', () {
      expect(normalizeScannedCode(''), '');
      expect(normalizeScannedCode('   '), '');
    });
  });
}

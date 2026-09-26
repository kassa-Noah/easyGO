import 'package:easygo_frontend/features/agency/models/agency_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConsoleBranch.fromJson', () {
    test('reads the coordinates the backend stores for a branch', () {
      final ConsoleBranch branch = ConsoleBranch.fromJson(<String, dynamic>{
        'id': 'b1',
        'name': 'Kribi Branch',
        'city': 'Kribi',
        'address': 'Boulevard Maritime',
        'latitude': 2.9391,
        'longitude': 9.9103,
        'phone': '690555111',
        'isActive': true,
      });

      expect(branch.latitude, closeTo(2.9391, 0.00001));
      expect(branch.longitude, closeTo(9.9103, 0.00001));
      expect(branch.phone, '690555111');
      expect(branch.isActive, isTrue);
    });

    test('leaves coordinates null when the record has none', () {
      // Editing must not present a missing coordinate as a real 0, 0.
      final ConsoleBranch branch = ConsoleBranch.fromJson(<String, dynamic>{
        'id': 'b1',
        'name': 'Branch',
        'city': 'City',
        'address': 'Address',
      });

      expect(branch.latitude, isNull);
      expect(branch.longitude, isNull);
      expect(branch.phone, isNull);
      expect(branch.isActive, isFalse);
    });

    test('accepts coordinates sent as strings', () {
      final ConsoleBranch branch = ConsoleBranch.fromJson(<String, dynamic>{
        'latitude': '4.0511',
        'longitude': '9.7679',
      });

      expect(branch.latitude, closeTo(4.0511, 0.00001));
      expect(branch.longitude, closeTo(9.7679, 0.00001));
    });

    test('keeps a negative coordinate', () {
      final ConsoleBranch branch = ConsoleBranch.fromJson(<String, dynamic>{
        'latitude': -33.9249,
        'longitude': 18.4241,
      });

      expect(branch.latitude, closeTo(-33.9249, 0.00001));
    });
  });
}

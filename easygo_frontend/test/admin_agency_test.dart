import 'package:easygo_frontend/features/admin/models/admin_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminAgency.fromJson', () {
    test('reads a newly created agency, which carries no relations', () {
      // POST /agencies answers with the bare record: no branches array and no
      // _count, so the console must not report counts it was not given.
      final AdminAgency agency = AdminAgency.fromJson(<String, dynamic>{
        'id': 'a1',
        'name': 'Littoral Express',
        'description': 'Coastal interurban transport.',
        'isActive': true,
        'createdAt': '2026-09-26T08:00:00.000Z',
      });

      expect(agency.id, 'a1');
      expect(agency.name, 'Littoral Express');
      expect(agency.isActive, isTrue);
      expect(agency.branchCount, 0);
      expect(agency.tripCount, 0);
      expect(agency.vehicleCount, 0);
      expect(agency.staffCount, 0);
      expect(agency.cityLabel, '—');
      expect(agency.statusLabel, 'Active');
    });

    test('reads the counts the admin list provides', () {
      final AdminAgency agency = AdminAgency.fromJson(<String, dynamic>{
        'id': 'a1',
        'name': 'Finexs Voyages',
        'isActive': true,
        'branches': <dynamic>[
          <String, dynamic>{'id': 'b1', 'city': 'Yaounde'},
          <String, dynamic>{'id': 'b2', 'city': 'Douala'},
          <String, dynamic>{'id': 'b3', 'city': 'Douala'},
        ],
        '_count': <String, dynamic>{
          'branches': 3,
          'trips': 2,
          'vehicles': 2,
          'staff': 1,
        },
      });

      expect(agency.branchCount, 3);
      expect(agency.tripCount, 2);
      expect(agency.vehicleCount, 2);
      expect(agency.staffCount, 1);
      // Cities are de-duplicated for the summary line.
      expect(agency.cityLabel, 'Yaounde, Douala');
    });

    test('reports a suspended agency as suspended', () {
      final AdminAgency agency = AdminAgency.fromJson(<String, dynamic>{
        'id': 'a1',
        'name': 'Paused Lines',
        'isActive': false,
      });

      expect(agency.statusLabel, 'Suspended');
    });

    test('never claims verification, which the platform cannot record', () {
      // The record has one active flag and no verification field, so the only
      // two states are Active and Suspended.
      final AdminAgency agency = AdminAgency.fromJson(<String, dynamic>{
        'id': 'a1',
        'name': 'Any Agency',
        'isActive': true,
      });

      expect(agency.statusLabel, isNot(contains('Verif')));
      expect(agency.statusLabel, isNot(contains('Pending')));
    });
  });
}

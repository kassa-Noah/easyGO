import 'package:easygo_frontend/features/admin/models/admin_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminRoute.fromJson', () {
    test('reads the route, its branches and the owning agency', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'id': 'r1',
        'originBranchId': 'b1',
        'destinationBranchId': 'b2',
        'baseFare': '3500',
        'distanceKm': 300,
        'estimatedDurationMinutes': 300,
        'isActive': true,
        'originBranch': <String, dynamic>{
          'id': 'b1',
          'name': 'Yaounde Main Branch',
          'city': 'Yaounde',
          'agency': <String, dynamic>{'name': 'Finexs Voyages'},
        },
        'destinationBranch': <String, dynamic>{
          'id': 'b2',
          'name': 'Kribi Branch',
          'city': 'Kribi',
          'agency': <String, dynamic>{'name': 'Finexs Voyages'},
        },
      });

      expect(route.label, 'Yaounde → Kribi');
      expect(route.agencyName, 'Finexs Voyages');
      expect(route.baseFare, 3500);
      expect(route.originBranchId, 'b1');
      expect(route.isActive, isTrue);
    });

    test('reads the fare when the API sends it as a string', () {
      // Prisma serialises Decimal columns as strings; the fare must not become
      // zero because of it.
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'baseFare': '5000',
      });

      expect(route.baseFare, 5000);
    });

    test('reports missing distance and duration as absent, not as zero', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'baseFare': 5000,
      });

      expect(route.distanceKm, isNull);
      expect(route.estimatedDurationMinutes, isNull);
      expect(route.distanceLabel, 'Distance not recorded');
      expect(route.durationLabel, 'Duration not recorded');
    });

    test('formats a duration in whole hours', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'estimatedDurationMinutes': 240,
      });

      expect(route.durationLabel, '4 h');
    });

    test('formats a duration that is not a whole number of hours', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'estimatedDurationMinutes': 190,
      });

      expect(route.durationLabel, '3 h 10 min');
    });

    test('formats a duration under an hour', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'estimatedDurationMinutes': 45,
      });

      expect(route.durationLabel, '45 min');
    });

    test('does not show a whole distance with a decimal point', () {
      final AdminRoute whole = AdminRoute.fromJson(<String, dynamic>{
        'distanceKm': 250.0,
      });

      expect(whole.distanceLabel, '250 km');
    });

    test('keeps a fractional distance', () {
      final AdminRoute fractional = AdminRoute.fromJson(<String, dynamic>{
        'distanceKm': 12.5,
      });

      expect(fractional.distanceLabel, '12.5 km');
    });

    test('reads a retired route as inactive', () {
      final AdminRoute route = AdminRoute.fromJson(<String, dynamic>{
        'isActive': false,
      });

      expect(route.isActive, isFalse);
    });
  });

  group('AdminBranch.fromAgencyJson', () {
    test('carries the agency down onto the branch', () {
      final AdminBranch? branch = AdminBranch.fromAgencyJson(
        <String, dynamic>{'id': 'a1', 'name': 'Finexs Voyages'},
        <String, dynamic>{
          'id': 'b1',
          'name': 'Kribi Branch',
          'city': 'Kribi',
        },
      );

      expect(branch, isNotNull);
      expect(branch!.agencyId, 'a1');
      expect(branch.agencyName, 'Finexs Voyages');
      expect(branch.label, 'Finexs Voyages — Kribi Branch (Kribi)');
    });

    test('skips a branch with no id, which could not be selected', () {
      final AdminBranch? branch = AdminBranch.fromAgencyJson(
        <String, dynamic>{'id': 'a1', 'name': 'Finexs Voyages'},
        <String, dynamic>{'name': 'No identifier'},
      );

      expect(branch, isNull);
    });
  });
}

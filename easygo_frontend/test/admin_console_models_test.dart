import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/admin/models/admin_console.dart';

/// Captured from the running API (`GET /api/admin/statistics` and
/// `/api/admin/dashboard`) so the administrator models are verified against
/// real backend data rather than a hand-written guess.

const Map<String, dynamic> realStatistics = <String, dynamic>{
  'users': <String, dynamic>{
    'total': 6,
    'active': 6,
    'customers': 4,
    'agencyStaff': 1,
  },
  'agencies': <String, dynamic>{'total': 2, 'active': 2},
  'trips': <String, dynamic>{'total': 2, 'scheduled': 2, 'arrived': 0},
  'bookings': <String, dynamic>{
    'total': 15,
    'pending': 4,
    'confirmed': 5,
    'completed': 1,
    'cancelled': 5,
  },
  'payments': <String, dynamic>{
    'total': 9,
    'successful': 7,
    'pending': 0,
    'failed': 2,
    'totalSuccessfulAmount': '35000',
  },
  'tickets': <String, dynamic>{'total': 5},
  'luggage': <String, dynamic>{'total': 3, 'delivered': 0, 'lost': 0},
  'parcels': <String, dynamic>{
    'total': 3,
    'delivered': 0,
    'collected': 0,
    'lost': 0,
  },
  'journeys': <String, dynamic>{'total': 4, 'completed': 0},
  'reviews': <String, dynamic>{'total': 0},
};

const Map<String, dynamic> realAgency = <String, dynamic>{
  'id': '912184dc-5b52-4a80-b6bd-177fd01d56ea',
  'name': 'Finexs Voyages',
  'description': 'Finexs Voyages interurban transport services.',
  'phone': '690111222',
  'email': 'contact@finexs.com',
  'logoUrl': null,
  'website': null,
  'isActive': true,
  'createdAt': '2026-09-11T13:11:45.842Z',
  'branches': <dynamic>[
    <String, dynamic>{'id': 'b1', 'name': 'Douala Main Branch', 'city': 'Douala'},
    <String, dynamic>{'id': 'b2', 'name': 'Yaounde Main Branch', 'city': 'Yaounde'},
  ],
};

const Map<String, dynamic> realAccount = <String, dynamic>{
  'id': 'b8812311-f329-4d69-8e80-7ded16d9bcef',
  'firstName': 'Audit',
  'lastName': 'User',
  'email': 'audit.user@easygo.cm',
  'phone': '699888777',
  'role': 'CUSTOMER',
  'isActive': true,
  'createdAt': '2026-09-25T15:20:54.175Z',
};

void main() {
  group('AdminStatistics', () {
    test('maps the real statistics payload', () {
      final AdminStatistics s = AdminStatistics.fromJson(realStatistics);

      expect(s.usersTotal, 6);
      expect(s.usersActive, 6);
      expect(s.usersCustomers, 4);
      expect(s.usersAgencyStaff, 1);
      expect(s.agenciesTotal, 2);
      expect(s.agenciesActive, 2);
      expect(s.tripsScheduled, 2);
      expect(s.bookingsTotal, 15);
      expect(s.bookingsCancelled, 5);
      // The API serialises the settlement total as a decimal string.
      expect(s.paymentsSuccessfulAmount, 35000);
      expect(s.parcelsTotal, 3);
      expect(s.reviewsTotal, 0);
    });

    test('the booking counters add up to the total', () {
      final AdminStatistics s = AdminStatistics.fromJson(realStatistics);

      expect(
        s.bookingsPending +
            s.bookingsConfirmed +
            s.bookingsCompleted +
            s.bookingsCancelled,
        s.bookingsTotal,
      );
    });

    test('derives the suspended agency count instead of inventing a state', () {
      final AdminStatistics s = AdminStatistics.fromJson(realStatistics);

      expect(s.agenciesInactive, 0);
    });

    test('treats a missing block as zero rather than throwing', () {
      final AdminStatistics s = AdminStatistics.fromJson(<String, dynamic>{});

      expect(s.usersTotal, 0);
      expect(s.bookingsTotal, 0);
      expect(s.paymentsSuccessfulAmount, 0);
    });
  });

  group('AdminDashboard', () {
    test('reads the counters and the newest accounts', () {
      final AdminDashboard dashboard = AdminDashboard.fromJson(<String, dynamic>{
        'statistics': realStatistics,
        'recentActivity': <String, dynamic>{
          'users': <dynamic>[
            realAccount,
            <String, dynamic>{
              ...realAccount,
              'id': 'newer',
              'email': 'newer@easygo.cm',
              'createdAt': '2026-09-26T09:00:00.000Z',
            },
          ],
        },
      });

      expect(dashboard.statistics.bookingsTotal, 15);
      expect(dashboard.recentUsers, hasLength(2));

      // The newest account has to come first: the screen shows this list as it
      // arrives.
      expect(dashboard.newestAccounts.first.email, 'newer@easygo.cm');
    });

    test('survives a dashboard with no recent activity', () {
      final AdminDashboard dashboard = AdminDashboard.fromJson(<String, dynamic>{
        'statistics': realStatistics,
      });

      expect(dashboard.recentUsers, isEmpty);
      expect(dashboard.statistics.usersTotal, 6);
    });
  });

  group('AdminAgency', () {
    test('collects the branch cities it will display', () {
      final AdminAgency agency = AdminAgency.fromJson(realAgency);

      expect(agency.name, 'Finexs Voyages');
      expect(agency.branchCount, 2);
      expect(agency.branchCities, <String>['Douala', 'Yaounde']);
      expect(agency.cityLabel, 'Douala, Yaounde');
      expect(agency.statusLabel, 'Active');
    });

    test('reports an inactive agency as suspended', () {
      final AdminAgency agency = AdminAgency.fromJson(<String, dynamic>{
        ...realAgency,
        'isActive': false,
        'branches': <dynamic>[],
      });

      expect(agency.statusLabel, 'Suspended');
      expect(agency.cityLabel, '—');
    });
  });

  group('AdminAccount', () {
    test('maps the real account payload', () {
      final AdminAccount account = AdminAccount.fromJson(realAccount);

      expect(account.fullName, 'Audit User');
      expect(account.email, 'audit.user@easygo.cm');
      expect(account.role, 'CUSTOMER');
      expect(account.statusLabel, 'Active');
      expect(account.createdAt, isNotNull);
    });

    test('reports a disabled account as suspended', () {
      final AdminAccount account = AdminAccount.fromJson(<String, dynamic>{
        ...realAccount,
        'isActive': false,
        'phone': null,
      });

      expect(account.statusLabel, 'Suspended');
      expect(account.phone, isNull);
    });
  });

  group('admin formatting', () {
    test('groups counts with thousands separators', () {
      expect(formatAdminCount(0), '0');
      expect(formatAdminCount(57), '57');
      expect(formatAdminCount(1248), '1,248');
      expect(formatAdminCount(1234567), '1,234,567');
    });

    test('formats dates and amounts the way the console shows them', () {
      final DateTime moment = DateTime(2026, 6, 12, 9, 5);

      expect(formatAdminDate(moment), '12/06/2026');
      expect(formatAdminDateTime(moment), '12/06/2026 • 09:05');
      expect(formatAdminAmount(35000), '35,000 FCFA');
    });
  });
}

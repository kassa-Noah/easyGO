import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/bookings/models/verified_ticket.dart';

/// The agency verification screen reads a ticket through this model.
///
/// The payload nests the passenger and the trip under the booking, and the
/// route cities under the branches, so a wrong path here would leave the screen
/// showing dashes for a ticket the backend considers perfectly valid. The
/// fixture below is the shape the verification endpoint actually returns.

Map<String, dynamic> _payload({
  String status = 'ACTIVE',
  String? usedAt,
  Map<String, dynamic>? user = const <String, dynamic>{
    'id': 'user-1',
    'firstName': 'Claire',
    'lastName': 'Client',
    'email': 'customer@easygo.com',
    'phone': '690000003',
  },
}) {
  return <String, dynamic>{
    'id': 'ticket-1',
    'ticketNumber': 'TKT-MUHHUC0I-XD7O6P',
    'qrCodeData': '{"type":"EASYGO_DIGITAL_TICKET"}',
    'status': status,
    'issuedAt': '2026-09-25T20:05:00.000Z',
    'usedAt': usedAt,
    'bookingId': 'booking-1',
    'booking': <String, dynamic>{
      'id': 'booking-1',
      'bookingReference': 'EG-MUHHTYRB-AKLKLR',
      'status': 'CONFIRMED',
      'user': user,
      'trip': <String, dynamic>{
        'id': 'trip-1',
        'departureTime': '2026-10-10T08:00:00.000Z',
        'agency': <String, dynamic>{'id': 'agency-1', 'name': 'Finexs Voyages'},
        'route': <String, dynamic>{
          'id': 'route-1',
          'originBranch': <String, dynamic>{
            'id': 'branch-1',
            'city': 'Yaounde',
            'name': 'Yaounde Main Branch',
          },
          'destinationBranch': <String, dynamic>{
            'id': 'branch-2',
            'city': 'Douala',
            'name': 'Douala Main Branch',
          },
        },
        'vehicle': <String, dynamic>{
          'id': 'vehicle-1',
          'brand': 'Toyota',
          'model': 'Coaster',
          'registrationNumber': 'LT-001-EG',
        },
      },
    },
  };
}

void main() {
  group('VerifiedTicket.fromJson', () {
    test('names the passenger from the booking', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(_payload());

      expect(ticket.passengerName, 'Claire Client');
      expect(ticket.passengerPhone, '690000003');
    });

    test('reads the route from the branches, not the route itself', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(_payload());

      expect(ticket.originCity, 'Yaounde');
      expect(ticket.destinationCity, 'Douala');
    });

    test('builds the vehicle description from brand, model and plate', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(_payload());

      expect(ticket.vehicleDescription, 'Toyota Coaster • LT-001-EG');
    });

    test('carries the booking reference and the agency name', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(_payload());

      expect(ticket.bookingReference, 'EG-MUHHTYRB-AKLKLR');
      expect(ticket.agencyName, 'Finexs Voyages');
    });

    test('treats an ACTIVE ticket as usable at the gate', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(_payload());

      expect(ticket.isUsable, isTrue);
      expect(ticket.isUsed, isFalse);
      expect(ticket.statusLabel, 'Valid');
    });

    test('reports a ticket that was already taken', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(
        _payload(status: 'USED', usedAt: '2026-10-10T07:50:00.000Z'),
      );

      expect(ticket.isUsable, isFalse);
      expect(ticket.isUsed, isTrue);
      expect(ticket.statusLabel, 'Already used');
      expect(ticket.usedAt, isNotNull);
    });

    test('falls back to the branch name when the branch has no city', () {
      final Map<String, dynamic> payload = _payload();
      final Map<String, dynamic> trip =
          (payload['booking'] as Map<String, dynamic>)['trip']
              as Map<String, dynamic>;
      final Map<String, dynamic> route = trip['route'] as Map<String, dynamic>;
      (route['originBranch'] as Map<String, dynamic>).remove('city');

      final VerifiedTicket ticket = VerifiedTicket.fromJson(payload);

      expect(ticket.originCity, 'Yaounde Main Branch');
    });

    test('survives a payload with no passenger at all', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(
        _payload(user: null),
      );

      expect(ticket.passengerName, '');
      expect(ticket.passengerPhone, isNull);
      expect(ticket.ticketNumber, 'TKT-MUHHUC0I-XD7O6P');
    });

    test('reports an unrecognised status verbatim rather than as valid', () {
      final VerifiedTicket ticket = VerifiedTicket.fromJson(
        _payload(status: 'REVOKED'),
      );

      expect(ticket.isUsable, isFalse);
      expect(ticket.statusLabel, 'REVOKED');
    });
  });
}

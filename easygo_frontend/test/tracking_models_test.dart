import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/tracking/models/tracking.dart';

/// These payloads were captured from the running easyGO API
/// (`GET /api/parcels/track/:trackingNumber` and
/// `GET /api/luggage/track/:trackingNumber`) so that the models
/// are verified against real backend data rather than assumptions.
const Map<String, dynamic> realParcelPayload = <String, dynamic>{
  'id': '5387db52-6b15-4f00-bd5e-011a6c6ef86b',
  'trackingNumber': 'PAR-MUGZCQ60-VJQLU0',
  'description': 'Clothes in a medium box',
  'weightKg': 8.5,
  'recipientName': 'Mary Example',
  'recipientPhone': '699123456',
  'status': 'REGISTERED',
  'progressPercentage': 0,
  'shipmentPrice': null,
  'senderId': '524a3d07-1657-420e-80f5-2510892c412d',
  'recipientUserId': null,
  'originBranchId': 'b143047d-6d8b-49de-bcf9-7e0b80920bdf',
  'destinationBranchId': 'f5a7727e-1de0-4dfb-bbfd-531ac3662732',
  'tripId': null,
  'createdAt': '2026-09-25T13:11:59.353Z',
  'updatedAt': '2026-09-25T13:11:59.353Z',
  'sender': <String, dynamic>{
    'id': '524a3d07-1657-420e-80f5-2510892c412d',
    'firstName': 'E2E',
    'lastName': 'Tester',
  },
  'recipientUser': null,
  'originBranch': <String, dynamic>{
    'id': 'b143047d-6d8b-49de-bcf9-7e0b80920bdf',
    'name': 'Yaounde Main Branch',
    'city': 'Yaounde',
    'address': 'Mvog-Mbi, Yaounde',
    'agency': <String, dynamic>{'id': 'a1', 'name': 'Finexs Voyages'},
  },
  'destinationBranch': <String, dynamic>{
    'id': 'f5a7727e-1de0-4dfb-bbfd-531ac3662732',
    'name': 'Douala Main Branch',
    'city': 'Douala',
    'address': 'Akwa, Douala',
    'agency': <String, dynamic>{'id': 'a1', 'name': 'Finexs Voyages'},
  },
  'trip': null,
  'trackingEvents': <dynamic>[
    <String, dynamic>{
      'id': 'd9b488e3-f8eb-4bcf-9b55-240eb91cc376',
      'status': 'REGISTERED',
      'progressPercentage': 0,
      'location': null,
      'description': 'Parcel registered',
      'parcelId': '5387db52-6b15-4f00-bd5e-011a6c6ef86b',
      'updatedById': '524a3d07-1657-420e-80f5-2510892c412d',
      'createdAt': '2026-09-25T13:11:59.456Z',
    },
  ],
};

const Map<String, dynamic> realLuggagePayload = <String, dynamic>{
  'id': '0c7bbac9-bdd5-47e8-a757-f9e0e6a270b3',
  'trackingNumber': 'LUG-MUGZCQ0H-20LB45',
  'description': 'Large black suitcase',
  'weightKg': 18.5,
  'status': 'REGISTERED',
  'progressPercentage': 0,
  'bookingId': '4ca35f9c-cb84-4545-8db0-22911ec1594f',
  'createdAt': '2026-09-25T13:11:59.162Z',
  'updatedAt': '2026-09-25T13:11:59.162Z',
  'booking': <String, dynamic>{
    'id': '4ca35f9c-cb84-4545-8db0-22911ec1594f',
    'bookingReference': 'EG-MUGWZJ17-Z3SM2N',
    'status': 'CONFIRMED',
    'trip': <String, dynamic>{
      'id': '7df477ba-ea73-4e41-887d-851c58a1874d',
      'departureTime': '2026-10-10T07:00:00Z',
      'agency': <String, dynamic>{'id': 'a1', 'name': 'Finexs Voyages'},
      'route': <String, dynamic>{
        'id': 'af0f9f5e-cf2b-4463-9865-9232b61e5431',
        'originBranch': <String, dynamic>{
          'id': 'b1',
          'city': 'Yaounde',
          'name': 'Yaounde Main Branch',
        },
        'destinationBranch': <String, dynamic>{
          'id': 'b2',
          'city': 'Douala',
          'name': 'Douala Main Branch',
        },
      },
    },
  },
  'trackingEvents': <dynamic>[
    <String, dynamic>{
      'id': 'e1',
      'status': 'REGISTERED',
      'progressPercentage': 0,
      'location': null,
      'description': 'Luggage registered',
      'luggageId': '0c7bbac9-bdd5-47e8-a757-f9e0e6a270b3',
      'updatedById': '524a3d07-1657-420e-80f5-2510892c412d',
      'createdAt': '2026-09-25T13:11:59.456Z',
    },
  ],
};

void main() {
  group('Parcel.fromJson', () {
    test('maps the real tracking payload', () {
      final Parcel parcel = Parcel.fromJson(realParcelPayload);

      expect(parcel.trackingNumber, 'PAR-MUGZCQ60-VJQLU0');
      expect(parcel.description, 'Clothes in a medium box');
      expect(parcel.weightKg, 8.5);
      expect(parcel.recipientName, 'Mary Example');
      expect(parcel.recipientPhone, '699123456');
      expect(parcel.status, 'REGISTERED');
      expect(parcel.progressPercentage, 0);
      expect(parcel.senderName, 'E2E Tester');
      expect(parcel.originCity, 'Yaounde');
      expect(parcel.destinationCity, 'Douala');
      expect(parcel.originAgencyName, 'Finexs Voyages');
      expect(parcel.routeLabel, 'Yaounde → Douala');
      expect(parcel.trackingEvents, hasLength(1));
      expect(parcel.trackingEvents.first.statusLabel, 'Registered');
    });

    test('tolerates the nullable fields the backend returns', () {
      final Parcel parcel = Parcel.fromJson(realParcelPayload);

      expect(parcel.tripId, isNull);
      expect(parcel.recipientUserId, isNull);
      expect(parcel.shipmentPrice, isNull);
      expect(parcel.departureTime, isNull);
      expect(parcel.isDelivered, isFalse);
      expect(parcel.isCancelled, isFalse);
    });

    test('reports a missing route instead of guessing cities', () {
      final Parcel parcel = Parcel.fromJson(<String, dynamic>{
        'trackingNumber': 'PAR-1',
        'description': 'Box',
        'recipientName': 'R',
        'recipientPhone': '6',
        'status': 'IN_TRANSIT',
        'progressPercentage': 45,
      });

      expect(parcel.originCity, isNull);
      expect(parcel.destinationCity, isNull);
      expect(parcel.routeLabel, 'Route unavailable');
      expect(parcel.trackingEvents, isEmpty);
    });
  });

  group('Luggage.fromJson', () {
    test('maps the real tracking payload including nested booking', () {
      final Luggage luggage = Luggage.fromJson(realLuggagePayload);

      expect(luggage.trackingNumber, 'LUG-MUGZCQ0H-20LB45');
      expect(luggage.description, 'Large black suitcase');
      expect(luggage.weightKg, 18.5);
      expect(luggage.status, 'REGISTERED');
      expect(luggage.bookingReference, 'EG-MUGWZJ17-Z3SM2N');
      expect(luggage.agencyName, 'Finexs Voyages');
      expect(luggage.originCity, 'Yaounde');
      expect(luggage.destinationCity, 'Douala');
      expect(luggage.departureTime, isNotNull);
      expect(luggage.routeLabel, 'Yaounde → Douala');
      expect(luggage.trackingEvents, hasLength(1));
    });

    test('handles luggage without a nested booking', () {
      final Luggage luggage = Luggage.fromJson(<String, dynamic>{
        'trackingNumber': 'LUG-1',
        'status': 'IN_TRANSIT',
        'progressPercentage': 60,
      });

      expect(luggage.bookingReference, isNull);
      expect(luggage.agencyName, isNull);
      expect(luggage.routeLabel, 'Route unavailable');
      expect(luggage.trackingEvents, isEmpty);
    });
  });

  group('status helpers', () {
    test('formatTrackingStatus title-cases backend values', () {
      expect(formatTrackingStatus('IN_TRANSIT'), 'In Transit');
      expect(formatTrackingStatus('READY_FOR_COLLECTION'), 'Ready For Collection');
      expect(formatTrackingStatus('RECEIVED_AT_ORIGIN_AGENCY'), 'Received At Origin Agency');
      expect(formatTrackingStatus('REGISTERED'), 'Registered');
      expect(formatTrackingStatus(''), '');
    });

    test('terminal parcel states are recognised', () {
      expect(
        Parcel.fromJson(<String, dynamic>{'status': 'DELIVERED'}).isDelivered,
        isTrue,
      );
      expect(
        Parcel.fromJson(<String, dynamic>{'status': 'COLLECTED'}).isDelivered,
        isTrue,
      );
      expect(
        Parcel.fromJson(<String, dynamic>{'status': 'CANCELLED'}).isCancelled,
        isTrue,
      );
      expect(
        Luggage.fromJson(<String, dynamic>{'status': 'LOST'}).isLost,
        isTrue,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/agency/models/agency_console.dart';

/// The agency, trip and booking payloads below were captured from the
/// running easyGO API (`GET /api/staff/agency`, `/staff/trips` and
/// `/staff/bookings`) so the console models are verified against real
/// backend data. The `payments` and `ticket` sub-objects follow the
/// documented response shape for a confirmed booking.

const Map<String, dynamic> realAgencyResponse = <String, dynamic>{
  'staffRole': 'MANAGER',
  'agency': <String, dynamic>{
    'id': '912184dc-5b52-4a80-b6bd-177fd01d56ea',
    'name': 'Finexs Voyages',
    'description': 'Finexs Voyages interurban transport services.',
    'phone': '690111222',
    'email': 'contact@finexs.com',
    'logoUrl': null,
    'website': null,
    'isActive': true,
    'branches': <dynamic>[
      <String, dynamic>{
        'id': 'f5a7727e-1de0-4dfb-bbfd-531ac3662732',
        'name': 'Douala Main Branch',
        'city': 'Douala',
        'address': 'Akwa, Douala',
        'phone': '690111224',
        'isActive': true,
        'agencyId': '912184dc-5b52-4a80-b6bd-177fd01d56ea',
      },
      <String, dynamic>{
        'id': 'b143047d-6d8b-49de-bcf9-7e0b80920bdf',
        'name': 'Yaounde Main Branch',
        'city': 'Yaounde',
        'address': 'Mvog-Mbi, Yaounde',
        'phone': '690111223',
        'isActive': true,
        'agencyId': '912184dc-5b52-4a80-b6bd-177fd01d56ea',
      },
    ],
  },
};

const Map<String, dynamic> realTrip = <String, dynamic>{
  'id': '7df477ba-ea73-4e41-887d-851c58a1874d',
  'departureTime': '2026-10-10T07:00:00Z',
  'arrivalTime': '2026-10-10T11:00:00Z',
  'price': '5000',
  'totalSeats': 30,
  'availableSeats': 22,
  'status': 'SCHEDULED',
  'route': <String, dynamic>{
    'originBranch': <String, dynamic>{
      'id': 'b143047d-6d8b-49de-bcf9-7e0b80920bdf',
      'name': 'Yaounde Main Branch',
      'city': 'Yaounde',
      'address': 'Mvog-Mbi, Yaounde',
    },
    'destinationBranch': <String, dynamic>{
      'id': 'f5a7727e-1de0-4dfb-bbfd-531ac3662732',
      'name': 'Douala Main Branch',
      'city': 'Douala',
      'address': 'Akwa, Douala',
    },
  },
  'vehicle': <String, dynamic>{
    'id': 'b0f17ecc-335a-434f-a849-6ade7c56ff08',
    'registrationNumber': 'LT-001-EG',
    'model': 'Coaster',
    'brand': 'Toyota',
    'capacity': 30,
  },
  '_count': <String, dynamic>{'bookings': 10, 'parcels': 1},
};

const Map<String, dynamic> realBooking = <String, dynamic>{
  'id': 'c90f7282-2d5f-4917-ae51-8b708814a5e8',
  'bookingReference': 'EG-MUH670F0-V42W9B',
  'numberOfSeats': 1,
  'tripAmount': '5000',
  'taxiPickupAmount': '0',
  'taxiDropoffAmount': '0',
  'totalAmount': '5000',
  'status': 'CONFIRMED',
  'user': <String, dynamic>{
    'id': 'f7ece475-64ab-4e26-b504-f9b8aaea7748',
    'firstName': 'Claire',
    'lastName': 'Client',
    'email': 'customer@easygo.com',
    'phone': '690000003',
  },
  'trip': <String, dynamic>{
    'id': '7df477ba-ea73-4e41-887d-851c58a1874d',
    'departureTime': '2026-10-10T07:00:00Z',
    'route': <String, dynamic>{
      'originBranch': <String, dynamic>{'city': 'Yaounde'},
      'destinationBranch': <String, dynamic>{'city': 'Douala'},
    },
  },
  'payments': <dynamic>[
    <String, dynamic>{'id': 'p1', 'status': 'PENDING'},
    <String, dynamic>{
      'id': 'p2',
      'status': 'SUCCESSFUL',
      'transactionReference': 'PAY-MUH3YJF1-KK14HH',
    },
  ],
  'ticket': <String, dynamic>{
    'id': 't1',
    'ticketNumber': 'TKT-MUH3YJJP-MYZ3RF',
    'status': 'ACTIVE',
  },
  'journey': <String, dynamic>{'id': 'j1', 'status': 'PICKUP_ASSIGNED'},
};

void main() {
  group('StaffAgencyProfile', () {
    test('maps the real agency payload', () {
      final StaffAgencyProfile profile = StaffAgencyProfile.fromJson(
        realAgencyResponse,
      );

      expect(profile.staffRole, 'MANAGER');
      expect(profile.name, 'Finexs Voyages');
      expect(profile.email, 'contact@finexs.com');
      expect(profile.isActive, isTrue);
      expect(profile.branches, hasLength(2));
      expect(profile.cities, <String>['Douala', 'Yaounde']);
      expect(profile.branches.first.name, 'Douala Main Branch');
    });
  });

  group('ConsoleTrip', () {
    test('maps the real trip payload', () {
      final ConsoleTrip trip = ConsoleTrip.fromJson(realTrip);

      expect(trip.routeLabel, 'Yaounde → Douala');
      expect(trip.totalSeats, 30);
      expect(trip.availableSeats, 22);
      expect(trip.bookedSeats, 8);
      expect(trip.price, 5000);
      expect(trip.statusLabel, 'Scheduled');
      expect(trip.vehicleDescription, 'Toyota Coaster');
      expect(trip.vehicleRegistration, 'LT-001-EG');
      expect(trip.bookingCount, 10);
      expect(trip.parcelCount, 1);
    });

    test('never reports negative booked seats', () {
      final ConsoleTrip trip = ConsoleTrip.fromJson(<String, dynamic>{
        'totalSeats': 30,
        'availableSeats': 40,
        'status': 'SCHEDULED',
      });

      expect(trip.bookedSeats, 0);
    });
  });

  group('ConsoleBooking', () {
    test('maps the real booking payload including the passenger', () {
      final ConsoleBooking booking = ConsoleBooking.fromJson(realBooking);

      expect(booking.bookingReference, 'EG-MUH670F0-V42W9B');
      expect(booking.passengerName, 'Claire Client');
      expect(booking.passengerPhone, '690000003');
      expect(booking.routeLabel, 'Yaounde → Douala');
      expect(booking.totalAmount, 5000);
      expect(booking.numberOfSeats, 1);
      expect(booking.statusLabel, 'Confirmed');
      expect(booking.hasJourney, isTrue);
    });

    test('reads the latest payment and the issued ticket', () {
      final ConsoleBooking booking = ConsoleBooking.fromJson(realBooking);

      expect(booking.paymentStatus, 'SUCCESSFUL');
      expect(booking.ticketNumber, 'TKT-MUH3YJJP-MYZ3RF');
    });

    test('tolerates a booking with no passenger, payment or ticket', () {
      final ConsoleBooking booking = ConsoleBooking.fromJson(<String, dynamic>{
        'bookingReference': 'EG-1',
        'status': 'PENDING',
      });

      expect(booking.passengerName, '');
      expect(booking.paymentStatus, isNull);
      expect(booking.ticketNumber, isNull);
      expect(booking.hasJourney, isFalse);
      expect(booking.routeLabel, ' → ');
    });
  });

  group('ConsoleLuggage', () {
    test('maps the passenger from the nested booking', () {
      final ConsoleLuggage luggage = ConsoleLuggage.fromJson(
        <String, dynamic>{
          'id': 'l1',
          'trackingNumber': 'LUG-MUH3YJR1-EY01OL',
          'description': 'Audit suitcase',
          'weightKg': 12.5,
          'status': 'RECEIVED_AT_AGENCY',
          'progressPercentage': 15,
          'booking': <String, dynamic>{
            'bookingReference': 'EG-MUH670F0-V42W9B',
            'tripId': 't1',
            'user': <String, dynamic>{
              'firstName': 'Claire',
              'lastName': 'Client',
              'phone': '+237690000001',
            },
            'ticket': <String, dynamic>{'ticketNumber': 'TKT-0001'},
            'trip': <String, dynamic>{
              'departureTime': '2026-10-10T06:00:00.000Z',
              'route': <String, dynamic>{
                'originBranch': <String, dynamic>{'city': 'Yaounde'},
                'destinationBranch': <String, dynamic>{'city': 'Douala'},
              },
            },
          },
          'trackingEvents': <dynamic>[
            <String, dynamic>{
              'id': 'e1',
              'status': 'RECEIVED_AT_AGENCY',
              'progressPercentage': 15,
              'location': 'Yaounde Main Branch',
              'description': 'Received by the agency',
              'createdAt': '2026-09-25T16:30:00.000Z',
            },
          ],
        },
      );

      expect(luggage.trackingNumber, 'LUG-MUH3YJR1-EY01OL');
      expect(luggage.passengerName, 'Claire Client');
      expect(luggage.passengerPhone, '+237690000001');
      expect(luggage.bookingReference, 'EG-MUH670F0-V42W9B');
      expect(luggage.ticketNumber, 'TKT-0001');
      expect(luggage.tripId, 't1');
      expect(luggage.departureTime, isNotNull);
      expect(luggage.routeLabel, 'Yaounde → Douala');
      expect(luggage.weightKg, 12.5);
      expect(luggage.statusLabel, 'Received by Agency');
      expect(luggage.trackingEvents, hasLength(1));
      expect(luggage.trackingEvents.first.location, 'Yaounde Main Branch');
    });
  });

  group('tracking lifecycle', () {
    test('maps the agency wording onto the stored luggage enums', () {
      expect(luggageStatusToApi('Registered'), 'REGISTERED');
      expect(luggageStatusToApi('Received by Agency'), 'RECEIVED_AT_AGENCY');
      expect(luggageStatusToApi('Arrived'), 'ARRIVED_AT_DESTINATION_AGENCY');
      expect(luggageStatusToApi('Ready for Collection'), 'READY_FOR_COLLECTION');
      expect(luggageStatusToApi('Delivered'), 'DELIVERED');
    });

    test('maps the stored luggage enums back onto the agency wording', () {
      expect(luggageStatusLabel('RECEIVED_AT_AGENCY'), 'Received by Agency');
      expect(
        luggageStatusLabel('ARRIVED_AT_DESTINATION_AGENCY'),
        'Arrived',
      );
      expect(luggageStatusLabel('DELIVERED'), 'Delivered');
    });

    test('parcels reuse the wording with their own origin enum', () {
      expect(parcelStatusToApi('Received by Agency'), 'RECEIVED_AT_ORIGIN_AGENCY');
      expect(parcelStatusLabel('RECEIVED_AT_ORIGIN_AGENCY'), 'Received by Agency');
      expect(parcelStatusLabel('COLLECTED'), 'Collected');
    });

    test('advances one stage at a time and stops at the end', () {
      expect(nextLuggageStatus('Registered'), 'Received by Agency');
      expect(nextLuggageStatus('Loaded'), 'In Transit');
      expect(nextLuggageStatus('Delivered'), isNull);
      expect(nextLuggageStatus('Lost'), isNull);
      expect(nextParcelStatus('Ready for Collection'), 'Delivered');
      expect(nextParcelStatus('Delivered'), isNull);
    });
  });

  group('ConsoleParcel', () {
    test('maps the sender, recipient and route', () {
      final ConsoleParcel parcel = ConsoleParcel.fromJson(<String, dynamic>{
        'id': 'p1',
        'trackingNumber': 'PAR-MUH3YJVA-YRDPTS',
        'description': 'Audit parcel',
        'weightKg': 8.5,
        'recipientName': 'Mary Example',
        'recipientPhone': '699123456',
        'status': 'IN_TRANSIT',
        'progressPercentage': 45,
        'sender': <String, dynamic>{
          'firstName': 'Claire',
          'lastName': 'Client',
        },
        'originBranch': <String, dynamic>{'city': 'Yaounde'},
        'destinationBranch': <String, dynamic>{'city': 'Douala'},
        'trackingEvents': <dynamic>[],
      });

      expect(parcel.trackingNumber, 'PAR-MUH3YJVA-YRDPTS');
      expect(parcel.senderName, 'Claire Client');
      expect(parcel.recipientName, 'Mary Example');
      expect(parcel.recipientPhone, '699123456');
      expect(parcel.routeLabel, 'Yaounde → Douala');
      expect(parcel.statusLabel, 'In Transit');
      expect(parcel.trackingEvents, isEmpty);
    });
  });

  group('AgencyDashboard', () {
    test('maps the real dashboard counters', () {
      final AgencyDashboard dashboard = AgencyDashboard.fromJson(
        <String, dynamic>{
          'trips': <String, dynamic>{
            'total': 2,
            'scheduled': 2,
            'departed': 0,
            'arrived': 0,
            'cancelled': 0,
          },
          'bookings': <String, dynamic>{
            'total': 11,
            'pending': 3,
            'confirmed': 8,
            'completed': 0,
            'cancelled': 0,
          },
          'luggage': <String, dynamic>{
            'total': 3,
            'inTransit': 0,
            'delivered': 0,
          },
          'parcels': <String, dynamic>{
            'total': 3,
            'inTransit': 0,
            'delivered': 0,
          },
          'revenue': <String, dynamic>{'successfulPayments': '45000'},
          'upcomingTrips': <dynamic>[realTrip],
          'recentBookings': <dynamic>[realBooking],
        },
      );

      expect(dashboard.tripCount(), 2);
      expect(dashboard.scheduledTripCount(), 2);
      expect(dashboard.bookingCount(), 11);
      expect(dashboard.confirmedBookingCount(), 8);
      expect(dashboard.luggageCount(), 3);
      expect(dashboard.parcelCount(), 3);
      expect(dashboard.revenue, 45000);
      expect(dashboard.upcomingTrips, hasLength(1));
      expect(dashboard.recentBookings, hasLength(1));
      expect(dashboard.recentBookings.first.passengerName, 'Claire Client');
    });

    test('an empty dashboard reports zeroes instead of failing', () {
      final AgencyDashboard dashboard = AgencyDashboard.fromJson(
        <String, dynamic>{},
      );

      expect(dashboard.tripCount(), 0);
      expect(dashboard.bookingCount(), 0);
      expect(dashboard.revenue, 0);
      expect(dashboard.upcomingTrips, isEmpty);
      expect(dashboard.recentBookings, isEmpty);
    });
  });
}

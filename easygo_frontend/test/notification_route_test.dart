import 'package:easygo_frontend/features/notifications/notification_route.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which screen a notification opens, and — more importantly — when it opens
/// none.
///
/// The defect this exists for is a notification that could not be opened at all.
/// The risk in fixing it is the opposite one: a card that offers a link which
/// leads nowhere, or that sends a customer to an administrator's console. Both
/// of those are asserted against here.
void main() {
  NotificationDestination destination(String? referenceType, String? role) {
    return notificationDestination(referenceType: referenceType, role: role);
  }

  group('a notification with no reference', () {
    test('opens nothing', () {
      expect(destination(null, roleCustomer), NotificationDestination.none);
      expect(destination('', roleCustomer), NotificationDestination.none);
      expect(destination(null, roleAdmin), NotificationDestination.none);
    });

    test('opens nothing even when the role is known', () {
      // Knowing who is reading must not turn a reference-less notice into a
      // link. Its card carries no chevron for this reason.
      expect(destination(null, roleAgencyStaff), NotificationDestination.none);
    });

    test('opens nothing for a reference this build does not know', () {
      // A newer backend adding a tenth kind of record must not make the client
      // offer a dead link.
      expect(
        destination('SOMETHING_NEW', roleCustomer),
        NotificationDestination.none,
      );
    });
  });

  group('a message notification', () {
    test('opens the thread for every role that can have one', () {
      // The one destination that is not a list. This is the case the whole
      // change exists for.
      expect(
        destination('CONVERSATION', roleCustomer),
        NotificationDestination.conversation,
      );
      expect(
        destination('CONVERSATION', roleAgencyStaff),
        NotificationDestination.conversation,
      );
    });

    test('opens the thread even when the role could not be read', () {
      // Reaching a thread does not need the role to be decided here: the two
      // screens are chosen in the notification screen, which knows whether the
      // reader is the customer. Losing the role must not lose the one
      // destination the reader complained about.
      expect(
        destination('CONVERSATION', null),
        NotificationDestination.conversation,
      );
    });
  });

  group('a booking notification', () {
    test('sends each role to its own console', () {
      expect(
        destination('BOOKING', roleCustomer),
        NotificationDestination.clientTrips,
      );
      expect(
        destination('BOOKING', roleAgencyStaff),
        NotificationDestination.agencyBookings,
      );
      expect(
        destination('BOOKING', roleAdmin),
        NotificationDestination.adminBookings,
      );
    });

    test('does not send a customer to an agency or admin screen', () {
      expect(
        destination('BOOKING', roleCustomer),
        isNot(NotificationDestination.agencyBookings),
      );
      expect(
        destination('BOOKING', roleCustomer),
        isNot(NotificationDestination.adminBookings),
      );
    });
  });

  group('a trip notification', () {
    test('sends each role to its own console', () {
      expect(
        destination('TRIP', roleCustomer),
        NotificationDestination.clientTrips,
      );
      expect(
        destination('TRIP', roleAgencyStaff),
        NotificationDestination.agencyTrips,
      );
      expect(
        destination('TRIP', roleAdmin),
        NotificationDestination.adminTrips,
      );
    });
  });

  group('a parcel notification', () {
    test('sends each role to its own console', () {
      expect(
        destination('PARCEL', roleCustomer),
        NotificationDestination.clientParcels,
      );
      expect(
        destination('PARCEL', roleAgencyStaff),
        NotificationDestination.agencyParcels,
      );
      expect(
        destination('PARCEL', roleAdmin),
        NotificationDestination.adminParcels,
      );
    });
  });

  group('a luggage notification', () {
    test('sends each role to its own console', () {
      expect(
        destination('LUGGAGE', roleCustomer),
        NotificationDestination.clientLuggage,
      );
      expect(
        destination('LUGGAGE', roleAgencyStaff),
        NotificationDestination.agencyLuggage,
      );
      expect(
        destination('LUGGAGE', roleAdmin),
        NotificationDestination.adminLuggage,
      );
    });
  });

  group('an agency notification', () {
    test('opens the agency list for an administrator', () {
      // New agencies are announced to administrators, who are the only ones with
      // a console that lists them.
      expect(
        destination('AGENCY', roleAdmin),
        NotificationDestination.adminAgencies,
      );
    });

    test('opens nothing for anyone else', () {
      expect(
        destination('AGENCY', roleCustomer),
        NotificationDestination.none,
      );
      expect(
        destination('AGENCY', roleAgencyStaff),
        NotificationDestination.none,
      );
    });
  });

  group('when the role could not be read', () {
    test('a role-dependent destination opens nothing', () {
      // Not guessed. An account whose role was unreadable may not have the
      // console the guess would send it to.
      for (final String reference in <String>[
        'BOOKING',
        'TRIP',
        'PARCEL',
        'LUGGAGE',
        'AGENCY',
      ]) {
        expect(
          destination(reference, null),
          NotificationDestination.none,
          reason: '$reference must not resolve without a role',
        );
      }
    });

    test('an unrecognised role opens nothing', () {
      expect(
        destination('BOOKING', 'SOMETHING_ELSE'),
        NotificationDestination.none,
      );
    });
  });

  test('every reference the backend can send resolves for someone', () {
    // The `NotificationReference` enum in the Prisma schema, which must stay in
    // step with this. A value added there and forgotten here resolves to `none`
    // for every role, so a notification that should open something silently
    // stops opening it.
    const Map<String, String> storedReferences = <String, String>{
      'CONVERSATION': roleCustomer,
      'BOOKING': roleCustomer,
      'TRIP': roleCustomer,
      'PARCEL': roleCustomer,
      'LUGGAGE': roleCustomer,
      // An agency notice is only ever addressed to an administrator.
      'AGENCY': roleAdmin,
    };

    for (final MapEntry<String, String> entry in storedReferences.entries) {
      expect(
        destination(entry.key, entry.value),
        isNot(NotificationDestination.none),
        reason:
            '${entry.key} resolves to nothing for ${entry.value}, so its '
            'notification cannot be opened',
      );
    }
  });
}

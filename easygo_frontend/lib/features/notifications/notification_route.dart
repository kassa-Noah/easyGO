/// Where a notification leads.
///
/// The platform used to write a notification that said something had happened
/// and left the reader to go and find the thing themselves: a "new message"
/// notification could not be opened, and there was no way to tell which
/// notification could be opened and which could not. The backend now records
/// what each notification is about, and this is the client's half of that.
enum NotificationDestination {
  /// Nothing to open. A platform-wide notice has no record behind it, and the
  /// interface shows no link rather than a link that leads nowhere.
  none,

  /// The thread the message was posted in. This is the one destination that is
  /// not a list: a message is worth reading, not worth hunting for.
  conversation,

  clientTrips,
  agencyBookings,
  adminBookings,
  agencyTrips,
  adminTrips,
  clientParcels,
  agencyParcels,
  adminParcels,
  clientLuggage,
  agencyLuggage,
  adminLuggage,
  adminAgencies,
}

/// The role the notification list is being read with, as the API names it.
const String roleCustomer = 'CUSTOMER';
const String roleAgencyStaff = 'AGENCY_STAFF';
const String roleAdmin = 'ADMIN';

/// Resolves [referenceType] and the reader's [role] to a destination.
///
/// Two things are deliberately not done here.
///
/// A notification opens the screen that *lists* the record rather than the
/// record's own page, for everything except a conversation. The record screens
/// take a fully loaded model rather than an id — `TripDetailsScreen` wants a
/// `Booking`, `AgencyBookingDetailsScreen` wants a booking, `TrackingDetailsScreen`
/// wants a parcel — so reaching one by id would mean giving a handful of screens
/// a second way to be built. That is worth doing, but it is a change to those
/// screens, not to this decision, and until it is done landing on the list that
/// contains the record is honest where a link that silently failed would not be.
///
/// A [role] of null — the account could not be read — resolves to
/// [NotificationDestination.none] for everything that depends on it, rather than
/// guessing a console the reader may not have. A conversation is reached the
/// same way by every role that can have one, so it still resolves.
NotificationDestination notificationDestination({
  required String? referenceType,
  required String? role,
}) {
  switch (referenceType) {
    case 'CONVERSATION':
      return NotificationDestination.conversation;

    case 'BOOKING':
      return _forRole(
        role,
        customer: NotificationDestination.clientTrips,
        staff: NotificationDestination.agencyBookings,
        admin: NotificationDestination.adminBookings,
      );

    case 'TRIP':
      return _forRole(
        role,
        customer: NotificationDestination.clientTrips,
        staff: NotificationDestination.agencyTrips,
        admin: NotificationDestination.adminTrips,
      );

    case 'PARCEL':
      return _forRole(
        role,
        customer: NotificationDestination.clientParcels,
        staff: NotificationDestination.agencyParcels,
        admin: NotificationDestination.adminParcels,
      );

    case 'LUGGAGE':
      return _forRole(
        role,
        customer: NotificationDestination.clientLuggage,
        staff: NotificationDestination.agencyLuggage,
        admin: NotificationDestination.adminLuggage,
      );

    case 'AGENCY':
      // Only an administrator has an agency console to open.
      return role == roleAdmin
          ? NotificationDestination.adminAgencies
          : NotificationDestination.none;

    default:
      // No reference at all, or one this build does not know. A newer backend
      // adding a kind of record must not make the client offer a dead link.
      return NotificationDestination.none;
  }
}

NotificationDestination _forRole(
  String? role, {
  required NotificationDestination customer,
  required NotificationDestination staff,
  required NotificationDestination admin,
}) {
  switch (role) {
    case roleCustomer:
      return customer;
    case roleAgencyStaff:
      return staff;
    case roleAdmin:
      return admin;
    default:
      return NotificationDestination.none;
  }
}

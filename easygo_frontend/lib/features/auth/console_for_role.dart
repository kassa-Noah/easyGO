import 'package:flutter/widgets.dart';

import '../admin/navigation/admin_main_navigation.dart';
import '../agency/navigation/agency_main_navigation.dart';
import '../client/home/main_screen.dart';

/// The console an account opens.
///
/// Two places need this and they have to agree: the sign-in screen, and the
/// splash screen when it finds a session that is already signed in. A mapping
/// written out in both is a mapping that drifts, and the drift would be an
/// account being sent to a console it was never meant to see.
///
/// Returns null for a role this build does not serve rather than falling back to
/// one. An account the app cannot show has to be a visible failure, because the
/// alternative is an administrator quietly dropped into the customer app.
Widget? consoleForRole(String role) {
  switch (role) {
    case 'ADMIN':
      return const AdminMainNavigation();

    case 'AGENCY_STAFF':
      return const AgencyMainNavigation();

    case 'CUSTOMER':
      return const ClientMainScreen();
  }

  return null;
}

import 'package:easygo_frontend/features/admin/navigation/admin_main_navigation.dart';
import 'package:easygo_frontend/features/agency/navigation/agency_main_navigation.dart';
import 'package:easygo_frontend/features/auth/console_for_role.dart';
import 'package:easygo_frontend/features/client/home/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which console an account opens.
///
/// Two screens need this answer — the sign-in screen, and the splash screen
/// restoring a session that is already signed in — and the cost of them
/// disagreeing is an account being shown a console it was never meant to see.
/// These pin the answer itself rather than either caller.
void main() {
  test('each role opens its own console', () {
    expect(consoleForRole('ADMIN'), isA<AdminMainNavigation>());
    expect(consoleForRole('AGENCY_STAFF'), isA<AgencyMainNavigation>());
    expect(consoleForRole('CUSTOMER'), isA<ClientMainScreen>());
  });

  test('an administrator never lands in the customer app', () {
    // The specific mistake a fallback would make: an unrecognised role falling
    // through to the customer app, which is the one console that must not be a
    // default because it is the one most accounts have.
    expect(consoleForRole('ADMIN'), isNot(isA<ClientMainScreen>()));
    expect(consoleForRole('AGENCY_STAFF'), isNot(isA<ClientMainScreen>()));
  });

  test('a role this build does not serve opens nothing', () {
    // Not a default. An account the app cannot show has to be a visible failure
    // — the callers sign it out — rather than being quietly given a console.
    expect(consoleForRole('SUPPORT'), isNull);
    expect(consoleForRole(''), isNull);
    expect(consoleForRole('admin'), isNull);
  });
}

import 'package:easygo_frontend/features/admin/models/admin_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminStaffMember.fromJson', () {
    Map<String, dynamic> membership({
      String role = 'MANAGER',
      bool isActive = true,
      Map<String, dynamic>? user,
    }) {
      return <String, dynamic>{
        'id': 'm1',
        'role': role,
        'isActive': isActive,
        'userId': 'u1',
        'user':
            user ??
            <String, dynamic>{
              'id': 'u1',
              'firstName': 'Aline',
              'lastName': 'Agent',
              'email': 'manager@easygo.com',
              'phone': '690111222',
            },
      };
    }

    test('reads the account behind the membership', () {
      final AdminStaffMember member = AdminStaffMember.fromJson(membership());

      expect(member.userId, 'u1');
      expect(member.name, 'Aline Agent');
      expect(member.email, 'manager@easygo.com');
      expect(member.phone, '690111222');
      expect(member.role, 'Manager');
      expect(member.isActive, isTrue);
    });

    test('names the agent role', () {
      final AdminStaffMember member = AdminStaffMember.fromJson(
        membership(role: 'AGENT'),
      );

      expect(member.role, 'Agent');
    });

    test('falls back to the user id when the account is not attached', () {
      // The API always nests the user, but a missing one must not leave the
      // row without any way to identify the membership.
      final AdminStaffMember member = AdminStaffMember.fromJson(
        <String, dynamic>{'id': 'm1', 'role': 'AGENT', 'userId': 'u9'},
      );

      expect(member.userId, 'u9');
      expect(member.name, '');
      expect(member.email, '');
    });

    test('reads a suspended membership', () {
      final AdminStaffMember member = AdminStaffMember.fromJson(
        membership(isActive: false),
      );

      expect(member.isActive, isFalse);
    });

    test('survives an account with no phone on record', () {
      final AdminStaffMember member = AdminStaffMember.fromJson(
        membership(
          user: <String, dynamic>{
            'id': 'u1',
            'firstName': 'No',
            'lastName': 'Phone',
            'email': 'nophone@easygo.cm',
          },
        ),
      );

      expect(member.phone, isNull);
      expect(member.name, 'No Phone');
    });
  });

  group('adminStaffRoleLabel', () {
    test('names the two agency-side roles', () {
      expect(adminStaffRoleLabel('MANAGER'), 'Manager');
      expect(adminStaffRoleLabel('AGENT'), 'Agent');
    });

    test('falls back to readable text for an unknown role', () {
      expect(adminStaffRoleLabel('SUPERVISOR'), 'Supervisor');
    });
  });

  group('AdminAccount', () {
    test('reads the platform role, which decides who can be attached', () {
      // Attaching requires a CUSTOMER, so the role has to survive parsing.
      final AdminAccount account = AdminAccount.fromJson(<String, dynamic>{
        'id': 'u1',
        'firstName': 'Claire',
        'lastName': 'Client',
        'email': 'customer@easygo.com',
        'role': 'CUSTOMER',
        'isActive': true,
      });

      expect(account.role, 'CUSTOMER');
      expect(account.fullName, 'Claire Client');
    });
  });
}

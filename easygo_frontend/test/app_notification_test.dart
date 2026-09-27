import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_frontend/features/notifications/models/app_notification.dart';

/// The API stores a notification with a `status` of UNREAD or READ and a
/// `type` drawn from nine categories. These tests pin both, because reading a
/// boolean the API never sends would silently mark every notification as read.
///
/// They also pin the reference, which is what lets a notification be opened
/// instead of only read.

void main() {
  group('AppNotification', () {
    test('treats a READ status as read', () {
      final AppNotification read = AppNotification.fromJson(<String, dynamic>{
        'id': 'n1',
        'title': 'Booking Confirmed',
        'message': 'Your journey was confirmed.',
        'type': 'BOOKING',
        'status': 'READ',
        'readAt': '2026-09-25T10:00:00.000Z',
        'createdAt': '2026-09-25T09:00:00.000Z',
      });

      expect(read.isRead, isTrue);
      expect(read.readAt, isNotNull);
    });

    test('treats an UNREAD status as unread', () {
      final AppNotification unread = AppNotification.fromJson(<String, dynamic>{
        'id': 'n2',
        'title': 'Payment Successful',
        'message': 'Your payment went through.',
        'type': 'PAYMENT',
        'status': 'UNREAD',
      });

      expect(unread.isRead, isFalse);
      expect(unread.readAt, isNull);
    });

    test('defaults to unread when the status is absent', () {
      final AppNotification notification = AppNotification.fromJson(
        <String, dynamic>{'id': 'n3', 'title': 'x', 'message': 'y'},
      );

      expect(notification.status, 'UNREAD');
      expect(notification.isRead, isFalse);
    });

    test('groups the nine stored types into four headings', () {
      String group(String type) =>
          AppNotification.fromJson(<String, dynamic>{'type': type}).groupLabel;

      expect(group('BOOKING'), 'Journey');
      expect(group('PAYMENT'), 'Journey');
      expect(group('TICKET'), 'Journey');
      expect(group('TAXI'), 'Journey');
      expect(group('TRIP'), 'Journey');
      expect(group('LUGGAGE'), 'Tracking');
      expect(group('PARCEL'), 'Tracking');
      // A person writing to you is not the platform telling you something, so
      // the two do not share a heading.
      expect(group('MESSAGE'), 'Messages');
      expect(group('MESSAGE'), isNot(group('SYSTEM')));
      expect(group('SYSTEM'), 'System');
      // An unrecognised type must still land somewhere sensible.
      expect(group('SOMETHING_NEW'), 'System');
      expect(group(''), 'System');
    });

    test('gives every stored type its own icon', () {
      IconData icon(String type) =>
          AppNotification.fromJson(<String, dynamic>{'type': type}).icon;

      expect(icon('LUGGAGE'), Icons.luggage_outlined);
      expect(icon('PARCEL'), Icons.inventory_2_outlined);
      expect(icon('TAXI'), Icons.local_taxi_outlined);
      expect(icon('MESSAGE'), Icons.chat_bubble_outline);
      expect(icon('SYSTEM'), Icons.info_outline);
      expect(icon(''), Icons.notifications_outlined);
    });

    test('reads the record the notification is about', () {
      final AppNotification notification = AppNotification.fromJson(
        <String, dynamic>{
          'id': 'n4',
          'referenceType': 'CONVERSATION',
          'referenceId': 'c1',
        },
      );

      expect(notification.hasReference, isTrue);
      expect(notification.referenceType, 'CONVERSATION');
      expect(notification.referenceId, 'c1');
    });

    test('has no reference when the API sends none', () {
      final AppNotification notification = AppNotification.fromJson(
        <String, dynamic>{'id': 'n5', 'title': 'Platform maintenance'},
      );

      expect(notification.hasReference, isFalse);
      expect(notification.referenceType, isNull);
      expect(notification.referenceId, isNull);
    });

    test('counts a half-written reference as no reference at all', () {
      // A type with no id, or an id with no type, cannot be resolved. Treating
      // it as usable would put a link on a card that leads nowhere.
      final AppNotification typeOnly = AppNotification.fromJson(
        <String, dynamic>{'id': 'n6', 'referenceType': 'BOOKING'},
      );

      final AppNotification idOnly = AppNotification.fromJson(
        <String, dynamic>{'id': 'n7', 'referenceId': 'b1'},
      );

      final AppNotification blank = AppNotification.fromJson(
        <String, dynamic>{
          'id': 'n8',
          'referenceType': '  ',
          'referenceId': 'b1',
        },
      );

      expect(typeOnly.hasReference, isFalse);
      expect(idOnly.hasReference, isFalse);
      expect(blank.hasReference, isFalse);
    });

    test('describes how long ago a notification arrived', () {
      final DateTime now = DateTime(2026, 9, 25, 12);

      String age(Duration ago) => AppNotification.fromJson(<String, dynamic>{
        'createdAt': now.subtract(ago).toIso8601String(),
      }).ageLabel(now: now);

      expect(age(const Duration(seconds: 30)), 'Just now');
      expect(age(const Duration(minutes: 10)), '10 min ago');
      expect(age(const Duration(hours: 3)), '3 h ago');
      expect(age(const Duration(days: 1)), 'Yesterday');
      expect(age(const Duration(days: 4)), '4 days ago');
      // Beyond a week it falls back to the date.
      expect(age(const Duration(days: 30)), '26/08/2026');
    });

    test('has no age to show when the API sends no timestamp', () {
      expect(AppNotification.fromJson(<String, dynamic>{}).ageLabel(), '');
    });
  });
}

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void initializeNotifications() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for reminders',
        defaultColor: const Color(0xFF7BA8F9),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );
}

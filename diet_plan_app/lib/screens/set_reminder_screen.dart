import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_auth/firebase_auth.dart';

class SetReminderScreen extends StatefulWidget {
  const SetReminderScreen({super.key});

  @override
  _SetReminderScreenState createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _firestore = FirebaseFirestore.instance;

  TimeOfDay _breakfastTime = TimeOfDay.now();
  TimeOfDay _lunchTime = TimeOfDay.now();
  TimeOfDay _snackTime = TimeOfDay.now();
  TimeOfDay _dinnerTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _loadReminderTimes();
  }

  void initializeNotifications() {
  tz.initializeTimeZones(); // Initialize timezone data
  const initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  _flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


  Future<void> _loadReminderTimes() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _breakfastTime = _timeFromString(data['reminders']['breakfastTime'] as String?);
        _lunchTime = _timeFromString(data['reminders']['lunchTime'] as String?);
        _snackTime = _timeFromString(data['reminders']['snackTime'] as String?);
        _dinnerTime = _timeFromString(data['reminders']['dinnerTime'] as String?);
      });
    }
  }

  TimeOfDay _timeFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return TimeOfDay.now(); // Default time if parsing fails
    }
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
      final minute = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now(); // Default time if parsing fails
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, String mealType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        switch (mealType) {
          case 'breakfastTime':
            _breakfastTime = picked;
            break;
          case 'lunchTime':
            _lunchTime = picked;
            break;
          case 'snackTime':
            _snackTime = picked;
            break;
          case 'dinnerTime':
            _dinnerTime = picked;
            break;
        }
      });
      await _saveReminderTime(mealType, picked);
    }
  }

  Future<void> _saveReminderTime(String mealType, TimeOfDay time) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final formattedTime = _formatTimeOfDay(time);
    await _firestore.collection('users').doc(userId).update({
      'reminders.$mealType': formattedTime,
    });
    print('Time is saved for $mealType');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Meal Reminders'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildTimePickerRow('Breakfast', _breakfastTime, 'breakfastTime'),
            const Divider(thickness: 3),
            _buildTimePickerRow('Lunch', _lunchTime, 'lunchTime'),
            const Divider(thickness: 3),
            _buildTimePickerRow('Snack', _snackTime, 'snackTime'),
            const Divider(thickness: 3),
            _buildTimePickerRow('Dinner', _dinnerTime, 'dinnerTime'),
            const Divider(thickness: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _scheduleAllNotifications();
              },
              child: const Text(
                'Save Reminders',
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(String label, TimeOfDay time, String mealType) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      trailing: Text(
        time.format(context),
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      onTap: () => _selectTime(context, mealType),
    );
  }
Future<void> _scheduleNotification(String mealType, TimeOfDay time) async {
  final now = DateTime.now();
  var scheduledDate = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  // If the time is earlier than the current time, schedule for the next day
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  
  print('Scheduling $mealType notification at $scheduledDate');

  final androidDetails = AndroidNotificationDetails(
    'reminder_channel_id',
    'Reminder Notifications',
    channelDescription: 'Channel for meal reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  try {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      mealType.hashCode, // Using hashCode for a unique ID per meal type
      'Meal Reminder',
      'It\'s time for $mealType!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('Notification scheduled for $mealType at $scheduledDate');
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}


  Future<void> _scheduleAllNotifications() async {
    await _scheduleNotification('Breakfast', _breakfastTime);
    await _scheduleNotification('Lunch', _lunchTime);
    await _scheduleNotification('Snack', _snackTime);
    await _scheduleNotification('Dinner', _dinnerTime);
  }
}

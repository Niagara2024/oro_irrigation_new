import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_segmented_control.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController1 = ScrollController();
  final ScrollController scrollController2 = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final notificationProvider = Provider.of<PreferencesMainProvider>(context, listen: false);
    notificationProvider.initNotifications();
  }
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<PreferencesMainProvider>(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isScreenSizeLarge = constraints.maxWidth >= 550;
        return Column(
          children: [
            const SizedBox(height: 10,),
            CustomSegmentedControl(
              segmentTitles: const {
                0: 'Events',
                1: 'Alarms',
              },
              groupValue: notificationProvider.selectedSegment,
              onChanged: (value) => notificationProvider.updateSelectedSegment(value!),
            ),
            Expanded(
              child: notificationProvider.selectedSegment == 0
                  ? Padding(
                padding: isScreenSizeLarge ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20) : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: _buildNotificationList(context, 'event'),
              )
                  : Padding(
                padding: isScreenSizeLarge ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20) : const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: _buildNotificationList(context, 'alarm'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationList(BuildContext context, String category) {
    final notificationProvider = Provider.of<PreferencesMainProvider>(context);
    final notifications = category == 'event'
        ? notificationProvider.configuration!.eventNotificationsSent
        : notificationProvider.configuration!.alarmNotificationsSent;

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final value = category == 'event'
            ? notificationProvider.getValueForEvent(notification.notificationTypeId)
            : notificationProvider.getValueForAlarm(notification.notificationTypeId);

        return Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              surfaceTintColor: Colors.white,
              child: CustomCheckBoxListTile(
                  subtitle: notification.notificationDescription,
                  value: value ?? false,
                  onChanged: (newValue) => category == 'event'
                      ? notificationProvider.updateValueForEvent(notification.notificationTypeId, newValue!)
                      : notificationProvider.updateValueForAlarm(notification.notificationTypeId, newValue!),
                  borderRadius: BorderRadius.circular(15),
                  showCircleAvatar: true,
                  content: IconData(0xf0164, fontFamily: notification.iconFontFamily),
                  icon: notification.iconCodePoint.length < 6 ? IconData(int.parse(notification.iconCodePoint), fontFamily: notification.iconFontFamily) : IconData(0xf0164, fontFamily: notification.iconFontFamily)
              ),
            ),
            if (index == notifications.length - 1)
              const SizedBox(height: 70),
          ],
        );
      },
    );
  }

}


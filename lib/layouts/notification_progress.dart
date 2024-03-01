import 'package:Sea_Sm/views/screens/home_scanner_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController{

  static void showCustomNotification({required double progress, required int imageuploaded, required int numbereOfImages}) {
    double _uploadedProgress=progress*100;
    // AwesomeNotifications().requestPermissionToSendNotifications();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'chanel key',
        title: 'uploading.. $imageuploaded/$numbereOfImages',
        displayOnBackground: true,
        // backgroundColor: Colors.black,
        color: backColor,
        progress: progress * 100,
        displayOnForeground: true,
        notificationLayout: NotificationLayout.ProgressBar,
        body: '${_uploadedProgress.toInt()}%',
      ),
    );
  }
  static void showCompleteNotification() {
    // AwesomeNotifications().requestPermissionToSendNotifications();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'chanel key',
        title: 'upload complete ${const Icon(Icons.download_done_outlined)}',
        displayOnBackground: true,
        color: Colors.green,
        displayOnForeground: true,
        notificationLayout: NotificationLayout.Default,
        body: 'uploading images to firebase completed',
      ),
    );
  }
}

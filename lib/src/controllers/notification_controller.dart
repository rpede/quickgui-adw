import 'package:desktop_notifications/desktop_notifications.dart';

class NotificationController {
  final _client = NotificationsClient();

  Future<Notification> notify(String summary, {String body = ''}) {
    return _client.notify(
      summary,
      body: body,
      appName: 'Quickgui',
      expireTimeoutMs: 10000, /* 10 seconds */
    );
  }
}

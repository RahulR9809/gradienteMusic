import 'package:flutter/material.dart';
import 'package:yourappname/model/notificationlistmodel.dart';
import 'package:yourappname/webservice/apiservices.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationModel notificationModel = NotificationModel();
  bool loading = false;

  getNotification(String userid) async {
    loading = true;
    notificationModel = await ApiService().notification(userid);
    loading = false;
    notifyListeners();
  }
}

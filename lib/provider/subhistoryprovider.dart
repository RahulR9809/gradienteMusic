import 'package:yourappname/model/historymodel.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/utils.dart';

class SubHistoryProvider extends ChangeNotifier {
  HistoryModel historyModel = HistoryModel();

  bool loading = false;

  Future<void> getTransactionList() async {
    loading = true;
    historyModel = await ApiService().transactionList();
    printLog("getTransactionList status :==> ${historyModel.status}");
    printLog("getTransactionList message :==> ${historyModel.message}");
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    printLog("============ clearProvider ============");
    historyModel = HistoryModel();
  }
}

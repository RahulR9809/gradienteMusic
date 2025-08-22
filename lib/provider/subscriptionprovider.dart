import 'package:yourappname/model/subscriptionmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/utils.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel subscriptionModel = SubscriptionModel();

  bool loading = false;
  int cPlanPosition = -1, purchasePos = -1;

  Future<void> getPackages() async {
    printLog("getPackages userID :==> ${Constant.userID}");
    loading = true;
    subscriptionModel = await ApiService().getPackage();
    printLog("getPackages status :==> ${subscriptionModel.status}");
    printLog("getPackages message :==> ${subscriptionModel.message}");
    if (subscriptionModel.status == 200 && subscriptionModel.result != null) {
      if ((subscriptionModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (subscriptionModel.result?.length ?? 0); i++) {
          if (subscriptionModel.result?[i].isBuy == 1) {
            printLog("<============= Purchased =============>");
            setPurchasedPlan(i);
          }
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPurchasedPlan(int position) {
    printLog("setPurchasedPlan position :==> $position");
    purchasePos = position;
  }

  setCurrentPlan(int position) {
    printLog("setCurrentPlan position :==> $position");
    cPlanPosition = position;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearSubscriptionProvider ================>");
    subscriptionModel = SubscriptionModel();
    loading = false;
    cPlanPosition = -1;
    purchasePos = -1;
  }
}

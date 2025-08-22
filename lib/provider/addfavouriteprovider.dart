import 'package:flutter/material.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/webservice/apiservices.dart';

class AddFavouriteProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  bool loading = false;

  getAddFavourite(String userid, String songid) async {
    loading = true;
    successModel = await ApiService().addfavourite(userid, songid);
    loading = false;
    notifyListeners();
  }
}

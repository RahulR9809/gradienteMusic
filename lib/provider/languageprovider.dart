import 'package:flutter/material.dart';
import 'package:yourappname/model/languagemodel.dart';
import 'package:yourappname/webservice/apiservices.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageModel languageModel = LanguageModel();
  bool loading = false;

  getLanguage(String pageno) async {
    loading = true;
    languageModel = await ApiService().language(pageno);
    loading = false;
    notifyListeners();
  }
}

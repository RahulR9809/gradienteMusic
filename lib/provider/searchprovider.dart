import 'package:flutter/material.dart';
import 'package:yourappname/model/searchmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/utils/utils.dart';

class SearchProvider extends ChangeNotifier {
  SearchModel searchModel = SearchModel();
  List<Result>? resultDataList = [];
  bool loading = false, loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? morePage;

  /* Select Layout */
  String layoutType = Constant.radioType;

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  getSearch(String searchText, type, pageno) async {
    printLog("getAllSong searchText :====> $searchText");
    printLog("getAllSong pageno :========> $pageno");
    loading = true;
    searchModel = SearchModel();
    searchModel = await ApiService().search(searchText, type, pageno);
    if (searchModel.status == 200) {
      setPagination(searchModel.totalRows, searchModel.totalPage,
          searchModel.currentPage, searchModel.morePage);
      if (searchModel.result != null && (searchModel.result?.length ?? 0) > 0) {
        printLog(
            "searchModel length :==> ${(searchModel.result?.length ?? 0)}");
        for (var i = 0; i < (searchModel.result?.length ?? 0); i++) {
          resultDataList?.add(searchModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        resultDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        resultDataList = postMap.values.toList();
        printLog("resultDataList length :==> ${(resultDataList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    morePage = morePage;
    notifyListeners();
  }

  /* Chnage Tab */
  selectLayout(type) async {
    layoutType = type;
    notifyListeners();
  }

  clearSearch() {
    loadMore = false;
    loading = false;
    searchModel = SearchModel();
    resultDataList?.clear();
    resultDataList = [];
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    loadMore = false;
    loading = false;
    searchModel = SearchModel();
    resultDataList?.clear();
    resultDataList = [];
    layoutType = Constant.radioType;
  }
}

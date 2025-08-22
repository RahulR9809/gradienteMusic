import 'package:flutter/material.dart';
import 'package:yourappname/model/liveeventmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';

class LiveEventProvider extends ChangeNotifier {
  int position = 0;

  /* Live Event Pagination */
  LiveEventModel liveEventModel = LiveEventModel();
  bool loading = false, loadMore = false;
  int? totalRows, totalPage, currentPage, morePage;
  List<Result>? liveEventList = [];

  getLiveEventList(pageNo) async {
    loading = true;
    liveEventModel = await ApiService().liveEventList(pageNo);
    if (liveEventModel.status == 200) {
      setPagination(liveEventModel.totalRows, liveEventModel.totalPage,
          liveEventModel.currentPage, liveEventModel.morePage);
      if (liveEventModel.result != null &&
          (liveEventModel.result?.length ?? 0) > 0) {
        printLog(
            "songsModel length :==> ${(liveEventModel.result?.length ?? 0)}");
        for (var i = 0; i < (liveEventModel.result?.length ?? 0); i++) {
          liveEventList?.add(liveEventModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        liveEventList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        liveEventList = postMap.values.toList();
        printLog("resultSongList length :==> ${(liveEventList?.length ?? 0)}");
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

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  selectEvent(int index) {
    position = index;
    notifyListeners();
  }

  clearProvider() {
    liveEventModel = LiveEventModel();
    position = 0;
    loading = false;
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    morePage;
    liveEventList = [];
    liveEventList?.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:yourappname/model/podcastsectiondetailmodel.dart'
    as podcastsectiondetail;
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/utils/utils.dart';

class PodcatViewAllProvider extends ChangeNotifier {
  podcastsectiondetail.PodcastSectionDetailModel podcastSectionDetailModel =
      podcastsectiondetail.PodcastSectionDetailModel();
  int? totalRows, totalPage, currentPage, morePage;
  List<podcastsectiondetail.Result>? podcastList = [];

  /* Loading Field */
  bool loading = false, loadMore = false;

/* Banner Podcast APi */
  getPodcastSectionDetail(sectionId, pageNo) async {
    loading = true;
    podcastSectionDetailModel =
        await ApiService().podcastSectionDetailList(sectionId, pageNo);

    if (podcastSectionDetailModel.status == 200) {
      setPagination(
          podcastSectionDetailModel.totalRows,
          podcastSectionDetailModel.totalPage,
          podcastSectionDetailModel.currentPage,
          podcastSectionDetailModel.morePage);
      if (podcastSectionDetailModel.result != null &&
          (podcastSectionDetailModel.result?.length ?? 0) > 0) {
        printLog(
            "podcastList length :==> ${(podcastSectionDetailModel.result?.length ?? 0)}");
        for (var i = 0;
            i < (podcastSectionDetailModel.result?.length ?? 0);
            i++) {
          podcastList?.add(podcastSectionDetailModel.result?[i] ??
              podcastsectiondetail.Result());
        }
        final Map<int, podcastsectiondetail.Result> postMap = {};
        podcastList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        podcastList = postMap.values.toList();
        printLog("podcastList length :==> ${(podcastList?.length ?? 0)}");
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

  clearProvider() {
    podcastSectionDetailModel =
        podcastsectiondetail.PodcastSectionDetailModel();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    podcastList = [];
    podcastList?.clear();
    /* Loading Field */
    loading = false;
    loadMore = false;
  }
}

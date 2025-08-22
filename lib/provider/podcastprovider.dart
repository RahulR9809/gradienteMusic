import 'package:flutter/material.dart';
import 'package:yourappname/model/podcastsectionmodel.dart' as podcastsection;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';

class PodcatsProvider extends ChangeNotifier {
  /* Banner Podcast Pagination */
  bool loading = false, loadmore = false;
  podcastsection.PodcastSectionModel podcastSectionModel =
      podcastsection.PodcastSectionModel();
  List<podcastsection.Result>? sectionList = [];
  int? sectiontotalRows, sectiontotalPage, sectioncurrentPage;
  bool? sectionisMorePage;

  /* Section Api */
  Future<void> getSeactionList(pageNo) async {
    loading = true;
    podcastSectionModel = await ApiService().podcastSectionList(pageNo);
    if (podcastSectionModel.status == 200) {
      setSectionPaginationData(
          podcastSectionModel.totalRows,
          podcastSectionModel.totalPage,
          podcastSectionModel.currentPage,
          podcastSectionModel.morePage);
      if (podcastSectionModel.result != null &&
          (podcastSectionModel.result?.length ?? 0) > 0) {
        printLog(
            "SectionModel length :==> ${(podcastSectionModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $sectioncurrentPage');
        if (podcastSectionModel.result != null &&
            (podcastSectionModel.result?.length ?? 0) > 0) {
          printLog(
              "SectionModel length :==> ${(podcastSectionModel.result?.length ?? 0)}");
          for (var i = 0; i < (podcastSectionModel.result?.length ?? 0); i++) {
            sectionList?.add(
                podcastSectionModel.result?[i] ?? podcastsection.Result());
          }
          final Map<int, podcastsection.Result> postMap = {};
          sectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionList = postMap.values.toList();
          printLog("SectionList length :==> ${(sectionList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setSectionPaginationData(int? sectiontotalRows, int? sectiontotalPage,
      int? sectioncurrentPage, bool? sectionisMorePage) {
    this.sectioncurrentPage = sectioncurrentPage;
    this.sectiontotalRows = sectiontotalRows;
    this.sectiontotalPage = sectiontotalPage;
    sectionisMorePage = sectionisMorePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  clearProvider() {
    loading = false;
    loadmore = false;
    podcastSectionModel = podcastsection.PodcastSectionModel();
    sectionList = [];
    sectionList?.clear();
    sectiontotalRows;
    sectiontotalPage;
    sectioncurrentPage;
    sectionisMorePage;
  }
}

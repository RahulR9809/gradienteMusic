import 'package:flutter/material.dart';
import 'package:yourappname/model/bannermodel.dart' as banner;
import 'package:yourappname/model/sectionlistmodel.dart' as section;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';

class HomeProvider extends ChangeNotifier {
  banner.BannerModel bannerModel = banner.BannerModel();
  int? cBannerIndex = 0;
  bool bannerLoading = false;

  bool sectionLoading = false, loadmore = false;
  section.SectionListModel sectionListModel = section.SectionListModel();
  List<section.Result>? sectionList = [];
  int? sectiontotalRows, sectiontotalPage, sectioncurrentPage;
  bool? sectionisMorePage;

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  /* Home Banner Start */

  setLoading(bool isLoading) {
    bannerLoading = isLoading;
    sectionLoading = isLoading;
    notifyListeners();
  }

  getBanner(pageNo) async {
    bannerLoading = true;
    bannerModel = await ApiService().getBanner(pageNo);
    bannerLoading = false;
    notifyListeners();
  }

  /* Home Banner End */

  /* Section Api */
  Future<void> getSeactionList(pageNo) async {
    sectionLoading = true;
    sectionListModel = await ApiService().sectionList(pageNo);
    if (sectionListModel.status == 200) {
      setSectionPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        printLog(
            "SectionModel length :==> ${(sectionListModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $sectioncurrentPage');
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          printLog(
              "SectionModel length :==> ${(sectionListModel.result?.length ?? 0)}");
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionList?.add(sectionListModel.result?[i] ?? section.Result());
          }
          final Map<int, section.Result> postMap = {};
          sectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionList = postMap.values.toList();
          printLog("SectionList length :==> ${(sectionList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    sectionLoading = false;
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
    cBannerIndex = 0;
    sectionLoading = false;
    loadmore = false;
    bannerModel = banner.BannerModel();
    sectionListModel = section.SectionListModel();
    sectionList = [];
    sectionList?.clear();
    sectiontotalRows;
    sectiontotalPage;
    sectioncurrentPage;
    sectionisMorePage;
  }
}

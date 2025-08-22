import 'package:flutter/material.dart';
import 'package:yourappname/model/sectiondetailmodel.dart' as sectiondetail;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';

class ViewAllProvider extends ChangeNotifier {
  /* Section Detail Field */
  sectiondetail.SectionDetailModel sectionDetailModel =
      sectiondetail.SectionDetailModel();
  List<sectiondetail.Result>? sectionDetailList = [];

  /* Common Fields */
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  bool loading = false, loadmore = false;

/* Section Detail APi */

  Future<void> getSeactionDetail(sectionId, pageNo) async {
    loading = true;
    sectionDetailModel = await ApiService().sectionDetail(sectionId, pageNo);
    if (sectionDetailModel.status == 200) {
      setSectionPaginationData(
          sectionDetailModel.totalRows,
          sectionDetailModel.totalPage,
          sectionDetailModel.currentPage,
          sectionDetailModel.morePage);
      if (sectionDetailModel.result != null &&
          (sectionDetailModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(sectionDetailModel.result?.length ?? 0)}");
        if (sectionDetailModel.result != null &&
            (sectionDetailModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(sectionDetailModel.result?.length ?? 0)}");
          for (var i = 0; i < (sectionDetailModel.result?.length ?? 0); i++) {
            sectionDetailList
                ?.add(sectionDetailModel.result?[i] ?? sectiondetail.Result());
          }
          final Map<int, sectiondetail.Result> postMap = {};
          sectionDetailList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionDetailList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(sectionDetailList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setSectionPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = isMorePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  clearProvider() {
    /* Section Detail Field */
    sectionDetailModel = sectiondetail.SectionDetailModel();
    sectionDetailList = [];
    sectionDetailList?.clear();
    /* Common Fields */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    loading = false;
    loadmore = false;
  }
}

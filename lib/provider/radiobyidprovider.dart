import 'package:flutter/material.dart';
import 'package:yourappname/model/audiomodel.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/utils/utils.dart';

class RadioByIdProvider extends ChangeNotifier {
  AudioModel songsModel = AudioModel();
  List<Result>? resultSongList = [];

  bool loading = false, loadMore = false;
  /* Post Pagination */
  int? totalRows, totalPage, currentPage, morePage;

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  getRadiobyArtist(String itemId, String pageno) async {
    printLog("getRadiobyArtist itemId :======> $itemId");
    printLog("getRadiobyArtist pageno :======> $pageno");
    loading = true;
    songsModel = AudioModel();
    songsModel = await ApiService().radiobyartist(itemId, pageno.toString());
    if (songsModel.status == 200) {
      setPagination(songsModel.totalRows, songsModel.totalPage,
          songsModel.currentPage, songsModel.morePage);
      if (songsModel.result != null && (songsModel.result?.length ?? 0) > 0) {
        printLog("songsModel length :==> ${(songsModel.result?.length ?? 0)}");
        for (var i = 0; i < (songsModel.result?.length ?? 0); i++) {
          resultSongList?.add(songsModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        resultSongList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        resultSongList = postMap.values.toList();
        printLog("resultSongList length :==> ${(resultSongList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  getRadiobyCity(String itemId, String languagegId, String pageno) async {
    printLog("getRadiobyCity itemId :======> $itemId");
    printLog("getRadiobyCity langId :======> $languagegId");
    printLog("getRadiobyCity pageno :======> $pageno");
    loading = true;
    songsModel = AudioModel();
    songsModel =
        await ApiService().radiobycity(itemId, languagegId, pageno.toString());
    if (songsModel.status == 200) {
      setPagination(songsModel.totalRows, songsModel.totalPage,
          songsModel.currentPage, songsModel.morePage);
      if (songsModel.result != null && (songsModel.result?.length ?? 0) > 0) {
        printLog("songsModel length :==> ${(songsModel.result?.length ?? 0)}");
        for (var i = 0; i < (songsModel.result?.length ?? 0); i++) {
          resultSongList?.add(songsModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        resultSongList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        resultSongList = postMap.values.toList();
        printLog("resultSongList length :==> ${(resultSongList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  getRadiobyCategory(String itemId, String languagegId, String pageno) async {
    printLog("getRadiobyCategory itemId :======> $itemId");
    printLog("getRadiobyCategory langId :======> $languagegId");
    printLog("getRadiobyCategory pageno :======> $pageno");
    loading = true;
    songsModel = AudioModel();
    songsModel = await ApiService()
        .radiobycategory(itemId, languagegId, pageno.toString());
    if (songsModel.status == 200) {
      setPagination(songsModel.totalRows, songsModel.totalPage,
          songsModel.currentPage, songsModel.morePage);
      if (songsModel.result != null && (songsModel.result?.length ?? 0) > 0) {
        printLog("songsModel length :==> ${(songsModel.result?.length ?? 0)}");
        for (var i = 0; i < (songsModel.result?.length ?? 0); i++) {
          resultSongList?.add(songsModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        resultSongList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        resultSongList = postMap.values.toList();
        printLog("resultSongList length :==> ${(resultSongList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  getRadiobyLanguage(String itemId, String pageno) async {
    printLog("getRadiobyLanguage itemId :======> $itemId");
    printLog("getRadiobyLanguage pageno :======> $pageno");
    loading = true;
    songsModel = AudioModel();
    songsModel = await ApiService().radiobylanguage(itemId, pageno.toString());
    if (songsModel.status == 200) {
      setPagination(songsModel.totalRows, songsModel.totalPage,
          songsModel.currentPage, songsModel.morePage);
      if (songsModel.result != null && (songsModel.result?.length ?? 0) > 0) {
        printLog("songsModel length :==> ${(songsModel.result?.length ?? 0)}");
        for (var i = 0; i < (songsModel.result?.length ?? 0); i++) {
          resultSongList?.add(songsModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        resultSongList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        resultSongList = postMap.values.toList();
        printLog("resultSongList length :==> ${(resultSongList?.length ?? 0)}");
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

  clearProvider() {
    songsModel = AudioModel();
    resultSongList?.clear();
    resultSongList = [];
    loading = false;
    totalRows;
    totalPage;
    currentPage;
    morePage;
  }
}

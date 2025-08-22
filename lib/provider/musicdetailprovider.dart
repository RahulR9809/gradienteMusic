import 'package:flutter/material.dart';
import 'package:yourappname/model/commentlistmodel.dart' as comment;
import 'package:yourappname/model/commentlistmodel.dart';
import 'package:yourappname/model/getepisodebypodcastmodel.dart' as episode;
import 'package:yourappname/model/getepisodebypodcastmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/utils/utils.dart';

class MusicDetailProvider extends ChangeNotifier {
  String istype = "episode";
  SuccessModel successModel = SuccessModel();
  bool addcommentloading = false;

  /* Live Event Pagination */
  GetEpisodeByPodcstModel getEpisodeByPodcstModel = GetEpisodeByPodcstModel();
  bool loading = false, loadMore = false;
  int? totalRows, totalPage, currentPage, morePageEpisode;
  List<episode.Result>? episodeList = [];

  CommentListModel commentListModel = CommentListModel();
  bool commentloading = false, commentloadMore = false;
  int? commenttotalRows,
      commenttotalPage,
      commentcurrentPage,
      commentmorePageEpisode;
  List<comment.Result>? commentList = [];

  getEpisodebyPodcastList(podcastId, pageNo) async {
    loading = true;
    getEpisodeByPodcstModel =
        await ApiService().getEpisodebyPodcast(podcastId, pageNo);
    if (getEpisodeByPodcstModel.status == 200) {
      setPagination(
          getEpisodeByPodcstModel.totalRows,
          getEpisodeByPodcstModel.totalPage,
          getEpisodeByPodcstModel.currentPage,
          getEpisodeByPodcstModel.morePage);
      if (getEpisodeByPodcstModel.result != null &&
          (getEpisodeByPodcstModel.result?.length ?? 0) > 0) {
        printLog(
            "podcastList length :==> ${(getEpisodeByPodcstModel.result?.length ?? 0)}");
        for (var i = 0;
            i < (getEpisodeByPodcstModel.result?.length ?? 0);
            i++) {
          episodeList
              ?.add(getEpisodeByPodcstModel.result?[i] ?? episode.Result());
        }
        final Map<int, episode.Result> postMap = {};
        episodeList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        episodeList = postMap.values.toList();
        printLog("podcastList length :==> ${(episodeList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePageEpisode) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    morePageEpisode = morePageEpisode;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

/* Comment List APi */

  getCommentList(type, songId, episodeId, pageNo) async {
    commentloading = true;
    commentListModel =
        await ApiService().commentList(type, songId, episodeId, pageNo);
    if (commentListModel.status == 200) {
      setCommnetPagination(
          commentListModel.totalRows,
          commentListModel.totalPage,
          commentListModel.currentPage,
          commentListModel.morePage);
      if (commentListModel.result != null &&
          (commentListModel.result?.length ?? 0) > 0) {
        printLog(
            "commentList length :==> ${(commentListModel.result?.length ?? 0)}");
        for (var i = 0; i < (commentListModel.result?.length ?? 0); i++) {
          commentList?.add(commentListModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> postMap = {};
        commentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        commentList = postMap.values.toList();
        printLog("commentList length :==> ${(commentList?.length ?? 0)}");
        setCommentLoadMore(false);
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommnetPagination(
      int? totalRows, int? totalPage, int? currentPage, int? morePageEpisode) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.morePageEpisode = morePageEpisode;
    notifyListeners();
  }

  setCommentLoadMore(commentloadMore) {
    this.commentloadMore = commentloadMore;
    notifyListeners();
  }

/* Add Comment */

  getaddcomment(songId, comment, type, episodeId) {
    episodeList?[0].totalComment = (episodeList?[0].totalComment ?? 0) + 1;
    notifyListeners();
    addcomment(songId, comment, type, episodeId);
  }

  addcomment(songId, comment, type, episodeId) async {
    setSendingComment(true);
    successModel =
        await ApiService().addComment(songId, comment, type, episodeId);
    await getCommentList(type, songId, episodeId, "1");
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    debugPrint("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  changeMusicTab(type) {
    istype = type;
    notifyListeners();
  }

  clearProvider() {
    istype = "episode";
    /* Live Event Pagination */
    getEpisodeByPodcstModel = GetEpisodeByPodcstModel();
    loading = false;
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    morePageEpisode;
    episodeList = [];
    episodeList?.clear();
    /* Comment Field */
    commentListModel = CommentListModel();
    commentloading = false;
    commentloadMore = false;
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentmorePageEpisode;
    commentList = [];
    commentList?.clear();
  }

  clearComment() {
    commentListModel = CommentListModel();
    commentloading = false;
    commentloadMore = false;
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentmorePageEpisode;
    commentList = [];
    commentList?.clear();
  }
}

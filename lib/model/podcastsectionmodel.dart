// To parse this JSON data, do
//
//     final podcastSectionModel = podcastSectionModelFromJson(jsonString);

import 'dart:convert';

PodcastSectionModel podcastSectionModelFromJson(String str) =>
    PodcastSectionModel.fromJson(json.decode(str));

String podcastSectionModelToJson(PodcastSectionModel data) =>
    json.encode(data.toJson());

class PodcastSectionModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  PodcastSectionModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory PodcastSectionModel.fromJson(Map<String, dynamic> json) =>
      PodcastSectionModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  String? title;
  String? subTitle;
  int? categoryId;
  int? languageId;
  String? screenLayout;
  int? isPremium;
  int? orderByUpload;
  int? orderByPlay;
  int? noOfContent;
  int? viewAll;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<Datum>? data;

  Result({
    this.id,
    this.title,
    this.subTitle,
    this.categoryId,
    this.languageId,
    this.screenLayout,
    this.isPremium,
    this.orderByUpload,
    this.orderByPlay,
    this.noOfContent,
    this.viewAll,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        subTitle: json["sub_title"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        screenLayout: json["screen_layout"],
        isPremium: json["is_premium"],
        orderByUpload: json["order_by_upload"],
        orderByPlay: json["order_by_play"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "sub_title": subTitle,
        "category_id": categoryId,
        "language_id": languageId,
        "screen_layout": screenLayout,
        "is_premium": isPremium,
        "order_by_upload": orderByUpload,
        "order_by_play": orderByPlay,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? id;
  String? title;
  int? categoryId;
  String? languageId;
  String? portraitImg;
  String? landscapeImg;
  String? description;
  int? isPremium;
  int? totalPlay;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? cityName;
  int? isBuy;
  int? isFavorite;
  int? totalComment;

  Datum({
    this.id,
    this.title,
    this.categoryId,
    this.languageId,
    this.portraitImg,
    this.landscapeImg,
    this.description,
    this.isPremium,
    this.totalPlay,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.cityName,
    this.isBuy,
    this.isFavorite,
    this.totalComment,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        description: json["description"],
        isPremium: json["is_premium"],
        totalPlay: json["total_play"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        artistName: json["artist_name"],
        cityName: json["city_name"],
        isBuy: json["is_buy"],
        isFavorite: json["is_favorite"],
        totalComment: json["total_comment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category_id": categoryId,
        "language_id": languageId,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "description": description,
        "is_premium": isPremium,
        "total_play": totalPlay,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "city_name": cityName,
        "is_buy": isBuy,
        "is_favorite": isFavorite,
        "total_comment": totalComment,
      };
}

// To parse this JSON data, do
//
//     final podcastSectionDetailModel = podcastSectionDetailModelFromJson(jsonString);

import 'dart:convert';

PodcastSectionDetailModel podcastSectionDetailModelFromJson(String str) =>
    PodcastSectionDetailModel.fromJson(json.decode(str));

String podcastSectionDetailModelToJson(PodcastSectionDetailModel data) =>
    json.encode(data.toJson());

class PodcastSectionDetailModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  PodcastSectionDetailModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory PodcastSectionDetailModel.fromJson(Map<String, dynamic> json) =>
      PodcastSectionDetailModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
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
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
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
  int? isBuy;
  int? isFavorite;
  int? totalComment;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? cityName;

  Result({
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
    this.isBuy,
    this.isFavorite,
    this.totalComment,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.cityName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
        isBuy: json["is_buy"],
        isFavorite: json["is_favorite"],
        totalComment: json["total_comment"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        artistName: json["artist_name"],
        cityName: json["city_name"],
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
        "is_buy": isBuy,
        "is_favorite": isFavorite,
        "total_comment": totalComment,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "city_name": cityName,
      };
}

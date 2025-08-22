// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

import 'dart:convert';

SearchModel searchModelFromJson(String str) =>
    SearchModel.fromJson(json.decode(str));

String searchModelToJson(SearchModel data) => json.encode(data.toJson());

class SearchModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SearchModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
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
  String? name;
  String? image;
  String? songUploadType;
  String? songUrl;
  int? categoryId;
  dynamic languageId;
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
  int? isFavorite;
  int? isBuy;
  int? totalComment;

  Result({
    this.id,
    this.title,
    this.name,
    this.image,
    this.songUploadType,
    this.songUrl,
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
    this.isFavorite,
    this.isBuy,
    this.totalComment,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        name: json["name"],
        image: json["image"],
        songUploadType: json["song_upload_type"],
        songUrl: json["song_url"],
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
        isFavorite: json["is_favorite"],
        isBuy: json["is_buy"],
        totalComment: json["total_comment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "name": name,
        "image": image,
        "song_upload_type": songUploadType,
        "song_url": songUrl,
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
        "is_favorite": isFavorite,
        "is_buy": isBuy,
        "total_comment": totalComment,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "name": name,
      "image": image,
      "song_upload_type": songUploadType,
      "song_url": songUrl,
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
      "is_favorite": isFavorite,
      "is_buy": isBuy,
      "total_comment": totalComment,
    };
  }
}

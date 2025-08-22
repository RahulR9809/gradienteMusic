// To parse this JSON data, do
//
//     final bannerModel = bannerModelFromJson(jsonString);

import 'dart:convert';

BannerModel bannerModelFromJson(String str) =>
    BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  BannerModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
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
  dynamic languageId;
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
  int? type;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? cityName;
  int? artistId;
  int? cityId;
  String? name;
  String? image;
  String? songUploadType;
  String? songUrl;

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
    this.type,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.cityName,
    this.artistId,
    this.cityId,
    this.name,
    this.image,
    this.songUploadType,
    this.songUrl,
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
        type: json["type"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        artistName: json["artist_name"],
        cityName: json["city_name"],
        artistId: json["artist_id"],
        cityId: json["city_id"],
        name: json["name"],
        image: json["image"],
        songUploadType: json["song_upload_type"],
        songUrl: json["song_url"],
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
        "type": type,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "city_name": cityName,
        "artist_id": artistId,
        "city_id": cityId,
        "name": name,
        "image": image,
        "song_upload_type": songUploadType,
        "song_url": songUrl,
      };

  Map<String, dynamic> toMap() {
    return {
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
      "type": type,
      "category_name": categoryName,
      "language_name": languageName,
      "artist_name": artistName,
      "city_name": cityName,
      "artist_id": artistId,
      "city_id": cityId,
      "name": name,
      "image": image,
      "song_upload_type": songUploadType,
      "song_url": songUrl,
    };
  }
}

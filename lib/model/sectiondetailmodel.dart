// To parse this JSON data, do
//
//     final sectionDetailModel = sectionDetailModelFromJson(jsonString);

import 'dart:convert';

SectionDetailModel sectionDetailModelFromJson(String str) =>
    SectionDetailModel.fromJson(json.decode(str));

String sectionDetailModelToJson(SectionDetailModel data) =>
    json.encode(data.toJson());

class SectionDetailModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SectionDetailModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SectionDetailModel.fromJson(Map<String, dynamic> json) =>
      SectionDetailModel(
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
  int? artistId;
  int? categoryId;
  dynamic languageId;
  int? cityId;
  String? title;
  String? name;
  String? image;
  String? portraitImg;
  String? landscapeImg;
  String? link;
  String? startTime;
  String? endTime;
  int? isPaid;
  int? price;
  int? isJoin;
  String? songUploadType;
  String? songUrl;
  int? isPremium;
  int? totalPlay;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isFavorite;
  int? isBuy;
  int? totalComment;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? cityName;

  Result({
    this.id,
    this.artistId,
    this.categoryId,
    this.languageId,
    this.cityId,
    this.title,
    this.name,
    this.image,
    this.portraitImg,
    this.landscapeImg,
    this.link,
    this.startTime,
    this.endTime,
    this.isPaid,
    this.price,
    this.isJoin,
    this.songUploadType,
    this.songUrl,
    this.isPremium,
    this.totalPlay,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isFavorite,
    this.isBuy,
    this.totalComment,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.cityName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        artistId: json["artist_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        cityId: json["city_id"],
        title: json["title"],
        name: json["name"],
        image: json["image"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        isPaid: json["is_paid"],
        price: json["price"],
        link: json["link"],
        isJoin: json["is_join"],
        songUploadType: json["song_upload_type"],
        songUrl: json["song_url"],
        isPremium: json["is_premium"],
        totalPlay: json["total_play"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isFavorite: json["is_favorite"],
        isBuy: json["is_buy"],
        totalComment: json["total_comment"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        artistName: json["artist_name"],
        cityName: json["city_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "city_id": cityId,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "start_time": startTime,
        "end_time": endTime,
        "is_paid": isPaid,
        "price": price,
        "link": link,
        "is_join": isJoin,
        "name": name,
        "image": image,
        "song_upload_type": songUploadType,
        "song_url": songUrl,
        "is_premium": isPremium,
        "total_play": totalPlay,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_favorite": isFavorite,
        "is_buy": isBuy,
        "total_comment": totalComment,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "city_name": cityName,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "artist_id": artistId,
      "category_id": categoryId,
      "language_id": languageId,
      "city_id": cityId,
      "title": title,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "start_time": startTime,
      "end_time": endTime,
      "is_paid": isPaid,
      "price": price,
      "link": link,
      "is_join": isJoin,
      "name": name,
      "image": image,
      "song_upload_type": songUploadType,
      "song_url": songUrl,
      "is_premium": isPremium,
      "total_play": totalPlay,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "is_favorite": isFavorite,
      "is_buy": isBuy,
      "total_comment": totalComment,
      "category_name": categoryName,
      "language_name": languageName,
      "artist_name": artistName,
      "city_name": cityName,
    };
  }
}

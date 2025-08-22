// To parse this JSON data, do
//
//     final sectionListModel = sectionListModelFromJson(jsonString);

import 'dart:convert';

SectionListModel sectionListModelFromJson(String str) =>
    SectionListModel.fromJson(json.decode(str));

String sectionListModelToJson(SectionListModel data) =>
    json.encode(data.toJson());

class SectionListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SectionListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SectionListModel.fromJson(Map<String, dynamic> json) =>
      SectionListModel(
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
  String? subTitle;
  int? type;
  int? artistId;
  int? categoryId;
  dynamic languageId;
  int? cityId;
  String? screenLayout;
  int? isPremium;
  int? orderByUpload;
  int? orderByPlay;
  int? isPaid;
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
    this.type,
    this.artistId,
    this.categoryId,
    this.languageId,
    this.cityId,
    this.screenLayout,
    this.isPremium,
    this.orderByUpload,
    this.orderByPlay,
    this.isPaid,
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
        type: json["type"],
        artistId: json["artist_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        cityId: json["city_id"],
        screenLayout: json["screen_layout"],
        isPremium: json["is_premium"],
        orderByUpload: json["order_by_upload"],
        orderByPlay: json["order_by_play"],
        isPaid: json["is_paid"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "sub_title": subTitle,
        "type": type,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "city_id": cityId,
        "screen_layout": screenLayout,
        "is_premium": isPremium,
        "order_by_upload": orderByUpload,
        "order_by_play": orderByPlay,
        "is_paid": isPaid,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": data == null
            ? []
            : List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
  int? id;
  String? title;
  String? portraitImg;
  String? landscapeImg;
  String? date;
  String? startTime;
  String? endTime;
  int? isPaid;
  int? price;
  int? type;
  String? link;
  String? description;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isJoin;
  int? artistId;
  int? categoryId;
  dynamic languageId;
  int? cityId;
  String? name;
  String? image;
  String? songUploadType;
  String? songUrl;
  int? isPremium;
  int? totalPlay;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? cityName;
  int? isFavorite;
  int? isBuy;
  int? totalComment;
  String? bio;

  Datum({
    this.id,
    this.title,
    this.portraitImg,
    this.landscapeImg,
    this.date,
    this.startTime,
    this.endTime,
    this.isPaid,
    this.price,
    this.type,
    this.link,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isJoin,
    this.artistId,
    this.categoryId,
    this.languageId,
    this.cityId,
    this.name,
    this.image,
    this.songUploadType,
    this.songUrl,
    this.isPremium,
    this.totalPlay,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.cityName,
    this.isFavorite,
    this.isBuy,
    this.totalComment,
    this.bio,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        date: json["date"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        isPaid: json["is_paid"],
        price: json["price"],
        type: json["type"],
        link: json["link"],
        description: json["description"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isJoin: json["is_join"],
        artistId: json["artist_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        cityId: json["city_id"],
        name: json["name"],
        image: json["image"],
        songUploadType: json["song_upload_type"],
        songUrl: json["song_url"],
        isPremium: json["is_premium"],
        totalPlay: json["total_play"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        artistName: json["artist_name"],
        cityName: json["city_name"],
        isFavorite: json["is_favorite"],
        isBuy: json["is_buy"],
        totalComment: json["total_comment"],
        bio: json["bio"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "is_paid": isPaid,
        "price": price,
        "type": type,
        "link": link,
        "description": description,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_join": isJoin,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "city_id": cityId,
        "name": name,
        "image": image,
        "song_upload_type": songUploadType,
        "song_url": songUrl,
        "is_premium": isPremium,
        "total_play": totalPlay,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "city_name": cityName,
        "is_favorite": isFavorite,
        "is_buy": isBuy,
        "total_comment": totalComment,
        "bio": bio,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "date": date,
      "start_time": startTime,
      "end_time": endTime,
      "is_paid": isPaid,
      "price": price,
      "type": type,
      "link": link,
      "description": description,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "is_join": isJoin,
      "artist_id": artistId,
      "category_id": categoryId,
      "language_id": languageId,
      "city_id": cityId,
      "name": name,
      "image": image,
      "song_upload_type": songUploadType,
      "song_url": songUrl,
      "is_premium": isPremium,
      "total_play": totalPlay,
      "category_name": categoryName,
      "language_name": languageName,
      "artist_name": artistName,
      "city_name": cityName,
      "is_favorite": isFavorite,
      "is_buy": isBuy,
      "total_comment": totalComment,
      "bio": bio,
    };
  }
}

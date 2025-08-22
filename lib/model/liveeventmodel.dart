// To parse this JSON data, do
//
//     final liveEventModel = liveEventModelFromJson(jsonString);

import 'dart:convert';

LiveEventModel liveEventModelFromJson(String str) =>
    LiveEventModel.fromJson(json.decode(str));

String liveEventModelToJson(LiveEventModel data) => json.encode(data.toJson());

class LiveEventModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  LiveEventModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory LiveEventModel.fromJson(Map<String, dynamic> json) => LiveEventModel(
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

  Result({
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
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
      };
}

// To parse this JSON data, do
//
//     final getEpisodeByPodcstModel = getEpisodeByPodcstModelFromJson(jsonString);

import 'dart:convert';

GetEpisodeByPodcstModel getEpisodeByPodcstModelFromJson(String str) =>
    GetEpisodeByPodcstModel.fromJson(json.decode(str));

String getEpisodeByPodcstModelToJson(GetEpisodeByPodcstModel data) =>
    json.encode(data.toJson());

class GetEpisodeByPodcstModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetEpisodeByPodcstModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetEpisodeByPodcstModel.fromJson(Map<String, dynamic> json) =>
      GetEpisodeByPodcstModel(
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
  int? podcastsId;
  String? name;
  String? description;
  String? portraitImg;
  String? landscapeImg;
  String? episodeUploadType;
  String? episodeAudio;
  int? duration;
  int? totalPlay;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? podcastTitle;
  int? totalComment;

  Result({
    this.id,
    this.podcastsId,
    this.name,
    this.description,
    this.portraitImg,
    this.landscapeImg,
    this.episodeUploadType,
    this.episodeAudio,
    this.duration,
    this.totalPlay,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastTitle,
    this.totalComment,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        podcastsId: json["podcasts_id"],
        name: json["name"],
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        episodeUploadType: json["episode_upload_type"],
        episodeAudio: json["episode_audio"],
        duration: json["duration"],
        totalPlay: json["total_play"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        podcastTitle: json["podcast_title"],
        totalComment: json["total_comment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "podcasts_id": podcastsId,
        "name": name,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "episode_upload_type": episodeUploadType,
        "episode_audio": episodeAudio,
        "duration": duration,
        "total_play": totalPlay,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "podcast_title": podcastTitle,
        "total_comment": totalComment,
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "podcasts_id": podcastsId,
      "name": name,
      "description": description,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "episode_upload_type": episodeUploadType,
      "episode_audio": episodeAudio,
      "duration": duration,
      "total_play": totalPlay,
      "sortable": sortable,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "podcast_title": podcastTitle,
      "total_comment": totalComment,
    };
  }
}

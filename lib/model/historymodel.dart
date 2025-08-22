// To parse this JSON data, do
// final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

HistoryModel historyModelFromJson(String str) =>
    HistoryModel.fromJson(json.decode(str));

String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
  int? status;
  String? message;
  List<Result>? result;

  HistoryModel({
    this.status,
    this.message,
    this.result,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  int? userId;
  int? packageId;
  String? description;
  String? amount;
  String? paymentId;
  String? currencyCode;
  String? expiryDate;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? packageName;
  int? packagePrice;
  String? data;

  Result({
    this.id,
    this.userId,
    this.packageId,
    this.description,
    this.amount,
    this.paymentId,
    this.currencyCode,
    this.expiryDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.packageName,
    this.packagePrice,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        packageId: json["package_id"],
        description: json["description"],
        amount: json["amount"],
        paymentId: json["payment_id"],
        currencyCode: json["currency_code"],
        expiryDate: json["expiry_date"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        packageName: json["package_name"],
        packagePrice: json["package_price"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "package_id": packageId,
        "description": description,
        "amount": amount,
        "payment_id": paymentId,
        "currency_code": currencyCode,
        "expiry_date": expiryDate,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "package_name": packageName,
        "package_price": packagePrice,
        "data": data,
      };
}

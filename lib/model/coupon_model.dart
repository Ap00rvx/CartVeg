// To parse this JSON data, do
//
//     final coupon = couponFromJson(jsonString);

import 'dart:convert';

Coupon couponFromJson(String str) => Coupon.fromJson(json.decode(str));

String couponToJson(Coupon data) => json.encode(data.toJson());

class Coupon {
    String id;
    int minValue;
    DateTime expiry;
    int maxUsage;
    String couponCode;
    int offValue;
    bool isActive;
    bool isDeleted;
    List<dynamic> usedUsers;
    int v;

    Coupon({
        required this.id,
        required this.minValue,
        required this.expiry,
        required this.maxUsage,
        required this.couponCode,
        required this.offValue,
        required this.isActive,
        required this.isDeleted,
        required this.usedUsers,
        required this.v,
    });

    factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json["_id"],
        minValue: json["minValue"],
        expiry: DateTime.parse(json["expiry"]),
        maxUsage: json["maxUsage"],
        couponCode: json["couponCode"],
        offValue: json["offValue"],
        isActive: json["isActive"],
        isDeleted: json["isDeleted"],
        usedUsers: List<dynamic>.from(json["usedUsers"].map((x) => x)),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "minValue": minValue,
        "expiry": expiry.toIso8601String(),
        "maxUsage": maxUsage,
        "couponCode": couponCode,
        "offValue": offValue,
        "isActive": isActive,
        "isDeleted": isDeleted,
        "usedUsers": List<dynamic>.from(usedUsers.map((x) => x)),
        "__v": v,
    };
}

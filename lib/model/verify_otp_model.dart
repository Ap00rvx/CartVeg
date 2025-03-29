// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());

class VerifyOtpResponse {
    String message;
    int statusCode;
    Data data;

    VerifyOtpResponse({
        required this.message,
        required this.statusCode,
        required this.data,
    });

    factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => VerifyOtpResponse(
        message: json["message"],
        statusCode: json["statusCode"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "statusCode": statusCode,
        "data": data.toJson(),
    };
}

class Data {
    User user;
    String token;

    Data({
        required this.user,
        required this.token,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: User.fromJson(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
    };
}

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    String id;
    String name;
    String email;
    List<dynamic> fcmTokens;
    String phone;
    String role;
    bool isActivate;
    String password;
    List<dynamic> orders;
    List<dynamic> addresses;
    DateTime createdAt;
    DateTime updatedAt;
    int v;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.fcmTokens,
        required this.phone,
        required this.role,
        required this.isActivate,
        required this.password,
        required this.orders,
        required this.addresses,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        fcmTokens: List<dynamic>.from(json["fcmTokens"].map((x) => x)),
        phone: json["phone"],
        role: json["role"],
        isActivate: json["isActivate"],
        password: json["password"],
        orders: List<dynamic>.from(json["orders"].map((x) => x)),
        addresses: List<dynamic>.from(json["addresses"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "fcmTokens": List<dynamic>.from(fcmTokens.map((x) => x)),
        "phone": phone,
        "role": role,
        "isActivate": isActivate,
        "password": password,
        "orders": List<dynamic>.from(orders.map((x) => x)),
        "addresses": List<dynamic>.from(addresses.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
    };
}

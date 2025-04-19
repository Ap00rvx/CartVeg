// To parse this JSON data, do
//
//     final categoriesResponse = categoriesResponseFromJson(jsonString);

import 'dart:convert';

CategoriesResponse categoriesResponseFromJson(String str) => CategoriesResponse.fromJson(json.decode(str));

String categoriesResponseToJson(CategoriesResponse data) => json.encode(data.toJson());

class CategoriesResponse {
    bool success;
    String message;
    List<Category> categories;

    CategoriesResponse({
        required this.success,
        required this.message,
        required this.categories,
    });

    factory CategoriesResponse.fromJson(Map<String, dynamic> json) => CategoriesResponse(
        success: json["success"],
        message: json["message"],
        categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    };
}

class Category {
    String id;
    String name;
    String image;

    Category({
        required this.id,
        required this.name,
        required this.image,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["_id"],
        name: json["name"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
    };
}

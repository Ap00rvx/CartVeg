// To parse this JSON data, do
//
//     final productResponse = productResponseFromJson(jsonString);

import 'dart:convert';

ProductResponse productResponseFromJson(String str) => ProductResponse.fromJson(json.decode(str));

String productResponseToJson(ProductResponse data) => json.encode(data.toJson());

class ProductResponse {
    bool success;
    String message;
    Data data;

    ProductResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    Store store;
    List<Product> products;
    String deliveryTime;
    Pagination pagination;

    Data({
        required this.store,
        required this.products,
        required this.deliveryTime,
        required this.pagination,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        store: Store.fromJson(json["store"]),
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        deliveryTime: json["deliveryTime"],
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "store": store.toJson(),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "deliveryTime": deliveryTime,
        "pagination": pagination.toJson(),
    };
}

class Pagination {
    int currentPage;
    int limit;
    int totalProducts;
    int totalPages;

    Pagination({
        required this.currentPage,
        required this.limit,
        required this.totalProducts,
        required this.totalPages,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["currentPage"],
        limit: json["limit"],
        totalProducts: json["totalProducts"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "currentPage": currentPage,
        "limit": limit,
        "totalProducts": totalProducts,
        "totalPages": totalPages,
    };
}

class Product {
    String productId;
    int quantity;
    int threshold;
    bool availability;
    Details details;

    Product({
        required this.productId,
        required this.quantity,
        required this.threshold,
        required this.availability,
        required this.details,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["productId"],
        quantity: json["quantity"],
        threshold: json["threshold"],
        availability: json["availability"],
        details: Details.fromJson(json["details"]),
    );

    Map<String, dynamic> toJson() => {
        "productId": productId,
        "quantity": quantity,
        "threshold": threshold,
        "availability": availability,
        "details": details.toJson(),
    };
}

class Details {
    String name;
    String description;
    String unit;
    int price;
    int actualPrice;
    String category;
    String origin;
    String shelfLife;
    String image;

    Details({
        required this.name,
        required this.description,
        required this.unit,
        required this.price,
        required this.actualPrice,
        required this.category,
        required this.origin,
        required this.shelfLife,
        required this.image,
    });

    factory Details.fromJson(Map<String, dynamic> json) => Details(
        name: json["name"],
        description: json["description"],
        unit: json["unit"],
        price: json["price"],
        actualPrice: json["actualPrice"],
        category: json["category"],
        origin: json["origin"],
        shelfLife: json["shelfLife"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "unit": unit,
        "price": price,
        "actualPrice": actualPrice,
        "category": category,
        "origin": origin,
        "shelfLife": shelfLife,
        "image": image,
    };
}

class Store {
    String id;
    String name;
    Address address;
    String phone;
    String email;
    double latitude;
    double longitude;
    int radius;
    String openingTime;

    Store({
        required this.id,
        required this.name,
        required this.address,
        required this.phone,
        required this.email,
        required this.latitude,
        required this.longitude,
        required this.radius,
        required this.openingTime,
    });

    factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["_id"],
        name: json["name"],
        address: Address.fromJson(json["address"]),
        phone: json["phone"],
        email: json["email"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        radius: json["radius"],
        openingTime: json["openingTime"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "address": address.toJson(),
        "phone": phone,
        "email": email,
        "latitude": latitude,
        "longitude": longitude,
        "radius": radius,
        "openingTime": openingTime,
    };
}

class Address {
    String flatno;
    String street;
    String city;
    String state;
    String pincode;

    Address({
        required this.flatno,
        required this.street,
        required this.city,
        required this.state,
        required this.pincode,
    });

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        flatno: json["flatno"],
        street: json["street"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
    );

    Map<String, dynamic> toJson() => {
        "flatno": flatno,
        "street": street,
        "city": city,
        "state": state,
        "pincode": pincode,
    };
}

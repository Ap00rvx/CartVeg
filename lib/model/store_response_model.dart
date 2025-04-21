// To parse this JSON data, do
//
//     final nearestStoreResponse = nearestStoreResponseFromJson(jsonString);

import 'dart:convert';

NearestStoreResponse nearestStoreResponseFromJson(String str) => NearestStoreResponse.fromJson(json.decode(str));

String nearestStoreResponseToJson(NearestStoreResponse data) => json.encode(data.toJson());

class NearestStoreResponse {
    bool success;
    String message;
    Data data;

    NearestStoreResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory NearestStoreResponse.fromJson(Map<String, dynamic> json) => NearestStoreResponse(
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
    String deliveryTime;
    String distance;

    Data({
        required this.store,
        required this.deliveryTime,
        required this.distance,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        store: Store.fromJson(json["store"]),
        deliveryTime: json["deliveryTime"],
        distance: json["distance"],
    );

    Map<String, dynamic> toJson() => {
        "store": store.toJson(),
        "deliveryTime": deliveryTime,
        "distance": distance,
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

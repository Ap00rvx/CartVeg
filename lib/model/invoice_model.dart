// To parse this JSON data, do
//
//     final invoice = invoiceFromJson(jsonString);

import 'dart:convert';

Invoice invoiceFromJson(String str) => Invoice.fromJson(json.decode(str));

String invoiceToJson(Invoice data) => json.encode(data.toJson());

class Invoice {
    UserDetails userDetails;
    IngAddress billingAddress;
    IngAddress shippingAddress;
    String id;
    String invoiceId;
    String orderId;
    int totalAmount;
    String paymentStatus;
    DateTime orderDate;
    List<Item> items;
    String paymentMode;
    int v;

    Invoice({
        required this.userDetails,
        required this.billingAddress,
        required this.shippingAddress,
        required this.id,
        required this.invoiceId,
        required this.orderId,
        required this.totalAmount,
        required this.paymentStatus,
        required this.orderDate,
        required this.items,
        required this.paymentMode,
        required this.v,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        userDetails: UserDetails.fromJson(json["userDetails"]),
        billingAddress: IngAddress.fromJson(json["billingAddress"]),
        shippingAddress: IngAddress.fromJson(json["shippingAddress"]),
        id: json["_id"],
        invoiceId: json["invoiceId"],
        orderId: json["orderId"],
        totalAmount: json["totalAmount"],
        paymentStatus: json["paymentStatus"],
        orderDate: DateTime.parse(json["orderDate"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        paymentMode: json["paymentMode"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "userDetails": userDetails.toJson(),
        "billingAddress": billingAddress.toJson(),
        "shippingAddress": shippingAddress.toJson(),
        "_id": id,
        "invoiceId": invoiceId,
        "orderId": orderId,
        "totalAmount": totalAmount,
        "paymentStatus": paymentStatus,
        "orderDate": orderDate.toIso8601String(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "paymentMode": paymentMode,
        "__v": v,
    };
}

class IngAddress {
    String flatno;
    String street;
    String city;
    String state;
    String pincode;

    IngAddress({
        required this.flatno,
        required this.street,
        required this.city,
        required this.state,
        required this.pincode,
    });

    factory IngAddress.fromJson(Map<String, dynamic> json) => IngAddress(
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

class Item {
    String name;
    int quantity;
    int price;
    String id;

    Item({
        required this.name,
        required this.quantity,
        required this.price,
        required this.id,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        name: json["name"],
        quantity: json["quantity"],
        price: json["price"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
        "price": price,
        "_id": id,
    };
}

class UserDetails {
    String name;
    String email;
    String phone;

    UserDetails({
        required this.name,
        required this.email,
        required this.phone,
    });

    factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
    };
}

// To parse this JSON data, do
//
//     final createOrderResponse = createOrderResponseFromJson(jsonString);

import 'dart:convert';

CreateOrderResponse createOrderResponseFromJson(String str) => CreateOrderResponse.fromJson(json.decode(str));

String createOrderResponseToJson(CreateOrderResponse data) => json.encode(data.toJson());

class CreateOrderResponse {
    int statusCode;
    String message;
    Data data;

    CreateOrderResponse({
        required this.statusCode,
        required this.message,
        required this.data,
    });

    factory CreateOrderResponse.fromJson(Map<String, dynamic> json) => CreateOrderResponse(
        statusCode: json["statusCode"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String orderId;
    String userId;
    List<Product> products;
    DateTime orderDate;
    DateTime expectedDeliveryDate;
    int totalAmount;
    int totalItems;
    String status;
    bool isCashOnDelivery;
    DeliveryAddress deliveryAddress;
    String invoiceId;
    String paymentStatus;
    String id;
    int v;

    Data({
        required this.orderId,
        required this.userId,
        required this.products,
        required this.orderDate,
        required this.expectedDeliveryDate,
        required this.totalAmount,
        required this.totalItems,
        required this.status,
        required this.isCashOnDelivery,
        required this.deliveryAddress,
        required this.invoiceId,
        required this.paymentStatus,
        required this.id,
        required this.v,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["orderId"],
        userId: json["userId"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        orderDate: DateTime.parse(json["orderDate"]),
        expectedDeliveryDate: DateTime.parse(json["expectedDeliveryDate"]),
        totalAmount: json["totalAmount"],
        totalItems: json["totalItems"],
        status: json["status"],
        isCashOnDelivery: json["isCashOnDelivery"],
        deliveryAddress: DeliveryAddress.fromJson(json["deliveryAddress"]),
        invoiceId: json["invoiceId"],
        paymentStatus: json["paymentStatus"],
        id: json["_id"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "userId": userId,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "orderDate": orderDate.toIso8601String(),
        "expectedDeliveryDate": expectedDeliveryDate.toIso8601String(),
        "totalAmount": totalAmount,
        "totalItems": totalItems,
        "status": status,
        "isCashOnDelivery": isCashOnDelivery,
        "deliveryAddress": deliveryAddress.toJson(),
        "invoiceId": invoiceId,
        "paymentStatus": paymentStatus,
        "_id": id,
        "__v": v,
    };
}

class DeliveryAddress {
    String flatno;
    String street;
    String city;
    String state;
    String pincode;
    String id;

    DeliveryAddress({
        required this.flatno,
        required this.street,
        required this.city,
        required this.state,
        required this.pincode,
        required this.id,
    });

    factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
        flatno: json["flatno"],
        street: json["street"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "flatno": flatno,
        "street": street,
        "city": city,
        "state": state,
        "pincode": pincode,
        "_id": id,
    };
}

class Product {
    String productId;
    int quantity;
    String id;

    Product({
        required this.productId,
        required this.quantity,
        required this.id,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["productId"],
        quantity: json["quantity"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "productId": productId,
        "quantity": quantity,
        "_id": id,
    };
}

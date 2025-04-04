// To parse this JSON data, do
//
//     final userOrder = userOrderFromJson(jsonString);

import 'dart:convert';

UserOrder userOrderFromJson(String str) => UserOrder.fromJson(json.decode(str));

String userOrderToJson(UserOrder data) => json.encode(data.toJson());

class UserOrder {
    String id;
    String orderId;
    String userId;
    List<Product> products;
    DateTime orderDate;
    DateTime expectedDeliveryDate;
    int totalAmount;
    int shippingAmount;
    int totalItems;
    String status;
    bool isCashOnDelivery;
    DeliveryAddress deliveryAddress;
    String invoiceId;
    String paymentStatus;
    int v;

    UserOrder({
        required this.id,
        required this.orderId,
        required this.userId,
        required this.products,
        required this.orderDate,
        required this.expectedDeliveryDate,
        required this.totalAmount,
        required this.shippingAmount,
        required this.totalItems,
        required this.status,
        required this.isCashOnDelivery,
        required this.deliveryAddress,
        required this.invoiceId,
        required this.paymentStatus,
        required this.v,
    });

    factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
        id: json["_id"],
        orderId: json["orderId"],
        userId: json["userId"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        orderDate: DateTime.parse(json["orderDate"]),
        expectedDeliveryDate: DateTime.parse(json["expectedDeliveryDate"]),
        totalAmount: json["totalAmount"],
        shippingAmount: json["shippingAmount"],
        totalItems: json["totalItems"],
        status: json["status"],
        isCashOnDelivery: json["isCashOnDelivery"],
        deliveryAddress: DeliveryAddress.fromJson(json["deliveryAddress"]),
        invoiceId: json["invoiceId"],
        paymentStatus: json["paymentStatus"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "orderId": orderId,
        "userId": userId,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "orderDate": orderDate.toIso8601String(),
        "expectedDeliveryDate": expectedDeliveryDate.toIso8601String(),
        "totalAmount": totalAmount,
        "shippingAmount": shippingAmount,
        "totalItems": totalItems,
        "status": status,
        "isCashOnDelivery": isCashOnDelivery,
        "deliveryAddress": deliveryAddress.toJson(),
        "invoiceId": invoiceId,
        "paymentStatus": paymentStatus,
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
    ProductId productId;
    int quantity;
    String id;

    Product({
        required this.productId,
        required this.quantity,
        required this.id,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: ProductId.fromJson(json["productId"]),
        quantity: json["quantity"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "productId": productId.toJson(),
        "quantity": quantity,
        "_id": id,
    };
}

class ProductId {
    String id;
    String name;
    int price;
    String category;
    String image;

    ProductId({
        required this.id,
        required this.name,
        required this.price,
        required this.category,
        required this.image,
    });

    factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
        id: json["_id"],
        name: json["name"],
        price: json["price"],
        category: json["category"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "category": category,
        "image": image,
    };
}

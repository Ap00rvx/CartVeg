// To parse this JSON data, do
//
//     final createOrderResponse = createOrderResponseFromJson(jsonString);

import 'dart:convert';

CreateOrderResponse createOrderResponseFromJson(String str) => CreateOrderResponse.fromJson(json.decode(str));

String createOrderResponseToJson(CreateOrderResponse data) => json.encode(data.toJson());

class CreateOrderResponse {
    bool success;
    Data data;
    String message;

    CreateOrderResponse({
        required this.success,
        required this.data,
        required this.message,
    });

    factory CreateOrderResponse.fromJson(Map<String, dynamic> json) => CreateOrderResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
    };
}

class Data {
    Order order;
    Invoice invoice;

    Data({
        required this.order,
        required this.invoice,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        order: Order.fromJson(json["order"]),
        invoice: Invoice.fromJson(json["invoice"]),
    );

    Map<String, dynamic> toJson() => {
        "order": order.toJson(),
        "invoice": invoice.toJson(),
    };
}

class Invoice {
    String invoiceId;
    String orderId;
    UserDetails userDetails;
    int totalAmount;
    String paymentStatus;
    int shippingAmount;
    int discount;
    IngAddress billingAddress;
    IngAddress shippingAddress;
    DateTime orderDate;
    List<Item> items;
    String paymentMode;
    String id;
    int v;

    Invoice({
        required this.invoiceId,
        required this.orderId,
        required this.userDetails,
        required this.totalAmount,
        required this.paymentStatus,
        required this.shippingAmount,
        required this.discount,
        required this.billingAddress,
        required this.shippingAddress,
        required this.orderDate,
        required this.items,
        required this.paymentMode,
        required this.id,
        required this.v,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: json["invoiceId"],
        orderId: json["orderId"],
        userDetails: UserDetails.fromJson(json["userDetails"]),
        totalAmount: json["totalAmount"],
        paymentStatus: json["paymentStatus"],
        shippingAmount: json["shippingAmount"],
        discount: json["discount"],
        billingAddress: IngAddress.fromJson(json["billingAddress"]),
        shippingAddress: IngAddress.fromJson(json["shippingAddress"]),
        orderDate: DateTime.parse(json["orderDate"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        paymentMode: json["paymentMode"],
        id: json["_id"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "invoiceId": invoiceId,
        "orderId": orderId,
        "userDetails": userDetails.toJson(),
        "totalAmount": totalAmount,
        "paymentStatus": paymentStatus,
        "shippingAmount": shippingAmount,
        "discount": discount,
        "billingAddress": billingAddress.toJson(),
        "shippingAddress": shippingAddress.toJson(),
        "orderDate": orderDate.toIso8601String(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "paymentMode": paymentMode,
        "_id": id,
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

class Order {
    String orderId;
    String userId;
    List<Product> products;
    DateTime orderDate;
    DateTime expectedDeliveryDate;
    String storeId;
    int totalAmount;
    int shippingAmount;
    int totalItems;
    String status;
    bool isCashOnDelivery;
    DeliveryAddress deliveryAddress;
    String invoiceId;
    String paymentStatus;
    String id;
    int v;

    Order({
        required this.orderId,
        required this.userId,
        required this.products,
        required this.orderDate,
        required this.expectedDeliveryDate,
        required this.storeId,
        required this.totalAmount,
        required this.shippingAmount,
        required this.totalItems,
        required this.status,
        required this.isCashOnDelivery,
        required this.deliveryAddress,
        required this.invoiceId,
        required this.paymentStatus,
        required this.id,
        required this.v,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["orderId"],
        userId: json["userId"],
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        orderDate: DateTime.parse(json["orderDate"]),
        expectedDeliveryDate: DateTime.parse(json["expectedDeliveryDate"]),
        storeId: json["storeId"],
        totalAmount: json["totalAmount"],
        shippingAmount: json["shippingAmount"],
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
        "storeId": storeId,
        "totalAmount": totalAmount,
        "shippingAmount": shippingAmount,
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
    double latitude;
    double longitude;
    String id;

    DeliveryAddress({
        required this.flatno,
        required this.street,
        required this.city,
        required this.state,
        required this.pincode,
        required this.latitude,
        required this.longitude,
        required this.id,
    });

    factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
        flatno: json["flatno"],
        street: json["street"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "flatno": flatno,
        "street": street,
        "city": city,
        "state": state,
        "pincode": pincode,
        "latitude": latitude,
        "longitude": longitude,
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

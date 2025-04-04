// To parse this JSON data, do
//
//     final cartResponse = cartResponseFromJson(jsonString);

import 'dart:convert';

import 'package:cart_veg/model/product_model.dart';

Cart cartResponseFromJson(String str) => Cart.fromJson(json.decode(str));

String cartResponseToJson(Cart data) => json.encode(data.toJson());

class Cart {
    String msg;
    List<CartItem> items;
    int totalItems;
    int totalAmount;

    Cart({
        required this.msg,
        required this.items,
        required this.totalItems,
        required this.totalAmount,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        msg: json["msg"],
        items: List<CartItem>.from(json["cart"].map((x) => CartItem.fromJson(x))),
        totalItems: json["totalItems"],
        totalAmount: json["totalAmount"],
    );

    Map<String, dynamic> toJson() => {
        "msg": msg,
        "cart": List<dynamic>.from(items.map((x) => x.toJson())),
        "totalItems": totalItems,
        "totalAmount": totalAmount,
    };
}

class CartItem {
    Product product;
    String name;
    int price;
    int quantity;
    String image;
    int actualPrice;
    int totalPrice;

    CartItem({
        required this.product,
        required this.name,
        required this.price,
        required this.quantity,
        required this.image,
        required this.actualPrice,
        required this.totalPrice,
    });

    factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json["product"]),
        name: json["name"],
        price: json["price"],
        quantity: json["quantity"],
        image: json["image"],
        actualPrice: json["actualPrice"],
        totalPrice: json["totalPrice"],
    );

    Map<String, dynamic> toJson() => {
        "product": product.toJson(),
        "name": name,
        "price": price,
        "quantity": quantity,
        "image": image,
        "actualPrice": actualPrice,
        "totalPrice": totalPrice,
    };
}

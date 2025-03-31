// To use this model, you'll need to parse the JSON response
// using the fromJson factory constructors

class ProductResponse {
  final int statusCode;
  final String message;
  final ProductData data;

  ProductResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      data: ProductData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProductData {
  final List<Product> products;
  final Pagination pagination;

  ProductData({
    required this.products,
    required this.pagination,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      products: List<Product>.from(
        json['products'].map((x) => Product.fromJson(x)),
      ),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((x) => x.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String origin;
  final String shelfLife;
  final bool isAvailable;
  final String image;
  final int v;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int threshold;
  final double actualPrice;
  final String? unit;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.origin,
    required this.shelfLife,
    required this.isAvailable,
    required this.image,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
    required this.threshold,
    required this.actualPrice,
    this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      category: json['category'],
      origin: json['origin'],
      shelfLife: json['shelfLife'],
      isAvailable: json['isAvailable'],
      image: json['image'],
      v: json['__v'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      threshold: json['threshold'],
      actualPrice: json['actualPrice'].toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'origin': origin,
      'shelfLife': shelfLife,
      'isAvailable': isAvailable,
      'image': image,
      '__v': v,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'threshold': threshold,
      'actualPrice': actualPrice,
      'unit': unit,
    };
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalProducts;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalProducts,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalProducts: json['totalProducts'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalProducts': totalProducts,
      'limit': limit,
    };
  }
}
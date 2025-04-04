class SearchProductModel {
  final String id;
  final String name;
  final String image;

  SearchProductModel(
      {required this.id, required this.name, required this.image});

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {

    return SearchProductModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class DataResponse {
  Map<String, List<Category>>? graph;
  List<Category>? total;

  DataResponse({this.graph, this.total});

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<Category>>? graphMap;
    if (json['data'] != null && json['data']['graph'] != null) {
      graphMap = {};
      json['data']['graph'].forEach((key, value) {
        graphMap![key] = (value as List).map((item) => Category.fromJson(item)).toList();
      });
    }

    List<Category>? totalList;
    if (json['data'] != null && json['data']['total'] != null) {
      totalList = (json['data']['total'] as List).map((item) => Category.fromJson(item)).toList();
    }

    return DataResponse(graph: graphMap, total: totalList);
  }
}

class Category {
  int categoryId;
  String categoryName;
  int totalProduct;
  int inStock;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.totalProduct,
    required this.inStock,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      totalProduct: json['totalProduct'],
      inStock: json['inStock'],
    );
  }
}
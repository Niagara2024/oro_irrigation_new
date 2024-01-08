class DashboardModel {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int siteId;
  final String siteName;
  final String categoryName;
  final String modelName;
  final List<String> categoryList;
  List<NodeModel> nodeList;

  DashboardModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.siteId,
    required this.siteName,
    required this.categoryName,
    required this.modelName,
    required this.categoryList,
    required this.nodeList,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    var categoryListJson = json['categoryList'] as List?;
    List<String> categoryList = categoryListJson != null
        ? List<String>.from(categoryListJson)
        : [];
    var nodeList = json['nodeList'] as List;
    List<NodeModel> nodes = nodeList.map((node) => NodeModel.fromJson(node)).toList();

    return DashboardModel(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      siteId: json['siteId'],
      siteName: json['siteName'],
      categoryName: json['categoryName'],
      modelName: json['modelName'],
      categoryList: categoryList,
      nodeList: nodes,
    );
  }
}

class NodeModel {
  final int controllerId;
  final String modelName;
  final String categoryName;
  final String deviceId;
  final String deviceName;
  final int referenceNumber;
  double SVolt;
  double BatVolt;
  int RlyStatus;
  int Sensor;
  int Status;

  NodeModel({
    required this.controllerId,
    required this.modelName,
    required this.categoryName,
    required this.deviceId,
    required this.deviceName,
    required this.referenceNumber,
    required this.SVolt,
    required this.BatVolt,
    required this.RlyStatus,
    required this.Sensor,
    required this.Status,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      controllerId: json['controllerId'],
      modelName: json['modelName'],
      categoryName: json['categoryName'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      referenceNumber: json['referenceNumber'],
      SVolt: json['SVolt'] ?? 0,
      BatVolt: json['BatVolt'] ?? 0,
      RlyStatus: json['RlyStatus'] ?? 0,
      Sensor: json['Sensor'] ?? 0,
      Status: json['Status'] ?? 0,
    );
  }
}
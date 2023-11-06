class ProductListWithNode
{
  ProductListWithNode({
    this.userId = 0,
    this.dealerId = 0,
    this.productId = 0,
    this.groupId = 0,
    this.groupName = '',
    this.categoryName = '',
    this.deviceId = '',
    this.productDescription = '',
    this.modelName = '',
    this.modelDescription = '',
    this.userDeviceListId = 0,
  });

  int userId, dealerId, productId, groupId, userDeviceListId;
  String groupName, categoryName, productDescription, modelName, modelDescription, deviceId;


  factory ProductListWithNode.fromJson(Map<String, dynamic> json) => ProductListWithNode(
    userId: json['userId'],
    dealerId: json['dealerId'],
    productId: json['productId'],
    groupId: json['groupId'],
    groupName: json['groupName'],
    categoryName: json['categoryName'],
    deviceId: json['deviceId'],
    productDescription: json['productDescription'],
    modelName: json['modelName'],
    modelDescription: json['modelDescription'],
    userDeviceListId: json['userDeviceListId'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'dealerId': dealerId,
    'productId': productId,
    'groupId': groupId,
    'groupName': groupName,
    'categoryName': categoryName,
    'deviceId': deviceId,
    'productDescription': productDescription,
    'modelName': modelName,
    'modelDescription': modelDescription,
    'userDeviceListId': userDeviceListId,
  };
}

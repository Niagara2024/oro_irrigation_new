class DashboardNode
{
  int controllerId, referenceNumber;
  String modelName, categoryName, deviceId, deviceName;

  DashboardNode({
    this.controllerId = 0,
    this.referenceNumber = 0,
    this.modelName = '',
    this.categoryName ='',
    this.deviceId = '',
    this.deviceName ='',
  });

  factory DashboardNode.fromJson(Map<String, dynamic> json) => DashboardNode(
    controllerId: json['controllerId'],
    referenceNumber: json['referenceNumber'],
    modelName: json['modelName'],
    categoryName: json['categoryName'],
    deviceId: json['deviceId'],
    deviceName: json['deviceName'],
  );

}
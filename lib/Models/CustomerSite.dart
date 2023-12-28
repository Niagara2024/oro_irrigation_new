class CustomerSite
{
  CustomerSite({
    this.controllerId = 0,
    this.siteId = 0,
    this.deviceId = '',
    this.deviceName = '',
    this.siteName = '',
    this.categoryName = '',
    this.modelName = '',
  });

  int controllerId, siteId;
  String deviceId, deviceName, siteName, categoryName, modelName;

  factory CustomerSite.fromJson(Map<String, dynamic> json) => CustomerSite(
    controllerId: json['controllerId'],
    siteId: json['siteId']??'',
    deviceId: json['deviceId'],
    deviceName: json['deviceName'],
    siteName: json['siteName'],
    categoryName: json['categoryName'],
    modelName: json['modelName'],
  );

  Map<String, dynamic> toJson() => {
    'controllerId': controllerId,
    'siteId': siteId,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'siteName': siteName,
    'categoryName': categoryName,
    'modelName': modelName,
  };
}

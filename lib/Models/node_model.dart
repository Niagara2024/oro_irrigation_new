class NodeModel
{
  int userDeviceListId,productId, categoryId, modelId, productStatus, communicationMode, warrantyMonths, referenceNumber,serialNumber, interfaceTypeId, relayCount;
  String categoryName, modelName, productDescription, dateOfManufacturing, interface, interfaceInterval, deviceId, active;

  NodeModel({
    this.userDeviceListId = 0,
    this.productId = 0,
    this.categoryId = 0,
    this.categoryName ='',
    this.modelId = 0,
    this.modelName ='',
    this.deviceId = '',
    this.productDescription = '',
    this.dateOfManufacturing = '',
    this.warrantyMonths = 0,
    this.productStatus = 0,
    this.communicationMode = 0,
    this.referenceNumber = 0,
    this.serialNumber = 0,
    this.interface = '',
    this.interfaceInterval = '',
    this.interfaceTypeId = 0,
    this.relayCount = 0,
    this.active = '',
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
    userDeviceListId: json['userDeviceListId'],
    productId: json['productId'],
    categoryId: json['categoryId'],
    categoryName: json['categoryName'],
    modelId: json['modelId'],
    modelName: json['modelName'],
    deviceId: json['deviceId'],
    productDescription: json['productDescription'],
    dateOfManufacturing: json['dateOfManufacturing'],
    warrantyMonths: json['warrantyMonths'],
    productStatus: json['productStatus'],
    communicationMode: json['communicationMode'],
    referenceNumber: json['referenceNumber'],
    serialNumber: json['serialNumber'],
    interface: json['interface'],
    interfaceInterval: json['interfaceInterval'],
    interfaceTypeId: json['interfaceTypeId'],
    relayCount: json['relayCount'],
    active: json['active'],
  );

}
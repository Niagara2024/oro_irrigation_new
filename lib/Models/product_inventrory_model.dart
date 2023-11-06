class ProductListModel
{
  ProductListModel({
    this.productId = 0,
    this.categoryId = 0,
    this.categoryName ='',
    this.modelId = 0,
    this.modelName ='',
    this.deviceId = '',
    this.productDescription = '',
    this.dateOfManufacturing = '',
    this.warrentyMonths = 0,
    this.productStatus = 0,
    this.communicationMode = 0,
    this.latestBuyer = '',
    this.active = '',
  });


  int productId, categoryId, modelId, productStatus, communicationMode, warrentyMonths;
  String categoryName, modelName, productDescription, dateOfManufacturing, latestBuyer,deviceId, active;

  factory ProductListModel.fromJson(Map<String, dynamic> json) => ProductListModel(
    productId: json['productId'],
    categoryId: json['categoryId'],
    categoryName: json['categoryName'],
    modelId: json['modelId'],
    modelName: json['modelName'],
    deviceId: json['deviceId'],
    productDescription: json['productDescription'],
    dateOfManufacturing: json['dateOfManufacturing'],
    warrentyMonths: json['warrentyMonths'],
    productStatus: json['productStatus'],
    communicationMode: json['communicationMode'],
    latestBuyer: json['latestBuyer'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'modelId': modelId,
    'modelName': modelName,
    'deviceId': deviceId,
    'productDescription': productDescription,
    'dateOfManufacturing': dateOfManufacturing,
    'warrentyMonths': warrentyMonths,
    'productStatus': productStatus,
    'communicationMode': communicationMode,
    'latestBuyer': latestBuyer,
    'active': active,
  };
}
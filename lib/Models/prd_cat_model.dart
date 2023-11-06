class PrdCateModel
{
  PrdCateModel({
    this.categoryId = 0,
    this.categoryName = '',
    this.smsFormat = '',
    this.relayCount = 0,
    this.active = '',
  });

  int categoryId, relayCount;
  String categoryName, smsFormat, active;

  factory PrdCateModel.fromJson(Map<String, dynamic> json) => PrdCateModel(
    categoryId: json['categoryId'],
    categoryName: json['categoryName'],
    smsFormat: json['smsFormat'],
    relayCount: json['relayCount'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'smsFormat': smsFormat,
    'relayCount': relayCount,
    'active': active,
  };
}
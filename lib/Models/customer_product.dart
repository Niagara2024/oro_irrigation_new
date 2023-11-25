class CustomerProductModel
{
  int prdId, prdStatus;
  String catName, model, buyer, imei, groupName, lastModified;

  CustomerProductModel({
    this.prdId = 0,
    this.prdStatus = 0,
    this.catName ='',
    this.model = '',
    this.imei = '',
    this.buyer = '',
    this.groupName = '',
    this.lastModified = '',

  });

  factory CustomerProductModel.fromJson(Map<String, dynamic> json) => CustomerProductModel(
    prdId: json['prdId'],
    prdStatus: json['prdStatus'],
    catName: json['catName'],
    model: json['model'],
    imei: json['imei'],
    buyer: json['buyer'],
    groupName: json['groupName']??'',
    lastModified: json['lastModified'],
  );

}
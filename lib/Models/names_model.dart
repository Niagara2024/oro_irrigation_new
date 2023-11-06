class NamesModel {
  int? nameTypeId;
  String? nameDescription;
  List<dynamic>? userName;

  NamesModel({
    this.nameTypeId,
    this.nameDescription,
    this.userName,
  });

  factory NamesModel.fromJson(Map<String, dynamic> json) => NamesModel(
    nameTypeId: json["nameTypeId"],
    nameDescription: json["nameDescription"],
    userName: json["userName"],
  );

  Map<String, dynamic> toJson() => {
    'nameTypeId': nameTypeId,
    'nameDescription': nameDescription,
    'userName': userName,
  };
}
import 'dart:convert';

SelectionModel selectionModelFromJson(String str) => SelectionModel.fromJson(json.decode(str));

String selectionModelToJson(SelectionModel data) => json.encode(data.toJson());

class SelectionModel {
  int? code;
  String? message;
  Data? data;

  SelectionModel({
    this.code,
    this.message,
    this.data,
  });

  factory SelectionModel.fromJson(Map<String, dynamic> json) => SelectionModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<NameData>? irrigationPump;
  List<NameData>? mainValve;
  List<NameData>? centralFertilizerSite;
  List<NameData>? localFertilizer;
  List<NameData>? centralFilterSite;
  List<NameData>? localFilter;

  Data({
    this.irrigationPump,
    this.mainValve,
    this.centralFertilizerSite,
    this.localFertilizer,
    this.centralFilterSite,
    this.localFilter,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    irrigationPump: json["irrigationPump"] == null ? [] : List<NameData>.from(json["irrigationPump"]!.map((x) => NameData.fromJson(x))),
    mainValve: json["mainValve"] == null ? [] : List<NameData>.from(json["mainValve"]!.map((x) => NameData.fromJson(x))),
    centralFertilizerSite: json["centralFertilizerSite"] == null ? [] : List<NameData>.from(json["centralFertilizerSite"]!.map((x) => NameData.fromJson(x))),
    localFertilizer: json["localFertilizer"] == null ? [] : List<NameData>.from(json["localFertilizer"]!.map((x) => NameData.fromJson(x))),
    centralFilterSite: json["centralFilterSite"] == null ? [] : List<NameData>.from(json["centralFilterSite"]!.map((x) => NameData.fromJson(x))),
    localFilter: json["localFilter"] == null ? [] : List<NameData>.from(json["localFilter"]!.map((x) => NameData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "irrigationPump": irrigationPump == null ? [] : List<dynamic>.from(irrigationPump!.map((x) => x.toJson())),
    "mainValve": mainValve == null ? [] : List<dynamic>.from(mainValve!.map((x) => x.toJson())),
    "centralFertilizerSite": centralFertilizerSite == null ? [] : List<dynamic>.from(centralFertilizerSite!.map((x) => x.toJson())),
    "localFertilizer": localFertilizer == null ? [] : List<dynamic>.from(localFertilizer!.map((x) => x.toJson())),
    "centralFilterSite": centralFilterSite == null ? [] : List<dynamic>.from(centralFilterSite!.map((x) => x.toJson())),
    "localFilter": localFilter == null ? [] : List<dynamic>.from(localFilter!.map((x) => x.toJson())),
  };
}

class NameData {
  int? sNo;
  String? id;
  String? location;
  String? name;
  bool? selected;

  NameData({
    this.sNo,
    this.id,
    this.location,
    this.name,
    this.selected,
  });

  factory NameData.fromJson(Map<String, dynamic> json) =>
      NameData(
        sNo: json["sNo"],
        id: json["id"],
        location: json["location"],
        name: json["name"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() =>
      {
        "sNo": sNo,
        "id": id,
        "location": location,
        "name": name,
        "selected": selected,
      };
}
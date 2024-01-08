class ProgramServiceDevices {
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<CentralFertilizerSite> centralFertilizerSite;
  List<dynamic> centralFertilizer;
  List<dynamic> localFertilizer;
  List<CentralFilterSite> centralFilterSite;
  List<dynamic> localFilter;

  ProgramServiceDevices({
    required this.irrigationPump,
    required this.mainValve,
    required this.centralFertilizerSite,
    required this.centralFertilizer,
    required this.localFertilizer,
    required this.centralFilterSite,
    required this.localFilter,
  });

  factory ProgramServiceDevices.fromJson(Map<String, dynamic> json) {
    return ProgramServiceDevices(
      irrigationPump: List<IrrigationPump>.from(
          json['irrigationPump'].map((x) => IrrigationPump.fromJson(x))),
      mainValve: List<MainValve>.from(
          json['mainValve'].map((x) => MainValve.fromJson(x))),
      centralFertilizerSite: List<CentralFertilizerSite>.from(
          json['centralFertilizerSite']
              .map((x) => CentralFertilizerSite.fromJson(x))),
      centralFertilizer: List<dynamic>.from(json['centralFertilizer']),
      localFertilizer: List<dynamic>.from(json['localFertilizer']),
      centralFilterSite: List<CentralFilterSite>.from(
          json['centralFilterSite']
              .map((x) => CentralFilterSite.fromJson(x))),
      localFilter: List<dynamic>.from(json['localFilter']),
    );
  }
}

class IrrigationPump {
  int sNo;
  String id;
  String location;
  String name;
  int status;

  IrrigationPump({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
    required this.status,
  });

  factory IrrigationPump.fromJson(Map<String, dynamic> json) {
    return IrrigationPump(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class MainValve {
  int sNo;
  String id;
  String location;
  String name;
  int status;

  MainValve({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
    required this.status,
  });

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class CentralFertilizerSite {
  int sNo;
  String id;
  String location;
  String name;
  int status;

  CentralFertilizerSite({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
    required this.status,
  });

  factory CentralFertilizerSite.fromJson(Map<String, dynamic> json) {
    return CentralFertilizerSite(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class CentralFilterSite {
  int sNo;
  String id;
  String location;
  String name;
  int status;

  CentralFilterSite({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
    required this.status,
  });

  factory CentralFilterSite.fromJson(Map<String, dynamic> json) {
    return CentralFilterSite(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      status: json['status'],
    );
  }
}
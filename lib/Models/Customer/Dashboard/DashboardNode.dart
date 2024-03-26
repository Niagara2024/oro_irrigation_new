class DashboardModel {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int siteId;
  final String siteName;
  final String categoryName;
  final String modelName;
  List<NodeModel> nodeList;
  List<CurrentProgram> currentProgram;
  List<NextProgram> nextProgram;
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<CentralFertilizerSite> centralFertilizerSite;
  List<dynamic> localFertilizer;
  List<FilterModel> centralFilterSite;
  List<dynamic> localFilter;
  List<Agitator> agitator;

  DashboardModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.siteId,
    required this.siteName,
    required this.categoryName,
    required this.modelName,
    required this.nodeList,
    required this.currentProgram,
    required this.nextProgram,
    required this.irrigationPump,
    required this.mainValve,
    required this.centralFertilizerSite,
    required this.localFertilizer,
    required this.centralFilterSite,
    required this.localFilter,
    required this.agitator,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {

    var nodeList = json['nodeList'] as List;
    List<NodeModel> nodes = nodeList.isNotEmpty? nodeList.map((node) => NodeModel.fromJson(node)).toList() : [];

    var currentProgram = json['currentSchedule'] as List;
    List<CurrentProgram> cProgram = nodeList.isNotEmpty? currentProgram.map((crProgram) => CurrentProgram.fromJson(crProgram)).toList() : [];

    var nextProgram = json['nextSchedule'] as List;
    List<NextProgram> nxtProgram = nodeList.isNotEmpty? nextProgram.map((nxtProgram) => NextProgram.fromJson(nxtProgram)).toList() : [];

    return DashboardModel(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      siteId: json['siteId'],
      siteName: json['siteName'],
      categoryName: json['categoryName'],
      modelName: json['modelName'],
      nodeList: nodes,
      currentProgram: cProgram,
      nextProgram: nxtProgram,
      irrigationPump: List<IrrigationPump>.from(json['irrigationPump'].map((x) => IrrigationPump.fromJson(x))),
      mainValve: List<MainValve>.from(json['mainValve'].map((x) => MainValve.fromJson(x))),
      centralFertilizerSite: List<CentralFertilizerSite>.from(json['centralFertilizerSite'].map((x) => CentralFertilizerSite.fromJson(x))),
      localFertilizer: List<dynamic>.from(json['localFertilizer']),
      centralFilterSite: List<FilterModel>.from(json['centralFilterSite'].map((x) => FilterModel.fromJson(x))),
      localFilter: List<dynamic>.from(json['localFilter']),
      agitator: List<Agitator>.from(json['agitator'].map((x) => Agitator.fromJson(x))),
    );

  }
}

class NodeModel {
  final int controllerId, serialNumber;
  final String modelName;
  final String categoryName;
  final String deviceId;
  final String deviceName;
  final int referenceNumber;
  double slrVolt;
  double batVolt;
  List<dynamic> rlyStatus;
  List<dynamic> sensor;
  int status;

  NodeModel({
    required this.controllerId,
    required this.serialNumber,
    required this.modelName,
    required this.categoryName,
    required this.deviceId,
    required this.deviceName,
    required this.referenceNumber,
    required this.slrVolt,
    required this.batVolt,
    required this.rlyStatus,
    required this.sensor,
    required this.status,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {

    return NodeModel(
      controllerId: json['controllerId'],
      serialNumber: json['serialNumber'],
      modelName: json['modelName'],
      categoryName: json['categoryName'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      referenceNumber: json['referenceNumber'],
      slrVolt: json['SVolt'] ?? 0.0,
      batVolt: json['BatVolt'] ?? 0.0,
      rlyStatus: json['RlyStatus'] ?? [],
      sensor: json['Sensor'] ?? [],
      status: json['Status'] ?? 0,
    );
  }
}

class CurrentProgram {
  final String programName, programCategory,zoneName,startTime, duration_Qty, duration_QtyCompleted;
  String duration_QtyLeft;
  final int programId, programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone;
  List<dynamic> valve;

  CurrentProgram({
    required this.programId,
    required this.programName,
    required this.programCategory,
    required this.zoneName,
    required this.programType,
    required this.totalRtc,
    required this.currentRtc,
    required this.totalCycle,
    required this.currentCycle,
    required this.totalZone,
    required this.currentZone,
    required this.startTime,
    required this.duration_Qty,
    required this.duration_QtyCompleted,
    required this.duration_QtyLeft,
    required this.valve,
  });

  factory CurrentProgram.fromJson(Map<String, dynamic> json) {
    return CurrentProgram(
      programId: 1,
      programName: json['ProgName'] ?? "",
      programCategory: json['ProgCategory'] ?? "",
      zoneName: json['ZoneName'] ?? "",
      programType: json['ProgType'] ?? 0,
      totalRtc: json['TotalRtc'] ?? 0,
      currentRtc: json['CurrentRtc'] ?? 0,
      totalCycle: json['TotalCycle'] ?? 0,
      currentCycle: json['CurrentCycle'] ?? 0,
      totalZone: json['TotalZone'] ?? 0,
      currentZone: json['CurrentZone'] ?? 0,
      startTime: json['StartTime'] ?? "",
      duration_Qty: json['Duration_Qty'] ?? "",
      duration_QtyCompleted: json['Duration_QtyCompleted'] ?? "",
      duration_QtyLeft: json['Duration_QtyLeft'] ?? "",
      valve: json['Valve'] ?? [],
    );
  }

}

class NextProgram {
  final String programName, programCategory,zoneName,startTime;
  final int programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone;

  NextProgram({
    required this.programName,
    required this.programCategory,
    required this.zoneName,
    required this.programType,
    required this.totalRtc,
    required this.currentRtc,
    required this.totalCycle,
    required this.currentCycle,
    required this.totalZone,
    required this.currentZone,
    required this.startTime,
  });

  factory NextProgram.fromJson(Map<String, dynamic> json) {
    return NextProgram(
      programName: json['ProgName'] ?? "",
      programCategory: json['ProgCategory'] ?? "",
      zoneName: json['ZoneName'] ?? "",
      programType: json['ProgType'] ?? 0,
      totalRtc: json['TotalRtc'] ?? 0,
      currentRtc: json['CurrentRtc'] ?? 0,
      totalCycle: json['TotalCycle'] ?? 0,
      currentCycle: json['CurrentCycle'] ?? 0,
      totalZone: json['TotalZone'] ?? 0,
      currentZone: json['CurrentZone'] ?? 0,
      startTime: json['StartTime'] ?? "",
    );
  }

}

class RelayStatus {
  final String? name;
  final int? rlyNo;
  final int? status;

  RelayStatus({
    required this.name,
    required this.rlyNo,
    required this.status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      name: json['Name'],
      rlyNo: json['RlyNo'],
      status: json['Status'],
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

  CentralFertilizerSite({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
  });

  factory CentralFertilizerSite.fromJson(Map<String, dynamic> json) {

    return CentralFertilizerSite(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
    );
  }
}

class FilterModel {
  int sNo;
  String id;
  String name;
  String location;
  List<Filters> filter;

  FilterModel({required this.sNo, required this.id, required this.name, required this.location, required this.filter});
  factory FilterModel.fromJson(Map<String, dynamic> json) {

    var filterList = json['filter'] as List;
    List<Filters> filter = filterList.map((filter) => Filters.fromJson(filter)).toList();

    return FilterModel(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      filter: filter,
    );
  }
}

class Filters {
  int sNo;
  String id;
  String name;
  String location;
  int status;

  Filters({required this.sNo, required this.id, required this.name, required this.location,
    required this.status});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      status: json['status'],
    );
  }
}

class Agitator {
  int sNo;
  String id;
  String name;
  String location;
  int status;

  Agitator({required this.sNo, required this.id, required this.name, required this.location,
    required this.status});

  factory Agitator.fromJson(Map<String, dynamic> json) {
    return Agitator(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      status: json['status'],
    );
  }
}
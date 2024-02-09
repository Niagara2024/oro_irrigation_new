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
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {

    var nodeList = json['nodeList'] as List;
    List<NodeModel> nodes = nodeList.isNotEmpty? nodeList.map((node) => NodeModel.fromJson(node)).toList() : [];

    var currentProgram = json['currentProgram'] as List;
    List<CurrentProgram> cProgram = nodeList.isNotEmpty? currentProgram.map((crProgram) => CurrentProgram.fromJson(crProgram)).toList() : [];

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
  //List<dynamic> sensor;
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
    //required this.sensor,
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
      //sensor: sensor,
      status: json['Status'] ?? 0,
    );
  }
}


class CurrentProgram {
  final String programName, programCategory,zoneName,startTime;
  final int programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone;

  CurrentProgram({
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

  factory CurrentProgram.fromJson(Map<String, dynamic> json) {
    return CurrentProgram(
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

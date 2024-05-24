
class DashboardModel {
  final int userGroupId;
  final String groupName;
  final String active;
  List<MasterData> master;

  DashboardModel({
    required this.userGroupId,
    required this.groupName,
    required this.active,
    required this.master,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {

    var masterList = json['master'] as List;
    List<MasterData> master = masterList.isNotEmpty? masterList.map((master) => MasterData.fromJson(master)).toList() : [];

    return DashboardModel(
      userGroupId: json['userGroupId'],
      groupName: json['groupName'],
      active: json['active'],
      master: master,
    );
  }
}

class MasterData {
  List<LiveData> liveData;
  List<IrrigationLine> irrigationLine;
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  String liveSyncDate;
  String liveSyncTime;

  MasterData({
    required this.liveData,
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.liveSyncDate,
    required this.liveSyncTime,
    required this.irrigationLine,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {

    if(json['categoryId']==1){
      //drip irrigation controller
      var liveData = json['2400'] as List;
      List<LiveData> liveList = liveData.isNotEmpty? liveData.map((live) => LiveData.fromJson(live)).toList() : [];

      var irrigationLine = json['irrigationLine'] as List;
      List<IrrigationLine> irgLine = irrigationLine.isNotEmpty? irrigationLine.map((irl) => IrrigationLine.fromJson(irl)).toList() : [];

      return MasterData(
        controllerId: json['controllerId'],
        deviceId: json['deviceId'],
        deviceName: json['deviceName'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        modelId: json['modelId'],
        modelName: json['modelName'],
        liveSyncDate: json['liveSyncDate'] ?? '',
        liveSyncTime: json['liveSyncTime'] ?? '',
        liveData: liveList,
        irrigationLine: irgLine,
      );
    }else{
      //pump controller
      return MasterData(
        controllerId: json['controllerId'],
        deviceId: json['deviceId'],
        deviceName: json['deviceName'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        modelId: json['modelId'],
        modelName: json['modelName'],
        liveSyncDate: json['liveSyncDate'] ?? '',
        liveSyncTime: json['liveSyncTime'] ?? '',
        liveData: [],
        irrigationLine: [],
      );
    }
  }

}

class LiveData {
  List<NodeData> nodeList;
  List<PumpData> sourcePumps;  // For Type 1 pumps
  List<PumpData> irrigationPumps;  // For Type 2 pumps

  LiveData({
    required this.nodeList,
    required this.sourcePumps,
    required this.irrigationPumps,
  });

  factory LiveData.fromJson(Map<String, dynamic> json) {
    var nodeData = json['2401'] as List;
    List<NodeData> nodeList = nodeData.isNotEmpty? nodeData.map((node) => NodeData.fromJson(node)).toList(): [];

    var pumpData = json['2407'] as List;
    List<PumpData> pumpList = pumpData.isNotEmpty? pumpData.map((pmp) => PumpData.fromJson(pmp)).toList(): [];

    List<PumpData> sourcePumps = [];
    List<PumpData> irrigationPumps = [];

    for (var pump in pumpList) {
      if (pump.Type == 1) {
        sourcePumps.add(pump);
      } else if (pump.Type == 2) {
        irrigationPumps.add(pump);
      }
    }

    return LiveData(
      nodeList: nodeList,
      sourcePumps: sourcePumps,
      irrigationPumps: irrigationPumps,
    );
  }
}


class NodeData {
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  int serialNumber;
  int referenceNumber;
  double SVolt;
  double BatVolt;
  List<RelayStatus> RlyStatus;
  List<SensorStatus> Sensor;
  int Status;

  NodeData({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.serialNumber,
    required this.referenceNumber,
    required this.SVolt,
    required this.BatVolt,
    required this.RlyStatus,
    required this.Sensor,
    required this.Status,
  });

  factory NodeData.fromJson(Map<String, dynamic> json) {

    var rlyStatusList = json['RlyStatus'] as List;
    List<RelayStatus> rlyStatus = rlyStatusList.map((rlyStatus) => RelayStatus.fromJson(rlyStatus)).toList();

    var sensorList = json['Sensor'] as List;
    List<SensorStatus> sensor = sensorList.map((sensor) => SensorStatus.fromJson(sensor)).toList();

    return NodeData(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      serialNumber: json['serialNumber'],
      referenceNumber: json['referenceNumber'],
      SVolt: json['SVolt'],
      BatVolt: json['BatVolt'],
      RlyStatus: rlyStatus,
      Sensor: sensor,
      Status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'serialNumber': serialNumber,
      'referenceNumber': referenceNumber,
      'SVolt': SVolt,
      'BatVolt': BatVolt,
      'RlyStatus': RlyStatus,
      'Sensor': Sensor,
      'Status': Status,
    };
  }
}

class PumpData {
  int Type;
  String Name;
  String Location;
  int Status;
  int Reason;
  List<dynamic> Watermeter;
  List<dynamic> Pressure;
  List<dynamic> Level;
  List<dynamic> Float;
  String OnDelay;
  String OnDelayCompleted;
  String OnDelayLeft;
  String Program;

  PumpData({
    required this.Type,
    required this.Name,
    required this.Location,
    required this.Status,
    required this.Reason,
    required this.Watermeter,
    required this.Pressure,
    required this.Level,
    required this.Float,
    required this.OnDelay,
    required this.OnDelayCompleted,
    required this.OnDelayLeft,
    required this.Program,
  });

  factory PumpData.fromJson(Map<String, dynamic> json) {
    return PumpData(
      Type: json['Type'],
      Name: json['Name'],
      Location: json['Location'],
      Status: json['Status'],
      Reason: json['Reason'],
      Watermeter: json['Watermeter'],
      Pressure: json['Pressure'],
      Level: json['Level'],
      Float: json['Float'],
      OnDelay: json['OnDelay'],
      OnDelayCompleted: json['OnDelayCompleted'],
      OnDelayLeft: json['OnDelayLeft'],
      Program: json['Program'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': Type,
      'Name': Name,
      'Location': Location,
      'Status': Status,
      'Reason': Reason,
      'Watermeter': Watermeter,
      'Pressure': Pressure,
      'Level': Level,
      'Float': Float,
      'OnDelay': OnDelay,
      'OnDelayCompleted': OnDelayCompleted,
      'OnDelayLeft': OnDelayLeft,
      'Program': Program,
    };
  }
}

class SensorData {
  int S_No;
  String Line;
  String PrsIn;
  String PrsOut;
  String DpValue;
  String Watermeter;
  int IrrigationPauseFlag;
  int DosingPauseFlag;

  SensorData({
    required this.S_No,
    required this.Line,
    required this.PrsIn,
    required this.PrsOut,
    required this.DpValue,
    required this.Watermeter,
    required this.IrrigationPauseFlag,
    required this.DosingPauseFlag,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      S_No: json['S_No'],
      Line: json['Line'],
      PrsIn: json['PrsIn'],
      PrsOut: json['PrsOut'],
      DpValue: json['DpValue'],
      Watermeter: json['Watermeter'],
      IrrigationPauseFlag: json['IrrigationPauseFlag'],
      DosingPauseFlag: json['DosingPauseFlag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'S_No': S_No,
      'Line': Line,
      'PrsIn': PrsIn,
      'PrsOut': PrsOut,
      'DpValue': DpValue,
      'Watermeter': Watermeter,
      'IrrigationPauseFlag': IrrigationPauseFlag,
      'DosingPauseFlag': DosingPauseFlag,
    };
  }
}

class IrrigationLine {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  List<MainValve> mainValve;
  List<Valve> valve;
  //List<PressureSensor> pressureSensor;

  IrrigationLine({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.mainValve,
    required this.valve,
    //required this.pressureSensor,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {

    var mainValve = json['mainValve'] as List;
    List<MainValve> mainValveList = mainValve.isNotEmpty? mainValve.map((mv) => MainValve.fromJson(mv)).toList() : [];

    var valveData = json['valve'] as List;
    List<Valve> valveDataList = valveData.isNotEmpty? valveData.map((vl) => Valve.fromJson(vl)).toList() : [];

    return IrrigationLine(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      mainValve: mainValveList,
      valve: valveDataList,
      //pressureSensor: (json['pressureSensor'] as List).map((i) => PressureSensor.fromJson(i)).toList(),
    );
  }

}

class MainValve {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  MainValve({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class Valve {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  Valve({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class PressureSensor {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  PressureSensor({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory PressureSensor.fromJson(Map<String, dynamic> json) {
    return PressureSensor(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'hid': hid,
      'name': name,
      'location': location,
      'type': type,
      'status': status,
    };
  }
}

class RelayStatus {
  final String? Name;
  final int? RlyNo;
  final int? Status;

  RelayStatus({
    required this.Name,
    required this.RlyNo,
    required this.Status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      Name: json['Name'],
      RlyNo: json['RlyNo'],
      Status: json['Status'],
    );
  }
}

class SensorStatus {
  final String? Name;
  final String? Value;

  SensorStatus({
    required this.Name,
    required this.Value,
  });

  factory SensorStatus.fromJson(Map<String, dynamic> json) {
    return SensorStatus(
      Name: json['Name'],
      Value: json['Value'],
    );
  }
}


/*class DashboardModel {

  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int siteId;
  final String siteName;
  final String categoryName;
  final String modelName;
  List<NodeModel> nodeList;
  //List<CurrentScheduleModel> currentProgram;
  //List<NextProgram> nextProgram;
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<CentralFertilizerSite> centralFertilizerSite;
  List<dynamic> localFertilizer;
  List<FilterModel> centralFilterSite;
  List<dynamic> localFilter;
  List<Agitator> agitator;
  List<IrrigationLine> irrigationLine;

  DashboardModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.siteId,
    required this.siteName,
    required this.categoryName,
    required this.modelName,
    required this.nodeList,
    //required this.currentProgram,
    //required this.nextProgram,
    required this.irrigationPump,
    required this.mainValve,
    required this.centralFertilizerSite,
    required this.localFertilizer,
    required this.centralFilterSite,
    required this.localFilter,
    required this.agitator,
    required this.irrigationLine,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {

    var nodeList = json['nodeList'] as List;
    List<NodeModel> nodes = nodeList.isNotEmpty? nodeList.map((node) => NodeModel.fromJson(node)).toList() : [];

    //var currentProgram = json['currentSchedule'] as List;
    //List<CurrentScheduleModel> cProgram = nodeList.isNotEmpty? currentProgram.map((crProgram) => CurrentScheduleModel.fromJson(crProgram)).toList() : [];

    //var nextProgram = json['nextSchedule'] as List;
    //List<NextProgram> nxtProgram = nodeList.isNotEmpty? nextProgram.map((nxtProgram) => NextProgram.fromJson(nxtProgram)).toList() : [];

    return DashboardModel(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      siteId: json['siteId'],
      siteName: json['siteName'],
      categoryName: json['categoryName'],
      modelName: json['modelName'],
      nodeList: nodes,
      //currentProgram: cProgram,
      //nextProgram: nxtProgram,
      irrigationPump: List<IrrigationPump>.from(json['irrigationPump'].map((x) => IrrigationPump.fromJson(x))),
      mainValve: List<MainValve>.from(json['mainValve'].map((x) => MainValve.fromJson(x))),
      centralFertilizerSite: List<CentralFertilizerSite>.from(json['centralFertilizerSite'].map((x) => CentralFertilizerSite.fromJson(x))),
      localFertilizer: List<dynamic>.from(json['localFertilizer']),
      centralFilterSite: List<FilterModel>.from(json['centralFilterSite'].map((x) => FilterModel.fromJson(x))),
      localFilter: List<dynamic>.from(json['localFilter']),
      agitator: List<Agitator>.from(json['agitator'].map((x) => Agitator.fromJson(x))),
      irrigationLine: List<IrrigationLine>.from(json['irrigationLine'].map((x) => IrrigationLine.fromJson(x))),
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
  List<RelayStatus> rlyStatus;
  List<Sensor> sensor;
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

    var rlyStatusList = json['RlyStatus'] as List;
    List<RelayStatus> rlyStatus = rlyStatusList.map((rlyStatus) => RelayStatus.fromJson(rlyStatus)).toList();

    var sensorList = json['Sensor'] as List;
    List<Sensor> sensor = sensorList.map((sensor) => Sensor.fromJson(sensor)).toList();

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
      rlyStatus: rlyStatus,
      sensor: sensor,
      status: json['Status'] ?? 0,
    );
  }
}

class CurrentScheduleModel {
  final String programName, programCategory,zoneName,startTime, duration_Qty, duration_QtyCompleted;
  String duration_QtyLeft;
  final int programId, programType, totalRtc,currentRtc,totalCycle,currentCycle,totalZone,currentZone;
  List<dynamic> valve;

  CurrentScheduleModel({
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

  factory CurrentScheduleModel.fromJson(Map<String, dynamic> json) {
    return CurrentScheduleModel(
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
  final String? Name;
  final int? RlyNo;
  final int? Status;

  RelayStatus({
    required this.Name,
    required this.RlyNo,
    required this.Status,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      Name: json['Name'],
      RlyNo: json['RlyNo'],
      Status: json['Status'],
    );
  }
}

class Sensor {
  final String? Name;
  final String? Value;

  Sensor({
    required this.Name,
    required this.Value,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      Name: json['Name'],
      Value: json['Value'],
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

class IrrigationLine {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  List<MainValve> mainValve;
  List<Valve> valve;
  List<PressureSensor> pressureSensor;

  IrrigationLine({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.mainValve,
    required this.valve,
    required this.pressureSensor,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      mainValve: List<MainValve>.from(json['mainValve'].map((x) => MainValve.fromJson(x))),
      valve: List<Valve>.from(json['valve'].map((x) => Valve.fromJson(x))),
      pressureSensor: List<PressureSensor>.from(json['pressureSensor'].map((x) => PressureSensor.fromJson(x))),
    );
  }
}

class Valve {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  Valve({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }
}

class PressureSensor {
  int sNo;
  String id;
  String hid;
  String name;
  String location;
  String type;
  int status;

  PressureSensor({
    required this.sNo,
    required this.id,
    required this.hid,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
  });

  factory PressureSensor.fromJson(Map<String, dynamic> json) {
    return PressureSensor(
      sNo: json['sNo'],
      id: json['id'],
      hid: json['hid'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      status: json['status'],
    );
  }
}*/

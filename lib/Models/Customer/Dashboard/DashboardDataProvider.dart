import 'LineOrSequence.dart';

class DashboardDataProvider
{
  bool startTogether;
  String time, flow;
  int method;
  List<SourcePump> sourcePump;
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<LineOrSequence> lineOrSequence;
  List<FertilizerModel> centralFertilizerSite;
  List<FertilizerModel> localFertilizerSite;
  List<FilterModel> centralFilterSite;
  List<FilterModel> localFilterSite;
  List<Agitator> agitator;
  List<Fan> fan;
  List<Fogger> fogger;



  DashboardDataProvider({
    required this.startTogether,
    required this.time,
    required this.flow,
    required this.method,
    required this.sourcePump,
    required this.irrigationPump,
    required this.mainValve,
    required this.lineOrSequence,
    required this.centralFertilizerSite,
    required this.localFertilizerSite,
    required this.centralFilterSite,
    required this.localFilterSite,
    required this.agitator,
    required this.fan,
    required this.fogger,
  });

  factory DashboardDataProvider.fromJson(Map<String, dynamic> json) {
    bool startTogetherStatus = json['startTogether'];
    String timeVal = json['time'];
    String flowVal = json['flow'];
    int method = json['method'];
    List<SourcePump> sourcePumpList = (json['sourcePump'] as List)
        .map((sourcePumpJson) => SourcePump.fromJson(sourcePumpJson))
        .toList();

    List<IrrigationPump> irrigationPump = (json['irrigationPump'] as List)
        .map((sourcePumpJson) => IrrigationPump.fromJson(sourcePumpJson))
        .toList();

    List<MainValve> mainValve = (json['mainValve'] as List)
        .map((sourcePumpJson) => MainValve.fromJson(sourcePumpJson))
        .toList();

    List<LineOrSequence> lineOrSequence = (json['lineOrSequence'] as List)
        .map((irrigationLineJson) => LineOrSequence.fromJson(irrigationLineJson))
        .toList();

    List<FilterModel> centralFilterSite = (json['centralFilterSite'] as List)
        .map((centralFilter) => FilterModel.fromJson(centralFilter))
        .toList();

    List<FilterModel> localFilterSite = (json['localFilter'] as List)
        .map((localFilter) => FilterModel.fromJson(localFilter))
        .toList();

    List<FertilizerModel> centralFertilizerSite = (json['centralFertilizerSite'] as List)
        .map((centralFertilizer) => FertilizerModel.fromJson(centralFertilizer))
        .toList();

    List<FertilizerModel> localFertilizerSite = (json['localFertilizer'] as List)
        .map((localFertilizer) => FertilizerModel.fromJson(localFertilizer))
        .toList();

    List<Agitator> agitator = (json['agitator'] as List)
        .map((agitator) => Agitator.fromJson(agitator))
        .toList();

    List<Fan> fan = (json['fan'] as List)
        .map((fan) => Fan.fromJson(fan))
        .toList();

    List<Fogger> fogger = (json['fogger'] as List)
        .map((fogger) => Fogger.fromJson(fogger))
        .toList();

    return DashboardDataProvider(
      startTogether: startTogetherStatus,
      time: timeVal,
      flow: flowVal,
      method: method,
      sourcePump: sourcePumpList,
      mainValve: mainValve,
      lineOrSequence: lineOrSequence,
      irrigationPump: irrigationPump,
      centralFertilizerSite: centralFertilizerSite,
      localFertilizerSite: localFertilizerSite,
      centralFilterSite: centralFilterSite,
      localFilterSite: localFilterSite,
      agitator: agitator,
      fan: fan,
      fogger: fogger,
    );
  }

}

class SourcePump {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;
  SourcePump({required this.sNo, required this.id, required this.name, required this.location, required this.selected});
  factory SourcePump.fromJson(Map<String, dynamic> json) {
    return SourcePump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}

class IrrigationPump {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  IrrigationPump({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory IrrigationPump.fromJson(Map<String, dynamic> json) {
    return IrrigationPump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}

class MainValve {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  MainValve({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}

class FilterModel {
  int sNo;
  String id;
  String name;
  String location;
  List<FilterList> filter;


  FilterModel({required this.sNo, required this.id, required this.name, required this.location, required this.filter});
  factory FilterModel.fromJson(Map<String, dynamic> json) {

    var filterList = json['filter'] as List;
    List<FilterList> filter = filterList.map((filter) => FilterList.fromJson(filter)).toList();

    return FilterModel(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      filter: filter,
    );
  }
}

class FertilizerModel {
  int sNo;
  String id;
  String name;
  String location;
  List<FertilizerChanel> fertilizer;

  FertilizerModel({required this.sNo, required this.id, required this.name, required this.location, required this.fertilizer});

  factory FertilizerModel.fromJson(Map<String, dynamic> json) {

    var fertilizerList = json['fertilizer'] as List;
    List<FertilizerChanel> fertilizer = fertilizerList.map((fertilizer) => FertilizerChanel.fromJson(fertilizer)).toList();

    return FertilizerModel(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      fertilizer: fertilizer,
    );
  }
}

class FilterList {
  int sNo;
  String id;
  String name;
  String location;
  String time;
  String flow;
  bool selected;

  FilterList({required this.sNo, required this.id, required this.name, required this.location,
    required this.time, required this.flow, required this.selected});

  factory FilterList.fromJson(Map<String, dynamic> json) {
    return FilterList(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      time: json['time'],
      flow: json['flow'],
      selected: json['selected'],
    );
  }
}

class FertilizerChanel {
  int sNo;
  String id;
  String name;
  String location;
  String time;
  String flow;
  bool selected;

  FertilizerChanel({required this.sNo, required this.id, required this.name, required this.location,
    required this.time, required this.flow, required this.selected});

  factory FertilizerChanel.fromJson(Map<String, dynamic> json) {
    return FertilizerChanel(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      time: json['time'],
      flow: json['flow'],
      selected: json['selected'],
    );
  }
}

class Agitator {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  Agitator({required this.sNo, required this.id, required this.name, required this.location,
    required this.selected});

  factory Agitator.fromJson(Map<String, dynamic> json) {
    return Agitator(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}

class Fan {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  Fan({required this.sNo, required this.id, required this.name, required this.location,
    required this.selected});

  factory Fan.fromJson(Map<String, dynamic> json) {
    return Fan(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}

class Fogger {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  Fogger({required this.sNo, required this.id, required this.name, required this.location,
    required this.selected});

  factory Fogger.fromJson(Map<String, dynamic> json) {
    return Fogger(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}
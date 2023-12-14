import 'dart:convert';

class SequenceModel {
  List<dynamic> sequence;
  Default defaultData;

  SequenceModel({required this.sequence, required this.defaultData});

  factory SequenceModel.fromJson(Map<String, dynamic> json) {
    return SequenceModel(
      sequence: json['data']['sequence'] ?? [],
      defaultData: Default.fromJson(json['data']['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sequence" : sequence,
      "defaultData": defaultData.toJson()
    };
  }

  dynamic toMqtt() {
    return sequence;
  }
}

class Default {
  bool startTogether;
  bool longSequence;
  bool reuseValve;
  bool namedGroup;
  List<Line> line;
  List<Line> group;
  List<Valve> agitator;

  Default({
    required this.startTogether,
    required this.line,
    required this.group,
    required this.longSequence,
    required this.reuseValve,
    required this.namedGroup,
    required this.agitator
  });

  factory Default.fromJson(Map<String, dynamic> json) {
    List<Line> lineList = List<Line>.from(json['line'].map((x) => Line.fromJson(x)));
    List<Line> groupList = List<Line>.from(json['group'].map((x) => Line.fromJson(x)));
    List<Valve> agitatorList = List<Valve>.from(json['agitator'].map((x) => Valve.fromJson(x)));

    return Default(
      startTogether: json['startTogether'],
      longSequence: json['longSequence'],
      reuseValve: json['reuseValve'],
      namedGroup: json['namedGroup'] ?? false,
      line: lineList,
      group: groupList,
      agitator: agitatorList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "startTogether": startTogether,
      "longSequence": longSequence,
      "reuseValve": reuseValve,
      "namedGroup": namedGroup,
      "line": line.map((e) => e.toJson()).toList(),
      "group": group.map((e) => e.toJson()).toList(),
      "agitator": agitator.map((e) => e.toJson()).toList(),
    };
  }
}

class Line {
  int sNo;
  String id;
  String location;
  String name;
  List<Valve> valve;

  Line({required this.sNo, required this.id, required this.location, required this.name, required this.valve});

  factory Line.fromJson(Map<String, dynamic> json) {
    var valveList = json['valve'] as List<dynamic>?;

    List<Valve> valves = valveList != null
        ? valveList.map((e) => Valve.fromJson(e as Map<String, dynamic>)).toList()
        : [];

    return Line(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      valve: valves,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "location": location,
      "name": name,
      "valve": valve.map((e) => e.toJson()).toList(),
    };
  }
}

class Valve {
  int sNo;
  String id;
  String location;
  String name;

  Valve({required this.sNo, required this.id, required this.location, required this.name});

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sNo": sNo,
      "id": id,
      "location": location,
      "name": name,
    };
  }
}

class SampleScheduleModel {
  ScheduleAsRunListModel scheduleAsRunList;
  ScheduleByDaysModel scheduleByDays;
  String selected;
  DefaultModel defaultModel;

  SampleScheduleModel({
    required this.scheduleAsRunList,
    required this.scheduleByDays,
    required this.selected,
    required this.defaultModel,
  });

  factory SampleScheduleModel.fromJson(Map<String, dynamic> json) {
    return SampleScheduleModel(
      scheduleAsRunList: ScheduleAsRunListModel.fromJson(json['data']['schedule']['scheduleAsRunList']),
      scheduleByDays: ScheduleByDaysModel.fromJson(json['data']['schedule']['scheduleByDays']),
      selected: json['data']['schedule']['selected'],
      defaultModel: DefaultModel.fromJson(json['data']['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleAsRunList': scheduleAsRunList.toJson(),
      'scheduleByDays': scheduleByDays.toJson(),
      'selected': selected,
    };
  }
}

class ScheduleAsRunListModel {
  Map<String, dynamic> rtc;
  Map<String, dynamic> schedule;

  ScheduleAsRunListModel({
    required this.rtc,
    required this.schedule,
  });

  factory ScheduleAsRunListModel.fromJson(Map<String, dynamic> json) {
    return ScheduleAsRunListModel(
      rtc: json['rtc'],
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'schedule': schedule,
    };
  }
}

class ScheduleByDaysModel {
  Map<String, dynamic> rtc;
  Map<String, dynamic> schedule;

  ScheduleByDaysModel({
    required this.rtc,
    required this.schedule,
  });

  factory ScheduleByDaysModel.fromJson(Map<String, dynamic> json) {
    return ScheduleByDaysModel(
      rtc: json['rtc'],
      schedule: json['schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'schedule': schedule,
    };
  }
}

class DefaultModel {
  int runListLimit;
  bool rtcOffTime;
  bool rtcMaxTime;

  DefaultModel({
    required this.runListLimit,
    required this.rtcOffTime,
    required this.rtcMaxTime,
  });

  factory DefaultModel.fromJson(Map<String, dynamic> json) {
    return DefaultModel(
      runListLimit: json['runListLimit'],
      rtcOffTime: json['rtcOffTime'],
      rtcMaxTime: json['rtcMaxTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runListLimit': runListLimit,
      'rtcOffTime': rtcOffTime,
      'rtcMaxTime': rtcMaxTime,
    };
  }
}

class SampleConditions {
  List<Condition> condition;
  DefaultData defaultData;

  SampleConditions({required this.condition, required this.defaultData});

  factory SampleConditions.fromJson(Map<String, dynamic> json) {
    var conditionList = json['data']['condition'] as List;
    List<Condition> conditions = conditionList.map((e) => Condition.fromJson(e)).toList();

    return SampleConditions(
      condition: conditions,
      defaultData: DefaultData.fromJson(json['data']['default']),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return condition.map((e) => e.toJson()).toList();
  }
}

class Condition {
  String title;
  int widgetTypeId;
  String iconCodePoint;
  String iconFontFamily;
  dynamic value;
  bool hidden;
  bool selected;

  Condition({
    required this.title,
    required this.widgetTypeId,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.value,
    required this.hidden,
    required this.selected,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      title: json['title'],
      widgetTypeId: json['widgetTypeId'],
      iconCodePoint: json['iconCodePoint'],
      iconFontFamily: json['iconFontFamily'],
      value: json['value'],
      hidden: json['hidden'],
      selected: json['selected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'selected': selected,
    };
  }
}

class DefaultData {
  List<ConditionLibraryItem> conditionLibrary;

  DefaultData({required this.conditionLibrary});

  factory DefaultData.fromJson(Map<String, dynamic> json) {
    var conditionLibraryList = json['conditionLibrary'] as List;
    List<ConditionLibraryItem> conditionLibraryItems =
    conditionLibraryList.map((e) => ConditionLibraryItem.fromJson(e)).toList();

    return DefaultData(conditionLibrary: conditionLibraryItems);
  }
}

class ConditionLibraryItem {
  int sNo;
  String id;
  String location;
  String name;
  bool enable;
  String state;
  String duration;
  String conditionIsTrueWhen;
  String fromTime;
  String untilTime;
  bool notification;
  String usedByProgram;
  String program;
  String zone;
  String dropdown1;
  String dropdown2;
  String dropdownValue;

  ConditionLibraryItem({
    required this.sNo,
    required this.id,
    required this.location,
    required this.name,
    required this.enable,
    required this.state,
    required this.duration,
    required this.conditionIsTrueWhen,
    required this.fromTime,
    required this.untilTime,
    required this.notification,
    required this.usedByProgram,
    required this.program,
    required this.zone,
    required this.dropdown1,
    required this.dropdown2,
    required this.dropdownValue,
  });

  factory ConditionLibraryItem.fromJson(Map<String, dynamic> json) {
    return ConditionLibraryItem(
      sNo: json['sNo'],
      id: json['id'],
      location: json['location'],
      name: json['name'],
      enable: json['enable'],
      state: json['state'],
      duration: json['duration'],
      conditionIsTrueWhen: json['conditionIsTrueWhen'],
      fromTime: json['fromTime'],
      untilTime: json['untilTime'],
      notification: json['notification'],
      usedByProgram: json['usedByProgram'],
      program: json['program'],
      zone: json['zone'],
      dropdown1: json['dropdown1'],
      dropdown2: json['dropdown2'],
      dropdownValue: json['dropdownValue'],
    );
  }
}

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
  List<NameData>? centralFertilizer;
  List<NameData>? localFertilizer;
  List<NameData>? centralFilterSite;
  List<NameData>? localFilter;

  Data({
    this.irrigationPump,
    this.mainValve,
    this.centralFertilizerSite,
    this.centralFertilizer,
    this.localFertilizer,
    this.centralFilterSite,
    this.localFilter,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    irrigationPump: json["irrigationPump"] == null ? [] : List<NameData>.from(json["irrigationPump"]!.map((x) => NameData.fromJson(x))),
    mainValve: json["mainValve"] == null ? [] : List<NameData>.from(json["mainValve"]!.map((x) => NameData.fromJson(x))),
    centralFertilizerSite: json["centralFertilizerSite"] == null ? [] : List<NameData>.from(json["centralFertilizerSite"]!.map((x) => NameData.fromJson(x))),
    centralFertilizer: json["centralFertilizerSite"] == null ? [] : List<NameData>.from(json["centralFertilizer"]!.map((x) => NameData.fromJson(x))),
    localFertilizer: json["localFertilizer"] == null ? [] : List<NameData>.from(json["localFertilizer"]!.map((x) => NameData.fromJson(x))),
    centralFilterSite: json["centralFilterSite"] == null ? [] : List<NameData>.from(json["centralFilterSite"]!.map((x) => NameData.fromJson(x))),
    localFilter: json["localFilter"] == null ? [] : List<NameData>.from(json["localFilter"]!.map((x) => NameData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "irrigationPump": irrigationPump == null ? [] : List<dynamic>.from(irrigationPump!.map((x) => x.toJson())),
    "mainValve": mainValve == null ? [] : List<dynamic>.from(mainValve!.map((x) => x.toJson())),
    "centralFertilizerSite": centralFertilizerSite == null ? [] : List<dynamic>.from(centralFertilizerSite!.map((x) => x.toJson())),
    "centralFertilizer": centralFertilizerSite == null ? [] : List<dynamic>.from(centralFertilizer!.map((x) => x.toJson())),
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

class AlarmType {
  int notificationTypeId;
  String notification;
  String notificationDescription;
  String iconCodePoint;
  String iconFontFamily;
  bool selected;

  AlarmType({
    required this.notificationTypeId,
    required this.notification,
    required this.notificationDescription,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.selected,
  });

  factory AlarmType.fromJson(Map<String, dynamic> json) {
    return AlarmType(
      notificationTypeId: json['notificationTypeId'],
      notification: json['notification'],
      notificationDescription: json['notificationDescription'],
      iconCodePoint: json['iconCodePoint'],
      iconFontFamily: json['iconFontFamily'],
      selected: json['selected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "notificationTypeId": notificationTypeId,
      "notification": notification,
      "notificationDescription": notificationDescription,
      "iconCodePoint": iconCodePoint,
      "iconFontFamily": iconFontFamily,
      "selected": selected,
    };
  }
}

class AlarmData {
  List<AlarmType> general;
  List<AlarmType> ecPh;

  AlarmData({
    required this.general,
    required this.ecPh,
  });

  factory AlarmData.fromJson(Map<String, dynamic> json) {
    List<AlarmType> generalList = (json['data']['general'] as List)
        .map((item) => AlarmType.fromJson(item))
        .toList();

    List<AlarmType> ecPhList = (json['data']['ecPh'] as List)
        .map((item) => AlarmType.fromJson(item))
        .toList();

    return AlarmData(
      general: generalList,
      ecPh: ecPhList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "general": general.map((e) => e.toJson()).toList(),
      "ecPh": ecPh.map((e) => e.toJson()).toList()
    };
  }
}

class ProgramLibrary {
  List<String> programType;
  List<Program> program;
  int programLimit;
  int agitatorCount;

  ProgramLibrary({required this.programType, required this.program, required this.programLimit, required this.agitatorCount});

  factory ProgramLibrary.fromJson(Map<String, dynamic> json) {
    return ProgramLibrary(
      programType: List<String>.from(json['data']['programType'] ?? []),
      programLimit: json['data']['programLimit'],
      agitatorCount: json['data']['agitatorCount'],
      program: List<Program>.from((json['data']['program'] as List<dynamic>? ?? []).map((program) => Program.fromJson(program))),
    );
  }
}

class Program {
  int programId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  int priority;
  dynamic sequence;
  Map<String, dynamic> schedule;

  Program({
    required this.programId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.priority,
    required this.sequence,
    required this.schedule
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
        programId: json['programId'],
        serialNumber: json['serialNumber'],
        programName: json['programName'],
        defaultProgramName: json['defaultProgramName'],
        programType: json['programType'],
        priority: json['priority'],
        sequence: json['sequence'],
        schedule: json['schedule']
    );
  }
}

class ProgramDetails {
  // int programId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  int priority;
  bool completionOption;

  ProgramDetails({
    // required this.programId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.priority,
    required this.completionOption
  });

  factory ProgramDetails.fromJson(Map<String, dynamic> json) {
    return ProgramDetails(
      // programId: json['data']['programId'],
      serialNumber: json['data']['serialNumber'] ?? 0,
      programName: json['data']['programName'],
      defaultProgramName: json['data']['defaultProgramName'],
      programType: json['data']['programType'],
      priority: json['data']['priority'],
      completionOption: json['data']['incompleteRestart'] == "1" ? true : false,
    );
  }
}
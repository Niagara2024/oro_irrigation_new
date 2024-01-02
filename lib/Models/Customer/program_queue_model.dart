class ProgramQueueModel {
  int code;
  String message;
  ProgramQueueData data;

  ProgramQueueModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProgramQueueModel.fromJson(Map<String, dynamic> json) {
    return ProgramQueueModel(
      code: json['code'],
      message: json['message'],
      data: ProgramQueueData.fromJson(json['data']),
    );
  }
}

class ProgramQueueData {
  List<ProgramQueue> low;
  List<ProgramQueue> high;

  ProgramQueueData({
    required this.low,
    required this.high,
  });

  factory ProgramQueueData.fromJson(Map<String, dynamic> json) {
    return ProgramQueueData(
      low: json['Low'] == null?  [] : List<ProgramQueue>.from(json['Low'].map((x) => ProgramQueue.fromJson(x))),
      high: json['High'] == null?  [] : List<ProgramQueue>.from(json['High'].map((x) => ProgramQueue.fromJson(x))),
    );

  }
}

class ProgramQueue {
  int programQueueId;
  int userId;
  int controllerId;
  int serialNumber;
  String programName;
  String defaultProgramName;
  String programType;
  String priority;
  String startTime;

  ProgramQueue({
    required this.programQueueId,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.priority,
    required this.startTime,
  });

  factory ProgramQueue.fromJson(Map<String, dynamic> json) {
    return ProgramQueue(
      programQueueId: json['programQueueId'],
      userId: json['userId'],
      controllerId: json['controllerId'],
      serialNumber: json['serialNumber'],
      programName: json['programName'],
      defaultProgramName: json['defaultProgramName'],
      programType: json['programType'],
      priority: json['priority'],
      startTime: json['startTime'],
    );
  }
}

class EnergySaveSettings {
  bool energySaveFunction;
  String startDayTime;
  String stopDayTime;
  bool pauseMainLine;
  DayTimeRange sunday;
  DayTimeRange monday;
  DayTimeRange tuesday;
  DayTimeRange wednesday;
  DayTimeRange thursday;
  DayTimeRange friday;
  DayTimeRange saturday;

  EnergySaveSettings({
    required this.energySaveFunction,
    required this.startDayTime,
    required this.stopDayTime,
    required this.pauseMainLine,
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory EnergySaveSettings.fromJson(Map<String, dynamic> json) {
    return EnergySaveSettings(
      energySaveFunction: json["data"]["energySaveFunction"]['energySaveFunction'] ?? false,
      startDayTime: json["data"]["energySaveFunction"]['startDayTime'] ?? "00:00",
      stopDayTime: json["data"]["energySaveFunction"]['stopDayTime'] ?? "00:00",
      pauseMainLine: json["data"]["energySaveFunction"]['pauseMainLine'] ?? false,
      sunday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['sunday'] ?? {}),
      monday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['monday'] ?? {}),
      tuesday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['tuesday'] ?? {}),
      wednesday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['wednesday'] ?? {}),
      thursday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['thursday'] ?? {}),
      friday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['friday'] ?? {}),
      saturday: DayTimeRange.fromJson(json["data"]["energySaveFunction"]['saturday'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "energySaveFunction": energySaveFunction,
      "startDayTime": startDayTime,
      "stopDayTime": stopDayTime,
      "pauseMainLine": pauseMainLine,
      "sunday": sunday.toJson(),
      "monday": monday.toJson(),
      "tuesday": tuesday.toJson(),
      "wednesday": wednesday.toJson(),
      "thursday": thursday.toJson(),
      "friday": friday.toJson(),
      "saturday": saturday.toJson(),
    };
  }

  String toMqtt() {
    return '${energySaveFunction ? 1 : 0},'
        '${startDayTime != "00:00" ? convertTo24HourFormat(startDayTime) : "00:00:00"},'
        '${stopDayTime != "00:00" ? convertTo24HourFormat(stopDayTime) : "00:00:00"},'
        '${pauseMainLine ? 1 : 0},'
        '${sunday.toMqtt()},'
        '${monday.toMqtt()},'
        '${tuesday.toMqtt()},'
        '${wednesday.toMqtt()},'
        '${thursday.toMqtt()},'
        '${friday.toMqtt()}'
        '${saturday.toMqtt()}';
  }
}

class DayTimeRange {
  String from;
  String to;
  bool selected;

  DayTimeRange({
    required this.from,
    required this.to,
    required this.selected
  });

  factory DayTimeRange.fromJson(Map<String, dynamic> json) {
    return DayTimeRange(
        from: json['from'] ?? "00:00",
        to: json['to'] ?? "00:00",
        selected: json["selected"] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "from": from,
      "to": to,
      "selected": selected
    };
  }

  String toMqtt() {
    return '${selected ? 1 : 0},'
        '${from != "00:00" ? convertTo24HourFormat(from) : "00:00:00"},'
        '${to != "00:00" ? convertTo24HourFormat(to) : "00:00:00"}\n';
  }
}

class PowerOffRecoveryModel{
  late String duration;
  late List selectedOption;

  PowerOffRecoveryModel({required this.duration, required this.selectedOption});

  factory PowerOffRecoveryModel.fromJson(Map<String, dynamic> json) {
    return PowerOffRecoveryModel(
        duration: json['data']['powerOffRecovery']['duration'] ?? "00:00",
        selectedOption: json['data']['powerOffRecovery']['selectedOption'] ?? []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "duration": duration,
      "selectedOption": selectedOption
    };
  }

  String getOptionCode(option) {
    if (option.contains("Reset") && option.contains("Queue") && option.contains("Irrigation")) {
      return "1,1,1";
    } else if (option.contains("Reset") && option.contains("Queue")) {
      return "1,1,0";
    } else if (option.contains("Reset") && option.contains("Irrigation")) {
      return "1,0,1";
    } else if (option.contains("Queue") && option.contains("Irrigation")) {
      return "0,1,1";
    } else if (option.contains("Reset")) {
      return "1,0,0";
    } else if (option.contains("Queue")) {
      return "0,1,0";
    } else if (option.contains("Irrigation")) {
      return "0,0,1";
    } else {
      return "0,0,0";
    }
  }
  String toMqtt() {
    return '${duration != "00:00" ? convertTo24HourFormat(duration) : "00:00:00"}, '
        '${getOptionCode(selectedOption)},'
        '';
  }
}

String convertTo24HourFormat(String time12Hour) {
  List<String> components = time12Hour.split(' ');
  String timePart = components[0];
  String period = components[1];

  List<String> timeComponents = timePart.split(':');
  int hour = int.parse(timeComponents[0]);
  int minute = int.parse(timeComponents[1]);

  if (period == 'PM' && hour < 12) {
    hour += 12;
  } else if (period == 'AM' && hour == 12) {
    hour = 0;
  }

  String formattedHour = hour.toString().padLeft(2, '0');
  String formattedMinute = minute.toString().padLeft(2, '0');

  return '$formattedHour:$formattedMinute:00';
}
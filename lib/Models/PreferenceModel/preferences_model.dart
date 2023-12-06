class GeneralData {
  String userName;
  String categoryName;
  String controllerName;
  String deviceId;
  int controllerId;

  GeneralData({
    required this.userName,
    required this.categoryName,
    required this.controllerName,
    required this.deviceId,
    required this.controllerId
  });

  factory GeneralData.fromJson(Map<String, dynamic> json) {
    return GeneralData(
      userName: json['userName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      controllerName: json['controllerName'] ?? '',
      deviceId: json['deviceId'] ?? 0,
      controllerId: json['controllerId'] ?? 0
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'categoryName': categoryName,
      'controllerName': controllerName,
      'deviceId': deviceId,
      'controllerId': controllerId
    };
  }
}

class Contacts {
  List<ContactItem> name;
  List<ContactItem> list;

  Contacts({
    required this.name,
    required this.list,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'] as List<dynamic>? ?? [];
    final listData = json['list'] as List<dynamic>? ?? [];

    final name = nameData.map((item) {
      return ContactItem.fromJson(item);
    }).toList();

    final list = listData.map((item) {
      return ContactItem.fromJson(item);
    }).toList();

    return Contacts(
      name: name,
      list: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
    };
  }
}

class ContactItem {
  String? id;
  String? name;
  String? value;

  ContactItem({
    this.id,
    this.name,
    this.value,
  });

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value' : value
    };
  }
}

class ContactType {
  final String contactType;
  final String contactDescription;

  ContactType({
    required this.contactType,
    required this.contactDescription,
  });

  factory ContactType.fromJson(Map<String, dynamic> json) {
    return ContactType(
      contactType: json['contact'] ?? '',
      contactDescription: json['contactDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactType': contactType,
    };
  }
}

class Pumps {
  List<PumpItem2> sourcePumpName;
  List<PumpItem2> irrigationPumpName;
  List<PumpItem> list;

  Pumps({
    required this.sourcePumpName,
    required this.irrigationPumpName,
    required this.list,
  });

  factory Pumps.fromJson(Map<String, dynamic> json) {
    final sourcePumpNameData = json['sourcePumpName'] as List<dynamic>? ?? [];
    final irrigationPumpNameData = json['irrigationPumpName'] as List<dynamic>? ?? [];
    final listData = json['list'] as List<dynamic>? ?? [];

    final sourcePumpName = sourcePumpNameData.map((item) {
      return PumpItem2.fromJson(item);
    }).toList();

    final irrigationPumpName = irrigationPumpNameData.map((item) {
      return PumpItem2.fromJson(item);
    }).toList();

    final list = listData.map((item) {
      return PumpItem.fromJson(item);
    }).toList();

    return Pumps(
      sourcePumpName: sourcePumpName,
      irrigationPumpName: irrigationPumpName,
      list: list,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
    };
  }
}

class PumpItem2 {
  String id;
  String? name;

  PumpItem2({
    required this.id,
    this.name,
  });

  factory PumpItem2.fromJson(Map<String, dynamic> json) {
    return PumpItem2(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class PumpItem {
  String id;
  List<PumpValue> value;

  PumpItem({
    required this.id,
    required this.value,
  });

  factory PumpItem.fromJson(Map<String, dynamic> json) {
    return PumpItem(
      id: json['id'] ?? '',
      value: (json['value'] as List<dynamic>?)
          ?.map((valueJson) => PumpValue.fromJson(valueJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value.map((value) => value.toJson()).toList(),
    };
  }
}

class PumpValue {
  String type;
  String selectedContact;

  PumpValue({required this.type, required this.selectedContact});

  factory PumpValue.fromJson(Map<String, dynamic> json) {
    return PumpValue(
      type: json['type'],
      selectedContact: json['selectedContact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'selectedContact': selectedContact,
    };
  }
}

class ContactTypeOfPump {
  String type;
  String? iconCodePoint;
  String? iconFontFamily;

  ContactTypeOfPump({
    required this.type,
    this.iconCodePoint,
    this.iconFontFamily,
  });

  factory ContactTypeOfPump.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? '';
    final iconCodePoint = json['iconCodePoint'] ?? '';
    final iconFontFamily = json['iconFontFamily'] ?? '';

    return ContactTypeOfPump(
      type: type,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
    };
  }
}

class SelectedContact {
  List<ContactTypeOfPump> selectedContact;

  SelectedContact({required this.selectedContact});

  factory SelectedContact.fromJson(List<dynamic> json) {
    final selectedContact = json.map((item) {
      return ContactTypeOfPump.fromJson(item);
    }).toList();

    return SelectedContact(
      selectedContact: selectedContact,
    );
  }
  List<Map<String, dynamic>> toJson() {
    return selectedContact.map((item) => item.toJson()).toList();
  }
}

class PumpSettingModel {
  final String id;
  final List<PumpSettings> pumpSettings;

  PumpSettingModel({
    required this.id,
    required this.pumpSettings,
  });

  factory PumpSettingModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final pumpSettingsData = json['pumpSettings'] as List;

    final pumpSettings = pumpSettingsData
        .map((data) => PumpSettings.fromJson(data))
        .toList();

    return PumpSettingModel(id: id, pumpSettings: pumpSettings);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pumpSettings': pumpSettings.map((item) => item.toJson()).toList(),
    };
  }
}

class RtcTimeSetting {
  int rtc;
  String onTime;
  String offTime;

  RtcTimeSetting({
    required this.rtc,
    required this.onTime,
    required this.offTime,
  });

  factory RtcTimeSetting.fromJson(Map<String, dynamic> json) {
    return RtcTimeSetting(
      rtc: json['rtc'] ?? 0,
      onTime: json['onTime'],
      offTime: json['offTime'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rtc': rtc,
      'onTime': onTime,
      'offTime': offTime,
    };
  }
}

class WidgetSetting {
  String title;
  int widgetTypeId;
  String iconCodePoint;
  String iconFontFamily;
  dynamic value;
  List<RtcTimeSetting>? rtcSettings;
  bool hidden;

  WidgetSetting({
    required this.title,
    required this.widgetTypeId,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.value,
    this.rtcSettings,
    required this.hidden
  });

  factory WidgetSetting.fromJson(Map<String, dynamic> json) {
    final rtcData = json['value'];
    List<RtcTimeSetting>? rtcSettings;
    if (rtcData is List<dynamic>) {
      rtcSettings = rtcData.map((rtcItem) {
        return RtcTimeSetting.fromJson(rtcItem);
      }).toList();
    }

    return WidgetSetting(
        title: json['title'],
        widgetTypeId: json['widgetTypeId'],
        iconCodePoint: json['iconCodePoint'],
        iconFontFamily: json['iconFontFamily'],
        value: json['value'],
        rtcSettings: rtcSettings,
        hidden: json['hidden']
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'widgetTypeId': widgetTypeId,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'value': value,
      'hidden': hidden,
    };

    if (title == 'RTC TIMER') {
      json['value'] = (rtcSettings?.map((item) => item.toJson()).toList())!;
    } else {
      json['value'] = value;
    }

    return json;
  }
}

class PumpSettings {
  String type;
  List<WidgetSetting> setting;

  PumpSettings({
    required this.type,
    required this.setting,
  });

  factory PumpSettings.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    List<dynamic>? settingsData;
    if (type == "21") {
      settingsData = json["2 Phase Selection"];
    } else if (type == "22") {
      settingsData = json["Timer Setting"];
    } else if (type == "23") {
      settingsData = json["Current Setting"];
    } else if (type == "24") {
      settingsData = json["Voltage Setting"];
    } else if (type == "25") {
      settingsData = json["Additional Setting"];
    }

    final settings = settingsData?.map((setting) {
      return WidgetSetting.fromJson(setting);
    }).toList() ?? [];

    return PumpSettings(
      type: type,
      setting: settings,
    );
  }
  Map<String, dynamic> toJson() {
    String settingName = '';
    if (type == "21") {
      settingName = "2 Phase Selection";
    } else if (type == "22") {
      settingName = "Timer Setting";
    } else if (type == "23") {
      settingName = "Current Setting";
    } else if (type == "24") {
      settingName = "Voltage Setting";
    } else if (type == "25") {
      settingName = "Additional Setting";
    }
    return {
      'type': type,
      settingName: setting.map((item) => item.toJson()).toList(),
    };
  }
}

class NotificationType {
  int notificationTypeId;
  String notification;
  String notificationDescription;
  String iconCodePoint;
  String? iconFontFamily;
  bool? value;

  NotificationType({
    required this.notificationTypeId,
    required this.notification,
    required this.notificationDescription,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.value
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) {
    return NotificationType(
        notificationTypeId: json['notificationTypeId'],
        notification: json['notification'],
        notificationDescription: json['notificationDescription'],
        iconCodePoint: json['iconCodePoint'],
        iconFontFamily: json['iconFontFamily'],
        value: json['value'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationTypeId': notificationTypeId,
      'notification': notification,
      'notificationDescription': notificationDescription,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'value': value ?? false,
    };
  }
}

class Configuration {
  GeneralData general;
  List<ContactItem>? contacts;
  List<ContactItem> contactName;
  List<ContactItem> sourcePumpName;
  List<ContactItem> irrigationPumpName;
  List<ContactType> contactType;
  ContactTypeOfPump contactTypeOfPump;
  List<PumpItem>? pumps;
  SelectedContact selectedContact;
  List<PumpSettings> pumpSettings;
  List<PumpSettingModel>? settings;
  List<NotificationType> eventNotifications;
  List<NotificationType> alarmNotifications;
  List<NotificationType> eventNotificationsSent;
  List<NotificationType> alarmNotificationsSent;

  Configuration({
    required this.general,
    required this.contacts,
    required this.contactName,
    required this.sourcePumpName,
    required this.irrigationPumpName,
    required this.contactType,
    required this.contactTypeOfPump,
    required this.pumps,
    required this.selectedContact,
    required this.settings,
    required this.pumpSettings,
    required this.eventNotifications,
    required this.alarmNotifications,
    required this.eventNotificationsSent,
    required this.alarmNotificationsSent
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {

    final generalData = GeneralData.fromJson(json['general']);

    final contactData = json['contacts'] as List<dynamic>?;
    final contacts = contactData?.map((setting) {
      return ContactItem.fromJson(setting);
    }).toList() ?? [];

    final contactNameData = json['contactName'] as List<dynamic>;
    final contactName = contactNameData.map((setting) {
      return ContactItem.fromJson(setting);
    }).toList();
    final sourcePumpNameData = json['sourcePumpName'] as List<dynamic>;
    final sourcePumpName = sourcePumpNameData.map((setting) {
      return ContactItem.fromJson(setting);
    }).toList();
    final irrigationPumpNameData = json['irrigationPumpName'] as List<dynamic>;
    final irrigationPumpName = irrigationPumpNameData.map((setting) {
      return ContactItem.fromJson(setting);
    }).toList();
    final contactTypesData = json['contactType'] as List<dynamic>?;

    final contactTypes = contactTypesData?.map((setting) {
      return ContactType.fromJson(setting);
    }).toList() ?? [];

    final pumpsData = json['pumps'] as List<dynamic>;
    final pumps = pumpsData.map((setting) {
      return PumpItem.fromJson(setting);
    }).toList();

    final selectedContactData = json['selectedContact'] as List<dynamic>? ?? [];
    final selectedContact = SelectedContact.fromJson(selectedContactData);

    final pumpSettingsData = json['pumpSettings'] as List<dynamic>?;

    final pumpSettings = pumpSettingsData?.map((setting) {
      return PumpSettings.fromJson(setting['templateJson']);
    }).toList() ?? [];

    final individualPumpSettingsData = json['settings'] as List<dynamic>?;
    final settings = individualPumpSettingsData?.map((pumpSettings) {
      return PumpSettingModel.fromJson(pumpSettings);
    }).toList() ?? [];

    final eventNotificationsData = json['notificationType']['event'] as List<dynamic>?;
    final eventNotificationsDataSent = json['notifications']['event'] as List<dynamic>?;

    final eventNotificationsSent = eventNotificationsDataSent?.map((event) {
      return NotificationType.fromJson(event);
    }).toList() ?? [];

    final eventNotifications = eventNotificationsData?.map((event) {
      return NotificationType.fromJson(event);
    }).toList() ?? [];

    final alarmNotificationsData = json['notificationType']['alarm'] as List<dynamic>?;
    final alarmNotificationsDataSent = json['notifications']['alarm'] as List<dynamic>?;

    final alarmNotificationsSent = alarmNotificationsDataSent?.map((alarm) {
      return NotificationType.fromJson(alarm);
    }).toList() ?? [];

    final alarmNotifications = alarmNotificationsData?.map((alarm) {
      return NotificationType.fromJson(alarm);
    }).toList() ?? [];

    return Configuration(
        general: generalData,
        contactType: contactTypes,
        contactTypeOfPump: ContactTypeOfPump.fromJson(selectedContactData[0]),
        contacts: contacts,
        contactName: contactName,
        sourcePumpName: sourcePumpName,
        irrigationPumpName: irrigationPumpName,
        pumps: pumps,
        selectedContact: selectedContact,
        pumpSettings: pumpSettings,
        settings: settings,
        eventNotifications: eventNotifications,
        alarmNotifications: alarmNotifications,
        eventNotificationsSent: eventNotificationsSent,
        alarmNotificationsSent: alarmNotificationsSent
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'general': general.toJson(),
      'contacts': contacts?.map((item) => item.toJson()).toList(),
      'settings': settings?.map((item) => item.toJson()).toList(),
      'pumps': pumps?.map((item) => item.toJson()).toList(),
      'notifications': {
        'event': eventNotificationsSent.map((item) => item.toJson()).toList(),
        'alarm': alarmNotificationsSent.map((item) => item.toJson()).toList(),
      },
    };
  }

  Map<String, dynamic> toMqtt() {
    String formattedOutput = '';

    String notificationData = "";
    for (int i = 0; i < eventNotificationsSent.length; i++) {
      notificationData += "${i + 1},1, ${eventNotificationsSent[i].notification ?? ''},0";
      if (i < eventNotificationsSent.length - 1) {
        notificationData += ";\n";
      }
    }
    for (int i = 0; i < alarmNotificationsSent.length; i++) {
      notificationData += "${i + 2},1, ${alarmNotificationsSent[i].notification ?? ''},0";
      if (i < alarmNotificationsSent.length - 1) {
        notificationData += ";\n";
      }
    }
    if (settings != null) {
      formattedOutput += settings!.map((item) {
        var tsData = item.id ?? '';

        tsData += "${item.pumpSettings.map((pumpSetting) {
          var values = pumpSetting.setting
              .map((setting) {
            if (setting.value is List<dynamic>) {
              final rtcSettings = setting.value as List<dynamic>;

              List<String> rtcTimes = [];

              for (var rtcSetting in rtcSettings) {
                if (rtcSetting is Map<String, dynamic> &&
                    rtcSetting.containsKey('onTime') &&
                    rtcSetting.containsKey('offTime')) {
                  final onTime = rtcSetting['onTime'] as String;
                  final offTime = rtcSetting['offTime'] as String;
                  rtcTimes.add('ontime: $onTime, offtime: $offTime');
                }
              }

              return rtcTimes.join(', ');
            } else {
              if(setting.value is bool) {
                return setting.value ? 1: 0;
              }
              else{
                return setting.value;
              }
            }
          })
              .join(",");
          return values;
        }).join(",")}#";

        return tsData;
      }).join("\n");
    }

    formattedOutput += '"#';
    Map<String, dynamic> mqttData = {
      "301 Pref General": '${general.categoryName ?? ''}, ${general.deviceId ?? ''}, ${general.userName ?? ''}, ${general.controllerName ?? ''}',
      "302 Pref Contacts": contacts
          ?.map((item) => "${item.id}, ${item.name},${item.value}")
          .join(";\n"),
      "304 Pref Pump": pumps?.map((item) {
        var pumpData = "${item.id},${item.value.map((e) => e.selectedContact).join(",")}";
        return pumpData;
      }).join(";\n"),
    };
    mqttData['303 TS'] = formattedOutput;
    mqttData["305 Pref Notification"] = notificationData;

    return mqttData;
  }
}
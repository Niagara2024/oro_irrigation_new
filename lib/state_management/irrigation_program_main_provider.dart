import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import '../Models/IrrigationModel/irrigation_program_model.dart';
import '../Models/IrrigationModel/selection_model.dart';
import '../constants/http_service.dart';



class IrrigationProgramMainProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    Future.delayed(Duration.zero, (){
      notifyListeners();
    });
  }

  //TODO:SEQUENCE SCREEN PROVIDER
  final HttpService httpService = HttpService();

  IrrigationLine? _irrigationLine;
  IrrigationLine? get irrigationLine => _irrigationLine;

  Future<void> getUserProgramSequence(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSequence = await httpService.postRequest('getUserProgramSequence', userData);
      if(getUserProgramSequence.statusCode == 200) {
        final responseJson = getUserProgramSequence.body;
        final convertedJson = jsonDecode(responseJson);
        _irrigationLine = IrrigationLine.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  bool isRecentlySelected = false;

  void valveSelection(Valve valves, titleIndex, valveIndex, isGroup) {
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';

    if (_irrigationLine!.sequence.isNotEmpty) {
      final lastItem = _irrigationLine!.sequence.last['valve'];
      if(lastItem!.isNotEmpty && lastItem.last['sNo'] == valves) {
        isRecentlySelected = true;
      } else {
        isRecentlySelected = false;
        updateSequencedValves(valves, valueToShow, titleIndex+1);
      }
    } else {
      isRecentlySelected = false;
      updateSequencedValves(valves, valueToShow, titleIndex+1);
    }
    notifyListeners();
    // log(_irrigationLine!.sequence);
  }

  bool isSameLine = false;
  bool isStartTogether = false;
  bool isReuseValve = true;
  bool isContains = false;
  bool isAgitator = false;

  void updateIsAgitator() {
    isAgitator = true;
    notifyListeners();
  }
  void updateSequencedValves(Valve valves, valueToShow, titleIndex) {
    if (isSingleValveMode) {
      if(selectedProgramType == 'Agitator Program') {
        _irrigationLine!.sequence.add({
          "valve": [valves.toJson()],
          "selected": [valves.name]
        });
      } else {
        int length = _irrigationLine!.sequence.isNotEmpty
            ? _irrigationLine!.sequence[0]['valve'].length
            : 0;

        for (var i = 0; i < length; i++) {
          if (_irrigationLine!.sequence.any((item) => item['valve'].length > i && item['valve'][i]['sNo']! == valves.sNo)) {
            isContains = true;
            break;
          } else {
            isContains = false;
          }
        }
        if (irrigationLine!.defaultData.reuseValve || !isContains) {
          isReuseValve = false;
          _irrigationLine!.sequence.add({
            "valve": [valves.toJson()],
            "selected": [valueToShow]
          });
          isStartTogether = false;
        } else {
          isReuseValve = true;
        }
      }
    }
    else {
      if (_irrigationLine!.sequence.isEmpty && !isAgitator) {
        _irrigationLine!.sequence.add({
          "valve": [valves.toJson()],
          "selected": [valueToShow]
        });
        isStartTogether = false;
      } else {
        int lastIndex = _irrigationLine!.sequence.length - 1;
        if (lastIndex >= 0) {
          Map<String, List> lastItem = _irrigationLine!.sequence[lastIndex];
          List? sNoList = lastItem["valve"];
          isSameLine = lastItem['selected']!.every((item) {
            String itemString = item.toString();
            return itemString.startsWith(titleIndex.toString());
          });

          if (valves is! List<dynamic>) {
            log('Not string');
          }

          if(selectedProgramType == 'Agitator Program') {
            sNoList?.add(valves.toJson());
            List<String>? selectedList = lastItem["selected"]?.cast<String>();
            selectedList?.add(valves.name);
          }

          if (irrigationLine!.defaultData.startTogether) {
            if (irrigationLine!.defaultData.reuseValve || !sNoList!.any((element) => element['sNo'] == valves.sNo)) {
              isReuseValve = false;
              sNoList?.add(valves.toJson());
              List<String>? selectedList = lastItem["selected"]?.cast<String>();
              selectedList?.add(valueToShow);
            } else {
              isReuseValve = true;
            }
          } else {
            if (isSameLine) {
              if (irrigationLine!.defaultData.reuseValve || !sNoList!.any((element) => element['sNo'] == valves.sNo)) {
                isReuseValve = false;
                sNoList?.add(valves.toJson());
                List<String>? selectedList = lastItem["selected"]?.cast<String>();
                selectedList?.add(valueToShow);
                isStartTogether = false;
              } else {
                isReuseValve = true;
                isStartTogether = false;
              }
            } else {
              isStartTogether = true;
            }
          }
        }
      }
    }
  }

  void reorderSelectedValves(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final valve = _irrigationLine!.sequence[oldIndex];
    _irrigationLine!.sequence.removeAt(oldIndex);
    _irrigationLine!.sequence.insert(newIndex, valve);
  }

  bool isSingleValveMode = true;
  bool isMultipleValveMode = false;
  void enableMultipleValveMode() {
    isSingleValveMode = false;
    isMultipleValveMode = true;
    isDelete = false;
    notifyListeners();
  }

  void enableSingleValveMode() {
    isSingleValveMode = true;
    isMultipleValveMode = false;
    isDelete = false;
    notifyListeners();
  }

  bool isDelete = false;
  void deleteFunction() {
    isDelete = true;
    isMultipleValveMode = false;
    isSingleValveMode = false;
    notifyListeners();
  }

  void deleteButton() {
    _irrigationLine!.sequence.clear();
    notifyListeners();
  }

  bool isSelected(valveIndex, titleIndex, isGroup) {
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';
    return _irrigationLine!.sequence.any((list) => list['selected']!.contains(valueToShow));
  }

  //TODO: SCHEDULE SCREEN PROVIDERS
  SampleScheduleModel? _sampleScheduleModel;
  SampleScheduleModel? get sampleScheduleModel => _sampleScheduleModel;

  Future<void> scheduleData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramSchedule = await httpService.postRequest('getUserProgramSchedule', userData);
      if(getUserProgramSchedule.statusCode == 200) {
        final responseJson = getUserProgramSchedule.body;
        final convertedJson = jsonDecode(responseJson);
        if(convertedJson['data']['schedule'].isEmpty) {
          convertedJson['data']['schedule'] = {
            "scheduleAsRunList" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "00", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "00", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "noOfDays": "00", "startDate": DateTime.now().toString(), "type" : [] },
            },
            "scheduleByDays" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "00", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "00", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "startDate": DateTime.now().toString(), "runDays": "00", "skipDays": "00" }
            },
            "selected" : "NO SCHEDULE",
          };
        }
        _sampleScheduleModel = SampleScheduleModel.fromJson(convertedJson);
      }else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }

    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateRtcProperty(newTime, selectedRtc, property, scheduleType) {
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList){
      final selectedRtcKey = sampleScheduleModel!.scheduleAsRunList.rtc.keys.toList()[selectedRtcIndex1];
      sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey][property] = newTime;
    } else {
      final selectedRtcKey = sampleScheduleModel!.scheduleByDays.rtc.keys.toList()[selectedRtcIndex2];
      sampleScheduleModel!.scheduleByDays.rtc[selectedRtcKey][property] = newTime;
    }
    notifyListeners();
  }

  void updateStartDate(newDate, scheduleType) {
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList) {
      sampleScheduleModel!.scheduleAsRunList.schedule['startDate'] = newDate.toString();
    } else if(scheduleType == sampleScheduleModel!.scheduleByDays) {
      sampleScheduleModel!.scheduleByDays.schedule = {
        "startDate": newDate.toString(),
        "runDays": sampleScheduleModel!.scheduleByDays.schedule['runDays'],
        "skipDays": sampleScheduleModel!.scheduleByDays.schedule['skipDays']
      };
    }
    notifyListeners();
  }

  void updateNumberOfDays(newNumberOfDays, daysType, scheduleType) {
    scheduleType.schedule[daysType] = newNumberOfDays;
    notifyListeners();
  }

  List<String> scheduleTypes = ['NO SCHEDULE', 'SCHEDULE AS RUN LIST', 'SCHEDULE BY DAYS'];

  String? get selectedScheduleType => sampleScheduleModel?.selected ?? "NO SCHEDULE";

  void updateSelectedValue(newValue) {
    sampleScheduleModel!.selected = newValue;
    notifyListeners();
  }

  int _selectedRtcIndex1 = 0;

  int get selectedRtcIndex1 => _selectedRtcIndex1;

  void updateRtcIndex1(int newIndex) {
    _selectedRtcIndex1 = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  int _selectedRtcIndex2 = 0;

  int get selectedRtcIndex2 => _selectedRtcIndex2;

  void updateRtcIndex2(int newIndex) {
    _selectedRtcIndex2 = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  List<String> scheduleOptions = ['DO NOTHING', 'DO ONE TIME', 'DO WATERING', 'DO FERTIGATION'];

  void initializeDropdownValues(numberOfDays, existingDays, type) {
    if (sampleScheduleModel!.scheduleAsRunList.schedule['type'].isEmpty || int.parse(existingDays) == 0) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'] = List.generate(int.parse(numberOfDays), (index) => 'DO NOTHING');
    } else {
      if (int.parse(numberOfDays) != int.parse(existingDays)) {
        if (int.parse(numberOfDays) < int.parse(existingDays)) {
          for (var i = 0; i < int.parse(existingDays); i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = type[i];
          }
        } else {
          var newDays = int.parse(numberOfDays) - int.parse(existingDays);
          for (var i = 0; i < newDays; i++) {
            sampleScheduleModel!.scheduleAsRunList.schedule['type'].add('DO NOTHING');
          }
        }
      }
    }
    notifyListeners();
  }

  void updateDropdownValue(index, newValue) {
    if (index >= 0 && index < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length) {
      sampleScheduleModel!.scheduleAsRunList.schedule['type'][index] = newValue;
      notifyListeners();
    }
  }

  int selectedButtonIndex = -1;
  void setAllSame(index) {
    bool allSame = true;
    switch(index) {
      case 0:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[0];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[0]) {
            allSame = false;
          }
        }
        break;
      case 1:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[1];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[1]) {
            allSame = false;
          }
        }
        break;
      case 2:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[2];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[2]) {
            allSame = false;
          }
        }
        break;
      case 3:
        for (int i = 0; i < sampleScheduleModel!.scheduleAsRunList.schedule['type'].length; i++) {
          sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] = scheduleOptions[3];
          if(sampleScheduleModel!.scheduleAsRunList.schedule['type'][i] != scheduleOptions[3]) {
            allSame = false;
          }
        }
        break;
    }
    if (allSame) {
      selectedButtonIndex = index;
    }
    notifyListeners();
  }

  String? errorText;

  void validateInputAndSetErrorText(input, runListLimit) {
    if (input.isEmpty) {
      errorText = 'Please enter a value';
    } else {
      int? parsedValue = int.tryParse(input);
      if (parsedValue == null) {
        errorText = 'Please enter a valid number';
      } else if (parsedValue > (runListLimit)) {
        errorText = 'Value should not exceed $runListLimit';
      } else {
        errorText = null;
      }
    }
    notifyListeners();
  }

  //TODO: CONDITIONS PROVIDER
  Map<String, dynamic> sampleConditionsData = {
    "data": {
      "condition": [
        {
          "title": "START BY CONDITION",
          "widgetTypeId": 6,
          "iconCodePoint": "0xe4cb",
          "iconFontFamily": "MaterialIcons",
          "value": {},
          "hidden": false,
          "selected": false
        },
        {
          "title": "STOP BY CONDITION",
          "widgetTypeId": 6,
          "iconCodePoint": "0xe606",
          "iconFontFamily": "MaterialIcons",
          "value": {},
          "hidden": false,
          "selected": false
        },
        {
          "title": "ENABLE BY CONDITION",
          "widgetTypeId": 6,
          "iconCodePoint": "0xe66c",
          "iconFontFamily": "MaterialIcons",
          "value": {},
          "hidden": false,
          "selected": false
        },
        {
          "title": "DISABLE BY CONDITION",
          "widgetTypeId": 6,
          "iconCodePoint": "0xe66b",
          "iconFontFamily": "MaterialIcons",
          "value": {},
          "hidden": false,
          "selected": false
        }
      ],
      "default": {
        "conditionLibrary": [
          {"sNo": 1, "id": "COND1", "location": "", "name": "Condition1", "enable": false, "state": "", "duration": "00:00", "conditionIsTrueWhen": "", "fromTime": "00:00", "untilTime": "00:00", "notification": false, "usedByProgram": "", "program": "", "zone": "", "dropdown1": "", "dropdown2": "", "dropdownValue": ""},
          {"sNo": 2, "id": "COND2", "location": "", "name": "Condition2", "enable": false, "state": "", "duration": "00:00", "conditionIsTrueWhen": "", "fromTime": "00:00", "untilTime": "00:00", "notification": false, "usedByProgram": "", "program": "", "zone": "", "dropdown1": "", "dropdown2": "", "dropdownValue": ""},
          {"sNo": 3, "id": "COND3", "location": "", "name": "Condition3", "enable": false, "state": "", "duration": "00:00", "conditionIsTrueWhen": "", "fromTime": "00:00", "untilTime": "00:00", "notification": false, "usedByProgram": "", "program": "", "zone": "", "dropdown1": "", "dropdown2": "", "dropdownValue": ""},
        ]
      }
    }
  };

  SampleConditions? _sampleConditions;
  SampleConditions? get sampleConditions => _sampleConditions;

  Future<void> conditionTypeData(int userId, int controllerId) async {
    _sampleConditions = SampleConditions.fromJson(sampleConditionsData);

    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateConditionType(newValue, conditionTypeIndex) {
    _sampleConditions!.condition[conditionTypeIndex].selected = newValue;
    notifyListeners();
  }

  void updateConditions(title, sNo, newValue, conditionTypeIndex) {
    _sampleConditions!.condition[conditionTypeIndex].value = {
      "sNo": sNo,
      "name" : newValue
    };
    notifyListeners();
  }

  //TODO: WATER AND FERT PROVIDER
  List<dynamic> sequenceData = [];
  List<dynamic> serverDataWM = [];
  List<dynamic> channelData = [];
  int selectedGroup = 0;
  int selectedSite = 0;
  int selectedInjector = 0;
  List<dynamic> sequence = [];
  String radio = 'set individual';
  dynamic apiData = {};
  Map<String,dynamic> currentSequenceDetails = {};
  bool isThereData  = false;
  var currentChannel = {};
  int segmentedControlGroupValue = 0;

  Map<int, Widget> myTabs = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Water",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Fert",style: TextStyle(color: Colors.white)),
    ),
    2: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Moisture",style: TextStyle(color: Colors.white)),
    ),
    3: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Level",style: TextStyle(color: Colors.white)),
    )
  };
  void editSegmentedControlGroupValue(int value){
    segmentedControlGroupValue = value;
    myTabs = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Water",style: TextStyle(color: segmentedControlGroupValue == 0 ? Colors.white : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Fert",style: TextStyle(color: segmentedControlGroupValue == 1 ? Colors.white : Colors.black)),
      ),
      2: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Moisture",style: TextStyle(color: segmentedControlGroupValue == 2 ? Colors.white : Colors.black)),
      ),
      3: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Sensor",style: TextStyle(color: segmentedControlGroupValue == 3 ? Colors.white : Colors.black)),
      ),
    };
    notifyListeners();
  }

  void updateSequenceForFert(List<dynamic> sequenceData){
    sequence = [];
    for(var i in sequenceData){
      var seq = '';
      for(var j in i['selected']){
        seq += '${seq.isNotEmpty ? ' & ' : ''}$j';
      }
      sequence.add(seq);
    }
    notifyListeners();
  }

  void editIsThereData(){
    isThereData = false;
    notifyListeners();
  }
  void editRadio(String value){
    radio = value;
    notifyListeners();
  }

  void editNextForGroupSiteInjector(String title){
    switch(title){
      case ('selectedGroup'):{
        selectedGroup += 1;
        var afterAddList = [];
        for(var i in sequenceData){
          for(var j in i.entries){
            afterAddList.add(j.key);
          }
        }
        if(afterAddList.contains(sequence[selectedGroup])){
          currentSequenceDetails = sequenceData[afterAddList.indexOf(sequence[selectedGroup])];
          if(currentSequenceDetails[sequence[selectedGroup]]['dSite'].length != 0){
            isThereData = true;
          }else{
            isThereData = false;
          }
        }
        break;
      }
      case ('selectedSite'):{
        selectedSite += 1;
        break;
      }
      case ('selectedInjector'):{
        selectedInjector += 1;
        break;
      }
    }
    notifyListeners();
  }

  void editBackForGroupSiteInjector(String title){
    switch(title){
      case ('selectedGroup'):{
        selectedGroup -= 1;
        var afterAddList = [];
        for(var i in sequenceData){
          for(var j in i.entries){
            afterAddList.add(j.key);
          }
        }
        if(afterAddList.contains(sequence[selectedGroup])){
          currentSequenceDetails = sequenceData[afterAddList.indexOf(sequence[selectedGroup])];
          if(currentSequenceDetails[sequence[selectedGroup]]['dSite'].length != 0){
            isThereData = true;
          }else{
            isThereData = false;
          }
        }
        break;
      }
      case ('selectedSite'):{
        selectedSite -= 1;
        break;
      }
      case ('selectedInjector'):{
        selectedInjector -= 1;
        break;
      }
    }
    notifyListeners();
  }

  void editGroupSiteInjector(String title,int value){
    switch(title){
      case ('selectedGroup'):{
        selectedGroup = value;
        break;
      }
      case ('selectedSite'):{
        selectedSite = value;
        break;
      }
      case ('selectedInjector'):{
        selectedInjector = value;
        break;
      }
    }
    notifyListeners();
  }

  void editApiData(dynamic value){
    apiData = value;
    notifyListeners();
  }

  void getDataForParticularChannel(int? sno){
    var injectorData = {};
    for(var i in channelData){
      for(var j in i.entries){
        if(j.key == 'sNo'){
          if(j.value == sno){
            injectorData = i;
          }
        }
      }
    }
    currentChannel = injectorData;
    notifyListeners();
    // return injectorData;
  }

  void editWaterSetting(String title, String value){
    List<String> afterAddList = [];
    for(var i in sequenceData){
      for(var j in i.entries){
        afterAddList.add(j.key);
      }
    }
    if(afterAddList.contains(sequence[selectedGroup])){
      switch(title){
        case('type'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['type'] = value;
          break;
        }
        case('time'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['time'] = value;
          break;
        }
        case('flow'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['flow'] = value;
          break;
        }
      }
    }
    notifyListeners();
  }
  void editParticularChannelDetails(String title,String? value){
    List<String> afterAddList = [];
    for(var i in sequenceData){
      for(var j in i.entries){
        afterAddList.add(j.key);
      }
    }
    if(afterAddList.contains(sequence[selectedGroup])){
      switch(title){
        case('type'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['dSite'][selectedSite]['injector'][selectedInjector]['type'] = value;
          break;
        }
        case('time'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['dSite'][selectedSite]['injector'][selectedInjector]['time'] = value;
          break;
        }
        case('flow'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['dSite'][selectedSite]['injector'][selectedInjector]['flow'] = value;
          break;
        }
        case('EC'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['dSite'][selectedSite]['injector'][selectedInjector]['EC'] = value;
          break;
        }
        case('PH'):{
          sequenceData[afterAddList.indexOf(sequence[selectedGroup])][sequence[selectedGroup]]['dSite'][selectedSite]['injector'][selectedInjector]['PH'] = value;
          break;
        }
      }
      currentSequenceDetails = sequenceData[afterAddList.indexOf(sequence[selectedGroup])];
      if(currentSequenceDetails[sequence[selectedGroup]]['dSite'].length != 0){
        isThereData = true;
      }else{
        isThereData = false;
      }
    }
    notifyListeners();
  }

  void waterAndFert(dynamic data){
    var list = [];
    for(var i in sequenceData){
      for(var j in i.entries){
        list.add(j.key);
      }
    }
    if(!list.contains(sequence[selectedGroup])){
      var mySequence = {
        '${data['selectedGroup']}' : {
          'dSite' : [],
          'type' : 'Time',
          'time' : '00:00',
          'flow' : '0',
          'moisture_high' : '0',
          'moisture_low' : '0',
          'moisture_middle' : false,
          'level_high' : '0',
          'level_low' : '0',
          'level_middle' : false,
        }
      };
      var usedSite = [];
      for(var cd in data['data']['fertilization']){
        if(!cd['id'].contains('IL')){
          var totalLineInSequence = [];
          var listOfLine = data['selectedGroup'].split(',');
          for(var line in listOfLine){
            var myLine = line.split('.');
            if(!totalLineInSequence.contains(myLine[0])){
              totalLineInSequence.add(myLine[0]);
            }
          }
          var checkLineInCdSite = cd['location'];
          for(var checkLine in totalLineInSequence){
            if(checkLineInCdSite.contains(checkLine)){
              var listOfChannel = [];
              for(var inj in cd['fertilizer']){
                var channel = {
                  'sNo' : inj['sNo'],
                  'name' : inj['name'],
                  'id' : inj['id'],
                  'location' : inj['location'],
                  'type' : 'Time',
                  'time' : '00:00',
                  'flow' : '0',
                  'EC' : '0',
                  'PH' : '0'
                };
                listOfChannel.add(channel);
              }
              var myCd = {
                'name' : cd['name'],
                'sNo' : cd['sNo'],
                'id' : cd['id'],
                'location' : cd['location'],
                'injector' : listOfChannel
              };
              usedSite.add(myCd);
              mySequence['${data['selectedGroup']}']?['dSite'] = usedSite;
            }
          }
        }else{
          var totalLineInSequence = [];
          var listOfLine = data['selectedGroup'].split(',');
          for(var line in listOfLine){
            var myLine = line.split('.');
            if(!totalLineInSequence.contains(myLine[0])){
              totalLineInSequence.add(myLine[0]);
            }
          }
          var checkLineInCdSite = cd['id'].split('');
          for(var checkLine in totalLineInSequence){
            if(checkLineInCdSite.contains(checkLine)){
              var listOfChannel = [];
              for(var inj in cd['fertilizer']){
                var channel = {
                  'sNo' : inj['sNo'],
                  'name' : inj['name'],
                  'id' : inj['id'],
                  'location' : inj['location'],
                  'type' : 'Time',
                  'time' : '00:00',
                  'flow' : '0',
                  'EC' : '0',
                  'PH' : '0'
                };
                listOfChannel.add(channel);
              }
              var myCd = {
                'name' : cd['name'],
                'sNo' : cd['sNo'],
                'id' : cd['id'],
                'location' : cd['location'],
                'injector' : listOfChannel
              };
              usedSite.add(myCd);
              mySequence['${data['selectedGroup']}']?['dSite'] = usedSite;
            }
          }
        }
      }
      sequenceData.add(mySequence);
    }
    var afterAddList = [];
    for(var i in sequenceData){
      for(var j in i.entries){
        afterAddList.add(j.key);
      }
    }
    if(afterAddList.contains(data['selectedGroup'])){
      currentSequenceDetails = sequenceData[afterAddList.indexOf(data['selectedGroup'])];
      if(currentSequenceDetails[sequence[selectedGroup]]['dSite'].length != 0){
        isThereData = true;
      }else{
        isThereData = false;
      }

    }
    notifyListeners();
  }

  void dataToWF(){
    serverDataWM = [];
    List<dynamic> mySequence = _irrigationLine!.sequence;
    for(var sequence in mySequence){
      var seq = '';
      for(var vl in sequence['selected']){
        seq += '${seq.isNotEmpty ? ' & ' : ''}$vl';
      }
      check : for(var i in sequenceData){
        for(var j in i.entries){
          if(j.key == seq){
            sequence['water&fert'] = [j.value];
            log("sequence['water&fert'] : ${sequence['water&fert']}");
            break check;
          }
        }
      }
      serverDataWM.add(sequence);
    }
    notifyListeners();
  }

  // dynamic selectedSequenceDetails(String value){
  //   var data = {};
  //   for(var i in sequenceData){
  //     for(var j in i.entries){
  //       if(j.key == value){
  //         data = i;
  //       }
  //     }
  //   }
  //   currentSequenceDetails = data;
  //   return data;
  // }

  //TODO: SELECTION PROVIDER
  SelectionModel _selectionModel = SelectionModel();
  SelectionModel get selectionModel => _selectionModel;

  void updateSelectionModel(SelectionModel newSelectionModel) {
    _selectionModel = newSelectionModel;
    notifyListeners();
  }

  Future<void> fetchSelectionData(int userId, int controllerId, int serialNumber) async {
    var userData = {
      "userId": userId,
      "controllerId": controllerId,
      "serialNumber": serialNumber
    };
    final response = await HttpService().postRequest("getUserProgramSelection", userData);
    final jsonData = json.decode(response.body);
    try {

      _selectionModel = SelectionModel.fromJson(jsonData);
    } catch (e) {
      log('Error: $e');
    }

    Future.delayed(const Duration(seconds: 0), () {
      notifyListeners();
    });
  }

  void selectItem(int index, String title) {

    switch (title) {
      case 'MAIN VALVE':
        selectionModel.data!.mainValve![index].selected = !selectionModel.data!.mainValve![index].selected!;
        break;
      case 'PUMP SELECTION':
        selectionModel.data!.irrigationPump![index].selected = !selectionModel.data!.irrigationPump![index].selected!;
        break;
      case 'Central Fertilizer':
        selectionModel.data!.centralFertilizerSite![index].selected = !selectionModel.data!.centralFertilizerSite![index].selected!;
        break;
      case 'Local Fertilizer':
        selectionModel.data!.localFertilizer![index].selected = !selectionModel.data!.localFertilizer![index].selected!;
        break;
      case 'Central Filter':
        selectionModel.data!.centralFilterSite![index].selected = !selectionModel.data!.centralFilterSite![index].selected!;
        break;
      case 'Local Filter':
        selectionModel.data!.localFilter![index].selected = !selectionModel.data!.localFilter![index].selected!;
        break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  //TODO: ALARM SCREEN PROVIDER
  AlarmData? _alarmData;
  AlarmData? get alarmData => _alarmData;
  Future<void> alarmDataFetched(userId, controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramAlarm = await httpService.postRequest('getUserProgramAlarm', userData);
      if(getUserProgramAlarm.statusCode == 200) {
        final responseJson = getUserProgramAlarm.body;
        final convertedJson = jsonDecode(responseJson);
        _alarmData = AlarmData.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateValueForGeneral(notificationTypeId, newValue) {
    final item = _alarmData!.general.firstWhere(
            (notification) => notification.notificationTypeId == notificationTypeId,
        orElse: () => throw Exception('Item not found for identifier: $notificationTypeId',
        ));

    item.selected = newValue;
    notifyListeners();
  }

  void updateValueForEcPh(notificationTypeId, newValue) {
    final item = _alarmData!.ecPh.firstWhere(
            (notification) => notification.notificationTypeId == notificationTypeId,
        orElse: () => throw Exception('Item not found for identifier: $notificationTypeId',
        ));

    item.selected = newValue;
    notifyListeners();
  }

  //TODO: DONE SCREEN PROVIDER
  List<dynamic> programList = [];
  int programCount = 0;
  String programName = '';
  String defaultProgramName = '';
  int priority = 0;
  bool isCompletionEnabled = false;
  List<int> priorityList = [];
  List<String> programTypes = [];
  String selectedProgramType = '';

  int serialNumberCreation = 0;
  bool irrigationProgramType = false;

  List<int> serialNumberList = [];
  ProgramDetails? _programDetails;
  ProgramDetails? get programDetails => _programDetails;
  Future<void> doneData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramDetails', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programDetails = ProgramDetails.fromJson(convertedJson);
        programCount = _programLibrary!.program.isEmpty ? 1 : _programLibrary!.program.length + 1;
        serialNumberCreation = _programLibrary!.program.length + 1;
        priorityList = List.generate(_programLibrary!.program.length, (index) => (index + 1));
        priority = _programDetails!.priority;
        programName = (_programDetails!.programName == '' || _programDetails!.programName.isEmpty) ?  "Program $programCount" : _programDetails!.programName;
        selectedProgramType = _programDetails!.programType == '' ? selectedProgramType : _programDetails!.programType;
        defaultProgramName = (_programDetails!.defaultProgramName == '' || _programDetails!.defaultProgramName.isEmpty) ?  "Program $programCount" : _programDetails!.defaultProgramName;
        isCompletionEnabled = _programDetails!.completionOption;
        Future.delayed(Duration.zero, () {
          notifyListeners();
        });
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  //TODO: PROGRAM LIBRARY
  bool get getProgramType => _programDetails?.programType == "Irrigation Program" ? true : false;
  ProgramLibrary? _programLibrary;
  ProgramLibrary? get programLibrary => _programLibrary;

  int _selectedSegment = 0;

  int get selectedSegment => _selectedSegment;
  bool agitatorCountIsNotZero = false;
  void updateSelectedSegment(int newIndex) {
    _selectedSegment = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  Future<void> programLibraryData(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };

      var getUserProgramName = await httpService.postRequest('getUserProgramNameList', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programLibrary = ProgramLibrary.fromJson(convertedJson);
        priorityList = List.generate(_programLibrary!.program.length, (index) => (index + 1));
        priority = _programDetails?.priority ?? 0;
        agitatorCountIsNotZero = convertedJson['data']['agitatorCount'] != 0 ? true : false;
        // irrigationProgramType = _programLibrary?.program[serialNumber].programType == "Irrigation Program" ? true : false;
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    notifyListeners();
  }

  //TODO: PROGRAM RESET
  Future<String> userProgramReset(int userId, int controllerId, int serialNumber, int programId) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "modifyUser": userId,
        "programId": programId
      };

      var getUserProgramName = await httpService.putRequest('resetUserProgram', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        log("HTTP Request failed or received an unexpected response.");
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  void updateProgramName(dynamic newValue, String type) {
    switch (type) {
      case 'programName':
        programName = newValue != ''? newValue : programName;
        break;
      case 'priority':
        priority = int.tryParse(newValue) ?? 0;
        break;
      case 'completion':
        isCompletionEnabled = newValue as bool;
        break;
      case 'programType':
        selectedProgramType = newValue as String;
        break;
    }
    notifyListeners();
  }

  bool isIrrigationProgram = false;
  bool isAgitatorProgram = false;
  bool showIrrigationPrograms = false;
  bool showAgitatorPrograms = false;
  bool showAllPrograms = true;

  void updateShowPrograms(all, irrigation, agitator) {
    showAllPrograms = all;
    showIrrigationPrograms = irrigation;
    showAgitatorPrograms = agitator;
    notifyListeners();
  }
  void updateIsIrrigationProgram() {
    isIrrigationProgram = true;
    isAgitatorProgram = false;
    notifyListeners();
  }

  void updateIsAgitatorProgram() {
    isAgitatorProgram = true;
    isIrrigationProgram = false;
    notifyListeners();
  }

  List<String> label1 = ['Sequence', 'Schedule', 'Conditions', 'Water & Fert', 'Selection', 'Alarm', 'Done'];
  List<IconData> icons1 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.local_florist_rounded,
    Icons.checklist,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  List<String> label2 = ['Sequence', 'Schedule', 'Conditions', 'Alarm', 'Done'];
  List<IconData> icons2 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  //TODO: UPDATE PROGRAM DETAILS
  Future<String> updateUserProgramDetails(
      int userId, int controllerId, int serialNumber, int programId, String programName, String programType, int priority) async {
    try {
      Map<String, dynamic> userData = {
        "userId": userId,
        "controllerId": controllerId,
        "modifyUser": userId,
        "programId": programId,
        "programName": programName,
        "programType": programType,
        "priority": priority,
      };

      var updateUserProgramDetails = await httpService.putRequest('updateUserProgramDetails', userData);

      if (updateUserProgramDetails.statusCode == 200) {
        final responseJson = updateUserProgramDetails.body;
        final convertedJson = jsonDecode(responseJson);
        notifyListeners();
        return convertedJson['message'];
      } else {
        throw Exception("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }


}
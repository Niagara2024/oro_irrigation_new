import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../Models/IrrigationModel/sequence_model.dart';
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

  SequenceModel? _irrigationLine;
  SequenceModel? get irrigationLine => _irrigationLine;
  List zoneSnoList = [];
  List zoneNameList = [];
  List sNoList = [];
  List programSNoList = [];
  String zoneSerialNumberCreation = '';

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
        _irrigationLine = SequenceModel.fromJson(convertedJson);
      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  bool isRecentlySelected = false;

  void valveSelection(valves, titleIndex, valveIndex, isGroup, serialNumber) {
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';
    int zoneSno() {
      if(_irrigationLine!.sequence.isEmpty) {
        int zoneSNo = 1;
        return zoneSNo++;
      } else {
        int length = _irrigationLine!.sequence.length+1;
        return length++;
      }
    }
    updateSequencedValves(valves, valueToShow, titleIndex+1, serialNumber, zoneSno(), isGroup);
    notifyListeners();
  }

  bool isSameLine = false;
  bool isStartTogether = false;
  bool isReuseValve = true;
  bool isContains = false;
  bool isAgitator = false;
  bool groupAdding = false;

  void updateIsAgitator() {
    isAgitator = true;
    notifyListeners();
  }

  void updateSequencedValves(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup) {
    if (isSingleValveMode) {
      handleSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup);
      groupAdding = false;
    } else {
      handleMultipleValvesMode(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup);
    }
  }

  void handleSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup) {
    if (selectedProgramType == 'Agitator Program') {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
    } else {
      handleNonAgitatorSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup);
    }
  }

  void handleNonAgitatorSingleValveMode(valves, valueToShow, serialNumber, sNo, isGroup) {
    bool isContains = checkValveContainment(valves, isGroup);

    if (irrigationLine!.defaultData.reuseValve || !isContains) {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
      isStartTogether = false;
      isReuseValve = false;
    } else {
      isReuseValve = true;
    }
  }

  bool checkValveContainment(valves, isGroup) {
    for (var item in _irrigationLine!.sequence) {
      if (!isGroup) {
        if (item['valve'].any((valve) => valve['sNo']! == valves['sNo'])) {
          return true;
        }
      } else if (isGroup) {
        for(var valveInGroup in valves){
          if(item['valve'].any((valve) => valve['sNo']! == valveInGroup["sNo"])) {
            return true;
          }
        }
      }
    }
    return false;
  }
  void handleMultipleValvesMode(valves, valueToShow, titleIndex, serialNumber, sNo, isGroup) {
    if (_irrigationLine!.sequence.isEmpty && !isAgitator) {
      addSequence(valves, valueToShow, serialNumber, sNo, isGroup);
      isStartTogether = false;
    } else {
      var lastIndex = _irrigationLine!.sequence.length - 1;
      var selectedLength = _irrigationLine!.sequence[lastIndex]["selected"].length - 1;

      if (!_irrigationLine!.sequence[lastIndex]["selected"][selectedLength].startsWith("G")) {
        handleNonEmptySequence(valves, valueToShow, titleIndex, isGroup);
        groupAdding = false;
      } else {
        groupAdding = true;
      }
    }
  }

  void addSequence(valves, valueToShow, serialNumber, sNo, isGroup) {
    _irrigationLine!.sequence.add({
      "sNo": sNo,
      "id": 'SEQ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo',
      "name": 'Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo',
      "location": '',
      "valve": isGroup ? valves : [valves],
      "selected": [valueToShow]
    });
    zoneSnoList.add('${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    zoneNameList.add('Sequence ${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    programSNoList.add('${serialNumber == 0 ? serialNumberCreation : serialNumber}.$sNo');
    notifyListeners();
  }

  void handleNonEmptySequence(valves, valueToShow, titleIndex, isGroup) {
    int lastIndex = _irrigationLine!.sequence.length - 1;

    if (lastIndex >= 0) {
      dynamic lastItem = _irrigationLine!.sequence[lastIndex];
      List? sNoList = lastItem["valve"];
      isSameLine = lastItem['selected']!.every((item) {
        String itemString = item.toString();
        return itemString.startsWith(titleIndex.toString());
      });

      if (selectedProgramType == 'Agitator Program') {
        updateAgitatorProgram(valves, sNoList, valueToShow, lastItem);
      } else {
        updateNonAgitatorProgram(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
      }
    }
  }

  void updateAgitatorProgram(valves, sNoList, valueToShow, lastItem) {
    sNoList?.add(valves);
    List<String>? selectedList = lastItem["selected"]?.cast<String>();
    selectedList?.add(valves['name']);
  }

  void updateNonAgitatorProgram(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    if (irrigationLine!.defaultData.startTogether) {
      handleStartTogether(valves, sNoList, valueToShow, lastItem);
    } else {
      handleNonStartTogether(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
    }
  }

  void handleStartTogether(valves, sNoList, valueToShow, lastItem) {
    if (irrigationLine!.defaultData.reuseValve || !sNoList!.any((element) => element['sNo'] == valves['sNo'])) {
      print("yes");
      isReuseValve = false;
      sNoList?.add(valves);
      List<String>? selectedList = lastItem["selected"]?.cast<String>();
      selectedList?.add(valueToShow);
    } else {
      print("no");
      isReuseValve = true;
    }
  }

  void handleNonStartTogether(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    if (isSameLine) {
      handleSameLine(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup);
    } else {
      isStartTogether = true;
    }
  }

  void handleSameLine(valves, sNoList, valueToShow, lastItem, titleIndex, isGroup) {
    print("handleSameLine");
    if (!irrigationLine!.defaultData.startTogether) {
      if (!isGroup) {
        if (!sNoList!.any((element) => element['sNo'] == valves['sNo'])) {
          isReuseValve = false;
          sNoList?.add(valves);
          List<String>? selectedList = lastItem["selected"]?.cast<String>();
          selectedList?.add(valueToShow);
          isStartTogether = false;
        } else {
          if (irrigationLine!.defaultData.reuseValve) {
            sNoList?.add(valves);
            List<String>? selectedList = lastItem["selected"]?.cast<String>();
            selectedList?.add(valueToShow);
            isReuseValve = false;
          } else {
            isReuseValve = true;
          }
        }
      } else {
        isStartTogether = false;
      }
    } else {
      isStartTogether = false;
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
  bool isNext = false;
  bool isMultipleValveMode = false;
  void enableMultipleValveMode() {
    isSingleValveMode = false;
    isMultipleValveMode = true;
    isDelete = false;
    isNext = false;
    notifyListeners();
  }

  void enableSingleValveMode() {
    isSingleValveMode = true;
    isMultipleValveMode = false;
    isDelete = false;
    isNext = false;
    notifyListeners();
  }

  bool isDelete = false;
  void deleteFunction() {
    isDelete = true;
    isMultipleValveMode = false;
    isSingleValveMode = false;
    isNext = false;
    notifyListeners();
  }

  void enableSkipNex() {
    isDelete = false;
    isMultipleValveMode = true;
    isSingleValveMode = false;
    isNext = true;
    notifyListeners();
  }

  void deleteButton() {
    _irrigationLine!.sequence.clear();
    notifyListeners();
  }

  bool isSelected(valveIndex, titleIndex, isGroup, bigScreen, valve) {
    final String valueToShow = isGroup ? 'G${valveIndex + 1}' : '${titleIndex + 1}.${valveIndex + 1}';

    return bigScreen
        ? _irrigationLine!.sequence.any((list) => list['valve']!.any((v) => v['name'] == valve))
        : _irrigationLine!.sequence.any((list) => list['selected']!.contains(valueToShow)) || _irrigationLine!.sequence.any((list) => list['valve']!.any((v) => v['name'] == valve));
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
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "noOfDays": "00", "startDate": DateTime.now().toString(), "type" : [] },
            },
            "scheduleByDays" : {
              "rtc" : {
                "rtc1": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
                "rtc2": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "0", "maxTime": "00:00", "condition": false},
              },
              "schedule": { "startDate": DateTime.now().toString(), "runDays": "0", "skipDays": "0" }
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
    print(scheduleType);
    print(selectedRtc);
    print(property);
    print(newTime);
    if(scheduleType == sampleScheduleModel!.scheduleAsRunList){
      final selectedRtcKey = sampleScheduleModel!.scheduleAsRunList.rtc.keys.toList()[selectedRtcIndex1];
      sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey][property] = newTime;
      // print(sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey]['onTime']);
    } else {
      final selectedRtcKey = sampleScheduleModel!.scheduleByDays.rtc.keys.toList()[selectedRtcIndex2];
      sampleScheduleModel!.scheduleByDays.rtc[selectedRtcKey][property] = newTime;
      // print(sampleScheduleModel!.scheduleAsRunList.rtc[selectedRtcKey]['onTime']);
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
  SampleConditions? _sampleConditions;
  SampleConditions? get sampleConditions => _sampleConditions;
  bool conditionsLibraryIsNotEmpty = false;
  Future<void> getUserProgramCondition(int userId, int controllerId, int serialNumber) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber
      };
      var getUserProgramCondition = await httpService.postRequest('getUserProgramCondition', userData);
      if(getUserProgramCondition.statusCode == 200) {
        final responseJson = getUserProgramCondition.body;
        final convertedJson = jsonDecode(responseJson);
        _sampleConditions = SampleConditions.fromJson(convertedJson);
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

  void updateConditionType(newValue, conditionTypeIndex) {
    _sampleConditions!.condition[conditionTypeIndex].selected = newValue;
    notifyListeners();
  }

  void updateConditions(title, sNo, newValue, conditionTypeIndex) {
    print('$title, $sNo, $newValue, $conditionTypeIndex');
    _sampleConditions!.condition[conditionTypeIndex].value = {
      "sNo": sNo,
      "name" : newValue
    };
    notifyListeners();
  }

  //TODO: WATER AND FERT PROVIDER
  int sequenceSno = 0;
  List<dynamic> sequenceData = [];
  List<dynamic> serverDataWM = [];
  List<dynamic> channelData = [];
  int selectedGroup = 0;
  int selectedCentralSite = 0;
  int selectedLocalSite = 0;
  int selectedInjector = 0;
  List<dynamic> sequence = [];
  String radio = 'set individual';
  dynamic apiData = {};
  dynamic constantSetting = {};
  dynamic fertilizerSet = [];
  int segmentedControlGroupValue = 0;
  int segmentedControlCentralLocal = 0;
  TextEditingController waterQuantity = TextEditingController();
  TextEditingController preValue = TextEditingController();
  TextEditingController postValue = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController ph = TextEditingController();
  TextEditingController injectorValue = TextEditingController();
  ScrollController scrollControllerGroup = ScrollController();
  ScrollController scrollControllerSite = ScrollController();
  ScrollController scrollControllerInjector = ScrollController();

  Map<int, Widget> myTabs = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Water",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Fert",style: TextStyle(color: Colors.white)),
    ),
  };
  Map<int, Widget> cOrL = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Central",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Local",style: TextStyle(color: Colors.black)),
    ),
  };

  editFertilizerSet(dynamic data){
    fertilizerSet = data;
    notifyListeners();
  }

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
    };
    notifyListeners();
  }
  void editSegmentedCentralLocal(int value){
    segmentedControlCentralLocal = value;
    selectedCentralSite = 0;
    selectedLocalSite = 0;
    selectedInjector = 0;
    print('first');
    if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length != 0){
      ec.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['ecValue'].toString() ?? '';
      ph.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['phValue'].toString() ?? '';
      injectorValue.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'].toString() ?? '';
    }
    cOrL = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Central",style: TextStyle(color: segmentedControlCentralLocal == 0 ? Colors.white : Colors.black),),
      ),
      1: Padding(
        padding: const EdgeInsets.all(5),
        child: Text("Local",style: TextStyle(color: segmentedControlCentralLocal == 1 ? Colors.white : Colors.black)),
      ),
    };
    notifyListeners();
  }

  // void updateSequenceForFert(List<dynamic> sequenceData){
  //   sequence = [];
  //   for(var i in sequenceData){
  //     var seq = '';
  //     for(var j in i['selected']){
  //       seq += '${seq.isNotEmpty ? ' & ' : ''}$j';
  //     }
  //     sequence.add(seq);
  //   }
  //   notifyListeners();
  // }
  var waterAndFertData = [];

  void editApiData(dynamic value){
    apiData = value;
    notifyListeners();
  }
  void editConstantSetting(dynamic value){
    constantSetting = value;
    notifyListeners();
  }
  void waterAndFert(){

    var central = [];
    var local = [];
    for(var site in apiData['fertilization']){
      if(site['id'].contains('CFESI')){
        central.add(site);
      }else{
        local.add(site);
      }
    }
    for(var i in _irrigationLine!.sequence){
      var myCentral = [];
      var myLocal = [];
      var valList = [];
      for(var vl in i['valve']){
        if(!valList.contains(vl['location'])){
          valList.add(vl['location']);
        }
      }
      // this process is to find the central site for the sequence
      for(var cd in central){
        line : for(var il in cd['irrigationLine']){
          if(valList.contains(il['id'])){
            var createSite = {
              'sNo' : cd['sNo'],
              'name' : cd['name'],
              'id' : cd['id'],
              'location' : cd['location'],
              'recipe' : '-'
            };
            var fertilizer = [];
            for(var fert in cd['fertilizer']){
              fert['method'] = 'Time';
              fert['timeValue'] = '00:00:00';
              fert['quantityValue'] = '';
              fert['onOff'] = false;
              fertilizer.add(fert);
            }
            if(cd['ecSensor'].length != 0){
              createSite['ecValue'] = 0;
              createSite['needEcValue'] = false;
            }
            if(cd['phSensor'].length != 0){
              createSite['phValue'] = 0;
              createSite['needPhValue'] = false;
            }
            createSite['fertilizer'] = fertilizer;
            myCentral.add(createSite);
            break line;
          }
        }
      }
      // process end for central
      // this process is to find the Local site for the sequence
      for(var ld in local){
        if(valList.contains(ld['id'])){
          var createSite = {
            'sNo' : ld['sNo'],
            'name' : ld['name'],
            'id' : ld['id'],
            'location' : ld['location'],
            'recipe' : '-'
          };
          var fertilizer = [];
          for(var fert in ld['fertilizer']){
            fert['method'] = 'Time';
            fert['timeValue'] = '00:00:00';
            fert['quantityValue'] = '';
            fert['onOff'] = false;
            fertilizer.add(fert);
          }
          if(ld['ecSensor'].length != 0){
            createSite['ecValue'] = 0;
            createSite['needEcValue'] = false;
          }
          if(ld['phSensor'].length != 0){
            createSite['phValue'] = 0;
            createSite['needPhValue'] = false;
          }
          createSite['fertilizer'] = fertilizer;
          myLocal.add(createSite);
        }
      }
      // process end for local
      sequenceData.add({
        'sNo' : i['sNo'],
        'valve' : i['valve'],
        'name' : giveNameForSequence(i),
        'prePostMethod' : 'Time',
        'preValue' : '00:00:00',
        'postValue' : '00:00:00',
        'method' : 'Time',
        'timeValue' : '00:00:00',
        'quantityValue' : '0',
        'centralDosing' : myCentral,
        'localDosing' : myLocal,
        'selectedCentralSite' : -1,
        'selectedLocalSite' : -1,
      });
    }
    waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
    preValue.text = sequenceData[selectedGroup]['preValue'] ?? '';
    postValue.text = sequenceData[selectedGroup]['postValue'] ?? '';
    ec.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['ecValue'].toString() ?? '';
    ph.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['phValue'].toString() ?? '';
    print('sequenceData : ${jsonEncode(sequenceData)}');
    notifyListeners();
  }

  String fertMethodHw(String value){
    switch (value){
      case ('Time'):{
        return '1';
      }
      case ('Pro.time'):{
        return '1';
      }
      case ('Quantity'):{
        return '2';
      }
      case ('Pro.quantity'):{
        return '2';
      }
      default : {
        return '0';
      }
    }
  }

  void hwPayloadForWF(){
    var wf = '';
    for(var sq in sequenceData){
      var valId = '';
      for(var vl in sq['valve']){
        valId += '${valId.length != 0 ? ',' : ''}${vl['id']}';
      }
      var centralMethod = '';
      var centralTimeAndQuantity = '';
      var localMethod = '';
      var localTimeAndQuantity = '';
      var centralEC = '';
      var centralPH = '';
      var localEC = '';
      var localPH = '';
      if(sq['selectedCentralSite'] == -1){
        centralMethod = '________';
        centralTimeAndQuantity += '________';
      }else{
        var fertList = [];
        for(var ft in sq['centralDosing'][sq['selectedCentralSite']]['fertilizer']){
          centralMethod += '${centralMethod.length != 0 ? '_' : ''}${fertMethodHw(ft['method'])}';
          centralTimeAndQuantity += '${centralTimeAndQuantity.length != 0 ? '_' : ''}${ft['method'].contains('ime') ? ft['timeValve'] : ft['quantityValue']}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          centralMethod += '_';
          centralTimeAndQuantity += '_';
        }
      }
      if(sq['selectedLocalSite'] == -1){
        localMethod = '________';
        localTimeAndQuantity += '________';
      }else{
        var fertList = [];
        for(var ft in sq['localDosing'][sq['selectedLocalSite']]['fertilizer']){
          localMethod += '${localMethod.length != 0 ? '_' : ''}${fertMethodHw(ft['method'])}';
          localTimeAndQuantity += '${localTimeAndQuantity.length != 0 ? '_' : ''}${(ft['method'] == 'Time' || ft['method'] == 'Pro.time') ?  ft['timeValve'] : ft['quantityValue']}';
          fertList.add(fertMethodHw(ft['method']));
        }
        for(var coma = fertList.length;coma < 8;coma++){
          localMethod += '_';
          localTimeAndQuantity += '_';
        }
      }
      for(var ft in sq['centralDosing'])
        wf += '${wf.length != 0 ? ';' : ''}'
            '${sq['sNo']},${0},${sq['name']},'
            '${valId},,${10000},${sq['method'] == 'Time' ? 1 : 2},'
            '${sq['method'] == 'Time' ? sq['timeValue'] : sq['quantityValue']},'
            '${sq['selectedCentralSite'] == -1 ? 0 : 1},'
            '${sq['selectedLocalSite'] == -1 ? 0 : 1},'
            '${sq['prePostMethod'] == 'Time' ? 0 : 1},'
            '${sq['preValue']},'
            '${sq['postValue']},'
            '${centralMethod},'
            '${localMethod},'
            '${centralTimeAndQuantity},'
            '${localTimeAndQuantity}';
    }
    print('water and fert : ${wf}');
  }

  void editWaterSetting(String title, String value){
    if(title == 'method'){
      sequenceData[selectedGroup]['method'] = value;
    }else if(title == 'timeValue'){
      sequenceData[selectedGroup]['timeValue'] = value;
    }else if(title == 'quantityValue'){
      sequenceData[selectedGroup]['quantityValue'] = value;
    }
    notifyListeners();
  }
  //TODO : edit ec ph in central and local
  void editGroupSiteInjector(String title,int value){
    switch(title){
      case ('selectedGroup'):{
        selectedGroup = value;
        waterQuantity.text = sequenceData[selectedGroup]['quantityValue'] ?? '';
        break;
      }
      case ('selectedCentralSite'):{
        selectedCentralSite = value;
        if(sequenceData[selectedGroup]['centralDosing'].length != 0){
          ec.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          injectorValue.text = sequenceData[selectedGroup]['centralDosing'][selectedCentralSite]['fertilizer'][selectedInjector]['quantityValue'];
        }
        break;
      }
      case ('selectedLocalSite'):{
        selectedLocalSite = value;
        if( sequenceData[selectedGroup]['localDosing'].length != 0){
          ec.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['ecValue'].toString() ?? '';
          ph.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['phValue'].toString() ?? '';
          selectedInjector = 0;
          injectorValue.text = sequenceData[selectedGroup]['localDosing'][selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] ?? '';
        }
        break;
      }
      case ('selectedInjector'):{
        selectedInjector = value;
        injectorValue.text = sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][selectedLocalSite]['fertilizer'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['quantityValue'] ?? '';
        break;
      }
    }
    notifyListeners();
  }
  void editNext(){
    if(segmentedControlGroupValue == 1){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'].length - 1 != selectedInjector){
        editGroupSiteInjector('selectedInjector',selectedInjector + 1);
      }else if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length - 1 != (segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite)){
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) + 1);
      }else if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',0);
        editGroupSiteInjector('selectedInjector', 0);
      }
    }else{
      if(sequenceData.length - 1 != selectedGroup){
        editGroupSiteInjector('selectedGroup',selectedGroup + 1);
      }
    }

    notifyListeners();
  }
  void editBack(){
    if(segmentedControlGroupValue == 1){
      if(selectedInjector != 0){
        editGroupSiteInjector('selectedInjector',selectedInjector - 1);
      }else if((segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) != 0){
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',(segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite) - 1);
      }else if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
        editGroupSiteInjector(segmentedControlCentralLocal == 0 ? 'selectedCentralSite' : 'selectedLocalSite',sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'].length -1);
        editGroupSiteInjector('selectedInjector', sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['fertilizer'].length -1);
      }
    }else{
      if(selectedGroup != 0){
        editGroupSiteInjector('selectedGroup',selectedGroup - 1);
      }
    }
    notifyListeners();
  }

  void editEcPhNeedOrNot(String title){
    if(title == 'ec'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needEcValue'] = true;
      }
    }else if(title == 'ph'){
      if(sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] == true){
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] = false;
      }else{
        sequenceData[selectedGroup][segmentedControlCentralLocal == 0 ? 'centralDosing' : 'localDosing'][segmentedControlCentralLocal == 0 ? selectedCentralSite : selectedLocalSite]['needPhValue'] = true;
      }    }
    notifyListeners();
  }
  void editEcPh(String title,String ecOrPh, String value){
    if(title == 'centralDosing'){
      sequenceData[selectedGroup]['centralDosing'][selectedCentralSite][ecOrPh] = value;
    }else if(title == 'localDosing'){
      print(value);
      sequenceData[selectedGroup]['localDosing'][selectedLocalSite][ecOrPh] = value;
    }
    notifyListeners();
  }

  int waterValueInSec(){
    int sec = 0;
    if(sequenceData[selectedGroup]['method'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['timeValue'].split(':');
      sec = (int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]));
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }

          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['quantityValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['quantityValue'] != '' ? int.parse(sequenceData[selectedGroup]['quantityValue']) : 0)/valveFlowRate) as int;
      }
    }
    print('water finished');
    return sec;
  }
  double preValueInSec(){
    double sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['preValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]).toDouble();
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }
      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      print('nominalFlowRate : $nominalFlowRate');
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['preValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['preValue'] != '' ? int.parse(sequenceData[selectedGroup]['preValue']) : 0)/valveFlowRate);
      }
    }
    print('pre in seconds : $sec');
    return sec;
  }
  double postValueInSec(){
    double sec = 0;
    if(sequenceData[selectedGroup]['prePostMethod'] == 'Time'){
      var splitTime = sequenceData[selectedGroup]['postValue'].split(':');
      sec = int.parse(splitTime[0]) * 3600 + int.parse(splitTime[1]) * 60 + int.parse(splitTime[2]).toDouble();
    }else{
      var nominalFlowRate = [];
      var sno = [];
      for(var val in sequenceData[selectedGroup]['valve']){
        for(var i = 0;i < constantSetting['valve'].length;i++){
          for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
            if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
              if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
                if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                  sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                  nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
                }
              }
            }
          }
        }

      }
      var totalFlowRate = 0;
      for(var flwRate in nominalFlowRate){
        totalFlowRate = totalFlowRate + int.parse(flwRate);
      }
      var valveFlowRate = totalFlowRate * 0.00027778;
      if(sequenceData[selectedGroup]['postValue'] == '0'){
        sec = 0;
      }else{
        sec = ((sequenceData[selectedGroup]['postValue'] != '' ? int.parse(sequenceData[selectedGroup]['postValue']) : 0)/valveFlowRate);
      }
    }
    return sec;
  }
  double flowRate(){
    var nominalFlowRate = [];
    var sno = [];
    for(var val in sequenceData[selectedGroup]['valve']){
      print('valve >>> ${val['sNo']}');
      for(var i = 0;i < constantSetting['valve'].length;i++){
        for(var j = 0;j < constantSetting['valve'][i]['valve'].length;j++){
          if(!sno.contains(constantSetting['valve'][i]['valve'][j]['sNo'])){
            if('${val['sNo']}' == '${constantSetting['valve'][i]['valve'][j]['sNo']}'){
              if(constantSetting['valve'][i]['valve'][j]['nominalFlow'] != ''){
                sno.add(constantSetting['valve'][i]['valve'][j]['sNo']);
                nominalFlowRate.add(constantSetting['valve'][i]['valve'][j]['nominalFlow']);
              }
            }
          }
        }
      }

    }
    var totalFlowRate = 0;
    print('nominalFlowRate : ${nominalFlowRate}');
    for(var flwRate in nominalFlowRate){
      totalFlowRate = totalFlowRate + int.parse(flwRate);
    }
    var valveFlowRate = totalFlowRate * 0.00027778;
    return valveFlowRate;
  }

  //TODO : edit pre post in fert segment
  void editPrePostMethod(String title,int index,String value){
    switch (title){
      case 'prePostMethod' :{
        if(value == 'Time'){
          sequenceData[index]['preValue'] = '00:00:00';
          sequenceData[index]['postValue'] = '00:00:00';
        }else{
          sequenceData[index]['preValue'] = '0';
          sequenceData[index]['postValue'] = '0';
          preValue.text = '0';
          postValue.text = '0';
        }
        sequenceData[index]['prePostMethod'] = value;
        break;
      }
      case 'preValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          print('waterValueInSec() : ${waterValueInSec()}');
          print('postValueInSec() : ${postValueInSec()}');
          var diff = waterValueInSec() - postValueInSec();
          print('flowRate() : ${flowRate()}');
          var quantity = diff * flowRate();
          print('pre diff : ${quantity.round()}');
          print('pre diff1 : ${quantity}');

          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['preValue'] = '${quantity.toInt()}';
            preValue.text = '${quantity.toInt()}';
          }else{
            sequenceData[index]['preValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['preValue'] = value;
        }
        break;
      }
      case 'postValue' :{
        if(sequenceData[index]['prePostMethod'] != 'Time'){
          var diff = waterValueInSec() - preValueInSec();
          var quantity = diff * flowRate();
          print('post diff : ${quantity}');
          if(int.parse(value) >= quantity.toInt()){
            sequenceData[index]['postValue'] = '${quantity.toInt()}';
            postValue.text = '${quantity.toInt()}';
          }else{
            sequenceData[index]['postValue'] = (value == '' ? '0' : value);
          }
        }else{
          sequenceData[index]['postValue'] = value;
        }
        break;
      }

    }
    notifyListeners();
  }
  void editSelectedSite(String centralOrLocal,dynamic value){
    if(centralOrLocal == 'centralDosing'){
      sequenceData[selectedGroup]['selectedCentralSite'] = sequenceData[selectedGroup]['selectedCentralSite'] == value ? -1 : value;
    }else{
      sequenceData[selectedGroup]['selectedLocalSite'] = sequenceData[selectedGroup]['selectedLocalSite'] == value ? -1 : value;
    }
    notifyListeners();
  }

  void editOnOffInInjector(String centralOrLocal,int index,bool value){
    sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][index]['onOff'] = value;
    notifyListeners();
  }

  void editParticularChannelDetails(String title,String centralOrLocal,dynamic value){
    switch(title){
      case ('method') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['method'] = value;
        break;
      }
      case ('quantityValue') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['quantityValue'] = value;
        break;
      }
      case ('timeValue') : {
        sequenceData[selectedGroup][centralOrLocal][centralOrLocal == 'centralDosing' ? selectedCentralSite : selectedLocalSite]['fertilizer'][selectedInjector]['timeValue'] = value;
        break;
      }
    }
    notifyListeners();
  }

  String giveNameForSequence(dynamic data){
    var name = '';
    for(var i in data['selected']){
      name += '${name.length != 0 ? '&' : ''}$i';
    }
    return name;
  }


  void dataToWF() {
    serverDataWM = [];
    List<dynamic> mySequence = [];
    mySequence = List.from(_irrigationLine!.sequence);

    for (var index = 0; index < mySequence.length; index++) {
      var sequence = mySequence[index];

      var seq = '';
      for (var vl in sequence['selected']) {
        seq += '${seq.isNotEmpty ? ' & ' : ''}$vl';
      }

      check: for (var i in sequenceData) {
        for (var j in i.entries) {
          if (j.key == seq) {
            sequence['water&fert'] = [j.value];
            // log("sequence['water&fert'] : ${sequence['water&fert']}");
            break check;
          }
        }
      }
      serverDataWM.add(sequence);
    }
    notifyListeners();
  }

  //TODO: SELECTION PROVIDER
  SelectionModel _selectionModel = SelectionModel();
  SelectionModel get selectionModel => _selectionModel;

  void updateSelectionModel(SelectionModel newSelectionModel) {
    _selectionModel = newSelectionModel;
    notifyListeners();
  }
  List<String> filtrationModes = ['TIME', 'DP', 'BOTH'];
  String get selectedCentralFiltrationMode => _selectionModel.data?.additionalData?.centralFiltrationOperationMode ?? "TIME";
  String get selectedLocalFiltrationMode => _selectionModel.data?.additionalData?.localFiltrationOperationMode ?? "TIME";

  void updateFiltrationMode(newValue, bool isCentral) {
    if(isCentral) {
      _selectionModel.data?.additionalData?.centralFiltrationOperationMode = newValue;
    } else {
      _selectionModel.data?.additionalData?.localFiltrationOperationMode = newValue;
    }
    notifyListeners();
  }

  bool get isPumpStationMode => _selectionModel.data?.additionalData?.pumpStationMode ?? false;
  bool get isProgramBasedSet => _selectionModel.data?.additionalData?.programBasedSet ?? false;
  void updatePumpStationMode(newValue, title) {
    switch(title) {
      case "Pump Station Mode": _selectionModel.data?.additionalData?.pumpStationMode = newValue;
      break;
      case "Program based set selection": _selectionModel.data?.additionalData?.programBasedSet = newValue;
      break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  bool get centralFiltBegin => _selectionModel.data?.additionalData?.centralFiltrationBeginningOnly ?? false;
  bool get localFiltBegin => _selectionModel.data?.additionalData?.localFiltrationBeginningOnly ?? false;
  void updateFiltBegin(newValue, isCentral) {
    if(isCentral) {
      _selectionModel.data?.additionalData?.centralFiltrationBeginningOnly = newValue;
    } else {
      _selectionModel.data?.additionalData?.localFiltrationBeginningOnly = newValue;
    }
    notifyListeners();
  }

  Future<void> getUserProgramSelection(int userId, int controllerId, int serialNumber) async {
    var userData = {
      "userId": userId,
      "controllerId": controllerId,
      "serialNumber": serialNumber
    };
    try {
      final response = await HttpService().postRequest("getUserProgramSelection", userData);
      final jsonData = json.decode(response.body);
      if (jsonData['data']['additionalData'] != null) {
        _selectionModel = SelectionModel.fromJson(jsonData);
        // print(_selectionModel.data!.centralFertilizerSet!.centralFertilizerSet.map((e) => e.name));
        // print(_selectionModel.data!.localFertilizerSet!.centralFertilizerSet.map((e) => e.name));
      } else {
        jsonData['data']['additionalData'] = {
          "centralFiltrationOperationMode": "TIME",
          "localFiltrationOperationMode": "TIME",
          "centralFiltrationBeginningOnly": false,
          "localFiltrationBeginningOnly": false,
          "pumpStationMode": false,
          "programBasedSet": false
        };
        _selectionModel = SelectionModel.fromJson(jsonData);
      }
    } catch (e) {
      log('Error: $e');
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void updateSelectedItem(title, id) {
    switch(title) {
      case 'EC Sensors For central':
        for (int i = 0; i < selectionModel.data!.ecSensor!.length; i++) {
          var site = selectionModel.data!.centralFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.ecSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.ecSensor![i].id == id) {
              selectionModel.data!.ecSensor![i].selected = !selectionModel.data!.ecSensor![i].selected!;
            } else {
              if(selectionModel.data!.ecSensor![i].location!.startsWith("CFESI")) {
                selectionModel.data!.ecSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.ecSensor![i].location!.startsWith("CFESI")) {
              selectionModel.data!.ecSensor![i].selected = false;
            }
          }
        }
        break;
      case 'EC Sensors For local':
        for (int i = 0; i < selectionModel.data!.ecSensor!.length; i++) {
          var site = selectionModel.data!.localFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.ecSensor![i].location, orElse: () => NameData());
          if (site.selected == true) {
            if (selectionModel.data!.ecSensor![i].id == id) {
              selectionModel.data!.ecSensor![i].selected = !selectionModel.data!.ecSensor![i].selected!;
            } else {
              if(selectionModel.data!.ecSensor![i].location!.startsWith("IL")) {
                selectionModel.data!.ecSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.ecSensor![i].location!.startsWith("IL")) {
              selectionModel.data!.ecSensor![i].selected = false;
            }
          }
        }
        break;
      case 'pH Sensors For central':
        for (int i = 0; i < selectionModel.data!.phSensor!.length; i++) {
          var site = selectionModel.data!.centralFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.phSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.phSensor![i].id == id) {
              selectionModel.data!.phSensor![i].selected = !selectionModel.data!.phSensor![i].selected!;
            } else {
              if(selectionModel.data!.phSensor![i].location!.startsWith("CFESI")) {
                selectionModel.data!.phSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.phSensor![i].location!.startsWith("CFESI")) {
              selectionModel.data!.phSensor![i].selected = false;
            }
          }
        }
        break;
      case 'pH Sensors For local':
        for (int i = 0; i < selectionModel.data!.phSensor!.length; i++) {
          var site = selectionModel.data!.localFertilizerSite!
              .firstWhere((site) => site.id == selectionModel.data!.phSensor![i].location, orElse: () => NameData());

          if (site.selected == true) {
            if (selectionModel.data!.phSensor![i].id == id) {
              selectionModel.data!.phSensor![i].selected = !selectionModel.data!.phSensor![i].selected!;
            } else {
              if(selectionModel.data!.phSensor![i].location!.startsWith("IL")) {
                selectionModel.data!.phSensor![i].selected = false;
              }
            }
          } else {
            if(selectionModel.data!.phSensor![i].location!.startsWith("IL")) {
              selectionModel.data!.phSensor![i].selected = false;
            }
          }
        }
        break;
      case 'Central Fertilizer Set':
        for (var fertilizerSet in selectionModel.data!.centralFertilizerSet!) {
          bool hasSelectedSite = selectionModel.data!.centralFertilizerSite!
              .any((site) => site.id == (fertilizerSet.recipe.isNotEmpty
              ? fertilizerSet.recipe.first.location
              : null) && site.selected == true);

          if (hasSelectedSite) {
            if (fertilizerSet.recipe.any((element) => element.selected == true)) {
              if(fertilizerSet.recipe.firstWhere((element) => element.selected == true).id == id){
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = false;
              } else {
                fertilizerSet.recipe.firstWhere((element) => element.selected == true).selected = false;
                fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
              }
            } else {
              fertilizerSet.recipe.firstWhere((element) => element.id == id).selected = true;
            }
          }
        }

        break;
      case 'Local Fertilizer Set':
        selectionModel.data!.localFertilizerSet!.forEach((fertilizerSet) {
          bool hasSelectedSite = selectionModel.data!.localFertilizerSite!
              .any((site) => site.id == (fertilizerSet.recipe.isNotEmpty
              ? fertilizerSet.recipe.first.location
              : null) && site.selected == true);

          if (hasSelectedSite) {
            for (var i = 0; i < fertilizerSet.recipe.length; i++) {
              if(fertilizerSet.recipe[i].id == id) {
                fertilizerSet.recipe[i].selected = !fertilizerSet.recipe[i].selected;
              }
            }
          }
        });
        break;
      default:
        log('No match found');
    }
    notifyListeners();
  }

  void selectItem(int index, String title) {
    switch (title) {
      case 'List of Valves':
        selectionModel.data!.mainValve![index].selected = !selectionModel.data!.mainValve![index].selected!;
        break;
      case 'List of Pump':
        selectionModel.data!.irrigationPump![index].selected = !selectionModel.data!.irrigationPump![index].selected!;
        break;
      case 'Central Fertilizer Site':
        if(selectionModel.data!.centralFertilizerSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.centralFertilizerSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.centralFertilizerSite![oldIndex].selected = !selectionModel.data!.centralFertilizerSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.centralFertilizerSite![index].selected = false;
          } else{
            selectionModel.data!.centralFertilizerSite![index].selected = true;
          }
        } else {
          selectionModel.data!.centralFertilizerSite![index].selected = true;
        }
        break;
      case 'Central Fertilizer Injector':
        selectionModel.data!.centralFertilizerInjector![index].selected = !selectionModel.data!.centralFertilizerInjector![index].selected!;
        break;
      case 'Local Fertilizer Site':
        if(selectionModel.data!.localFertilizerSite!.any((element) => element.selected == true)) {
          int oldIndex = selectionModel.data!.localFertilizerSite!.indexWhere((element) => element.selected == true);
          selectionModel.data!.localFertilizerSite![oldIndex].selected = !selectionModel.data!.localFertilizerSite![oldIndex].selected!;
          if(oldIndex == index){
            selectionModel.data!.localFertilizerSite![index].selected = false;
          } else{
            selectionModel.data!.localFertilizerSite![index].selected = true;
          }
        } else {
          selectionModel.data!.localFertilizerSite![index].selected = true;
        }
        break;
      case 'Local Fertilizer Injector':
        selectionModel.data!.localFertilizerInjector![index].selected = !selectionModel.data!.localFertilizerInjector![index].selected!;
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
  List<String> priorityList2 = ["High", "Low"];
  bool isCompletionEnabled = false;
  List<int> priorityList = [];
  List<String> programTypes = [];
  String selectedProgramType = '';

  int serialNumberCreation = 0;
  bool irrigationProgramType = false;

  List<int> serialNumberList = [];
  ProgramDetails? _programDetails;
  ProgramDetails? get programDetails => _programDetails;
  String get delayBetweenZones => _programDetails!.delayBetweenZones;
  String get adjustPercentage => _programDetails!.adjustPercentage;
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
        // if(_programDetails != null) {
        programName = serialNumber == 0
            ? "Program $programCount"
            : _programDetails!.programName.isEmpty
            ? _programDetails!.defaultProgramName
            : _programDetails!.programName;
        // } else {
        //   programName = _programDetails!.defaultProgramName;
        // }
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

      var getUserProgramName = await httpService.postRequest('getUserProgramLibrary', userData);

      if (getUserProgramName.statusCode == 200) {
        final responseJson = getUserProgramName.body;
        final convertedJson = jsonDecode(responseJson);
        _programLibrary = ProgramLibrary.fromJson(convertedJson);
        priorityList = List.generate(_programLibrary!.program.length, (index) => (index + 1));
        priority = _programDetails?.priority ?? 0;
        agitatorCountIsNotZero = convertedJson['data']['agitatorCount'] != 0 ? true : false;
        conditionsLibraryIsNotEmpty = convertedJson['data']['conditionLibraryCount'] != 0 ? true : false;
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

  void updatePriority(newValue, index) {
    _programLibrary?.program[index].priority = int.tryParse(newValue) ?? 0;
    notifyListeners();
  }

  void updateProgramName(dynamic newValue, String type) {
    switch (type) {
      case 'programName':programName = newValue != '' ? newValue : programName;
      break;
      case 'priority':priority = int.tryParse(newValue) ?? 0;
      break;
      case 'completion':isCompletionEnabled = newValue as bool;
      break;
      case 'programType':selectedProgramType = newValue as String;
      break;
      case"delayBetweenZones": _programDetails!.delayBetweenZones = newValue;
      break;
      case"adjustPercentage": _programDetails!.adjustPercentage = newValue;
      break;
      default:
        log("Not found");
    }
    notifyListeners();
  }

  bool isIrrigationProgram = false;
  bool isAgitatorProgram = false;
  bool showIrrigationPrograms = false;
  bool showAgitatorPrograms = false;
  bool showAllPrograms = true;
  bool isActive = true;

  void updateActiveProgram() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateShowPrograms(all, irrigation, agitator, active) {
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

  List<String> label1 = ['Sequence', 'Schedule', 'Conditions', 'Selection', 'Water & Fert', 'Alarm', 'Done'];
  List<IconData> icons1 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.fact_check,
    Icons.checklist,
    Icons.local_florist_rounded,
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

  List<String> label3 = ['Sequence', 'Schedule', 'Alarm', 'Done'];
  List<IconData> icons3 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  List<String> label4 = ['Sequence', 'Schedule', 'Selection', 'Water & Fert', 'Alarm', 'Done'];
  List<IconData> icons4 = [
    Icons.view_headline_rounded,
    Icons.calendar_month,
    Icons.checklist,
    Icons.local_florist_rounded,
    Icons.alarm_rounded,
    Icons.done_rounded,
  ];

  //TODO: UPDATE PROGRAM DETAILS
  Future<String> updateUserProgramDetails(
      int userId, int controllerId, int serialNumber, int programId, String programName, int priority) async {
    try {
      Map<String, dynamic> userData = {
        "userId": userId,
        "controllerId": controllerId,
        "serialNumber": serialNumber,
        "modifyUser": userId,
        "programId": programId,
        "programName": programName,
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
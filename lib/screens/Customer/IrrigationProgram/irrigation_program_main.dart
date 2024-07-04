import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/MQTTManager.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/program_library.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/schedule_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/selection_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/sequence_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/water_fert_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Models/IrrigationModel/sequence_model.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import 'alarm_screen.dart';
import 'conditions_screen.dart';
import 'done_screen.dart';

class IrrigationProgram extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  final String programType;
  final String deviceId;
  final bool conditionsLibraryIsNotEmpty;
  const IrrigationProgram({Key? irrigationProgramKey,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    required this.programType,
    required this.conditionsLibraryIsNotEmpty, required this.deviceId}) :super(key: irrigationProgramKey);

  @override
  State<IrrigationProgram> createState() => _IrrigationProgramState();
}

class _IrrigationProgramState extends State<IrrigationProgram> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IrrigationProgramMainProvider irrigationProvider = IrrigationProgramMainProvider();
  bool isPressed = false;
  final HttpService httpService = HttpService();
  final delete = const SnackBar(content: Center(child: Text('The sequence is erased!')));
  final singleSelection = const SnackBar(content: Center(child: Text('Single valve selection is enabled')));
  final multipleSelection = const SnackBar(content: Center(child: Text('Multiple valve selection is enabled')));
  dynamic apiData = {};
  dynamic waterAndFertData = [];


  @override
  void initState() {
    super.initState();
    final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    irrigationProvider.doneData(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramSequence(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.scheduleData(widget.userId, widget.controllerId, widget.serialNumber);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var programPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: false);
        getData(programPvd, widget.userId, widget.controllerId, widget.serialNumber);
      });
      irrigationProvider.updateTabIndex(0);
    }
    irrigationProvider.getUserProgramSelection(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramCondition(widget.userId, widget.controllerId, widget.serialNumber);
    irrigationProvider.alarmDataFetched(widget.userId, widget.controllerId, widget.serialNumber);
    _tabController = TabController(
      length: (widget.serialNumber == 0
          ? irrigationProvider.isIrrigationProgram
          : widget.programType == "Irrigation Program")
          ? irrigationProvider.conditionsLibraryIsNotEmpty ? irrigationProvider.label1.length : irrigationProvider.label4.length
          : irrigationProvider.conditionsLibraryIsNotEmpty ? irrigationProvider.label2.length : irrigationProvider.label3.length,
      vsync: this,
    );

    _tabController.addListener(() {
      irrigationProvider.updateTabIndex(_tabController.index);
    });
  }

  void getData(IrrigationProgramMainProvider programPvd, userId, controllerId, serialNumber)async{
    programPvd.clearWaterFert();
    try{
      HttpService service = HttpService();
      var fert = await service.postRequest('getUserPlanningFertilizerSet', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response = await service.postRequest('getUserProgramWaterAndFert', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var response1 = await service.postRequest('getUserConstant', {'userId' : userId,'controllerId' : controllerId, 'serialNumber': serialNumber});
      var jsonData = response.body;
      var jsonData1 = response1.body;
      var jsonData2 = fert.body;
      var myData = jsonDecode(jsonData);
      var myData1 = jsonDecode(jsonData1);
      var myData2 = jsonDecode(jsonData2);
      programPvd.editApiData(myData['data']['default']);
      programPvd.editSequenceData(myData['data']['waterAndFert']);
      programPvd.editRecipe(myData2['data']['fertilizerSet']['fertilizerSet']);
      programPvd.editConstantSetting(myData1['data']['constant']);
    }catch(e){
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    irrigationProvider.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    int selectedIndex = mainProvider.selectedTabIndex;

    if(mainProvider.irrigationLine != null || mainProvider.programDetails != null) {
      final program = mainProvider.programDetails!.programName.isNotEmpty
          ? mainProvider.programName == ''? "Program ${mainProvider.programCount+1}" : mainProvider.programName
          : mainProvider.programDetails!.defaultProgramName;
      return LayoutBuilder(
        builder: (context, constrains) {
          return DefaultTabController(
            length: (widget.serialNumber == 0
                ? mainProvider.isIrrigationProgram
                : widget.programType == "Irrigation Program")
                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length,
            child: Scaffold(
              appBar: AppBar(
                // title: Text(mainProvider.programName != '' ? mainProvider.programName : 'New Program'),
                title: Text(widget.serialNumber == 0 ? "New Program" : program),
                centerTitle: false,
                leading: IconButton(
                  onPressed: () {
                    mainProvider.programLibraryData(widget.userId, widget.controllerId, widget.serialNumber);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                bottom: constrains.maxWidth < 500
                    ?
                PreferredSize(
                  preferredSize: const Size.fromHeight(80.0),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.background,
                    child: TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      tabs: [
                        for (int i = 0; i <  ((widget.serialNumber == 0
                            ? mainProvider.isIrrigationProgram
                            : widget.programType == "Irrigation Program")
                            ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                            : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length); i++)
                          CustomTab(
                            height: 80,
                            label: (widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1[i] : mainProvider.label4[i]
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2[i] : mainProvider.label3[i],
                            content: (widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons1[i] : mainProvider.icons4[i]
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons2[i] : mainProvider.icons3[i],
                            tabIndex: i,
                            selectedTabIndex: mainProvider.selectedTabIndex,
                          ),
                      ],
                    ),
                  ),
                ) : null,
                actions: [
                  if (selectedIndex == 0) ...[
                    _buildIconButton(mainProvider.isSingleValveMode, Icons.fiber_manual_record_outlined, mainProvider.enableSingleValveMode, "Enable Single Valve mode"),
                    _buildIconButton(mainProvider.isMultipleValveMode, Icons.join_full_outlined, mainProvider.enableMultipleValveMode, "Enable Multiple Valve mode"),
                    // _buildIconButton(mainProvider.isNext, Icons.queue_play_next, mainProvider.enableSkipNex),
                    _buildIconButton(mainProvider.isDelete, Icons.delete, mainProvider.deleteFunction, "Delete the sequence"),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              body: Row(
                children: <Widget>[
                  if (constrains.maxWidth > 500)
                    SizedBox(
                      width: 250,
                      child: Drawer(
                        child: ListView(
                          children: [
                            for (int i = 0; i <  ((widget.serialNumber == 0
                                ? mainProvider.isIrrigationProgram
                                : widget.programType == "Irrigation Program")
                                ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                                : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length); i++)
                              ListTile(
                                  title: Text((widget.serialNumber == 0
                                      ? mainProvider.isIrrigationProgram
                                      : widget.programType == "Irrigation Program")
                                      ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1[i] : mainProvider.label4[i]
                                      : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2[i] : mainProvider.label3[i],
                                    style: TextStyle(color: _tabController.index == i ? Colors.white : null),),
                                  leading: Icon((widget.serialNumber == 0
                                      ? mainProvider.isIrrigationProgram
                                      : widget.programType == "Irrigation Program")
                                      ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons1[i] : mainProvider.icons4[i]
                                      : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.icons2[i] : mainProvider.icons3[i],
                                    color: _tabController.index == i ? Colors.white : null,),
                                  selected: _tabController.index == i,
                                  onTap: () {
                                    _navigateToTab(i);
                                  },
                                  selectedTileColor: _tabController.index == i ? Theme.of(context).primaryColor : null,
                                  hoverColor: _tabController.index == i ? Theme.of(context).primaryColor : null
                              ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children:  [
                        for (
                        int i = 0;
                        i < ((widget.serialNumber == 0
                            ? mainProvider.isIrrigationProgram
                            : widget.programType == "Irrigation Program")
                            ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length : mainProvider.label4.length
                            : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length : mainProvider.label3.length);
                        i++)
                          _buildTabContent(i, (widget.serialNumber == 0
                              ? mainProvider.isIrrigationProgram
                              : widget.programType == "Irrigation Program"), mainProvider.conditionsLibraryIsNotEmpty),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: _buildFloatingActionButton(selectedIndex),
            ),
          );
        },
      );
    } else {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }
  }

  Widget _buildTabContent(int index, bool isIrrigationProgram, conditionsLibraryIsNotEmpty) {
    if (isIrrigationProgram) {
      if(conditionsLibraryIsNotEmpty) {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return SelectionScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return WaterAndFertScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 5:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 6:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      } else {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return SelectionScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return WaterAndFertScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 5:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      }
    } else {
      if(conditionsLibraryIsNotEmpty) {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 4:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      } else {
        switch (index) {
          case 0:
            return SequenceScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 1:
            return ScheduleScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 2:
            return AlarmScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          case 3:
            return DoneScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
          default:
            return Container();
        }
      }
    }
  }

  Widget? _buildFloatingActionButton(int selectedIndex)  {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    var dataToMqtt = {};
    var userData = {
      "defaultProgramName": mainProvider.defaultProgramName,
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "createUser": widget.userId,
      "serialNumber": widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber,
    };
    var programCategory = '';
    // if((!mainProvider.isIrrigationProgram || widget.programType != "Irrigation Program" )&& mainProvider.irrigationLine!.sequence.isNotEmpty) {
    //   programCategory = mainProvider.irrigationLine!.sequence[0]['valve'][0]['location'];
    // }
    // List sNoList = mainProvider.irrigationLine?.sequence.map((e) {
    //   List valveSerialNumbers = e['valve'].map((valve) => valve['sNo']).toList();
    //   return valveSerialNumbers.join('+');
    // }).toList() ?? [];
    // String formattedSNo = sNoList.join('_');
    List<NameData>? selectedPumpsList = mainProvider.selectionModel.data?.irrigationPump?.where((element) => element.selected == true).toList();
    List<NameData>? selectedMainValveList = mainProvider.selectionModel.data?.mainValve?.where((element) => element.selected == true).toList();
    String selectedPump = selectedPumpsList?.join('_') ?? '';
    String mainValve = selectedMainValveList?.join('_') ?? '';
    List daySelectionList = [
      mainProvider.sampleScheduleModel!.scheduleByDays.schedule['skipDays'] ?? '0',
      mainProvider.sampleScheduleModel!.scheduleByDays.schedule['runDays'] ?? '0',
      // int.parse(mainProvider.sampleScheduleModel!.scheduleByDays.schedule['skipDays']),
      // int.parse(mainProvider.sampleScheduleModel!.scheduleByDays.schedule['runDays'])
    ];
    String daySelectionString = daySelectionList.join('_');

    dynamic getDaySelectionMode() {
      List typeData = mainProvider.sampleScheduleModel!.scheduleAsRunList.schedule['type'];
      var selectionModeList = [];
      for(var i = 0; i < typeData.length; i++) {
        switch(typeData[i]) {
          case "DO NOTHING":
            selectionModeList.add(0);
            break;
          case "DO WATERING":
            selectionModeList.add(1);
            break;
          case "DO ONE TIME":
            selectionModeList.add(2);
            break;
          case "DO FERTIGATION":
            selectionModeList.add(3);
            break;
        }
      }
      return selectionModeList.join('_');
    }

    List<String> generateRtcTimeList(Map<String, dynamic> rtcData, String key, bool isCycles) {
      return List.generate(6, (index) {
        final rtcKey = 'rtc${index + 1}';
        String rtcValue;

        if (key == 'noOfCycles') {
          rtcValue = index < rtcData.length ? rtcData[rtcKey]['noOfCycles'].toString() : '0';
        } else {
          rtcValue = index < rtcData.length ? '${rtcData[rtcKey][key]}' : '00:00';
        }

        return key == 'noOfCycles' ? rtcValue : '$rtcValue:00';
      });
    }

    String generateRtcTimeString(SampleScheduleModel model, String type, bool isRunList) {
      final rtcTimeList = generateRtcTimeList(isRunList ? model.scheduleAsRunList.rtc : model.scheduleByDays.rtc, type, false);
      return rtcTimeList.join('_');
    }

    String generateFilterSiteString(List<NameData>? dataList, String idField) {
      final selectedIds = dataList?.where((element) => element.selected == true).map((element) => element.id ?? "").toList() ?? [];
      return selectedIds.join('_');
    }

    String generateFertilizerString(List<NameData>? dataList, String idField) {
      final selectedIds = dataList?.where((element) => element.selected == true).map((element) => element.id ?? "").toList() ?? [];
      return selectedIds.join('_');
    }

    String generateFertilizerLocationString(List<NameData>? dataList, String locationField) {
      final selectedLocations = dataList?.where((element) => element.selected == true).map((element) => element.location ?? "").toList() ?? [];
      return selectedLocations.join('_');
    }

    final sampleScheduleModel = mainProvider.sampleScheduleModel!;

    String sBRrtcOnTimeString = generateRtcTimeString(sampleScheduleModel, 'onTime', true);
    String sBDrtcOnTimeString = generateRtcTimeString(sampleScheduleModel, 'onTime', false);
    String sBRrtcMaxTimeString = generateRtcTimeString(sampleScheduleModel, 'maxTime', true);
    String sBDrtcMaxTimeString = generateRtcTimeString(sampleScheduleModel, 'maxTime', false);
    String sBRrtcOffTimeString = generateRtcTimeString(sampleScheduleModel, 'offTime', true);
    String sBDrtcOffTimeString = generateRtcTimeString(sampleScheduleModel, 'offTime', false);
    String sBRrtcNoOfCyclesString = generateRtcTimeString(sampleScheduleModel, 'noOfCycles', true);
    String sBDrtcNoOfCyclesString = generateRtcTimeString(sampleScheduleModel, 'noOfCycles', false);
    String sBRrtcIntervalString = generateRtcTimeString(sampleScheduleModel, 'interval', true);
    String sBDrtcIntervalString = generateRtcTimeString(sampleScheduleModel, 'interval', false);

    // String centralFertilizerSitesString = generateFertilizerString(mainProvider.selectionModel.data!.centralFertilizerSite, 'id');
    // String localFertString = generateFertilizerString(mainProvider.selectionModel.data!.localFertilizer, 'id');
    // String centralFertilizerInjString = generateFertilizerString(mainProvider.selectionModel.data!.centralFertilizer, 'id');
    // String localFertilizerInjString = generateFertilizerLocationString(mainProvider.selectionModel.data!.localFertilizer, 'location');

    // String centralFilterSiteString = generateFilterSiteString(mainProvider.selectionModel.data!.centralFilterSite, 'id');
    // String localFilterSiteString = generateFilterSiteString(mainProvider.selectionModel.data!.localFilter, 'id');

    List<String?> conditionList = mainProvider.sampleConditions?.condition
        .map((e) => e.value['sNo']?.toString())
        .toList() ?? List.generate(6, (index) => '0');

    conditionList = conditionList.map((value) => value ?? '0').toList();
    String conditionString = conditionList.join('_');

    // final selectedIds = mainProvider.selectionModel.data!.centralFilterSite?.where((element) => element.selected == true).map((element) => element.id ?? "").toList() ?? [];
    // List<String> generateFilterSelectionList() {
    //   return List.generate(10, (index) {
    //     return index < selectedIds.length ? '1' : '0';
    //   });
    // }
    // String centralFilterSelection = generateFilterSelectionList().join('_');

    // final selectedIds2 = mainProvider.selectionModel.data!.localFilter?.where((element) => element.selected == true).map((element) => element.id ?? "").toList() ?? [];
    // List<String> generateFilterSelectionList2() {
    //   return List.generate(10, (index) {
    //     return index < selectedIds2.length ? '1' : '0';
    //   });
    // }
    // String localFilterSelection = generateFilterSelectionList2().join('_');

    var alarmToMqtt = mainProvider.alarmData?.general.map((e) => e.selected == true ? 1 : 0).toList();
    alarmToMqtt?.addAll(mainProvider.alarmData?.ecPh.map((e) => e.selected == true ? 1 : 0).toList() ?? []);
    String? alarmString = alarmToMqtt?.join('_');
    List? zoneSnoList = [];
    List? zoneNameList = [];
    if(mainProvider.irrigationLine?.sequence != null || mainProvider.irrigationLine!.sequence.isNotEmpty){
      zoneSnoList = mainProvider.irrigationLine?.sequence.map((e) {
        String id = e['id'];
        return id.substring(3);
      }).toList();
      zoneNameList = mainProvider.irrigationLine?.sequence.map((e) => e['name']).toList();
    } else {
      zoneSnoList = mainProvider.zoneSnoList;
      zoneNameList = mainProvider.zoneNameList;
    }

    // String getListFromWaterAndFertData() {
    //   if(mainProvider.waterAndFertData.isNotEmpty || zoneSnoList != []) {
    //     List<String> resultList = [];
    //     for (var i = 0; i < mainProvider.waterAndFertData.length; i++) {
    //       List<String> currentSet = [];
    //       // currentSet.add('${zoneSnoList?[i]}');
    //       currentSet.add('${widget.serialNumber == 0 ? mainProvider.serialNumberCreation : widget.serialNumber}');
    //       currentSet.add('${zoneNameList?[i]}');
    //       // currentSet.add(sNoList[i]);
    //       currentSet.add('0');
    //       currentSet.add('${10000}');
    //
    //       if(mainProvider.waterAndFertData[i]['water&fert'] != null) {
    //         for(var j = 0; j < mainProvider.waterAndFertData[i]['water&fert'].length; j++) {
    //           currentSet.add(mainProvider.waterAndFertData[i]['water&fert'][j]['type']== 'Time'
    //               ? '${1}'
    //               : '${2}');
    //           currentSet.add(mainProvider.waterAndFertData[i]['water&fert'][j]['type']== 'Time'
    //               ? '${mainProvider.waterAndFertData[i]['water&fert'][j]['time']}:00'
    //               : '${mainProvider.waterAndFertData[i]['water&fert'][j]['flow']}');
    //           currentSet.add(mainProvider.selectionModel.data!.centralFertilizer!.any((element) => element.selected == true)
    //               ? '${1}'
    //               : '${0}');
    //           currentSet.add(mainProvider.selectionModel.data!.localFertilizer!.any((element) => element.selected == true)
    //               ? '${1}'
    //               : '${0}');
    //           currentSet.add('${1}');
    //           currentSet.add('00:10:00');
    //           currentSet.add('00:10:00');
    //           if (mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'] != null) {
    //             for (var k = 0; k < mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'].length; k++) {
    //               if(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'] != null) {
    //                 var fertilizerId = mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['id'];
    //                 var isCentralFertilizer = fertilizerId.startsWith("CFESI");
    //                 var isLocalFertilizer = fertilizerId.startsWith("IL");
    //                 String generateFilterList(List<dynamic>? dataList, String field) {
    //                   final filteredList = dataList
    //                       ?.map((element) => element[field] == 'Time' ? 1 : 0)
    //                       .toList() ?? [];
    //
    //                   while (filteredList.length < 8) {
    //                     filteredList.add(0);
    //                   }
    //
    //                   return filteredList.join('_');
    //                 }
    //
    //                 String generateDurationList(List<dynamic>? dataList, String field) {
    //                   final filteredList = dataList
    //                       ?.map((element) =>
    //                   element[field] == 'Time'
    //                       ? '${element['time']}:00'
    //                       : element[field] == 'Flow'
    //                       ? element['flow'] ?? "0"
    //                       : "00:00:00")
    //                       .toList() ?? [];
    //
    //                   while (filteredList.length < 8) {
    //                     filteredList.add(
    //                         field == 'Time' ? "00:00" : field == 'Flow' ? "0" : "00:00:00");
    //                   }
    //
    //                   return filteredList.join('_');
    //                 }
    //
    //                 if(isCentralFertilizer) {
    //                   for(var l = 0; l < mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'].length; l++) {
    //                     currentSet.add(generateFilterList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type'));
    //                   }
    //                 }
    //                 if(isLocalFertilizer) {
    //                   for(var l = 0; l < mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'].length; l++) {
    //                     currentSet.insert(14,generateFilterList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type'));
    //                   }
    //                 }
    //                 if(isCentralFertilizer) {
    //                   for(var l = 0; l < mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'].length; l++) {
    //                     currentSet.add(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'][l]['type'] == 'Time'
    //                         ? generateDurationList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type')
    //                         : generateDurationList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type'));
    //                   }
    //                 }
    //                 if(isLocalFertilizer) {
    //                   for(var l = 0; l < mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'].length; l++) {
    //                     currentSet.add(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'][l]['type'] == 'Time'
    //                         ? generateDurationList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type')
    //                         : generateDurationList(mainProvider.waterAndFertData[i]['water&fert'][j]['dSite'][k]['injector'], 'type'));
    //                   }
    //                 }
    //               }
    //             }
    //           }
    //         }
    //       }
    //       else {
    //         currentSet.add('${0}');
    //         currentSet.add('00:00:00');
    //         currentSet.add('${0}');
    //         currentSet.add('${0}');
    //         currentSet.add('${1}');
    //         currentSet.add('00:10:00');
    //         currentSet.add('00:10:00');
    //         currentSet.add('0_0_0_0_0_0_0_0');
    //         currentSet.add('0_0_0_0_0_0_0_0');
    //         currentSet.add("00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00");
    //         currentSet.add("00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00_00:00:00");
    //       }
    //       currentSet.add('${0}');
    //       currentSet.add('${0}');
    //       currentSet.add('${0}');
    //       currentSet.add('${0}');
    //       currentSet.add('');
    //       currentSet.add('');
    //       currentSet.add('');
    //       currentSet.add('${0}');
    //
    //       resultList.add(currentSet.join(','));
    //     }
    //     // print(resultList.join(';\n'));
    //     return resultList.join(';');
    //   } else {
    //     return '';
    //   }
    //   // print(resultList.join(';\n'));
    // }

    String scheduleAsRunListDateString = mainProvider.sampleScheduleModel!.scheduleAsRunList.schedule['startDate'];
    String scheduleByDayDateString = mainProvider.sampleScheduleModel!.scheduleByDays.schedule['startDate'];

    DateTime scheduleAsRunListDate = DateTime.parse(scheduleAsRunListDateString);
    DateTime scheduleByDayDate = DateTime.parse(scheduleByDayDateString);

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    String formattedScheduleAsRunListDate = formatter.format(scheduleAsRunListDate);
    String formattedScheduleByDayDate = formatter.format(scheduleByDayDate);

    List getProgramData = [
      widget.serialNumber == 0
          ? mainProvider.serialNumberCreation
          : widget.serialNumber,
      programCategory,
      mainProvider.programName,
      // formattedSNo,
      mainProvider.isPumpStationMode ? 1 : 0,
      selectedPump, mainValve, mainProvider.priority,
      mainProvider.sampleScheduleModel!.selected == "NO SCHEDULE"
          ? 1
          : mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? 2 : 3,
      mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? formattedScheduleAsRunListDate
          : formattedScheduleByDayDate,
      int.parse(mainProvider.sampleScheduleModel!.scheduleAsRunList.schedule['noOfDays']),
      mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? getDaySelectionMode()
          : daySelectionString,
      mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? sBRrtcOnTimeString
          : sBDrtcOnTimeString,
      mainProvider.sampleScheduleModel!.defaultModel.rtcMaxTime
          ? 3 : mainProvider.sampleScheduleModel!.defaultModel.rtcOffTime ? 2 : 1,
      mainProvider.sampleScheduleModel!.defaultModel.rtcMaxTime
          ? mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? sBRrtcMaxTimeString
          : sBDrtcMaxTimeString : mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? sBDrtcOffTimeString : sBRrtcOffTimeString,
      mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? sBRrtcNoOfCyclesString
          : sBDrtcNoOfCyclesString,
      mainProvider.sampleScheduleModel!.selected == "SCHEDULE AS RUN LIST"
          ? sBRrtcIntervalString
          : sBDrtcIntervalString,
      // centralFertilizerSitesString,
      // localFertString,
      // centralFertilizerInjString,
      // localFertilizerInjString,
      // centralFilterSiteString,
      // localFilterSiteString,
      mainProvider.selectedCentralFiltrationMode == "TIME" ? 1 : mainProvider.selectedCentralFiltrationMode == "DP" ? 2 : 3,
      mainProvider.selectedLocalFiltrationMode == "TIME" ? 1 : mainProvider.selectedLocalFiltrationMode == "DP" ? 2 : 3,
      // centralFilterSelection,
      // localFilterSelection,
      mainProvider.centralFiltBegin ? 1 : 0,
      mainProvider.localFiltBegin ? 1 : 0,
      mainProvider.sampleConditions?.condition != null ? mainProvider.sampleConditions!.condition.any((element) => element.selected == true) ? 1 : 0 : 0,
      conditionString,
      alarmString
    ];
    // print(getListFromWaterAndFertData());

    dataToMqtt = {
      "700" : [
        {
          "701": getProgramData.join(','),
          // "702": getListFromWaterAndFertData()
        }
      ],
    };
    if(selectedIndex == ((widget.serialNumber == 0
        ? mainProvider.isIrrigationProgram
        : widget.programType == "Irrigation Program")
        ? mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label1.length - 1 : mainProvider.label4.length - 1
        : mainProvider.conditionsLibraryIsNotEmpty ? mainProvider.label2.length - 1 : mainProvider.label3.length - 1)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            key: UniqueKey(),
            onPressed: () async{
              mainProvider.dataToWF();
              if(mainProvider.irrigationLine!.sequence.isNotEmpty) {
                var dataToSend = {
                  "sequence": mainProvider.irrigationLine!.sequence,
                  "schedule": mainProvider.sampleScheduleModel!.toJson(),
                  "conditions": mainProvider.sampleConditions!.toJson(),
                  "waterAndFert": mainProvider.serverDataWM,
                  "selection": mainProvider.selectionModel.data!.toJson(),
                  "alarm": mainProvider.alarmData!.toJson(),
                  "programName": mainProvider.programName,
                  "priority": mainProvider.priority,
                  "delayBetweenZones": mainProvider.programDetails!.delayBetweenZones,
                  "adjustPercentage": mainProvider.programDetails!.adjustPercentage,
                  "incompleteRestart": mainProvider.isCompletionEnabled ? "1" : "0",
                  "programType": mainProvider.selectedProgramType,
                  "hardware": dataToMqtt
                };
                userData.addAll(dataToSend);
                var userDataToMqtt = {
                  "userId": widget.userId,
                  "controllerId": widget.controllerId,
                };
                try {
                  final createUserProgram = await httpService.postRequest('createUserProgram', userData);
                  final response = jsonDecode(createUserProgram.body);
                  MQTTManager().publish(userDataToMqtt.toString(), 'AppToFirmware/${widget.deviceId}');
                  if(createUserProgram.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProgramLibraryScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,)),);
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
                  print("Error: $error");
                }
                // print(mainProvider.selectionModel.data!.localFertilizerSet!.map((e) => e.toJson()));
              }
              else {
                showAdaptiveDialog<Future>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                      title: 'Warning',
                      content: "Select valves to be sequence for Irrigation Program",
                      actions: [
                        TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
                      ],
                    );
                  },
                );
              }
            },
            // child: const Icon(Icons.send),
            child: const Text('http'),
          ),
          const SizedBox(width: 10,),
          OutlinedButton(
            key: UniqueKey(),
            onPressed: () async{
              MQTTManager().publish(dataToMqtt.toString(), 'AppToFirmware/${widget.deviceId}');
              print(dataToMqtt);
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Sent successfully'));
            },
            child: const Text('Mqtt'),
          )
        ],
      );
    } else {
      return null;
      // return Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     FloatingActionButton(
      //         onPressed: () {},
      //         child: const Text('Back'),
      //         backgroundColor: Colors.red
      //     ),
      //     const SizedBox(width: 20,),
      //     FloatingActionButton(
      //         onPressed: () {},
      //         child: const Text('Next'),
      //         backgroundColor: Colors.green
      //     ),
      //   ],
      // );
    }
  }

  Widget _buildIconButton(bool isActive, IconData iconData, VoidCallback onPressed, toolTip) {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: toolTip,
        onPressed: () {
          if (iconData == Icons.delete) {
            showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: 'Verify to delete',
                  content: 'Are you sure to erase the sequence?',
                  actions: [
                    TextButton(
                      child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        setState(() {
                          mainProvider.deleteButton();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'The sequence is erased!'));
                          // CustomOverlayWidget.showOverlay(context, "The sequence is erased!");
                        });
                      },
                    ),
                  ],
                );
              },
            );
          } else if (iconData == Icons.fiber_manual_record_outlined) {
            // ScaffoldMessenger.of(context).showSnackBar(singleSelection);
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Single valve selection is enabled'));
            // CustomOverlayWidget.showOverlay(context, "Single valve selection is enabled");
            onPressed();
          } else if(iconData == Icons.join_full_outlined){
            // ScaffoldMessenger.of(context).showSnackBar(multipleSelection);
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Multiple valve selection is enabled'));
            // CustomOverlayWidget.showOverlay(context, "Multiple valve selection is enabled");
            onPressed();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Enabled to add next sequence'));
            // CustomOverlayWidget.showOverlay(context, "Multiple valve selection is enabled");
            onPressed();
          }
        },
        icon: Icon(
          iconData,
          color: isActive ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
    );
  }
}

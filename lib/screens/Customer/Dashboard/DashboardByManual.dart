import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/Models/Customer/Dashboard/DashboardDataProvider.dart';
import '../../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../../Models/Customer/Dashboard/FertilizerChanel.dart';
import '../../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../../Models/Customer/Dashboard/ProgramList.dart';
import '../../../constants/http_service.dart';
import '../../../constants/mqtt_web_client.dart';
import '../../../constants/snack_bar.dart';
import '../../../constants/theme.dart';


enum Segment {manual, duration, flow}

class DashboardByManual extends StatefulWidget {
  const DashboardByManual({Key? key, required this.customerID, required this.siteID, required this.controllerID, required this.siteName, required this.imeiNo, required this.programList}) : super(key: key);
  final int customerID, siteID, controllerID;
  final String siteName, imeiNo;
  final List<ProgramList> programList;

  @override
  State<DashboardByManual> createState() => _DashboardByManualState();
}

class _DashboardByManualState extends State<DashboardByManual> {

  late List<DashboardDataProvider> dashBoardData = [];
  bool visibleLoading = false;
  int ddSelection = 0;
  int segmentIndex = 0;
  String flowOrDuration = '0';

  @override
  void initState() {
    super.initState();
    ProgramList defaultProgram = ProgramList(
      programId: 0,
      serialNumber: 0,
      programName: 'Default',
      defaultProgramName: '',
      programType: '',
      priority: 0,
      startDate: '',
      startTime: '',
      sequenceCount: 0,
      scheduleType: '',
      firstSequence: '',
      duration: '',
    );

    bool programWithNameExists = false;
    for (ProgramList program in widget.programList) {
      if (program.programName == 'Default') {
        programWithNameExists = true;
        break; // exit the loop if found
      }
    }

    if (!programWithNameExists) {
      widget.programList.insert(0, defaultProgram);
    } else {
      print('Program with name \'Default\' already exists in widget.programList.');
    }
    getControllerDashboardDetails(0, 0);
  }

  Future<void> payloadCallbackFunction(segIndex, value) async
  {
    print(segIndex);
    print(value);
    segmentIndex = segIndex;
    flowOrDuration = value;
  }

  Future<void> getControllerDashboardDetails(id, selection, ) async
  {
    ddSelection = selection;
    indicatorViewShow();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      dashBoardData = await fetchControllerData(id);
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<DashboardDataProvider>> fetchControllerData(id) async
  {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    //print(body);
    final response = await HttpService().postRequest("getCustomerDashboardByManual", body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      //print(jsonResponse);
      indicatorViewHide();

      if (jsonResponse['data'] != null) {
        dynamic data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          return [DashboardDataProvider.fromJson(data)];
        } else {
          throw Exception('Invalid response format: "data" is not a Map');
        }
      } else {
        throw Exception('Invalid response format: "data" is null');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Text(widget.siteName),
        actions: [
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () async {
            getControllerDashboardDetails(0, ddSelection);
          }),
          const SizedBox(width: 10,),
        ],
      ),
      body: visibleLoading? Center(
        child: Visibility(
          visible: visibleLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 25, 0, mediaQuery.size.width/2 - 25, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      ) :
      Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 350,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Source Pump'),
                            ),
                          SizedBox(
                            height: dashBoardData[0].sourcePump.length * 50,
                            child : ListView.builder(
                              itemCount: dashBoardData[0].sourcePump.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(dashBoardData[0].sourcePump[index].name),
                                      secondary: Image.asset('assets/images/source_pump.png'),
                                      value: dashBoardData[0].sourcePump[index].selected,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          dashBoardData[0].sourcePump[index].selected = newValue!;
                                        });
                                      },
                                    ),
                                    //Text(dashBoardData[0].irrigationPump[index].id, style: const TextStyle(fontSize: 11)),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Irrigation Pump'),
                            ),// Add this condition
                          SizedBox(
                            height: dashBoardData[0].irrigationPump.length * 50,
                            child: ListView.builder(
                              itemCount: dashBoardData[0].irrigationPump.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(dashBoardData[0].irrigationPump[index].name),
                                      secondary: Image.asset('assets/images/irrigation_pump.png'),
                                      value: dashBoardData[0].irrigationPump[index].selected,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          dashBoardData[0].irrigationPump[index].selected = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Main Valve'),
                            ),// Add this condition
                          SizedBox(
                            height: dashBoardData[0].mainValve.length  * 50,
                            child: ListView.builder(
                              itemCount: dashBoardData[0].mainValve.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(dashBoardData[0].mainValve[index].name),
                                      secondary: Image.asset('assets/images/main_valve.png'),
                                      value: dashBoardData[0].mainValve[index].selected,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          dashBoardData[0].mainValve[index].selected = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Central Filter Site'),
                            ),
                          SizedBox(
                            height: dashBoardData[0].centralFilterSite.length  * 57,
                            child: ListView.builder(
                              itemCount: dashBoardData[0].centralFilterSite.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(dashBoardData[0].centralFilterSite[index].name),
                                      secondary: Image.asset('assets/images/central_filtration.png'),
                                      value: dashBoardData[0].centralFilterSite[index].selected,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          dashBoardData[0].centralFilterSite[index].selected = newValue!;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Central Fertilizer Site'),
                            ),
                          SizedBox(
                            height: dashBoardData[0].centralFertilizerSite.length * 160,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: dashBoardData[0].centralFertilizerSite.length,
                              itemBuilder: (context, index) {
                                List<FertilizerChanel> fertilizers = dashBoardData[0].centralFertilizerSite[index].fertilizer;
                                return Card(
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Image.asset('assets/images/central_dosing.png'),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(dashBoardData[0].centralFertilizerSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                Text(dashBoardData[0].centralFertilizerSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                Text('Location : ${dashBoardData[0].centralFertilizerSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                              child: Text('Chanel', style: TextStyle(fontSize: 11),),
                                            ),

                                            SizedBox(
                                                width: MediaQuery.sizeOf(context).width-740,
                                                height: 46,
                                                child: Column(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 5, right: 5),
                                                      child: Divider(),
                                                    ),
                                                    SizedBox(
                                                      width: 310,
                                                      height: 30,
                                                      child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: fertilizers.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          return Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Column(
                                                                  children: [
                                                                    InkWell(
                                                                      child: CircleAvatar(
                                                                        radius: 15,
                                                                        backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                        child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                      ),
                                                                      onTap: (){
                                                                        setState(() {
                                                                          fertilizers[index].selected = !fertilizers[index].selected;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 5),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], programList: widget.programList, programSelectionCallback: getControllerDashboardDetails, ddSelectedVal: ddSelection, duration: dashBoardData[0].time, flow: dashBoardData[0].flow, callbackFunctionForPayload: payloadCallbackFunction,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: myTheme.primaryColor.withOpacity(0.1),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              IconButton(
                  tooltip: 'list view',
                  onPressed: () {
                    debugPrint("Like button pressed");
                  },
                  icon: const Icon(
                    Icons.list_alt,
                    size: 30,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  tooltip: 'mapview',
                  onPressed: () {
                    debugPrint("Dislike button pressed");
                  },
                  icon:  const Icon(
                    Icons.map_outlined,
                    size: 30,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        tooltip: 'Motor ON',
                        onPressed: () {
                          String strSldSourcePump = buildSelectedItemsString(dashBoardData[0].sourcePump);
                          String strSldIrrigationPump = buildSelectedItemsString(dashBoardData[0].irrigationPump);
                          String strSldMainValve = buildSelectedItemsString(dashBoardData[0].mainValve);
                          String strSldCtrlFilter = buildSelectedItemsString(dashBoardData[0].centralFilterSite);
                          //String strSldCtrlFrtChanel = buildSelectedItemsString(dashBoardData[0].centralFertilizerSite[0].fertilizer);

                          String strSldValve = '';
                          Map<String, List<DashBoardValve>> groupedValves = {};
                          for (int i = 0; i < dashBoardData[0].lineOrSequence.length; i++) {
                            LineOrSequence line = dashBoardData[0].lineOrSequence[i];
                            groupedValves = groupValvesByLocation(line.valves);
                            groupedValves.forEach((location, valves) {
                              for (int j = 0; j < valves.length; j++) {
                                if (valves[j].isOn) {
                                  strSldValve += '${valves[j].sNo}_';
                                }
                              }
                            });
                          }

                          strSldValve = strSldValve.isNotEmpty ? strSldValve.substring(0, strSldValve.length - 1) : '';
                          List<String> nonEmptyStrings = [
                            strSldSourcePump,
                            strSldIrrigationPump,
                            strSldMainValve,
                            strSldCtrlFilter,
                            strSldValve
                          ];

                          if (strSldIrrigationPump.isEmpty) {
                            GlobalSnackBar.show(context, 'Please select your Irrigation Pump and try again', 200);
                          }else if (dashBoardData[0].mainValve.isNotEmpty) {
                            if(strSldMainValve.isEmpty) {
                              GlobalSnackBar.show(context, 'Please select your Main Valve and try again', 200);
                            }else if (strSldValve.isEmpty) {
                              GlobalSnackBar.show(context, 'Valve is not open, please open it and try again', 200);
                            }
                            else{
                              String finalResult = nonEmptyStrings.where((s) => s.isNotEmpty).join('_');
                              functionSendPayloadToMqtt(segmentIndex, flowOrDuration, finalResult);
                            }
                          }else if (strSldValve.isEmpty) {
                            GlobalSnackBar.show(context, 'Valve is not open, please open it and try again', 200);
                          }else{
                            String finalResult = nonEmptyStrings.where((s) => s.isNotEmpty).join('_');
                            functionSendPayloadToMqtt(segmentIndex, flowOrDuration, finalResult);
                          }

                        },
                        icon: Icon(
                          Icons.play_circle_outline,
                          size: 30,
                          color: myTheme.primaryColor,
                        )),
                    IconButton(
                        tooltip: 'stop',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: const Icon(
                          Icons.stop_circle_outlined,
                          size: 30,
                          color: Colors.red,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<DashBoardValve>> groupValvesByLocation(List<DashBoardValve> valves) {
    Map<String, List<DashBoardValve>> groupedValves = {};
    for (var valve in valves) {
      if (!groupedValves.containsKey(valve.location)) {
        groupedValves[valve.location] = [];
      }
      groupedValves[valve.location]!.add(valve);
    }
    return groupedValves;
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

  String buildSelectedItemsString(itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].selected) {
        result += '${itemList[i].sNo}_';
      }
    }
    return result.isNotEmpty ? result.substring(0, result.length - 1) : '';
  }

  void functionSendPayloadToMqtt(sgmType, val, relayList) {
    String payload = '${1},${1},${1},${0},$relayList,${0},$sgmType,$val';
    String payLoadFinal = jsonEncode({
      "800": [{"801": payload}]
    });
    print(payLoadFinal);
    MqttWebClient().publishMessage('AppToFirmware/${widget.imeiNo}', payLoadFinal);
  }

}


class DisplayLineOrSequence extends StatefulWidget {
  const DisplayLineOrSequence({super.key, required this.lineOrSequence, required this.programList, required this.programSelectionCallback, required this.ddSelectedVal, required this.duration, required this.flow, required this.callbackFunctionForPayload});
  final List<LineOrSequence> lineOrSequence;
  final List<ProgramList> programList;
  final void Function(int, int) programSelectionCallback;
  final int ddSelectedVal;
  final String duration, flow;
  final void Function(int, String) callbackFunctionForPayload;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {
  Segment segmentView = Segment.manual;
  final TextEditingController _textController = TextEditingController();
  String durationValue = '', flowValue = '';
  double _remainingDuration = 70.0;
  final bool _sliderEnabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    durationValue = widget.duration;
    _textController.text = widget.flow;
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        const SizedBox(height: 10,),
        SizedBox(
          width: MediaQuery.of(context).size.width - 400,
          height: 50,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SegmentedButton<Segment>(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                    iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                  ),
                  segments: const <ButtonSegment<Segment>>[
                    ButtonSegment<Segment>(
                        value: Segment.manual,
                        label: Text('Manual base'),
                        icon: Icon(Icons.edit_note)),
                    ButtonSegment<Segment>(
                        value: Segment.duration,
                        label: Text('Duration base'),
                        icon: Icon(Icons.timer_outlined)),
                    ButtonSegment<Segment>(
                        value: Segment.flow,
                        label: Text('Flow base'),
                        icon: Icon(Icons.gas_meter_outlined)),
                  ],
                  selected: <Segment>{segmentView},
                  onSelectionChanged: (Set<Segment> newSelection) {
                    setState(() {
                      segmentView = newSelection.first;
                      if(segmentView.index==0){
                        widget.callbackFunctionForPayload(segmentView.index, '0');
                      }else if(segmentView.index==1){
                        widget.callbackFunctionForPayload(segmentView.index, durationValue);
                      }else{
                        widget.callbackFunctionForPayload(segmentView.index, _textController.text);
                      }
                    });
                  },
                ),
              ),
              widget.programList.length>1 ? const SizedBox(
                width: 130,
                height: 50,
                child: Center(child: Text('Schedule By')),
              ):
              Container(),
              widget.programList.length>1 ? SizedBox(
                width: 200,
                height: 50,
                child: DropdownButtonFormField(
                  value: widget.programList.isNotEmpty ? widget.programList[widget.ddSelectedVal] : null,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                  focusColor: Colors.transparent,
                  items: widget.programList.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.programName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.programSelectionCallback(value!.programId, widget.programList.indexOf(value),);
                  },
                ),
              ):
              Container(),
            ],
          ),
        ),
        segmentView.index == 0? Container():
        SizedBox(
          width: MediaQuery.of(context).size.width - 370,
          height: 50,
          child: ListTile(
            leading: segmentView.index == 1?
            SizedBox(
              width: 200,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Set Duration(HH:MM) :'),
                    const SizedBox(width: 5,),
                    InkWell(
                      onTap: () => _selectTimeDuration(context, TimeOfDay(hour: int.parse(durationValue.split(":")[0]), minute: int.parse(durationValue.split(":")[1]))),
                      child: Text(durationValue, style: const TextStyle(fontSize: 15),),
                    ),
                  ],
                ),
              ),
            ):
            SizedBox(
              width: 200,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Set Flow(Litter) :'),
                    const SizedBox(width: 10,),
                    SizedBox(width : 94, child: TextField(
                      maxLength: 7,
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Enter liter',
                        counterText: '',
                        border: InputBorder.none,
                        fillColor: Colors.greenAccent
                      ),
                      onChanged: (String value) {
                        widget.callbackFunctionForPayload(segmentView.index, value);
                      },
                    ),),
                  ],
                ),
              ),
            ),
            trailing: SizedBox(
              width: 220,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      value: _remainingDuration,
                      min: 0.0,
                      max: 100.0,
                      onChanged: _sliderEnabled ? (value) {
                        setState(() {
                          _remainingDuration = value;
                        });
                      } : null,
                    ),
                    const Text('70%'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child:
          ListView.builder(
            itemCount: widget.lineOrSequence.length,
            itemBuilder: (context, index) {
              LineOrSequence line = widget.lineOrSequence[index];
              Map<String, List<DashBoardValve>> groupedValves = groupValvesByLocation(line.valves);

              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width-380,
                        height: 50,
                        decoration: BoxDecoration(
                          color: myTheme.primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 10),
                                child: Text(line.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                              ),
                            ),

                            if (widget.ddSelectedVal!=0)
                              VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),

                            if(widget.ddSelectedVal!=0)
                              Center(
                                child: SizedBox(
                                  width: 60,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: line.selected,
                                      onChanged: (value) {
                                        setState(() {
                                          line.selected = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      for (var valveLocation in groupedValves.keys)
                        SizedBox(
                          height: (groupedValves[valveLocation]!.length * 40)+40,
                          width: MediaQuery.sizeOf(context).width-380,
                          child: widget.ddSelectedVal==0? DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Valve Id', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(child: Text('Location', style: TextStyle(fontSize: 14),)),
                                fixedWidth: 100,
                              ),
                              DataColumn2(
                                  label: Center(
                                    child: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(
                                  child: Text(
                                    'Valve Status',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                fixedWidth: 100,
                              ),
                            ],
                            rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Transform.scale(
                                    scale: 0.7,
                                    child: Tooltip(
                                      message: groupedValves[valveLocation]![index].isOn? 'Close' : 'Open',
                                      child: Switch(
                                        hoverColor: Colors.pink.shade100,
                                        value: groupedValves[valveLocation]![index].isOn,
                                        onChanged: (value) {
                                          setState(() {
                                            groupedValves[valveLocation]![index].isOn = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ))),
                            ])),
                          ) :
                          DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Valve Id', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(child: Text('Location', style: TextStyle(fontSize: 14),)),
                                fixedWidth: 100,
                              ),
                              DataColumn2(
                                  label: Center(
                                    child: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  size: ColumnSize.M
                              ),
                            ],
                            rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
                            ])),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Map<String, List<DashBoardValve>> groupValvesByLocation(List<DashBoardValve> valves) {
    Map<String, List<DashBoardValve>> groupedValves = {};
    for (var valve in valves) {
      if (!groupedValves.containsKey(valve.location)) {
        groupedValves[valve.location] = [];
      }
      groupedValves[valve.location]!.add(valve);
    }
    return groupedValves;
  }


  Future<void> _selectTimeDuration(BuildContext context, TimeOfDay time) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
      helpText: 'Set Duration(HH:MM)',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      //print('Selected time: $selectedTime');
      String hour = selectedTime.hour.toString().padLeft(2, '0');
      String minute = selectedTime.minute.toString().padLeft(2, '0');
      setState(() {
        durationValue = '$hour:$minute';
        widget.callbackFunctionForPayload(segmentView.index, durationValue);
      });

    }
  }
}


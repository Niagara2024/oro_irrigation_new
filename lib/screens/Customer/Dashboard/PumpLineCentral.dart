import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/AppImages.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/snack_bar.dart';
import '../../../state_management/DurationNotifier.dart';
import '../../../state_management/MqttPayloadProvider.dart';


class PumpLineCentral extends StatefulWidget {
  const PumpLineCentral({Key? key, required this.currentSiteData, required this.crrIrrLine, required this.masterIdx}) : super(key: key);
  final DashboardModel currentSiteData;
  final IrrigationLine crrIrrLine;
  final int masterIdx;

  @override
  State<PumpLineCentral> createState() => _PumpLineCentralState();
}

class _PumpLineCentralState extends State<PumpLineCentral> {

  int? getIrrigationPauseFlag(String line, List<dynamic> payload2408) {
    for (var data in payload2408) {
      if (data["Line"] == line) {
        return data["IrrigationPauseFlag"];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<MqttPayloadProvider>(context);
    int? irrigationPauseFlag = getIrrigationPauseFlag(widget.crrIrrLine.id, Provider.of<MqttPayloadProvider>(context).payload2408);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 9, left: 5, right: 5),
                child: provider.irrigationPump.isNotEmpty? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    provider.sourcePump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplaySourcePump(deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId,),
                    ):
                    const SizedBox(),
                    provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: SizedBox(
                        width: 52.50,
                        height: 70,
                        child : Stack(
                          children: [
                            provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                            Image.asset('assets/images/dp_sump.png'),
                          ],
                        ),
                      ),
                    ):
                    const SizedBox(),
                    provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplayIrrigationPump(currentLineId: widget.crrIrrLine.id, pumpList: widget.currentSiteData.master[widget.masterIdx].gemLive[0].pumpList,),
                    ):
                    const SizedBox(),
                    provider.filtersCentral.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplayFilter(currentLineId: widget.crrIrrLine.id,),
                    ): const SizedBox(),
                    for(int i=0; i<provider.payload2408.length; i++)
                      provider.payload2408.isNotEmpty?  Padding(
                        padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                        child: provider.payload2408[i]['Line'].contains(widget.crrIrrLine.id)? DisplaySensor(crInx: i):null,
                      ) : const SizedBox(),
                    provider.fertilizerCentral.isNotEmpty? DisplayCentralFertilizer(currentLineId: widget.crrIrrLine.id,): const SizedBox(),

                    //local
                    provider.irrigationPump.isNotEmpty? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (provider.fertilizerCentral.isNotEmpty || provider.filtersCentral.isNotEmpty) && provider.fertilizerLocal.isNotEmpty? SizedBox(
                              width: 4.5,
                              height: 150,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 42),
                                    child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                                  ),
                                  const SizedBox(width: 4.5,),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 45),
                                    child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                                  ),
                                ],
                              ),
                            ):
                            const SizedBox(),
                            provider.filtersLocal.isNotEmpty? Padding(
                              padding: EdgeInsets.only(top: provider.fertilizerLocal.isNotEmpty?38.4:0),
                              child: LocalFilter(currentLineId: widget.crrIrrLine.id,),
                            ):
                            const SizedBox(),
                            provider.fertilizerLocal.isNotEmpty? DisplayLocalFertilizer(currentLineId: widget.crrIrrLine.id,):
                            const SizedBox(),
                          ],
                        ),
                      ],
                    ):
                    const SizedBox(height: 20)
                  ],
                ):
                const SizedBox(height: 20),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 110,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child:TextButton(
              onPressed: () {
                int prFlag = 0;
                List<dynamic> records = provider.payload2408;
                int sNoToCheck = widget.crrIrrLine.sNo;
                var record = records.firstWhere((record) => record['S_No'] == sNoToCheck, orElse: () => null,);
                if (record != null) {
                  bool isIrrigationPauseFlagZero = record['IrrigationPauseFlag'] == 0;
                  if (isIrrigationPauseFlagZero) {
                    prFlag=1;
                  } else {
                    prFlag=0;
                  }
                  String payLoadFinal = jsonEncode({
                    "4900": [{"4901":
                    "$sNoToCheck, $prFlag",},]
                  });
                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.currentSiteData.master[widget.masterIdx].deviceId}');
                }else{
                  const GlobalSnackBar(code: 200, message: 'Controller connection lost...');
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(irrigationPauseFlag==1? Colors.green: Colors.orange),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  irrigationPauseFlag==1? const Icon(Icons.play_arrow_outlined, color: Colors.white):
                  const Icon(Icons.pause, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(irrigationPauseFlag==1? 'RESUME' : 'PAUSE', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}


class DisplaySourcePump extends StatefulWidget {
  const DisplaySourcePump({Key? key, required this.deviceId}) : super(key: key);
  final String deviceId;

  @override
  State<DisplaySourcePump> createState() => _DisplaySourcePumpState();
}

class _DisplaySourcePumpState extends State<DisplaySourcePump> {

  Timer? timer;
  //final GlobalKey _spKey = GlobalKey();
  final List<GlobalKey> _keys = [];
  OverlayEntry? _overlayEntry;
  bool _isHoveringButton = false;
  bool _isHoveringMenu = false;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return SizedBox(
      width: provider.sourcePump.length * 70,
      height: 100,
      child: ListView.builder(
        itemCount: provider.sourcePump.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          _keys.add(GlobalKey());
          return Column(
            children: [
              Stack(
                children: [
                  MouseRegion(
                    onEnter: (_) {
                      _isHoveringButton = true;
                      _showSPOnOffMenu(provider, index);
                    },
                    onExit: (_){
                      _isHoveringButton = false;
                      _checkForExit();
                    },
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      key: _keys[index],
                      child: AppImages.getAsset('sourcePump', provider.sourcePump[index]['Status'],''),
                    ),
                  ),
                  provider.sourcePump[index]['OnDelayLeft'] !='00:00:00'?
                  Positioned(
                    top: 30,
                    left: 7.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.greenAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.green, width: .50,),
                      ),
                      width: 55,
                      child: Center(
                        child: Column(
                          children: [
                            const Text("On delay", style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            )),
                            const Padding(
                              padding: EdgeInsets.only(left: 3, right: 3),
                              child: Divider(height: 0, color: Colors.grey,),
                            ),
                            Text(provider.sourcePump[index]['OnDelayLeft'],
                              style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):
                  const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 30,
                child: Text(provider.sourcePump[index]['SW_Name'] ?? provider.sourcePump[index]['Name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSPOnOffMenu(provider, index) {
    if (_overlayEntry == null) {
      final RenderBox renderBox = _keys[index].currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + renderBox.size.height,
          child: MouseRegion(
            onEnter: (_) => _isHoveringMenu = true,
            onExit: (_) {
              _isHoveringMenu = false;
              _checkForExit();
            },
            child: Material(
              elevation: 8.0,
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    onTap: null,
                    value: 0,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8,),
                          Center(child: Text(provider.sourcePump[index]['Name'], style: const TextStyle(color: Colors.black),)),
                          const SizedBox(height: 8,),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                child: IconButton(tooltip:'On',onPressed: (){
                                  String payload = '1,${provider.sourcePump[index]['S_No']},3,0';
                                  String payLoadFinal = jsonEncode({
                                    "800": [{"801": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');

                                  _isHoveringMenu = false;
                                  _checkForExit();

                                }, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                              ),
                              const SizedBox(width: 8,),
                              CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                child: IconButton(tooltip:'Off',onPressed: (){
                                  String payload = '0,${provider.sourcePump[index]['S_No']},3,0';
                                  String payLoadFinal = jsonEncode({
                                    "800": [{"801": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');

                                  _isHoveringMenu = false;
                                  _checkForExit();

                                }, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removePopupMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _checkForExit() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isHoveringButton && !_isHoveringMenu) {
        _removePopupMenu();
      }
    });
  }


  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.sourcePump.length; i++) {
          if(provider.sourcePump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.sourcePump[i]['OnDelayLeft'].split(':');
            int hours = int.parse(parts[0]);
            int minutes = int.parse(parts[1]);
            int seconds = int.parse(parts[2]);

            if (seconds > 0) {
              seconds--;
            } else {
              if (minutes > 0) {
                minutes--;
                seconds = 59;
              } else {
                if (hours > 0) {
                  hours--;
                  minutes = 59;
                  seconds = 59;
                }
              }
            }

            String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            if(provider.sourcePump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.sourcePump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }
}

class DisplayIrrigationPump extends StatefulWidget {
  const DisplayIrrigationPump({Key? key, required this.currentLineId, required this.pumpList}) : super(key: key);
  final String currentLineId;
  final List<PumpData> pumpList;

  @override
  State<DisplayIrrigationPump> createState() => _DisplayIrrigationPumpState();
}

class _DisplayIrrigationPumpState extends State<DisplayIrrigationPump> {

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updatePumpOnDelayTime();
    });
  }

  void _updatePumpOnDelayTime() {
    final irrigationPump = Provider.of<MqttPayloadProvider>(context, listen: false).irrigationPump;
    final onDelayNotifier = Provider.of<DurationNotifier>(context, listen: false);
    bool allOnDelayLeftZero = true;
    try {
      for (int i = 0; i < irrigationPump.length; i++) {
        if (irrigationPump[i]['OnDelayLeft'] != null) {
          List<String> parts = irrigationPump[i]['OnDelayLeft'].split(':');
          int hours = int.parse(parts[0]);
          int minutes = int.parse(parts[1]);
          int seconds = int.parse(parts[2]);

          if (seconds > 0) {
            seconds--;
          } else {
            if (minutes > 0) {
              minutes--;
              seconds = 59;
            } else {
              if (hours > 0) {
                hours--;
                minutes = 59;
                seconds = 59;
              }
            }
          }

          String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          if (irrigationPump[i]['OnDelayLeft'] != '00:00:00') {
            irrigationPump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
            onDelayNotifier.updateOnDelayTime(updatedDurationQtyLeft);
            allOnDelayLeftZero = false;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (allOnDelayLeftZero) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final irrigationPump = Provider.of<MqttPayloadProvider>(context).irrigationPump;
    _startTimer();

    final List<Map<String, dynamic>> filteredPumps = irrigationPump
        .where((pump) => pump['Location'].contains(widget.currentLineId))
        .toList()
        .cast<Map<String, dynamic>>();

    return SizedBox(
      width: filteredPumps.length * 70,
      height: 100,
      child: ListView.builder(
        itemCount: filteredPumps.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppImages.getAsset('irrigationPump', filteredPumps[index]['Status'],''),
                  ),
                  filteredPumps[index]['OnDelayLeft'] != '00:00:00'?
                  Positioned(
                    top: 30,
                    left: 7.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.greenAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.green, width: .50,),
                      ),
                      width: 55,
                      child: Center(
                        child: ValueListenableBuilder<String>(
                          valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                const Text("On delay", style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                )),
                                const Padding(
                                  padding: EdgeInsets.only(left: 3, right: 3),
                                  child: Divider(height: 0, color: Colors.grey,),
                                ),
                                Text(value, style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                )),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ) :
                  const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 30,
                child: Text(filteredPumps[index]['SW_Name'] ?? filteredPumps[index]['Name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}


class DisplaySensor extends StatelessWidget {
  const DisplaySensor({Key? key, required this.crInx}) : super(key: key);
  final int crInx;

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);
    Map<String, dynamic> jsonData = provider.payload2408[crInx];
    double totalWidth = 0;

    for( var key in jsonData.keys){
      dynamic value = jsonData[key];
      if((key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='-'){
        if(value!='-'){
          totalWidth += 70;
        }
      }
    }

    return jsonData.isNotEmpty ? SizedBox(
      width: totalWidth,
      height: 85,
      child: ListView.builder(
        itemCount: jsonData.keys.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String key = jsonData.keys.elementAt(index);
          dynamic value = jsonData[key];
          return (key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='-' ? Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: key=='PrsIn' || key=='PrsOut' ? Image.asset('assets/images/dp_prs_sensor.png') : Image.asset('assets/images/dp_flowmeter.png'),
                  ),
                  Positioned(
                    top: 42,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 15,
                      decoration: BoxDecoration(
                        color:Colors.yellow,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.grey, width: .50,),
                      ),
                      child: Center(
                        child: Text('$value', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ):
          const SizedBox();
        },
      ),
    ) : const SizedBox();
  }
}


class DisplayFilter extends StatefulWidget {
  const DisplayFilter({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<DisplayFilter> createState() => _DisplayFilterState();
}

class _DisplayFilterState extends State<DisplayFilter> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> filteredCentralFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersCentral
        .where((filter) => filter['Location'].contains(widget.currentLineId))
        .toList()
        .cast<Map<String, dynamic>>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for(int i=0; i<filteredCentralFilter.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filteredCentralFilter[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredCentralFilter[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              const SizedBox(),
              SizedBox(
                height: 90,
                width: filteredCentralFilter[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: filteredCentralFilter[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: AppImages.getAsset('filter', filteredCentralFilter[i]['FilterStatus'][flIndex]['Status'],''),
                            ),
                            Positioned(
                              top: 40,
                              left: 7.5,
                              child: filteredCentralFilter[i]['DurationLeft']!='00:00:00'? filteredCentralFilter[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 55,
                                child: Center(
                                  child: Text(filteredCentralFilter[i]['DurationLeft'],
                                    style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: filteredCentralFilter[i]['PrsIn']!='-' && filteredCentralFilter[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filteredCentralFilter[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(filteredCentralFilter[i]['FilterStatus'][flIndex]['SW_Name'] ?? filteredCentralFilter[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              filteredCentralFilter[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredCentralFilter[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
        Text(filteredCentralFilter.isNotEmpty? filteredCentralFilter[0]['SW_Name']?? filteredCentralFilter[0]['FilterSite']:'', style: const TextStyle(color: primaryColorDark),),
      ],
    );

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for(int fIndex=0; fIndex<provider.filtersCentral.length; fIndex++){
          if(provider.filtersCentral[fIndex]['DurationLeft']!='00:00:00'){

            List<String> parts = provider.filtersCentral[fIndex]['DurationLeft'].split(':');
            int hours = int.parse(parts[0]);
            int minutes = int.parse(parts[1]);
            int seconds = int.parse(parts[2]);

            if (seconds > 0) {
              seconds--;
            } else {
              if (minutes > 0) {
                minutes--;
                seconds = 59;
              } else {
                if (hours > 0) {
                  hours--;
                  minutes = 59;
                  seconds = 59;
                }
              }
            }

            String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            if(updatedDurationQtyLeft!='00:00:00'){
              setState(() {
                provider.filtersCentral[fIndex]['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }
    });
  }

}

class DisplayCentralFertilizer extends StatefulWidget {
  const DisplayCentralFertilizer({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<DisplayCentralFertilizer> createState() => _DisplayCentralFertilizerState();
}

class _DisplayCentralFertilizerState extends State<DisplayCentralFertilizer> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overallFrtCentral = Provider.of<MqttPayloadProvider>(context).fertilizerCentral;

   // MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);

    final List<Map<String, dynamic>> fertilizerCentral = overallFrtCentral
        .where((cfr) => cfr['Location'].contains(widget.currentLineId)).toList()
        .cast<Map<String, dynamic>>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<fertilizerCentral.length; fIndex++)
          SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(fIndex!=0)
                        SizedBox(
                          width: 4.5,
                          height: 120,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 42),
                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                              ),
                              const SizedBox(width: 4.5,),
                              Padding(
                                padding: const EdgeInsets.only(top: 45),
                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                          width: 70,
                          height: 120,
                          child : Stack(
                            children: [
                              AppImages.getAsset('booster', fertilizerCentral[fIndex]['Booster'][0]['Status'],''),
                              Positioned(
                                top: 70,
                                left: 15,
                                child: fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Text('Selector' , style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 85,
                                left: 18,
                                child: fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                  decoration: BoxDecoration(
                                    color: fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']==0? Colors.grey.shade300:
                                    fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']==1? Colors.greenAccent:
                                    fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']==2? Colors.orangeAccent:Colors.redAccent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: 45,
                                  height: 22,
                                  child: Center(
                                    child: Text(fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                    fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 115,
                                left: 8.3,
                                child: Image.asset('assets/images/dp_fert_vertical_pipe.png', width: 9.5, height: 37,),
                              ),
                            ],
                          )
                      ),
                      SizedBox(
                        width: fertilizerCentral[fIndex]['Fertilizer'].length * 70,
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: fertilizerCentral[fIndex]['Fertilizer'].length,
                          itemBuilder: (BuildContext context, int index) {
                            var fertilizer = fertilizerCentral[fIndex]['Fertilizer'][index];
                            double fertilizerQty = 0.0;
                            var qtyValue = fertilizer['Qty'];
                            if(qtyValue != null) {
                              if(fertilizer['Qty'] is String){
                                fertilizerQty = double.parse(fertilizer['Qty']);
                              }else if(fertilizer['Qty'] is int){
                                fertilizerQty = fertilizer['Qty'].toDouble();
                              }else{
                                fertilizerQty = fertilizer['Qty'];
                              }
                            }

                            var fertilizerLeftVal = fertilizer['QtyLeft'];
                            if (fertilizerLeftVal != null) {
                              if(fertilizerLeftVal is String){
                                fertilizer['QtyLeft'] = double.parse(fertilizer['QtyLeft']);
                              }else if(fertilizer['Qty'] is int){
                                fertilizer['QtyLeft'] = fertilizer['QtyLeft'].toDouble();
                              }else{
                                fertilizer['QtyLeft'] = fertilizer['QtyLeft'];
                              }
                            }

                            return SizedBox(
                              width: 70,
                              height: 120,
                              child: Stack(
                                children: [
                                  buildFertCheImage(index, fertilizer['Status'], fertilizerCentral[fIndex]['Fertilizer'].length, fertilizerCentral[fIndex]['Agitator']),
                                  Positioned(
                                    top: 52,
                                    left: 6,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                  Positioned(
                                    top: 50,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                        '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 65,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text('${fertilizer['FlowRate_LpH']}-lph', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 103,
                                    left: 0,
                                    child: fertilizer['Status'] !=0
                                        &&
                                        fertilizer['FertSelection'] !='_'
                                        &&
                                        fertilizer['DurationLeft'] !='00:00:00'
                                        ?
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 50,
                                      child: Center(
                                        child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                            ? fertilizer['DurationLeft']
                                            : fertilizer['QtyLeft'] != null ? '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' :'00.0 L' , style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ) :
                                    const SizedBox(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      fertilizerCentral[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                        width: 59,
                        height: 101,
                        child: AppImages.getAsset('agitator', fertilizerCentral[fIndex]['Agitator'][0]['Status'],''),
                      ) :
                      const SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: fertilizerCentral[fIndex]['Fertilizer'].length * 70,
                  child: Row(
                    children: [
                      if(fIndex!=0)
                        Row(
                          children: [
                            VerticalDivider(width: 0,color: Colors.grey.shade300,),
                            const SizedBox(width: 4.0,),
                            VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          ],
                        ),
                      Row(
                        children: [
                          const SizedBox(width: 10.5,),
                          VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          const SizedBox(width: 4.0,),
                          VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          const SizedBox(width: 5.0,),
                          SizedBox(
                            width: fertilizerCentral[fIndex]['Ec'].length>1? 170 : 85,
                            height: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fertilizerCentral[fIndex]['Ec'].isNotEmpty ? SizedBox(
                                  height: 15,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerCentral[fIndex]['Ec'].length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ec'][index]['Name']} : ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ec'][index]['Status']}', style: const TextStyle(fontSize: 10))),
                                          const SizedBox(width: 10,),
                                        ],
                                      );
                                    },
                                  ),
                                ) :
                                const SizedBox(),
                                fertilizerCentral[fIndex]['Ph'].isNotEmpty ? SizedBox(
                                  height: 15,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerCentral[fIndex]['Ph'].length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        children: [
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ph'][index]['Name']} : ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ph'][index]['Status']}', style: const TextStyle(fontSize: 10))),
                                          const SizedBox(width: 10,),
                                        ],
                                      );
                                    },
                                  ),
                                ):
                                const SizedBox(),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: fertilizerCentral[fIndex]['Fertilizer'].length>4? 150:100,
                            child: Center(
                              child: Text(fertilizerCentral[0]['SW_Name'] ?? fertilizerCentral[0]['FertilizerSite'], style: const TextStyle(color: primaryColorDark),),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildFertCheImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_fert_channel_last_aj';
      }else{
        imageName='dp_fert_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_fert_channel_first_aj';
        }else{
          imageName='dp_fert_channel_center_aj';
        }
      }else{
        imageName='dp_fert_channel_center';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/images/$imageName');

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (var central in provider.fertilizerCentral) {
          central['Fertilizer'].forEach((fertilizer) {
            int ferMethod = fertilizer['FertMethod'] is int
                ? fertilizer['FertMethod']
                : int.parse(fertilizer['FertMethod']);

            if (fertilizer['Status']==1 && ferMethod == 1) {
              //fertilizer time base
              List<String> parts = fertilizer['DurationLeft'].split(':');
              String updatedDurationQtyLeft = formatDuration(parts);
              setState(() {
                fertilizer['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
            else if (fertilizer['Status']==1 && ferMethod == 2) {
              //fertilizer flow base
              double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
              double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
              qtyLeftDouble -= flowRate;
              qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
              setState(() {
                fertilizer['QtyLeft'] = qtyLeftDouble;
              });
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 3){
              //fertilizer proposal time base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                List<String> parts = fertilizer['DurationLeft'].split(':');
                String updatedDurationQtyLeft = formatDuration(parts);
                fcOnTimeRd--;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['DurationLeft'] = updatedDurationQtyLeft;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 4){
              //fertilizer proposal qty base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 5){
              //fertilizer pro qty per 1000 Lit
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else{
              //print('ferMethod 6');
            }
          });
        }
      }
      catch(e){
        print(e);
      }

    });
  }

  String formatDuration(List<String> parts) {
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    if (seconds > 0) {
      seconds--;
    } else {
      if (minutes > 0) {
        minutes--;
        seconds = 59;
      } else {
        if (hours > 0) {
          hours--;
          minutes = 59;
          seconds = 59;
        }
      }
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double convertQtyLeftToDouble(dynamic qtyLeftValue) {
    double qtyLeftDouble = 0.00;
    if (qtyLeftValue is int) {
      qtyLeftDouble = qtyLeftValue.toDouble();
    } else if (qtyLeftValue is String) {
      qtyLeftDouble = double.tryParse(qtyLeftValue) ?? 0.00;
    } else if (qtyLeftValue is double) {
      qtyLeftDouble = qtyLeftValue;
    } else {
      qtyLeftDouble = 0.00;
    }
    return qtyLeftDouble;
  }

  double convertFlowValueToDouble(dynamic flowValue) {
    double flowRate = 0.00;
    if (flowValue is int) {
      flowRate = flowValue.toDouble();
    } else if (flowValue is String) {
      flowRate = double.tryParse(flowValue) ?? 0.00;
    } else if (flowValue is double) {
      flowRate = flowValue;
    } else {
      flowRate = 0.00; // Default value in case the type is unknown
    }
    return flowRate;
  }

}

class LocalFilter extends StatefulWidget {
  const LocalFilter({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<LocalFilter> createState() => _LocalFilterState();
}

class _LocalFilterState extends State<LocalFilter> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> filteredLocalFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersLocal
        .where((pump) => pump['Location'].contains(widget.currentLineId)).toList()
        .cast<Map<String, dynamic>>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for(int i=0; i<filteredLocalFilter.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filteredLocalFilter[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredLocalFilter[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              const SizedBox(),
              SizedBox(
                height: 90,
                width: filteredLocalFilter[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: filteredLocalFilter[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: AppImages.getAsset('filter', filteredLocalFilter[i]['FilterStatus'][flIndex]['Status'],''),
                            ),
                            Positioned(
                              top: 40,
                              left: 7.5,
                              child: filteredLocalFilter[i]['DurationLeft']!='00:00:00'? filteredLocalFilter[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 55,
                                child: Center(
                                  child: Text(filteredLocalFilter[i]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: filteredLocalFilter[i]['PrsIn']!='-' && filteredLocalFilter[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filteredLocalFilter[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(filteredLocalFilter[i]['FilterStatus'][flIndex]['SW_Name'] ?? filteredLocalFilter[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              filteredLocalFilter[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredLocalFilter[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
        Text(filteredLocalFilter.isNotEmpty? filteredLocalFilter[0]['SW_Name'] ?? filteredLocalFilter[0]['FilterSite']:'', style: const TextStyle(color: primaryColorDark),),
      ],
    );
  }

  Widget buildFilterImage(int cIndex, int status) {
    String imageName = 'dp_filter';

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      default:
        imageName += '_r.png';
    }

    return Image.asset('assets/images/$imageName');

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        if(provider.filtersLocal.isNotEmpty) {
          if(provider.filtersLocal[0]['DurationLeft']!='00:00:00'){
            List<String> parts = provider.filtersLocal[0]['DurationLeft'].split(':');
            int hours = int.parse(parts[0]);
            int minutes = int.parse(parts[1]);
            int seconds = int.parse(parts[2]);

            if (seconds > 0) {
              seconds--;
            } else {
              if (minutes > 0) {
                minutes--;
                seconds = 59;
              } else {
                if (hours > 0) {
                  hours--;
                  minutes = 59;
                  seconds = 59;
                }
              }
            }

            String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
            setState(() {
              provider.filtersLocal[0]['DurationLeft'] = updatedDurationQtyLeft;
            });
          }
        }
      }
      catch(e){
        print(e);
      }
    });
  }

}

class DisplayLocalFertilizer extends StatefulWidget {
  const DisplayLocalFertilizer({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<DisplayLocalFertilizer> createState() => _DisplayLocalFertilizerState();
}

class _DisplayLocalFertilizerState extends State<DisplayLocalFertilizer> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> fertilizerLocal =  Provider.of<MqttPayloadProvider>(context,listen: false).fertilizerLocal
        .where((frt) => frt['Location'].contains(widget.currentLineId)).toList()
        .cast<Map<String, dynamic>>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<fertilizerLocal.length; fIndex++)
          SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(fIndex!=0)
                        SizedBox(
                          width: 4.5,
                          height: 120,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 42),
                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                              ),
                              const SizedBox(width: 4.5,),
                              Padding(
                                padding: const EdgeInsets.only(top: 45),
                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                          width: 70,
                          height: 120,
                          child : Stack(
                            children: [
                              AppImages.getAsset('booster', fertilizerLocal[fIndex]['Booster'][0]['Status'],''),
                              Positioned(
                                top: 70,
                                left: 15,
                                child: fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Text('Selector' , style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    ),
                                  ),
                                ):
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 85,
                                left: 18,
                                child: fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                  decoration: BoxDecoration(
                                    color: fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']==0? Colors.grey.shade300:
                                    fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']==1? Colors.greenAccent:
                                    fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']==2? Colors.orangeAccent:Colors.redAccent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: 45,
                                  height: 22,
                                  child: Center(
                                    child: Text(fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                    fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 115,
                                left: 8.3,
                                child: Image.asset('assets/images/dp_fert_vertical_pipe.png', width: 9.5, height: 37,),
                              ),
                            ],
                          )
                      ),
                      SizedBox(
                        width: fertilizerLocal[fIndex]['Fertilizer'].length * 70,
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: fertilizerLocal[fIndex]['Fertilizer'].length,
                          itemBuilder: (BuildContext context, int index) {
                            var fertilizer = fertilizerLocal[fIndex]['Fertilizer'][index];
                            double fertilizerQty = 0.0;
                            var qtyValue = fertilizer['Qty'];
                            if(qtyValue != null) {
                              if(fertilizer['Qty'] is String){
                                fertilizerQty = double.parse(fertilizer['Qty']);
                              }else if(fertilizer['Qty'] is int){
                                fertilizerQty = fertilizer['Qty'].toDouble();
                              }else{
                                fertilizerQty = fertilizer['Qty'];
                              }
                            }

                            var fertilizerLeftVal = fertilizer['QtyLeft'];
                            if (fertilizerLeftVal != null) {
                              if(fertilizerLeftVal is String){
                                fertilizer['QtyLeft'] = double.parse(fertilizer['QtyLeft']);
                              }else if(fertilizer['Qty'] is int){
                                fertilizer['QtyLeft'] = fertilizer['QtyLeft'].toDouble();
                              }else{
                                fertilizer['QtyLeft'] = fertilizer['QtyLeft'];
                              }
                            }

                            return SizedBox(
                              width: 70,
                              height: 120,
                              child: Stack(
                                children: [
                                  buildFertCheImage(index, fertilizer['Status'], fertilizerLocal[fIndex]['Fertilizer'].length, fertilizerLocal[fIndex]['Agitator']),
                                  Positioned(
                                    top: 52,
                                    left: 6,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                  Positioned(
                                    top: 50,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                        '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 65,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text('${fertilizer['FlowRate_LpH']}-lph', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 103,
                                    left: 0,
                                    child: fertilizer['Status'] !=0
                                        &&
                                        fertilizer['FertSelection'] !='_'
                                        &&
                                        fertilizer['DurationLeft'] !='00:00:00'
                                        ?
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 50,
                                      child: Center(
                                        child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                            ? fertilizer['DurationLeft']
                                            : fertilizer['QtyLeft'] != null ? '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' :'00.0 L' , style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ) :
                                    const SizedBox(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      fertilizerLocal[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                        width: 59,
                        height: 101,
                        child: AppImages.getAsset('agitator', fertilizerLocal[fIndex]['Agitator'][0]['Status'],''),
                      ) :
                      const SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 200,
                  child: Row(
                    children: [
                      if(fIndex!=0)
                        Row(
                          children: [
                            VerticalDivider(width: 0,color: Colors.grey.shade300,),
                            const SizedBox(width: 4.0,),
                            VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          ],
                        ),
                      Row(
                        children: [
                          const SizedBox(width: 10.5,),
                          VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          const SizedBox(width: 4.0,),
                          VerticalDivider(width: 0,color: Colors.grey.shade300,),
                          const SizedBox(width: 5.0,),
                          SizedBox(
                            width: 170,
                            height: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fertilizerLocal[fIndex]['Ec'].isNotEmpty ? SizedBox(
                                  height: 15,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerLocal[fIndex]['Ec'].length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ec'][index]['Name']} : ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ec'][index]['Status']}', style: const TextStyle(fontSize: 10))),
                                          const SizedBox(width: 10,),
                                        ],
                                      );
                                    },
                                  ),
                                ) :
                                const SizedBox(),
                                fertilizerLocal[fIndex]['Ph'].isNotEmpty ? SizedBox(
                                  height: 15,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fertilizerLocal[fIndex]['Ph'].length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        children: [
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ph'][index]['Name']} : ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ph'][index]['Status']}', style: const TextStyle(fontSize: 10))),
                                          const SizedBox(width: 10,),
                                        ],
                                      );
                                    },
                                  ),
                                ) :
                                const SizedBox(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 15,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              width: 55,
                              child: Center(
                                child: Text(fertilizerLocal[0]['SW_Name']?? fertilizerLocal[0]['FertilizerSite'], style: const TextStyle(color: primaryColorDark),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildFertCheImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_fert_channel_last_aj';
      }else{
        imageName='dp_fert_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_fert_channel_first_aj';
        }else{
          imageName='dp_fert_channel_center_aj';
        }
      }else{
        imageName='dp_fert_channel_center';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/images/$imageName');

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);
        final List<Map<String, dynamic>> fertilizerLocal = provider.fertilizerLocal
            .where((pump) => pump['Location'].contains(widget.currentLineId))
            .toList()
            .cast<Map<String, dynamic>>();

        for (var local in fertilizerLocal) {
          local['Fertilizer'].forEach((fertilizer) {
            int ferMethod = fertilizer['FertMethod'] is int? fertilizer['FertMethod']
                : int.parse(fertilizer['FertMethod']);
            if (fertilizer['Status']==1 && ferMethod == 1) {
              //fertilizer time base
              List<String> parts = fertilizer['DurationLeft'].split(':');
              String updatedDurationQtyLeft = formatDuration(parts);
              setState(() {
                fertilizer['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
            else if (fertilizer['Status']==1 && ferMethod == 2) {
              //fertilizer flow base
              double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
              double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
              qtyLeftDouble -= flowRate;
              qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
              setState(() {
                fertilizer['QtyLeft'] = qtyLeftDouble;
              });
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 3){
              //fertilizer proposal time base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);

              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                List<String> parts = fertilizer['DurationLeft'].split(':');
                String updatedDurationQtyLeft = formatDuration(parts);
                fcOnTimeRd--;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['DurationLeft'] = updatedDurationQtyLeft;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                fertilizer['OffTime'] = '$fcOffTimeRd';
                setState((){
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 4){
              //fertilizer proposal qty base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if ((fertilizer['Status']==1 || fertilizer['Status']==4) && ferMethod == 5){
              //fertilizer pro qty per 1000 Lit
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else{
              print('ferMethod 6');
              timer?.cancel();
            }
          });
        }
      }
      catch(e){
        print(e);
      }

    });
  }

  String formatDuration(List<String> parts) {
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    if (seconds > 0) {
      seconds--;
    } else {
      if (minutes > 0) {
        minutes--;
        seconds = 59;
      } else {
        if (hours > 0) {
          hours--;
          minutes = 59;
          seconds = 59;
        }
      }
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double convertQtyLeftToDouble(dynamic qtyLeftValue) {
    double qtyLeftDouble = 0.00;
    if (qtyLeftValue is int) {
      qtyLeftDouble = qtyLeftValue.toDouble();
    } else if (qtyLeftValue is String) {
      qtyLeftDouble = double.tryParse(qtyLeftValue) ?? 0.00;
    } else if (qtyLeftValue is double) {
      qtyLeftDouble = qtyLeftValue;
    } else {
      qtyLeftDouble = 0.00;
    }
    return qtyLeftDouble;
  }

  double convertFlowValueToDouble(dynamic flowValue) {
    double flowRate = 0.00;
    if (flowValue is int) {
      flowRate = flowValue.toDouble();
    } else if (flowValue is String) {
      flowRate = double.tryParse(flowValue) ?? 0.00;
    } else if (flowValue is double) {
      flowRate = flowValue;
    } else {
      flowRate = 0.00; // Default value in case the type is unknown
    }
    return flowRate;
  }

}

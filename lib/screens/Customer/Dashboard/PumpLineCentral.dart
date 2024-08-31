import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/AppImages.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../state_management/DurationNotifier.dart';
import '../../../state_management/MqttPayloadProvider.dart';


class PumpLineCentral extends StatefulWidget {
  const PumpLineCentral({Key? key, required this.currentSiteData, required this.crrIrrLine, required this.masterIdx, required this.provider, required this.userId}) : super(key: key);
  final DashboardModel currentSiteData;
  final IrrigationLine crrIrrLine;
  final int masterIdx, userId;
  final MqttPayloadProvider provider;

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

    int? irrigationPauseFlag = getIrrigationPauseFlag(widget.crrIrrLine.id, widget.provider.payload2408);

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
                child: widget.provider.irrigationPump.isNotEmpty? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.provider.sourcePump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplaySourcePump(deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId, currentLineId: widget.crrIrrLine.id, spList:  widget.provider.sourcePump, userId: widget.userId,),
                    ):
                    const SizedBox(),

                    widget.provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: SizedBox(
                        width: 52.50,
                        height: 70,
                        child : Stack(
                          children: [
                            widget.provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                            Image.asset('assets/images/dp_sump.png'),
                          ],
                        ),
                      ),
                    ):
                    const SizedBox(),

                    widget.provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplayIrrigationPump(currentLineId: widget.crrIrrLine.id, deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId, ipList: widget.provider.irrigationPump,),
                    ):
                    const SizedBox(),

                    if(widget.provider.filtersCentral.isEmpty)
                      for(int i=0; i<widget.provider.payload2408.length; i++)
                        widget.provider.payload2408.isNotEmpty?  Padding(
                          padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                          child: widget.provider.payload2408[i]['Line'].contains(widget.crrIrrLine.id)? DisplaySensor(crInx: i):null,
                        ) :
                        const SizedBox(),

                    widget.provider.filtersCentral.isEmpty && widget.provider.fertilizerCentral.isEmpty &&
                        widget.provider.filtersLocal.isEmpty && widget.provider.fertilizerLocal.isEmpty ? SizedBox(
                      width: 4.5,
                      height: 100,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                          ),
                          const SizedBox(width: 4.5,),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                          ),
                        ],
                      ),
                    ):
                    const SizedBox(),


                    widget.provider.filtersCentral.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplayFilter(currentLineId: widget.crrIrrLine.id, filtersSites: widget.provider.filtersCentral,),
                    ): const SizedBox(),

                    if(widget.provider.filtersCentral.isNotEmpty)
                      for(int i=0; i<widget.provider.payload2408.length; i++)
                        widget.provider.payload2408.isNotEmpty?  Padding(
                          padding: EdgeInsets.only(top: widget.provider.fertilizerCentral.isNotEmpty || widget.provider.fertilizerLocal.isNotEmpty? 38.4:0),
                          child: widget.provider.payload2408[i]['Line'].contains(widget.crrIrrLine.id)? DisplaySensor(crInx: i):null,
                        ) : const SizedBox(),

                    widget.provider.fertilizerCentral.isNotEmpty? DisplayCentralFertilizer(currentLineId: widget.crrIrrLine.id,): const SizedBox(),

                    //local
                    widget.provider.irrigationPump.isNotEmpty? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.provider.fertilizerCentral.isNotEmpty || widget.provider.filtersCentral.isNotEmpty) && widget.provider.fertilizerLocal.isNotEmpty?
                            SizedBox(
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
                            widget.provider.filtersLocal.isNotEmpty? Padding(
                              padding: EdgeInsets.only(top: widget.provider.fertilizerLocal.isNotEmpty?38.4:0),
                              child: LocalFilter(currentLineId: widget.crrIrrLine.id, filtersSites: widget.provider.filtersLocal,),
                            ):
                            const SizedBox(),
                            widget.provider.fertilizerLocal.isNotEmpty? DisplayLocalFertilizer(currentLineId: widget.crrIrrLine.id,):
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
        irrigationPauseFlag !=2 ? Padding(
          padding: const EdgeInsets.all(8),
          child: TextButton(
            onPressed: () {
              List<dynamic> records = widget.provider.payload2408;
              var record = records.firstWhere((record) => record['S_No'] == widget.crrIrrLine.sNo,
                orElse: () => null,
              );
              if (record != null) {
                String payLoadFinal = jsonEncode({
                  "4900": [{
                      "4901": "${widget.crrIrrLine.sNo}, ${record['IrrigationPauseFlag'] == 0?1:0}",
                    }
                  ]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.currentSiteData.master[widget.masterIdx].deviceId}');
              } else {
                const GlobalSnackBar(code: 200, message: 'Controller connection lost...');
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(irrigationPauseFlag == 1 ? Colors.green : Colors.orange),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                irrigationPauseFlag == 1
                    ? const Icon(Icons.play_arrow_outlined, color: Colors.white)
                    : const Icon(Icons.pause, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  irrigationPauseFlag == 1 ? 'RESUME THE LINE' : 'PAUSE THE LINE',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ):
        const SizedBox(),
      ],
    );

  }

}


class DisplaySourcePump extends StatefulWidget {
  const DisplaySourcePump({Key? key, required this.deviceId, required this.currentLineId, required this.spList, required this.userId}) : super(key: key);
  final String deviceId;
  final String currentLineId;
  final List<dynamic> spList;
  final int userId;

  @override
  State<DisplaySourcePump> createState() => _DisplaySourcePumpState();
}

class _DisplaySourcePumpState extends State<DisplaySourcePump> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    for (var ip in widget.spList) {
      if (ip['DurationLeft'] != '00:00:00') {
        updatePumpOnDelayTime();
      }else{
        timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updatePumpOnDelayTime() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        for (var sp in widget.spList) {
          if (sp['OnDelayLeft'] != null && sp['OnDelayLeft']!='00:00:00') {
            List<String> parts = sp['OnDelayLeft'].split(':');
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
            if (sp['OnDelayLeft'] != '00:00:00') {
              setState(() {
                sp['OnDelayLeft'] = updatedDurationQtyLeft;
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


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPumps=[];
    if(widget.currentLineId=='all'){
      filteredPumps = widget.spList.toList().cast<Map<String, dynamic>>();
    }else{
      filteredPumps = widget.spList
          .where((pump) => pump['Location'].contains(widget.currentLineId))
          .toList()
          .cast<Map<String, dynamic>>();
    }

    return SizedBox(
      width: filteredPumps.length * 70,
      height: 100,
      child: Row(
        children: List.generate(filteredPumps.length, (index) {
          final pump = filteredPumps[index];
          return Column(
            children: [
              Stack(
                children: [
                  Tooltip(
                    message: 'View more details',
                    child: TextButton(
                      onPressed: () {
                        final RenderBox button = context.findRenderObject() as RenderBox;
                        final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final position = button.localToGlobal(Offset.zero, ancestor: overlay);

                        bool voltKeyExists = filteredPumps[index].containsKey('Voltage');
                        int signalStrength = voltKeyExists? int.parse(filteredPumps[index]['SignalStrength']):0;
                        int batteryVolt = voltKeyExists? int.parse(filteredPumps[index]['Battery']):0;
                        List<String> voltages = voltKeyExists? filteredPumps[index]['Voltage'].split(','):[];
                        List<String> current = voltKeyExists? filteredPumps[index]['Current'].split(','):[];

                        double level = 42.0;
                        List<String> columns = ['-', '-', '-'];

                        if(voltKeyExists){
                          for (var pair in current) {
                            List<String> parts = pair.split(':');
                            int columnIndex = int.parse(parts[0]) - 1;
                            columns[columnIndex] = parts[1];
                          }
                        }

                        showPopover(
                          context: context,
                          bodyBuilder: (context) => voltKeyExists?Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text('Version: ${filteredPumps[index]['Version']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(signalStrength == 0 ? Icons.wifi_off :
                                    signalStrength >= 1 && signalStrength <= 20 ?
                                    Icons.network_wifi_1_bar_outlined :
                                    signalStrength >= 21 && signalStrength <= 40 ?
                                    Icons.network_wifi_2_bar_outlined :
                                    signalStrength >= 41 && signalStrength <= 60 ?
                                    Icons.network_wifi_3_bar_outlined :
                                    signalStrength >= 61 && signalStrength <= 80 ?
                                    Icons.network_wifi_3_bar_outlined :
                                    Icons.wifi, color: Colors.black,),
                                    const SizedBox(width: 5,),
                                    Text('$signalStrength%'),

                                    const SizedBox(width: 5,),
                                    batteryVolt==0?const Icon(Icons.battery_0_bar):
                                    batteryVolt>0&&batteryVolt<=10?const Icon(Icons.battery_1_bar_rounded):
                                    batteryVolt>10&&batteryVolt<=30?const Icon(Icons.battery_2_bar_rounded):
                                    batteryVolt>30&&batteryVolt<=50?const Icon(Icons.battery_3_bar_rounded):
                                    batteryVolt>50&&batteryVolt<=70?const Icon(Icons.battery_4_bar_rounded):
                                    batteryVolt>70&&batteryVolt<=90?const Icon(Icons.battery_5_bar_rounded):
                                    const Icon(Icons.battery_6_bar_rounded),
                                    Text('$batteryVolt%'),
                                  ],
                                ),
                                tileColor: Colors.teal.shade50,
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: const Row(
                                  children: [
                                    SizedBox(width:100, child: Text('Phase', style: TextStyle(color: Colors.black54),),),
                                    //'${filteredPumps[index]['Phase']}'
                                    Spacer(),
                                    CircleAvatar(radius: 7,),
                                    VerticalDivider(color: Colors.transparent,),
                                    CircleAvatar(radius: 7,),
                                    VerticalDivider(color: Colors.transparent,),
                                    CircleAvatar(radius: 7,),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Voltage', style: TextStyle(color: Colors.black54),),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.red, thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('R : ${voltages[0]}'),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.yellow,thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('Y : ${voltages[1]}'),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.blue,thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('B : ${voltages[2]}'),),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Current', style: TextStyle(color: Colors.black54),),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[0])),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[1])),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[2])),),
                                  ],
                                ),
                              ),
                              /*const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 40,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Water Level', style: TextStyle(color: Colors.black54),),),
                                    const Spacer(),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                                        border: Border.all(color: Colors.blue, width: 0.50),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40 * (level / 100),  // Adjust height based on percentage
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade400,
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                                            ),
                                          ),
                                          // Text displaying the percentage
                                          Center(
                                            child: Text(
                                              '$level%',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),*/
                              ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MaterialButton(
                                      color: Colors.green,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        String payload = '${filteredPumps[index]['S_No']},1,1';
                                        String payLoadFinal = jsonEncode({
                                          "6200": [{"6201": payload}]
                                        });
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                        sentUserOperationToServer('${pump['SW_Name'] ?? pump['Name']} Start Manually', payLoadFinal);
                                        showSnakeBar('Pump of comment sent successfully');
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Start Manually',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 16,),
                                    MaterialButton(
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        String payload = '${filteredPumps[index]['S_No']},0,1';
                                        String payLoadFinal = jsonEncode({
                                          "6200": [{"6201": payload}]
                                        });
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                        sentUserOperationToServer('${pump['SW_Name'] ?? pump['Name']} Stop Manually', payLoadFinal);
                                        showSnakeBar('Pump of comment sent successfully');
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Stop Manually',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                tileColor: Colors.grey.shade100,
                              ),
                            ],
                          ):
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MaterialButton(
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      String payload = '${filteredPumps[index]['S_No']},1,1';
                                      String payLoadFinal = jsonEncode({
                                        "6200": [{"6201": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                      sentUserOperationToServer('${pump['SW_Name'] ?? pump['Name']} Start Manually', payLoadFinal);
                                      showSnakeBar('Pump of comment sent successfully');
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Start Manually',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 8,),
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      String payload = '${filteredPumps[index]['S_No']},0,1';
                                      String payLoadFinal = jsonEncode({
                                        "6200": [{"6201": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                      sentUserOperationToServer('${pump['SW_Name'] ?? pump['Name']} Stop Manually', payLoadFinal);
                                      showSnakeBar('Pump of comment sent successfully');
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Stop Manually',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onPop: () => print('Popover was popped!'),
                          direction: PopoverDirection.right,
                          width: voltKeyExists?325:140,
                          height: voltKeyExists?190: 80,
                          arrowHeight: 15,
                          arrowWidth: 30,
                          barrierColor: Colors.black54,
                          arrowDxOffset: filteredPumps.length==1?(position.dx+25)+(index*70)-140:
                          filteredPumps.length==2?(position.dx+25)+(index*70)-210:
                          filteredPumps.length==4?(position.dx+25)+(index*70)-350:
                          (position.dx+25)+(index*70)-280,
                        );
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: AppImages.getAsset('irrigationPump', pump['Status'], ''),
                      ),
                    ),
                  ),
                  pump['OnDelayLeft'] != '00:00:00'? Positioned(
                    top: 30,
                    left: 7.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.green, width: .50),
                      ),
                      width: 55,
                      child: Center(
                        child: ValueListenableBuilder<String>(
                          valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                const Text(
                                  "On delay",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 3, right: 3),
                                  child: Divider(
                                    height: 0,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 30,
                child: Text(
                  pump['SW_Name'] ?? pump['Name'],
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
        }),
      ),
    );
  }

  void showSnakeBar(String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.deviceId, "messageStatus": msg, "data": data, "createUser": widget.userId};
    final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}

class DisplayIrrigationPump extends StatefulWidget {
  const DisplayIrrigationPump({Key? key, required this.currentLineId, required this.deviceId, required this.ipList}) : super(key: key);
  final String currentLineId;
  final String deviceId;
  final List<dynamic> ipList;

  @override
  State<DisplayIrrigationPump> createState() => _DisplayIrrigationPumpState();
}

class _DisplayIrrigationPumpState extends State<DisplayIrrigationPump> {

  Timer? timer;

  @override
  void initState() {
    super.initState();
    for (var ip in widget.ipList) {
      if (ip['DurationLeft'] != '00:00:00') {
        updatePumpOnDelayTime();
      }else{
        timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updatePumpOnDelayTime() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        for (var ip in widget.ipList) {
          if (ip['OnDelayLeft'] != null && ip['OnDelayLeft']!='00:00:00') {
            List<String> parts = ip['OnDelayLeft'].split(':');
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
            if (ip['OnDelayLeft'] != '00:00:00') {
              setState(() {
                ip['OnDelayLeft'] = updatedDurationQtyLeft;
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

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> filteredPumps = [];
    if (widget.currentLineId == 'all') {
      filteredPumps =  widget.ipList.toList().cast<Map<String, dynamic>>();
    } else {
      filteredPumps =  widget.ipList
          .where((pump) => pump['Location'].contains(widget.currentLineId))
          .toList()
          .cast<Map<String, dynamic>>();
    }

    return SizedBox(
      width: filteredPumps.length * 70,
      height: 100,
      child: Row(
        children: List.generate(filteredPumps.length, (index) {
          final pump = filteredPumps[index];
          return Column(
            children: [
              Stack(
                children: [
                  Tooltip(
                    message: 'View more details',
                    child: TextButton(
                      onPressed: () {

                        final RenderBox button = context.findRenderObject() as RenderBox;
                        final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final position = button.localToGlobal(Offset.zero, ancestor: overlay);

                        bool voltKeyExists = filteredPumps[index].containsKey('Voltage');
                        int signalStrength = voltKeyExists? int.parse(filteredPumps[index]['SignalStrength']):0;
                        int batteryVolt = voltKeyExists? int.parse(filteredPumps[index]['Battery']):0;
                        List<String> voltages = voltKeyExists? filteredPumps[index]['Voltage'].split(','):[];
                        List<String> current = voltKeyExists? filteredPumps[index]['Current'].split(','):[];

                        double level = 42.0;
                        List<String> columns = ['-', '-', '-'];

                        if(voltKeyExists){
                          for (var pair in current) {
                            List<String> parts = pair.split(':');
                            int columnIndex = int.parse(parts[0]) - 1;
                            columns[columnIndex] = parts[1];
                          }
                        }

                        int srcCount = 0;
                        int irgCount = 0;
                        if (widget.currentLineId == 'all') {
                          srcCount = Provider.of<MqttPayloadProvider>(context, listen: false).sourcePump.length;
                          irgCount = Provider.of<MqttPayloadProvider>(context, listen: false).irrigationPump.length;
                        }else{
                          srcCount = Provider.of<MqttPayloadProvider>(context, listen: false).sourcePump
                              .where((pump) => pump['Location'].contains(widget.currentLineId)).toList()
                              .cast<Map<String, dynamic>>().length;

                          irgCount = Provider.of<MqttPayloadProvider>(context, listen: false).irrigationPump
                              .where((pump) => pump['Location'].contains(widget.currentLineId)).toList()
                              .cast<Map<String, dynamic>>().length;
                        }

                        showPopover(
                          context: context,
                          bodyBuilder: (context) => voltKeyExists?Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text('Version: ${filteredPumps[index]['Version']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(signalStrength == 0 ? Icons.wifi_off :
                                    signalStrength >= 1 && signalStrength <= 20 ?
                                    Icons.network_wifi_1_bar_outlined :
                                    signalStrength >= 21 && signalStrength <= 40 ?
                                    Icons.network_wifi_2_bar_outlined :
                                    signalStrength >= 41 && signalStrength <= 60 ?
                                    Icons.network_wifi_3_bar_outlined :
                                    signalStrength >= 61 && signalStrength <= 80 ?
                                    Icons.network_wifi_3_bar_outlined :
                                    Icons.wifi, color: Colors.black,),
                                    const SizedBox(width: 5,),
                                    Text('$signalStrength%'),

                                    const SizedBox(width: 5,),
                                    batteryVolt==0?const Icon(Icons.battery_0_bar):
                                    batteryVolt>0&&batteryVolt<=10?const Icon(Icons.battery_1_bar_rounded):
                                    batteryVolt>10&&batteryVolt<=30?const Icon(Icons.battery_2_bar_rounded):
                                    batteryVolt>30&&batteryVolt<=50?const Icon(Icons.battery_3_bar_rounded):
                                    batteryVolt>50&&batteryVolt<=70?const Icon(Icons.battery_4_bar_rounded):
                                    batteryVolt>70&&batteryVolt<=90?const Icon(Icons.battery_5_bar_rounded):
                                    const Icon(Icons.battery_6_bar_rounded),
                                    Text('$batteryVolt%'),
                                  ],
                                ),
                                tileColor: Colors.teal.shade50,
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: const Row(
                                  children: [
                                    SizedBox(width:100, child: Text('Phase',  style: TextStyle(color: Colors.black54),),),
                                    //'${filteredPumps[index]['Phase']}'
                                    Spacer(),
                                    CircleAvatar(radius: 7,),
                                    VerticalDivider(color: Colors.transparent,),
                                    CircleAvatar(radius: 7,),
                                    VerticalDivider(color: Colors.transparent,),
                                    CircleAvatar(radius: 7,),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Voltage', style: TextStyle(color: Colors.black54)),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.red, thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('R : ${voltages[0]}'),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.yellow,thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('Y : ${voltages[1]}'),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.blue,thickness: 1.5,),
                                    ),
                                    SizedBox(width: 50, child: Text('B : ${voltages[2]}'),),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 25,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Current', style: TextStyle(color: Colors.black54)),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[0])),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[1])),),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 2,top: 2),
                                      child: VerticalDivider(color: Colors.transparent,),
                                    ),
                                    SizedBox(width: 50, child: Center(child: Text(columns[2])),),
                                  ],
                                ),
                              ),
                              /*const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Divider(height: 6,color: Colors.black12),
                              ),
                              Container(
                                width: 315,
                                height: 40,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    const SizedBox(width:100, child: Text('Level', style: TextStyle(color: Colors.black54)),),
                                    const Spacer(),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                                        border: Border.all(color: Colors.blue, width: 0.50),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40 * (level / 100),  // Adjust height based on percentage
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade400,
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '$level%',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),*/
                            ],
                          ):
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No more data'),
                              )
                            ],
                          ),
                          onPop: () => print('Popover was popped!'),
                          direction: PopoverDirection.right,
                          width: voltKeyExists?325:125,
                          height: voltKeyExists?145: 75,
                          arrowHeight: 15,
                          arrowWidth: 30,
                          barrierColor: Colors.black54,
                          arrowDxOffset: srcCount==0 && irgCount==1? (position.dx+45)+(index*70)-210:
                          srcCount==1 && irgCount==1? (position.dx+45)+(index*70)-280:
                          srcCount==2 && irgCount==1? (position.dx+45)+(index*70)-350:
                          srcCount==3 && irgCount==1? (position.dx+45)+(index*70)-420:

                          srcCount==1 && irgCount==2? (position.dx+45)+(index*70)-350:

                          srcCount==2 && irgCount==2? (position.dx+45)+(index*70)-420:
                          srcCount==2 && irgCount==4? (position.dx+45)+(index*70)-560:

                          srcCount==4 && irgCount==2? (position.dx+45)+(index*70)-560:

                          srcCount==2 && irgCount==4? (position.dx+45)+(index*70)-560:
                          ((position.dy-position.dx)+12)+(index*70)-70,

                        );
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: AppImages.getAsset('irrigationPump', pump['Status'], ''),
                      ),
                    ),
                  ),
                  pump['OnDelayLeft'] != '00:00:00'? Positioned(
                    top: 30,
                    left: 7.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.green, width: .50),
                      ),
                      width: 55,
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              "On delay",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 3, right: 3),
                              child: Divider(
                                height: 0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(pump['OnDelayLeft'],
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
                  )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 30,
                child: Text(
                  pump['SW_Name'] ?? pump['Name'],
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
        }),
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
                    left: 5,
                    child: Container(
                      width: 57,
                      height: 15,
                      decoration: BoxDecoration(
                        color:Colors.yellow,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.grey, width: .50,),
                      ),
                      child: Center(
                        child: Text(key=='PrsIn' || key=='PrsOut' ?'$value':'$value Lps', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
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
  const DisplayFilter({Key? key, required this.currentLineId, required this.filtersSites}) : super(key: key);
  final String currentLineId;
  final List<dynamic> filtersSites;

  @override
  State<DisplayFilter> createState() => _DisplayFilterState();
}

class _DisplayFilterState extends State<DisplayFilter> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    for (var site in widget.filtersSites) {
      if (site['DurationLeft'] != '00:00:00') {
        durationUpdatingFunction();
      }else{
        timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> filteredCentralFilter=[];

    if(widget.currentLineId=='all'){
      filteredCentralFilter = widget.filtersSites.cast<Map<String, dynamic>>();
    }else{
      filteredCentralFilter = widget.filtersSites.where((filter) =>
          filter['Location'].contains(widget.currentLineId))
          .toList().cast<Map<String, dynamic>>();
    }

    return widget.currentLineId=='all' ?Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for(int i=0; i<filteredCentralFilter.length; i++)
              Column(
                children: [
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
                                      top: 55,
                                      left: 7.5,
                                      child: filteredCentralFilter[i]['DurationLeft']!='00:00:00'? filteredCentralFilter[i]['Status'] == (flIndex+1) ?
                                      Container(
                                        decoration: BoxDecoration(
                                          color:Colors.greenAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    width: filteredCentralFilter[i]['FilterStatus'].length * 60,
                    child: Center(
                      child: Text(filteredCentralFilter[i]['SW_Name'] ?? filteredCentralFilter[i]['FilterSite'], style: const TextStyle(color: primaryColorDark),),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ):
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for(int i=0; i<filteredCentralFilter.length; i++)
          Column(
            children: [
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
                                  top: 45,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(3),
                ),
                width: filteredCentralFilter[i]['FilterStatus'].length * 60,
                child: Center(
                  child: Text(filteredCentralFilter[0]['SW_Name'] ?? filteredCentralFilter[0]['FilterSite'], style: const TextStyle(color: primaryColorDark),),
                ),
              ),
            ],
          ),
      ],
    );

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        for (var site in widget.filtersSites) {
          if(site['DurationLeft']!='00:00:00'){
            for (var filters in site['FilterStatus']) {
              if(filters['Status']==1){
                List<String> parts = site['DurationLeft'].split(':');
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
                    site['DurationLeft'] = updatedDurationQtyLeft;
                  });
                }
              }
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

    List<Map<String, dynamic>> fertilizerCentral =[];
    if(widget.currentLineId=='all'){
      fertilizerCentral = Provider.of<MqttPayloadProvider>(context,listen: false).fertilizerCentral.toList().cast<Map<String, dynamic>>();
    }else{
      fertilizerCentral = overallFrtCentral
          .where((cfr) => cfr['Location'].contains(widget.currentLineId)).toList()
          .cast<Map<String, dynamic>>();
    }

    durationUpdatingFunction();

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

                          fertilizerCentral[fIndex]['Ec'].length!=0?SizedBox(
                            width: fertilizerCentral[fIndex]['Ec'].length>1? 130 : 70,
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
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ec'][index]['Name']} : ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.normal))),
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ec'][index]['Status']}0', style: const TextStyle(fontSize: 9))),
                                          const SizedBox(width: 5,),
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
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ph'][index]['Name']} : ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.normal),)),
                                          Center(child: Text('${fertilizerCentral[fIndex]['Ph'][index]['Status']}0', style: const TextStyle(fontSize: 9))),
                                          const SizedBox(width: 5,),
                                        ],
                                      );
                                    },
                                  ),
                                ):
                                const SizedBox(),
                              ],
                            ),
                          ):
                          const SizedBox(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: (fertilizerCentral[fIndex]['Fertilizer'].length * 65) - (fertilizerCentral[fIndex]['Ec'].length * 70),
                            child: Center(
                              child: Text(fertilizerCentral[fIndex]['SW_Name'] ?? fertilizerCentral[fIndex]['FertilizerSite'], style: const TextStyle(color: primaryColorDark),),
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
        final fertilizerCentral = Provider.of<MqttPayloadProvider>(context, listen: false).fertilizerCentral;
        for (var central in fertilizerCentral) {
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
  const LocalFilter({Key? key, required this.currentLineId, required this.filtersSites}) : super(key: key);
  final String currentLineId;
  final List<dynamic> filtersSites;

  @override
  State<LocalFilter> createState() => _LocalFilterState();
}

class _LocalFilterState extends State<LocalFilter> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    for (var site in widget.filtersSites) {
      if (site['DurationLeft'] != '00:00:00') {
        durationUpdatingFunction();
      }else{
        timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> filteredLocalFilter=[];
    if(widget.currentLineId=='all'){
      filteredLocalFilter = widget.filtersSites.cast<Map<String, dynamic>>();
    }else{
      filteredLocalFilter = widget.filtersSites.where((filter) =>
          filter['Location'].contains(widget.currentLineId))
          .toList().cast<Map<String, dynamic>>();
    }

    return widget.currentLineId=='all'? Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for(int i=0; i<filteredLocalFilter.length; i++)
              Column(
                children: [
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
                                      top: 55,
                                      left: 7.5,
                                      child: filteredLocalFilter[i]['DurationLeft']!='00:00:00'? filteredLocalFilter[i]['Status'] == (flIndex+1) ? Container(
                                        decoration: BoxDecoration(
                                          color:Colors.greenAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
                                        width: 55,
                                        child: Center(
                                          child: Text(filteredLocalFilter[i]['DurationLeft'],
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    width: filteredLocalFilter[i]['FilterStatus'].length * 60,
                    child: Center(
                      child: Text(filteredLocalFilter[i]['SW_Name'] ?? filteredLocalFilter[i]['FilterSite'], style: const TextStyle(color: primaryColorDark),),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ):
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for(int i=0; i<filteredLocalFilter.length; i++)
          Column(
            children: [
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
                              ),),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(3),
                ),
                width: filteredLocalFilter[i]['FilterStatus'].length * 60,
                child: Center(
                  child: Text(filteredLocalFilter[i]['SW_Name'] ?? filteredLocalFilter[i]['FilterSite'], style: const TextStyle(color: primaryColorDark),),
                ),
              ),
            ],
          ),
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
        for (var site in widget.filtersSites) {
          if(site['DurationLeft']!='00:00:00'){
            for (var filters in site['FilterStatus']) {
              if(filters['Status']==1){
                List<String> parts = site['DurationLeft'].split(':');
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
                    site['DurationLeft'] = updatedDurationQtyLeft;
                  });
                }
              }
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

    final overallFrtLocal = Provider.of<MqttPayloadProvider>(context).fertilizerLocal;

    List<Map<String, dynamic>> fertilizerLocal =[];
    if(widget.currentLineId=='all'){
      fertilizerLocal = Provider.of<MqttPayloadProvider>(context,listen: false).fertilizerLocal.toList().cast<Map<String, dynamic>>();
    }else{
      fertilizerLocal = overallFrtLocal
          .where((lfr) => lfr['Location'].contains(widget.currentLineId)).toList()
          .cast<Map<String, dynamic>>();
    }

    durationUpdatingFunction();

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
                  width: fertilizerLocal[fIndex]['Fertilizer'].length * 70,
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
                          fertilizerLocal[fIndex]['Ec'].length!=0?SizedBox(
                            width: fertilizerLocal[fIndex]['Ec'].length>1? 130 : 70,
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
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ec'][index]['Name']} : ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.normal))),
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ec'][index]['Status']}0', style: const TextStyle(fontSize: 9))),
                                          const SizedBox(width: 5,),
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
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ph'][index]['Name']} : ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.normal),)),
                                          Center(child: Text('${fertilizerLocal[fIndex]['Ph'][index]['Status']}0', style: const TextStyle(fontSize: 9))),
                                          const SizedBox(width: 5,),
                                        ],
                                      );
                                    },
                                  ),
                                ) :
                                const SizedBox(),
                              ],
                            ),
                          ):
                          const SizedBox(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: (fertilizerLocal[fIndex]['Fertilizer'].length * 63) - (fertilizerLocal[fIndex]['Ec'].length * 70),
                            child: Center(
                              child: Text(fertilizerLocal[0]['SW_Name']?? fertilizerLocal[0]['FertilizerSite'], style: const TextStyle(color: primaryColorDark),),
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
        final fertilizerLocal = Provider.of<MqttPayloadProvider>(context, listen: false).fertilizerLocal;
        for (var localFer in fertilizerLocal) {
          localFer['Fertilizer'].forEach((fertilizer) {
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

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          InkWell(
            onTap: () {

            },
            child: Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry A')),
            ),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[200],
            child: const Center(child: Text('Entry B')),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[300],
            child: const Center(child: Text('Entry C')),
          ),
        ],
      ),
    );
  }
}

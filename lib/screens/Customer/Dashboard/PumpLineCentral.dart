import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:popover/popover.dart';
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

    /*if(provider.filtersCentral.isEmpty && provider.filtersLocal.isEmpty
        && provider.fertilizerCentral.isEmpty && provider.fertilizerLocal.isEmpty){
      return Padding(
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
              child: DisplayIrrigationPump(currentLineId: widget.crrIrrLine.id, deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId,),
            ):
            const SizedBox(),
          ],
        ):
        const SizedBox(height: 20),
      );
    }*/

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
                      child: DisplaySourcePump(deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId, currentLineId: widget.crrIrrLine.id,),
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
                      child: DisplayIrrigationPump(currentLineId: widget.crrIrrLine.id, deviceId: widget.currentSiteData.master[widget.masterIdx].deviceId,),
                    ):
                    const SizedBox(),

                    if(provider.filtersCentral.isEmpty)
                      for(int i=0; i<provider.payload2408.length; i++)
                        provider.payload2408.isNotEmpty?  Padding(
                          padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                          child: provider.payload2408[i]['Line'].contains(widget.crrIrrLine.id)? DisplaySensor(crInx: i):null,
                        ) : const SizedBox(),

                    provider.filtersCentral.isEmpty && provider.fertilizerCentral.isEmpty &&
                        provider.filtersLocal.isEmpty && provider.fertilizerLocal.isEmpty ? SizedBox(
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


                    provider.filtersCentral.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: DisplayFilter(currentLineId: widget.crrIrrLine.id,),
                    ): const SizedBox(),

                    if(provider.filtersCentral.isNotEmpty)
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
                            (provider.fertilizerCentral.isNotEmpty || provider.filtersCentral.isNotEmpty) && provider.fertilizerLocal.isNotEmpty?
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
        irrigationPauseFlag !=2 ? Padding(
          padding: const EdgeInsets.all(8),
          child: TextButton(
            onPressed: () {
              int prFlag = 0;
              List<dynamic> records = provider.payload2408;
              int sNoToCheck = widget.crrIrrLine.sNo;
              var record = records.firstWhere(
                    (record) => record['S_No'] == sNoToCheck,
                orElse: () => null,
              );
              if (record != null) {
                bool isIrrigationPauseFlagZero = record['IrrigationPauseFlag'] == 0;
                if (isIrrigationPauseFlagZero) {
                  prFlag = 1;
                } else {
                  prFlag = 0;
                }
                String payLoadFinal = jsonEncode({
                  "4900": [
                    {
                      "4901": "$sNoToCheck, $prFlag",
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
  const DisplaySourcePump({Key? key, required this.deviceId, required this.currentLineId}) : super(key: key);
  final String deviceId;
  final String currentLineId;

  @override
  State<DisplaySourcePump> createState() => _DisplaySourcePumpState();
}

class _DisplaySourcePumpState extends State<DisplaySourcePump> {

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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final sourcePump = Provider.of<MqttPayloadProvider>(context, listen: false).sourcePump;
        for (int i = 0; i < sourcePump.length; i++) {
          if(sourcePump[i]['OnDelayLeft']!=null){
            List<String> parts = sourcePump[i]['OnDelayLeft'].split(':');
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
            if(sourcePump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                sourcePump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
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
    final sourcePump = Provider.of<MqttPayloadProvider>(context).sourcePump;

    _startTimer();

    List<Map<String, dynamic>> filteredPumps=[];
    if(widget.currentLineId=='all'){
      filteredPumps = sourcePump.toList().cast<Map<String, dynamic>>();
    }else{
      filteredPumps = sourcePump
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
                              ),
                              const Divider(height: 0),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text('Voltage :'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.red.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.red, width: .50,),
                                          ),
                                          child: Center(child: Text('R : ${voltages[0]}')),
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.yellow.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.yellow, width: .50,),
                                          ),
                                          child: Center(child: Text('Y : ${voltages[1]}')),
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.blue.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.blue, width: .50,),
                                          ),
                                          child: Center(child: Text('B : ${voltages[2]}')),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text('Current :'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[0])),  // Display the value for R
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[1])),  // Display the value for Y
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[2])),  // Display the value for B
                                        )
                                      ],
                                    ),
                                    const SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'Phase : ',
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${filteredPumps[index]['Phase']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 3,),
                                        const Text('Level'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 70,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.blue, width: 0.50),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 80 * (level / 100),  // Adjust height based on percentage
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
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Divider(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Material(
                                    elevation: 8.0,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 22.0,
                                      backgroundColor: Colors.green,
                                      child: IconButton(tooltip: 'ON',
                                          onPressed: () {
                                            String payload = '1,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    elevation: 8.0,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 22.0,
                                      backgroundColor: Colors.redAccent,
                                      child: IconButton(
                                          tooltip: 'OFF',
                                          onPressed: () {
                                            String payload = '0,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          icon: const Icon(
                                            Icons.power_settings_new,
                                            color: Colors.white,)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ):
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Material(
                                    elevation: 8.0,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 22.0,
                                      backgroundColor: Colors.green,
                                      child: IconButton(tooltip: 'ON',
                                          onPressed: () {
                                            String payload = '1,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                    ),
                                  ),
                                  Material(
                                    elevation: 8.0,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 22.0,
                                      backgroundColor: Colors.redAccent,
                                      child: IconButton(
                                          tooltip: 'OFF',
                                          onPressed: () {
                                            String payload = '0,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          icon: const Icon(
                                            Icons.power_settings_new,
                                            color: Colors.white,)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onPop: () => print('Popover was popped!'),
                          direction: PopoverDirection.right,
                          width: voltKeyExists?275:125,
                          height: voltKeyExists?270: 75,
                          arrowHeight: 15,
                          arrowWidth: 30,
                          barrierColor: Colors.black54,
                          arrowDxOffset: filteredPumps.length==1?(position.dx+25)+(index*70)-140:
                          filteredPumps.length==2?(position.dx+25)+(index*70)-210:
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
                  pump['OnDelayLeft'] != '00:00:00'
                      ? Positioned(
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
                  Tooltip(
                    message: 'View more details',
                    child: TextButton(
                      onPressed: () {
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

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: voltKeyExists? ListTile(
                                title: Text(filteredPumps[index]['SW_Name'] ?? filteredPumps[index]['Name']),
                                subtitle: Text('Version: ${filteredPumps[index]['Version']}', style: const TextStyle(fontSize: 10, color: Colors.grey),),
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
                              ):
                              Text(filteredPumps[index]['SW_Name'] ?? filteredPumps[index]['Name']),
                              content: SizedBox(
                                width: voltKeyExists?270:100,
                                height: voltKeyExists?175: 40,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        voltKeyExists?Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('Voltage :'),
                                            const SizedBox(height: 3,),
                                            Container(
                                              width: 75,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color:Colors.red.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.red, width: .50,),
                                              ),
                                              child: Center(child: Text('R : ${voltages[0]}')),
                                            ),
                                            const SizedBox(height: 8,),
                                            Container(
                                              width: 75,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color:Colors.yellow.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.yellow, width: .50,),
                                              ),
                                              child: Center(child: Text('Y : ${voltages[1]}')),
                                            ),
                                            const SizedBox(height: 8,),
                                            Container(
                                              width: 75,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color:Colors.blue.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.blue, width: .50,),
                                              ),
                                              child: Center(child: Text('B : ${voltages[2]}')),
                                            ),
                                          ],
                                        ):
                                        const SizedBox(),

                                        const SizedBox(width: 20,),

                                        voltKeyExists? Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text('Current :'),
                                            const SizedBox(height: 3,),
                                            Container(
                                              width: 70,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.teal, width: 0.50),
                                              ),
                                              child: Center(child: Text(columns[0])),  // Display the value for R
                                            ),
                                            const SizedBox(height: 8,),
                                            Container(
                                              width: 70,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.teal, width: 0.50),
                                              ),
                                              child: Center(child: Text(columns[1])),  // Display the value for Y
                                            ),
                                            const SizedBox(height: 8,),
                                            Container(
                                              width: 70,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.teal, width: 0.50),
                                              ),
                                              child: Center(child: Text(columns[2])),  // Display the value for B
                                            )
                                          ],
                                        ):
                                        const SizedBox(),

                                        const SizedBox(width: 20,),

                                        voltKeyExists? Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Phase : ',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '${filteredPumps[index]['Phase']}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 3,),
                                            const Text('Level'),
                                            const SizedBox(height: 3,),
                                            Container(
                                              width: 70,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                border: Border.all(color: Colors.blue, width: 0.50),
                                              ),
                                              child: Stack(
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 80 * (level / 100),  // Adjust height based on percentage
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
                                        ):
                                        const SizedBox(),
                                      ],
                                    ),

                                    voltKeyExists? const Divider():
                                    const SizedBox(),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        MaterialButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            String payload = '1,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          child: const Text('ON'),
                                        ),
                                        MaterialButton(
                                          color: Colors.redAccent,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            String payload = '0,${filteredPumps[index]['S_No']}';
                                            String payLoadFinal = jsonEncode({
                                              "6201": [{"6202": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                          },
                                          child: const Text('OFF'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  color: Colors.grey,
                                  textColor: Colors.black,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          },
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
                        child: AppImages.getAsset('sourcePump', filteredPumps[index]['Status'], ''),
                      ),
                    ),
                  ),
                  filteredPumps[index]['OnDelayLeft'] !='00:00:00'?
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
                            Text(filteredPumps[index]['OnDelayLeft'],
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
                child: Text(filteredPumps[index]['SW_Name'] ?? filteredPumps[index]['Name'],
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


}

class DisplayIrrigationPump extends StatefulWidget {
  const DisplayIrrigationPump({Key? key, required this.currentLineId, required this.deviceId}) : super(key: key);
  final String currentLineId;
  final String deviceId;

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

    List<Map<String, dynamic>> filteredPumps = [];
    if (widget.currentLineId == 'all') {
      filteredPumps = irrigationPump.toList().cast<Map<String, dynamic>>();
    } else {
      filteredPumps = irrigationPump
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
                              ),
                              const Divider(height: 0),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text('Voltage :'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.red.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.red, width: .50,),
                                          ),
                                          child: Center(child: Text('R : ${voltages[0]}')),
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.yellow.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.yellow, width: .50,),
                                          ),
                                          child: Center(child: Text('Y : ${voltages[1]}')),
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 75,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:Colors.blue.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.blue, width: .50,),
                                          ),
                                          child: Center(child: Text('B : ${voltages[2]}')),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text('Current :'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[0])),  // Display the value for R
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[1])),  // Display the value for Y
                                        ),
                                        const SizedBox(height: 8,),
                                        Container(
                                          width: 70,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.teal, width: 0.50),
                                          ),
                                          child: Center(child: Text(columns[2])),  // Display the value for B
                                        )
                                      ],
                                    ),
                                    const SizedBox(width: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'Phase : ',
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${filteredPumps[index]['Phase']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 3,),
                                        const Text('Level'),
                                        const SizedBox(height: 3,),
                                        Container(
                                          width: 70,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                            border: Border.all(color: Colors.blue, width: 0.50),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 80 * (level / 100),  // Adjust height based on percentage
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
                                  ],
                                ),
                              ),
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
                          width: voltKeyExists?275:125,
                          height: voltKeyExists?270: 75,
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
                  pump['OnDelayLeft'] != '00:00:00'
                      ? Positioned(
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

    List<Map<String, dynamic>> filteredCentralFilter=[];
    if(widget.currentLineId=='all'){
      filteredCentralFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersCentral.toList().cast<Map<String, dynamic>>();
    }else{
      filteredCentralFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersCentral
          .where((filter) => filter['Location'].contains(widget.currentLineId))
          .toList()
          .cast<Map<String, dynamic>>();
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
        final filtersCentral = Provider.of<MqttPayloadProvider>(context, listen: false).filtersCentral;
        for(int fIndex=0; fIndex<filtersCentral.length; fIndex++){
          if(filtersCentral[fIndex]['DurationLeft']!='00:00:00'){

            List<String> parts = filtersCentral[fIndex]['DurationLeft'].split(':');
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
                filtersCentral[fIndex]['DurationLeft'] = updatedDurationQtyLeft;
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
                            width: fertilizerCentral[fIndex]['Ec'].length>1? 115 : 60,
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
                          ):
                          const SizedBox(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: (fertilizerCentral[fIndex]['Fertilizer'].length * 65) - (fertilizerCentral[fIndex]['Ec'].length * 70),
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

    List<Map<String, dynamic>> filteredLocalFilter=[];
    if(widget.currentLineId=='all'){
      filteredLocalFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersLocal.toList().cast<Map<String, dynamic>>();
    }else{
      filteredLocalFilter = Provider.of<MqttPayloadProvider>(context,listen: false).filtersLocal
          .where((filter) => filter['Location'].contains(widget.currentLineId))
          .toList()
          .cast<Map<String, dynamic>>();
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
    ) :
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
        final filtersLocal = Provider.of<MqttPayloadProvider>(context, listen: false).filtersLocal;
        for(int fIndex=0; fIndex<filtersLocal.length; fIndex++){
          if(filtersLocal[fIndex]['DurationLeft']!='00:00:00'){

            List<String> parts = filtersLocal[fIndex]['DurationLeft'].split(':');
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
                filtersLocal[fIndex]['DurationLeft'] = updatedDurationQtyLeft;
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
                            width: fertilizerLocal[fIndex]['Ec'].length>1? 115 : 60,
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

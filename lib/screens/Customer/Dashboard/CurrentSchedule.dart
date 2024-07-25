import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/MyFunction.dart';
import '../../../constants/http_service.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.siteData, required this.customerID, required this.filteredCurrentSchedule}) : super(key: key);
  final DashboardModel siteData;
  final int customerID;
  final List<CurrentScheduleModel> filteredCurrentSchedule;

  @override
  State<CurrentSchedule> createState() => _CurrentScheduleState();
}

class _CurrentScheduleState extends State<CurrentSchedule> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //_startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateDurationQtyLeft();
    });
  }


  void _updateDurationQtyLeft() {
    bool allOnDelayLeftZero = true;
    try {
      if(widget.filteredCurrentSchedule.isNotEmpty){
        for (int i = 0; i < widget.filteredCurrentSchedule.length; i++) {
          if(widget.filteredCurrentSchedule[i].message=='Running.'){
            if (widget.filteredCurrentSchedule[i].duration_QtyLeft.contains(':')){
              List<String> parts = widget.filteredCurrentSchedule[i].duration_QtyLeft.split(':');
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
              if (widget.filteredCurrentSchedule[i].duration_QtyLeft != '00:00:00') {
                setState(() {
                  widget.filteredCurrentSchedule[i].duration_QtyLeft = updatedDurationQtyLeft;
                });
              }
            }
            else {
              double remainFlow = double.parse(widget.filteredCurrentSchedule[i].duration_QtyLeft);
              if (remainFlow > 0) {
                double flowRate = double.parse(widget.filteredCurrentSchedule[i].avgFlwRt);
                remainFlow -= flowRate;
                String formattedFlow = remainFlow.toStringAsFixed(2);
                setState(() {
                  widget.filteredCurrentSchedule[i].duration_QtyLeft = formattedFlow;
                });
              } else {
                widget.filteredCurrentSchedule[i].duration_QtyLeft = '0.00';
              }
            }
            allOnDelayLeftZero = false;
          }else{
            //pump on delay or filter running
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

    var screenWidth = MediaQuery.of(context).size.width;
    _startTimer();

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: screenWidth > 600 ? buildWideLayout():
                buildNarrowLayout(),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('CURRENT SCHEDULE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNarrowLayout() {
    return SizedBox(
      height: widget.filteredCurrentSchedule.length * 200,
      child: Card(
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
        elevation: 5,
        child: ListView.builder(
          itemCount: widget.filteredCurrentSchedule.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8, top: 5, bottom: 5),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Start at', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      Text(convert24HourTo12Hour(widget.filteredCurrentSchedule[index].startTime)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Duration', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      Text(widget.filteredCurrentSchedule[index].duration_Qty),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 0,),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(widget.filteredCurrentSchedule[index].duration_QtyLeft,style: const TextStyle(fontSize: 20)),
                                  const VerticalDivider(),
                                  Text('${widget.filteredCurrentSchedule[index].currentZone}/${widget.filteredCurrentSchedule[index].totalZone}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Current program', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Location & Zone', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Current RTC & Cyclic', style: TextStyle(fontWeight: FontWeight.normal),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(widget.filteredCurrentSchedule[index].programName),
                              const SizedBox(height: 3,),
                              Text('${widget.filteredCurrentSchedule[index].programCategory} & ${widget.filteredCurrentSchedule[index].zoneName}'),
                              const SizedBox(height: 3,),
                              Text('${formatRtcValues(widget.filteredCurrentSchedule[index].currentRtc, widget.filteredCurrentSchedule[index].totalRtc)} & '
                                  '${formatRtcValues(widget.filteredCurrentSchedule[index].currentCycle,widget.filteredCurrentSchedule[index].totalCycle)}'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(getContentByCode(widget.filteredCurrentSchedule[index].reasonCode), style: const TextStyle(fontSize: 12, color: Colors.black),),
                          widget.filteredCurrentSchedule[index].programName=='StandAlone - Manual'?
                          MaterialButton(
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            onPressed: widget.filteredCurrentSchedule[index].message=='Running.'? (){
                              String payload = '0,0,0,0';
                              String payLoadFinal = jsonEncode({
                                "800": [{"801": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                              sentManualModeToServer(0,
                                  widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'? 3:
                                  widget.filteredCurrentSchedule[index].duration_Qty.contains(':')?1: 2);
                            } : null,
                            child: const Text('Stop'),
                          ):
                          widget.filteredCurrentSchedule[index].programName.contains('StandAlone') ?
                          MaterialButton(
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            onPressed: () async {
                              String payLoadFinal = jsonEncode({
                                "3900": [{"3901": '0,${widget.filteredCurrentSchedule[index].programCategory},${widget.filteredCurrentSchedule[index].srlNo},'
                                    '${widget.filteredCurrentSchedule[index].zoneSNo},,,,,,,,,,;'}]
                              });

                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                              sentManualModeToServer(widget.filteredCurrentSchedule[index].programSno,
                                  widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'? 3:
                                  widget.filteredCurrentSchedule[index].duration_Qty.contains(':')?1: 2);
                            },
                            child: const Text('Stop'),
                          ):
                          MaterialButton(
                            color: Colors.green,
                            textColor: Colors.white,
                            onPressed: widget.filteredCurrentSchedule[index].message=='Running.'? (){
                              String payload = '${widget.filteredCurrentSchedule[index].srlNo},0';
                              String payLoadFinal = jsonEncode({
                                "3700": [{"3701": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                            } : null,
                            child: const Text('Skip'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if(index != widget.filteredCurrentSchedule.length - 1)
                  Divider(height: 5, color: Colors.teal.shade50, thickness: 4,),
                const SizedBox(height: 5,),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildWideLayout() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      height: (widget.filteredCurrentSchedule.length * 45) + 45,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 1200,
        dataRowHeight: 45.0,
        headingRowHeight: 40.0,
        headingRowColor: WidgetStateProperty.all<Color>(Colors.green.shade50),
        columns: const [
          DataColumn2(
              label: Text('Name', style: TextStyle(fontSize: 13),),
              size: ColumnSize.L
          ),
          DataColumn2(
              label: Text('Location', style: TextStyle(fontSize: 13)),
              size: ColumnSize.S
          ),
          DataColumn2(
              label: Text('Zone', style: TextStyle(fontSize: 13),),
              size: ColumnSize.S
          ),
          DataColumn2(
              label: Text('Zone Name', style: TextStyle(fontSize: 13)),
              size: ColumnSize.M
          ),
          DataColumn2(
            label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
            fixedWidth: 75,
          ),
          DataColumn2(
            label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
            fixedWidth: 75,
          ),
          DataColumn2(
            label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Center(child: Text('Total (D/FL)', style: TextStyle(fontSize: 13),)),
            fixedWidth: 100,
          ),
          DataColumn2(
            label: Center(child: Text('Avg/Flw Rate', style: TextStyle(fontSize: 13),)),
            fixedWidth: 100,
          ),
          DataColumn2(
            label: Center(child: Text('Remaining', style: TextStyle(fontSize: 13),)),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Center(child: Text('')),
            fixedWidth: 90,
          ),
        ],

        rows: List<DataRow>.generate(widget.filteredCurrentSchedule.length, (index) => DataRow(cells: [
          DataCell(
           Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.filteredCurrentSchedule[index].programName),
                  Text(getContentByCode(widget.filteredCurrentSchedule[index].reasonCode), style: const TextStyle(fontSize: 11, color: Colors.black),),
                ],
              ),
          ),
          DataCell(Text(widget.filteredCurrentSchedule[index].programCategory)),
          DataCell(Text('${widget.filteredCurrentSchedule[index].currentZone}/${widget.filteredCurrentSchedule[index].totalZone}')),
          DataCell(Text(widget.filteredCurrentSchedule[index].programName=='StandAlone - Manual'? '--':widget.filteredCurrentSchedule[index].zoneName)),
          DataCell(Center(child: Text(formatRtcValues(widget.filteredCurrentSchedule[index].currentRtc, widget.filteredCurrentSchedule[index].totalRtc)))),
          DataCell(Center(child: Text(formatRtcValues(widget.filteredCurrentSchedule[index].currentCycle,widget.filteredCurrentSchedule[index].totalCycle)))),
          DataCell(Center(child: Text(convert24HourTo12Hour(widget.filteredCurrentSchedule[index].startTime)))),
          DataCell(Center(child: Text(widget.filteredCurrentSchedule[index].programName=='StandAlone - Manual' &&
              (widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'||widget.filteredCurrentSchedule[index].duration_Qty=='0')?
          'Timeless': widget.filteredCurrentSchedule[index].duration_Qty))),
          DataCell(Center(child: Text('${widget.filteredCurrentSchedule[index].actualFlowRate}/hr'))),
          DataCell(Center(child: Text(widget.filteredCurrentSchedule[index].programName=='StandAlone - Manual' &&
              (widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'||widget.filteredCurrentSchedule[index].duration_Qty=='0')? '----': widget.filteredCurrentSchedule[index].duration_QtyLeft,
              style:  const TextStyle(fontSize: 20)))),
          DataCell(Center(
            child: widget.filteredCurrentSchedule[index].programName=='StandAlone - Manual'?
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: widget.filteredCurrentSchedule[index].message=='Running.'? (){
                String payload = '0,0,0,0';
                String payLoadFinal = jsonEncode({
                  "800": [{"801": payload}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                sentManualModeToServer(0, widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'? 3:
                widget.filteredCurrentSchedule[index].duration_Qty.contains(':')?1: 2);
              } : null,
              child: const Text('Stop'),
            ):
            widget.filteredCurrentSchedule[index].programName.contains('StandAlone') ?
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: () async {

                String payLoadFinal = jsonEncode({
                  "3900": [{"3901": '0,${widget.filteredCurrentSchedule[index].programCategory},${widget.filteredCurrentSchedule[index].programSno},'
                      '${widget.filteredCurrentSchedule[index].zoneSNo},,,,,,,,,0,'}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');

                sentManualModeToServer(widget.filteredCurrentSchedule[index].programSno,
                    widget.filteredCurrentSchedule[index].duration_Qty=='00:00:00'? 3:
                    widget.filteredCurrentSchedule[index].duration_Qty.contains(':')?1: 2);
              },
              child: const Text('Stop'),
            ):
            MaterialButton(
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: widget.filteredCurrentSchedule[index].message=='Running.'? (){
                String payload = '${widget.filteredCurrentSchedule[index].srlNo},0';
                String payLoadFinal = jsonEncode({
                  "3700": [{"3701": payload}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
              } : null,
              child: const Text('Skip'),
            ),
          )),
        ])),
      ),
    );
  }


  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

  List<Widget> buildValveRows(List<Map<String, dynamic>> valveData) {
    return valveData.map((valve) {
      return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              const SizedBox(height: 3),
              Image.asset(
                width: 40,
                height: 40,
                // Assuming 'Status' is a key in the valve map
                valve['Status'] == 0
                    ? 'assets/images/valve_gray.png'
                    : valve['Status'] == 1
                    ? 'assets/images/valve_green.png'
                    : valve['Status'] == 2
                    ? 'assets/images/valve_orange.png'
                    : 'assets/images/valve_red.png',
              ),
              const SizedBox(height: 3),
              Text(
                '${valve['Name']}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String getContentByCode(int code) {
    return GemProgramSSReasonCode.fromCode(code).content;
  }

  Future<void>sentManualModeToServer(int sNo, int method) async {
    try {
      final body = {
        "userId": widget.customerID,
        "controllerId": widget.siteData.master[0].controllerId,
        "serialNumber": sNo,
        "startFlag": 0,
        "method": method,
        "duration": '00:00:00',
        "flow": '0',
        "selection": [],
        "createUser": widget.customerID,
      };

      final response = await HttpService().postRequest("createUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}

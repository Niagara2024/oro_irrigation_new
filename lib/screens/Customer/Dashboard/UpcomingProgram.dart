import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../ScheduleView.dart';

class UpcomingProgram extends StatelessWidget {
  UpcomingProgram({Key? key, required this.siteData, required this.customerId}) : super(key: key);
  final DashboardModel siteData;
  final int customerId;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  height: provider.upcomingProgram.isNotEmpty? (provider.upcomingProgram.length * 45) + 45 : 50,
                  child: provider.upcomingProgram.isNotEmpty? Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      dataRowHeight: 45.0,
                      headingRowHeight: 40.0,
                      headingRowColor: MaterialStateProperty.all<Color>(Colors.yellow.shade50),
                      columns:  [
                        const DataColumn2(
                            label: Text('Name', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.L,
                        ),
                        const DataColumn2(
                            label: Text('Method', style: TextStyle(fontSize: 13)),
                            size: ColumnSize.M,
                        ),
                        const DataColumn2(
                            label: Text('Location', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.M,
                        ),
                        const DataColumn2(
                            label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                            fixedWidth: 50,
                        ),
                        const DataColumn2(
                            label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M,
                        ),
                        const DataColumn2(
                            label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M,
                        ),
                        const DataColumn2(
                            label: Center(child: Text('End Date', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M,
                        ),
                        DataColumn2(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    tooltip: 'Scheduled Program details',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ScheduleViewScreen(deviceId: siteData.master[0].deviceId, userId: customerId, controllerId: siteData.master[0].controllerId, customerId: customerId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.view_list_outlined)),
                                IconButton(
                                    tooltip: 'Create new Schedule',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ScheduleViewScreen(deviceId: siteData.master[0].deviceId, userId: customerId, controllerId: siteData.master[0].controllerId, customerId: customerId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_box_outlined))
                              ],
                            ),
                            fixedWidth: 265,
                        ),
                      ],
                      rows: List<DataRow>.generate(provider.upcomingProgram.length, (index) => DataRow(cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(provider.upcomingProgram[index]['ProgName']),
                              Text('${getContentByCode(provider.upcomingProgram[index]['StartStopReason'])} - ${provider.upcomingProgram[index]['StartStopReason']}', style: const TextStyle(fontSize: 11, color: Colors.black),),
                            ],
                          )
                        ),
                        DataCell(Text(provider.upcomingProgram[index]['SchedulingMethod']==1?'No Schedule':provider.upcomingProgram[index]['SchedulingMethod']==2?'Schedule by days':
                        provider.upcomingProgram[index]['SchedulingMethod']==3?'Schedule as run list':'Day count schedule')),
                        DataCell(Text(provider.upcomingProgram[index]['ProgCategory'])),
                        DataCell(Center(child: Text('${provider.upcomingProgram[index]['TotalZone']}'))),
                        DataCell(Center(child: Text('${provider.upcomingProgram[index]['StartDate']}'))),
                        DataCell(Center(child: Text('${provider.upcomingProgram[index]['StartTime']}'))),
                        DataCell(Center(child: Text('${provider.upcomingProgram[index]['EndDate']}'))),
                        DataCell(Row(
                            children: [
                              provider.upcomingProgram[index]['ProgOnOff'] == 0 ? MaterialButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                onPressed:() {
                                  String localFilePath = 'assets/audios/button_click_sound.mp3';
                                  audioPlayer.play(UrlSource(localFilePath));
                                  String payload = '${provider.upcomingProgram[index]['SNo']},1';
                                  String payLoadFinal = jsonEncode({
                                    "2900": [{"2901": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                                  sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Started by Manual', payLoadFinal);
                                },
                                child: const Text('Start by Manual'),
                              ) :
                              MaterialButton(
                                color: Colors.redAccent,
                                textColor: Colors.white,
                                onPressed:() {
                                  String localFilePath = 'assets/audios/audio_off.mp3';
                                  audioPlayer.play(UrlSource(localFilePath));
                                  String payload = '${provider.upcomingProgram[index]['SNo']},0';
                                  String payLoadFinal = jsonEncode({
                                    "2900": [{"2901": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                                  sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Stopped by Manual', payLoadFinal);
                                },
                                child: const Text('Stop by Manual'),
                              ),
                              const SizedBox(width: 5),
                              provider.upcomingProgram[index]['ProgPauseResume'] == 1 ? MaterialButton(
                                color: Colors.orange,
                                textColor: Colors.white,
                                onPressed:() {
                                  String payload = '${provider.upcomingProgram[index]['SNo']},2';
                                  String payLoadFinal = jsonEncode({
                                    "2900": [{"2901": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                                  sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Paused by Manual', payLoadFinal);
                                },
                                child: const Text('Pause'),
                              ) :
                              MaterialButton(
                                color: Colors.yellow,
                                textColor: Colors.black,
                                onPressed:() {
                                  String localFilePath = 'assets/audios/audio_off.mp3';
                                  audioPlayer.play(UrlSource(localFilePath));
                                  String payload = '${provider.upcomingProgram[index]['SNo']},3';
                                  String payLoadFinal = jsonEncode({
                                    "2900": [{"2901": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                                  sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Resume by Manual', payLoadFinal);
                                },
                                child: const Text('Resume'),
                              ),
                              const SizedBox(width: 5),
                              IconButton(tooltip: 'View details', icon: const Icon(Icons.more_vert), onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(provider.upcomingProgram[index]['ProgName']),
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                      content: Text('Start or Stop Reason Code = ${provider.upcomingProgram[index]['StartStopReason']}'),
                                      actions: <Widget>[
                                        MaterialButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          onPressed:() {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },)
                            ],
                          ),),
                      ])),
                    ),
                  ) :
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text('Upcoming Program not Available', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('SCHEDULED PROGRAM',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getContentByCode(int code) {
    switch (code) {
      case 1:
        return 'Running As Per Schedule';
      case 2:
        return 'Turned On Manually';
      case 3:
        return 'Started By Condition';
      case 4:
        return 'Turned Off Manually';
      case 5:
        return 'Program Turned Off';
      case 6:
        return 'Zone Turned Off';
      case 7:
        return 'Stopped By Condition';
      case 8:
        return 'Disabled By Condition';
      case 9:
        return 'StandAlone Program Started';
      case 10:
        return 'StandAlone Program Stopped';
      case 11:
        return 'StandAlone Program Stopped After Set Value';
      case 12:
        return 'StandAlone Manual Started';
      case 13:
        return 'StandAlone Manual Stopped';
      case 14:
        return 'StandAlone Manual Stopped After Set Value';
      case 15:
        return 'Started By Day Count Rtc';
      case 16:
        return 'Paused By User';
      case 17:
        return 'Manually Started Paused By User';
      case 18:
        return 'Program Deleted';
      case 19:
        return 'Program Ready';
      case 20:
        return 'Program Completed';
      case 21:
        return 'Resumed By User';
      case 23:
        return 'Paused By Condition';
      default:
        return 'Unknown content';
    }
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": siteData.master[0].controllerId, "messageStatus": msg, "data": data, "createUser": customerId};
    final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}


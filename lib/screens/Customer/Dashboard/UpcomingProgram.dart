import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../ScheduleView.dart';

class UpcomingProgram extends StatelessWidget {
  UpcomingProgram({Key? key, required this.siteData, required this.customerId, required this.scheduledPrograms}) : super(key: key);
  final DashboardModel siteData;
  final int customerId;
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<ScheduledProgram> scheduledPrograms;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: screenWidth > 600 ? buildWideLayout(context):
                buildNarrowLayout(context),
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

  Widget buildNarrowLayout(context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: scheduledPrograms.length * 210,
      child: Card(
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
        elevation: 5,
        child: ListView.builder(
          itemCount: scheduledPrograms.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Program Name', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Scheduled method', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Message', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Total Zone', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Start Date & Time', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('End Date', style: TextStyle(fontWeight: FontWeight.normal),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(scheduledPrograms[index].progName),
                              const SizedBox(height: 3,),
                              Text(scheduledPrograms[index].schedulingMethod==1?'No Schedule':scheduledPrograms[index].schedulingMethod==2?'Schedule by days':
                              scheduledPrograms[index].schedulingMethod==3?'Schedule as run list':'Day count schedule'),
                              const SizedBox(height: 3,),
                              Text(getContentByCode(scheduledPrograms[index].startStopReason), style: const TextStyle(fontSize: 11, color: Colors.black),),
                              const SizedBox(height: 3,),
                              Text('${scheduledPrograms[index].totalZone}'),
                              const SizedBox(height: 3,),
                              Text('${scheduledPrograms[index].startDate} : ${_convertTime(scheduledPrograms[index].startTime)}'),
                              const SizedBox(height: 3,),
                              Text(scheduledPrograms[index].endDate)
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          scheduledPrograms[index].progOnOff == 0 ? MaterialButton(
                            color: Colors.green,
                            textColor: Colors.white,
                            onPressed:() {
                              String localFilePath = 'assets/audios/button_click_sound.mp3';
                              audioPlayer.play(UrlSource(localFilePath));
                              String payload = '${scheduledPrograms[index].sNo},1';
                              String payLoadFinal = jsonEncode({
                                "2900": [{"2901": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                              sentUserOperationToServer('${scheduledPrograms[index].progName} Started by Manual', payLoadFinal);
                            },
                            child: const Text('Start by Manual'),
                          ):
                          MaterialButton(
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            onPressed:() {
                              String localFilePath = 'assets/audios/audio_off.mp3';
                              audioPlayer.play(UrlSource(localFilePath));
                              String payload = '${scheduledPrograms[index].sNo},0';
                              String payLoadFinal = jsonEncode({
                                "2900": [{"2901": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                              sentUserOperationToServer('${scheduledPrograms[index].progName} Stopped by Manual', payLoadFinal);
                            },
                            child: const Text('Stop by Manual'),
                          ),
                          const SizedBox(width: 5),
                          scheduledPrograms[index].progPauseResume == 1 ? MaterialButton(
                            color: Colors.orange,
                            textColor: Colors.white,
                            onPressed:() {
                              String payload = '${scheduledPrograms[index].sNo},2';
                              String payLoadFinal = jsonEncode({
                                "2900": [{"2901": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                              sentUserOperationToServer('${scheduledPrograms[index].progName} Paused by Manual', payLoadFinal);
                            },
                            child: const Text('Pause'),
                          ) :
                          MaterialButton(
                            color: Colors.yellow,
                            textColor: Colors.black,
                            onPressed:() {
                              String localFilePath = 'assets/audios/audio_off.mp3';
                              audioPlayer.play(UrlSource(localFilePath));
                              String payload = '${scheduledPrograms[index].sNo},3';
                              String payLoadFinal = jsonEncode({
                                "2900": [{"2901": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                              sentUserOperationToServer('${scheduledPrograms[index].progName} Resume by Manual', payLoadFinal);
                            },
                            child: const Text('Resume'),
                          ),
                          const SizedBox(width: 5),
                          /*IconButton(tooltip: 'View details', icon: const Icon(Icons.more_vert), onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(scheduledPrograms[index].progName),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                          content: Text('Start or Stop Reason Code = ${scheduledPrograms[index].startStopReason}'),
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
                                  },),*/
                        ],
                      ),
                    ],
                  ),
                ),
                if(index != scheduledPrograms.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(right: 5,left: 5),
                    child: Divider(color: Colors.teal, thickness: 0.3,),
                  ),
                const SizedBox(height: 5,),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildWideLayout(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      height: (scheduledPrograms.length * 45) + 45,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1000,
          dataRowHeight: 45.0,
          headingRowHeight: 40.0,
          headingRowColor: MaterialStateProperty.all<Color>(Colors.yellow.shade50),
          columns:  [
            const DataColumn2(
              label: Text('Name', style: TextStyle(fontSize: 13),),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Text('Method', style: TextStyle(fontSize: 13)),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Text('Message', style: TextStyle(fontSize: 13)),
              size: ColumnSize.L,
            ),
            const DataColumn2(
              label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
              fixedWidth: 50,
            ),
            const DataColumn2(
              label: Center(child: Text('Start Date & Time', style: TextStyle(fontSize: 13),)),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Center(child: Text('End Date', style: TextStyle(fontSize: 13),)),
              size: ColumnSize.S,
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

                ],
              ),
              fixedWidth: 230,
            ),
          ],
          rows: List<DataRow>.generate(scheduledPrograms.length, (index) => DataRow(cells: [
            DataCell(Text(scheduledPrograms[index].progName)),
            DataCell(Text(scheduledPrograms[index].schedulingMethod==1?'No Schedule':scheduledPrograms[index].schedulingMethod==2?'Schedule by days':
            scheduledPrograms[index].schedulingMethod==3?'Schedule as run list':'Day count schedule')),
            DataCell(Text('${getContentByCode(scheduledPrograms[index].startStopReason)} - ${scheduledPrograms[index].startStopReason}', style: const TextStyle(fontSize: 12),)),
            DataCell(Center(child: Text('${scheduledPrograms[index].totalZone}'))),
            DataCell(Center(child: Text('${scheduledPrograms[index].startDate} : ${_convertTime(scheduledPrograms[index].startTime)}'))),
            DataCell(Center(child: Text(scheduledPrograms[index].endDate))),
            DataCell(Row(
              children: [
                scheduledPrograms[index].progOnOff == 0 ? MaterialButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed:() {
                    String localFilePath = 'assets/audios/button_click_sound.mp3';
                    audioPlayer.play(UrlSource(localFilePath));
                    String payload = '${scheduledPrograms[index].sNo},1';
                    String payLoadFinal = jsonEncode({
                      "2900": [{"2901": payload}]
                    });
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                    sentUserOperationToServer('${scheduledPrograms[index].progName} Started by Manual', payLoadFinal);
                  },
                  child: const Text('Start by Manual'),
                ):
                MaterialButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed:() {
                    String localFilePath = 'assets/audios/audio_off.mp3';
                    audioPlayer.play(UrlSource(localFilePath));
                    String payload = '${scheduledPrograms[index].sNo},0';
                    String payLoadFinal = jsonEncode({
                      "2900": [{"2901": payload}]
                    });
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                    sentUserOperationToServer('${scheduledPrograms[index].progName} Stopped by Manual', payLoadFinal);
                  },
                  child: const Text('Stop by Manual'),
                ),
                const SizedBox(width: 5),
                scheduledPrograms[index].progPauseResume == 1 ? MaterialButton(
                  color: Colors.orange,
                  textColor: Colors.white,
                  onPressed:() {
                    String payload = '${scheduledPrograms[index].sNo},2';
                    String payLoadFinal = jsonEncode({
                      "2900": [{"2901": payload}]
                    });
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                    sentUserOperationToServer('${scheduledPrograms[index].progName} Paused by Manual', payLoadFinal);
                  },
                  child: const Text('Pause'),
                ) :
                MaterialButton(
                  color: Colors.yellow,
                  textColor: Colors.black,
                  onPressed:() {
                    String localFilePath = 'assets/audios/audio_off.mp3';
                    audioPlayer.play(UrlSource(localFilePath));
                    String payload = '${scheduledPrograms[index].sNo},3';
                    String payLoadFinal = jsonEncode({
                      "2900": [{"2901": payload}]
                    });
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[0].deviceId}');
                    sentUserOperationToServer('${scheduledPrograms[index].progName} Resume by Manual', payLoadFinal);
                  },
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 5),
                /*IconButton(tooltip: 'View details', icon: const Icon(Icons.more_vert), onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(scheduledPrograms[index].progName),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                    content: Text('Start or Stop Reason Code = ${scheduledPrograms[index].startStopReason}'),
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
                            },),*/
              ],
            ),),
          ])),
        ),
      ),
    );
  }

  String _convertTime(String timeString) {
    if(timeString=='-'){
      return '-';
    }
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
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


import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/irrigation_program_main.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/MyFunction.dart';
import '../../../constants/http_service.dart';
import '../../../constants/snack_bar.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../ScheduleView.dart';

class ScheduledProgramList extends StatelessWidget {
  ScheduledProgramList({Key? key, required this.siteData, required this.customerId, required this.scheduledPrograms, required this.masterInx}) : super(key: key);
  final DashboardModel siteData;
  final int customerId, masterInx;
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<ScheduledProgram> scheduledPrograms;

  @override
  Widget build(BuildContext context) {

    final hwConformationMsg = Provider.of<MqttPayloadProvider>(context).messageFromHw;
    /*if(hwConformationMsg!=null){
      GlobalSnackBar.show(context, hwConformationMsg['Message'], int.parse(hwConformationMsg['Code']));
      Provider.of<MqttPayloadProvider>(context).messageFromHw = null;
    }*/

    scheduledPrograms.sort((a, b) {
      DateTime dateTimeA = a.getDateTime();
      DateTime dateTimeB = b.getDateTime();
      return dateTimeA.compareTo(dateTimeB);
    });

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scheduledPrograms.length,
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
                              Text('${scheduledPrograms[index].startDate} : ${convert24HourTo12Hour(scheduledPrograms[index].startTime)}'),
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
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
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
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
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
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
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
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
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
          headingRowColor: WidgetStateProperty.all<Color>(Colors.yellow.shade50),
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
              label: Text('Status', style: TextStyle(fontSize: 13)),
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
                            builder: (context) => ScheduleViewScreen(deviceId: siteData.master[masterInx].deviceId, userId: customerId, controllerId: siteData.master[masterInx].controllerId, customerId: customerId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_list_outlined)),

                ],
              ),
              fixedWidth: 265,
            ),
          ],
          rows: List<DataRow>.generate(scheduledPrograms.length, (index) => DataRow(cells: [
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(scheduledPrograms[index].progName),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: scheduledPrograms[index].programStatusPercentage / 100.0,
                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                        color: Colors.blue.shade300,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 2.5,
                      ),
                    ),
                    const SizedBox(width: 7,),
                    Text('${scheduledPrograms[index].programStatusPercentage}%', style: const TextStyle(fontSize: 12, color: Colors.black45),)
                  ],
                )
              ],
            )),
            DataCell(Text(scheduledPrograms[index].schedulingMethod==1?'No Schedule':scheduledPrograms[index].schedulingMethod==2?'Schedule by days':
            scheduledPrograms[index].schedulingMethod==3?'Schedule as run list':'Day count schedule')),
            DataCell(Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text(getContentByCode(scheduledPrograms[index].startStopReason), style: const TextStyle(fontSize: 12),)),
                scheduledPrograms[index].startCondition.condition.isNotEmpty || scheduledPrograms[index].stopCondition.condition.isNotEmpty? IconButton(tooltip:'view condition', onPressed: () {
                  showAlertDialog(context, scheduledPrograms[index].startCondition, scheduledPrograms[index].stopCondition,scheduledPrograms[index].progName);
                }, icon: const Icon(Icons.visibility_outlined,)) :
                    const SizedBox(),
              ],
            )),
            DataCell(Center(child: Text('${scheduledPrograms[index].totalZone}'))),
            DataCell(Center(child: Text('${scheduledPrograms[index].startDate} : ${convert24HourTo12Hour(scheduledPrograms[index].startTime)}'))),
            DataCell(Center(child: Text(scheduledPrograms[index].endDate))),
            DataCell(Row(
              children: [
                Tooltip(
                  message: getDescription(int.parse(scheduledPrograms[index].progOnOff)),
                  child: MaterialButton(
                    color: int.parse(scheduledPrograms[index].progOnOff)>0? Colors.green: Colors.grey.shade300,
                    textColor: Colors.white,
                    onPressed:() {
                      if(int.parse(scheduledPrograms[index].progOnOff)>0){
                        String localFilePath = 'assets/audios/button_click_sound.mp3';
                        audioPlayer.play(UrlSource(localFilePath));
                        String payload = '${scheduledPrograms[index].sNo},${scheduledPrograms[index].progOnOff}';
                        String payLoadFinal = jsonEncode({
                          "2900": [{"2901": payload}]
                        });
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
                        sentUserOperationToServer('${scheduledPrograms[index].progName} ${getDescription(int.parse(scheduledPrograms[index].progOnOff))}', payLoadFinal);
                      }
                    },
                    child: Text(getButtonName(int.parse(scheduledPrograms[index].progOnOff))),
                  ),
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
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
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
                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.master[masterInx].deviceId}');
                    sentUserOperationToServer('${scheduledPrograms[index].progName} Resume by Manual', payLoadFinal);
                  },
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 5),

                IconButton(tooltip: 'Edit program', icon: const Icon(Icons.edit_outlined), onPressed: () {
                  String prgType = '';
                  bool conditionL = false;
                  if(scheduledPrograms[index].progCategory.contains('IL')){
                    prgType='Irrigation Program';
                  }else{
                    prgType='Agitator Program';
                  }
                  if(siteData.master[masterInx].conditionLibraryCount>0){
                    conditionL = true;
                  }

                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => IrrigationProgram(deviceId: siteData.master[masterInx].deviceId, userId: customerId, controllerId: siteData.master[masterInx].controllerId, serialNumber: scheduledPrograms[index].sNo, programType: prgType, conditionsLibraryIsNotEmpty: conditionL,),
                    ),
                  );
                },),
              ],
            ),),
          ])),
        ),
      ),
    );
  }

  String getButtonName(int code) {
    const Map<int, String> codeDescriptionMap = {
      -1: 'Paused Couldn\'t',
      1: 'Start Manually',
      -2: 'Cond Couldn\'t',
      7: 'Stop Manually',
      13: 'Bypass Start',
      11: 'Bypass Cond',
      12: 'Bypass Stop',
      0: 'Stop Manually',
      2: 'Pause',
      3: 'Resume',
      4: 'Cont Manually',
    };
    return codeDescriptionMap[code] ?? 'Code not found';
  }

  String getDescription(int code) {
    const Map<int, String> codeDescriptionMap = {
      -1: 'Paused Couldn\'t Start',
      1: 'Start Manually',
      -2: 'Started By Condition Couldn\'t Stop',
      7: 'Stop Manually',
      13: 'Bypass Start Condition',
      11: 'Bypass Condition',
      12: 'Bypass Stop Condition and Start',
      0: 'Stop Manually',
      2: 'Pause',
      3: 'Resume',
      4: 'Continue Manually',
    };
    return codeDescriptionMap[code] ?? 'Code not found';
  }

  void showAlertDialog(BuildContext context, StartCondition startCondition, StopCondition stopCondition, pName){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pName),
          content: SizedBox(
            height: startCondition.condition.isNotEmpty && stopCondition.condition.isNotEmpty ?250:120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                startCondition.condition.isNotEmpty ? Text('START CONDITION', style: TextStyle(fontSize: 15, color: startCondition.status==1? Colors.green: Colors.red)):
                const SizedBox(),
                startCondition.condition.isNotEmpty ?Column(
                  children: [
                    const SizedBox(height: 5,),
                    Text(startCondition.condition, style: TextStyle(fontSize: 12, color: startCondition.status==1? Colors.green.shade500: Colors.red.shade500),),
                    const SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 5,),
                        Container(
                          width: 100,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('Set Value', style: TextStyle(color: Colors.black45),),
                              Divider(height: 4, color: Colors.grey.shade300,),
                              Text('${startCondition.set}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Container(
                          width: 100,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('Actual Value', style: TextStyle(color: Colors.black54),),
                              Divider(height: 4, color: Colors.grey.shade300,),
                              Text('${startCondition.actual}'),
                            ],
                          ),
                        ),
                      ],)
                  ],
                ):
                const SizedBox(),

                startCondition.condition.isNotEmpty ? const Divider():
                const SizedBox(),

                stopCondition.condition.isNotEmpty ? Text('STOP CONDITION', style: TextStyle(fontSize: 15, color: stopCondition.status==1? Colors.green: Colors.red)):
                const SizedBox(),
                stopCondition.condition.isNotEmpty ?Column(
                  children: [
                    const SizedBox(height: 5,),
                    Text(stopCondition.condition, style: TextStyle(fontSize: 12, color: stopCondition.status==1? Colors.green.shade500: Colors.red.shade500),),
                    const SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      const SizedBox(width: 5,),
                      Container(
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('Set Value', style: TextStyle(color: Colors.black54),),
                            Divider(height: 4, color: Colors.grey.shade300,),
                            Text('${stopCondition.set}'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8,),
                        Container(
                          width: 100,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('Actual Value',style: TextStyle(color: Colors.black54),),
                              Divider(height: 4, color: Colors.grey.shade300,),
                              Text('${stopCondition.actual}'),
                            ],
                          ),
                        ),
                    ],)
                  ],
                ):
                const SizedBox(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getContentByCode(int code) {
    return GemProgramSSReasonCode.fromCode(code).content;
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": siteData.master[masterInx].controllerId, "messageStatus": msg, "data": data, "createUser": customerId};
    final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}
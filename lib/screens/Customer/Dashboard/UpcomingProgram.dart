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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: const Text('SCHEDULED PROGRAM',  style: TextStyle(color: Colors.black)),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                  ),
                ),
                child: IconButton(
                    tooltip: 'Schedule details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleViewScreen(deviceId: siteData.deviceId, userId: customerId, controllerId: siteData.controllerId, customerId: customerId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.view_list_outlined)),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.yellow.shade100,
                width: 1,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            height: provider.upcomingProgram.isNotEmpty? (provider.upcomingProgram.length * 50) + 35 : 40,
            child: provider.upcomingProgram.isNotEmpty? DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              dataRowHeight: 50.0,
              headingRowHeight: 35.0,
              headingRowColor: MaterialStateProperty.all<Color>(Colors.yellow.shade50),
              columns: const [
                DataColumn2(
                    label: Text('Name', style: TextStyle(fontSize: 13),),
                    size: ColumnSize.L
                ),
                DataColumn2(
                    label: Text('Method', style: TextStyle(fontSize: 13)),
                    size: ColumnSize.M

                ),
                DataColumn2(
                    label: Text('Line', style: TextStyle(fontSize: 13),),
                    size: ColumnSize.M
                ),
                DataColumn2(
                    label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 50
                ),
                DataColumn2(
                    label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.M
                ),
                DataColumn2(
                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.M
                ),
                DataColumn2(
                    label: Center(child: Text('End Date', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.M
                ),
                DataColumn2(
                    label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 80
                ),
              ],
              rows: List<DataRow>.generate(provider.upcomingProgram.length, (index) => DataRow(cells: [
                DataCell(Text(provider.upcomingProgram[index]['ProgName'])),
                DataCell(Text(provider.upcomingProgram[index]['SchedulingMethod']==1?'No Schedule':provider.upcomingProgram[index]['SchedulingMethod']==2?'Schedule by days':'Schedule as run list')),
                DataCell(Text(provider.upcomingProgram[index]['ProgCategory'])),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['TotalZone']}'))),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['StartDate']}'))),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['StartTime']}'))),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['EndDate']}'))),
                DataCell(
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
                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.deviceId}');
                      sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Started by Manual', payLoadFinal);
                    },
                    child: const Text('Start'),
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
                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.deviceId}');
                      sentUserOperationToServer('${provider.upcomingProgram[index]['ProgName']} Stopped by Manual', payLoadFinal);
                    },
                    child: const Text('Stop'),
                  ),
                ),
              ])),
            ) :
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Upcoming Program not Available', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": siteData.controllerId, "messageStatus": msg, "data": data, "createUser": customerId};
    final response = await HttpService().postRequest("createUserManualOperationInDashboard", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}

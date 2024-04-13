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
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5)
                    ),
                  ),
                  height: provider.upcomingProgram.isNotEmpty? (provider.upcomingProgram.length * 40) + 55 : 40,
                  child: provider.upcomingProgram.isNotEmpty? DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    dataRowHeight: 50.0,
                    headingRowHeight: 40.0,
                    headingRowColor: MaterialStateProperty.all<Color>(Colors.yellow.shade50),
                    columns:  [
                      const DataColumn2(
                          label: Text('Name', style: TextStyle(fontSize: 13),),
                          size: ColumnSize.L
                      ),
                      const DataColumn2(
                          label: Text('Method', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.M

                      ),
                      const DataColumn2(
                          label: Text('Line', style: TextStyle(fontSize: 13),),
                          size: ColumnSize.M
                      ),
                      const DataColumn2(
                          label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                          fixedWidth: 50
                      ),
                      const DataColumn2(
                          label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.M
                      ),
                      const DataColumn2(
                          label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.M
                      ),
                      const DataColumn2(
                          label: Center(child: Text('End Date', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.M
                      ),
                      DataColumn2(
                          label: Center(child: IconButton(
                              tooltip: 'Schedule details',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleViewScreen(deviceId: siteData.deviceId, userId: customerId, controllerId: siteData.controllerId, customerId: customerId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.view_list_outlined))),
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
              ),
              Positioned(
                top: 7.5,
                left: 5,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
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

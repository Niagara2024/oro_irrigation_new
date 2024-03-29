import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class UpcomingProgram extends StatelessWidget {
  UpcomingProgram({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('SCHEDULED PROGRAM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Container(
              color: Colors.white,
              height: provider.upcomingProgram.isNotEmpty? (provider.upcomingProgram.length * 50) + 35 : 25,
              child: provider.upcomingProgram.isNotEmpty? DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 50.0,
                headingRowHeight: 35.0,
                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
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
                      fixedWidth: 175
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
                  DataCell(Row(children: [
                    MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () {
                        String localFilePath = 'assets/audios/button_click_sound.mp3';
                        audioPlayer.play(UrlSource(localFilePath));
                        String payload = '${provider.upcomingProgram[index]['SNo']},1';
                        String payLoadFinal = jsonEncode({
                          "2900": [{"2901": payload}]
                        });
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.deviceId}');
                      },
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 5,),
                    MaterialButton(
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        String localFilePath = 'assets/audios/audio_off.mp3';
                        audioPlayer.play(UrlSource(localFilePath));
                        String payload = '${provider.upcomingProgram[index]['SNo']},0';
                        String payLoadFinal = jsonEncode({
                          "2900": [{"2901": payload}]
                        });
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.deviceId}');
                      },
                      child: const Text('Stop'),
                    ),
                  ],)),
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
      ),
    );
  }
}

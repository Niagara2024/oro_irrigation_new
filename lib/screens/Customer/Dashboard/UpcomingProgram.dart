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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          ListTile(
            tileColor: myTheme.primaryColor.withOpacity(0.2),
            title: const Text('UPCOMING PROGRAM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: provider.upcomingProgram.isNotEmpty? (provider.upcomingProgram.length * 45) + 35 : 50,
            child: provider.upcomingProgram.isNotEmpty? DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              dataRowHeight: 45.0,
              headingRowHeight: 35.0,
              headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
              columns: const [
                DataColumn2(
                    label: Text('Name', style: TextStyle(fontSize: 13),),
                    size: ColumnSize.L
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
                    fixedWidth: 100
                ),
                DataColumn2(
                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 100
                ),
                DataColumn2(
                    label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 50
                ),
              ],
              rows: List<DataRow>.generate(provider.upcomingProgram.length, (index) => DataRow(cells: [
                DataCell(Text(provider.upcomingProgram[index]['ProgName'])),
                DataCell(Text(provider.upcomingProgram[index]['ProgCategory'])),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['TotalZone']}'))),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['TotalZone']}'))),
                DataCell(Center(child: Text('${provider.upcomingProgram[index]['TotalZone']}'))),
                DataCell(Center(child: Transform.scale(
                  scale: 0.7,
                  child: Tooltip(
                    message: provider.upcomingProgram[index]['SwitchOnOff']==1? 'Off' : 'On',
                    child: Switch(
                      hoverColor: Colors.pink.shade100,
                      value: provider.upcomingProgram[index]['SwitchOnOff'] == 1 ? true : false,
                      onChanged: (value) {
                        String payload = '';
                        if(value){
                          String localFilePath = 'assets/audios/audio_off.mp3';
                          audioPlayer.play(UrlSource(localFilePath));
                          payload = '${provider.upcomingProgram[index]['SNo']},1';
                        }else{
                          String localFilePath = 'assets/audios/button_click_sound.mp3';
                          audioPlayer.play(UrlSource(localFilePath));
                          payload = '${provider.upcomingProgram[index]['SNo']}, 0';
                        }
                        String payLoadFinal = jsonEncode({
                          "2900": [{"2901": payload}]
                        });
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteData.deviceId}');
                      },
                    ),
                  ),
                ))),
              ])),
            ) :
            const Center(child: Text('Upcoming Program not Available')),
          ),
        ],
      ),
    );
  }
}

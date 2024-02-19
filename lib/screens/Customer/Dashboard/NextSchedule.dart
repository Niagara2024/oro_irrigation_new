import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class NextSchedule extends StatefulWidget {
  const NextSchedule({Key? key}) : super(key: key);

  @override
  State<NextSchedule> createState() => _NextScheduleState();
}

class _NextScheduleState extends State<NextSchedule> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          const ListTile(
            tileColor: Colors.white,
            title: Text('NEXT SCHEDULE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 0),
          SizedBox(
            height: provider.nextSchedule.isNotEmpty? (provider.nextSchedule.length * 45) + 35 : 50,
            child: provider.nextSchedule.isNotEmpty? DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              dataRowHeight: 45.0,
              headingRowHeight: 35.0,
              headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
              columns: const [
                DataColumn2(
                    label: Text('Name', style: TextStyle(fontSize: 13),),
                    fixedWidth: 110
                ),
                DataColumn2(
                    label: Text('Line', style: TextStyle(fontSize: 13),),
                    fixedWidth: 70
                ),
                DataColumn2(
                    label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 45
                ),
                DataColumn2(
                    label: Center(child: Text('Zone Name', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.M
                ),
                DataColumn2(
                    label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 90
                ),
                DataColumn2(
                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 80
                ),
              ],
              rows: List<DataRow>.generate(provider.nextSchedule.length, (index) => DataRow(cells: [
                DataCell(Text(provider.nextSchedule[index]['ProgName'])),
                DataCell(Text(provider.nextSchedule[index]['ProgCategory'])),
                DataCell(Center(child: Text('${provider.nextSchedule[index]['CurrentZone']}'))),
                DataCell(Center(child: Center(child: Text(provider.nextSchedule[index]['ZoneName'])))),
                DataCell(Center(child: Text(provider.nextSchedule[index]['StartDate']))),
                DataCell(Center(child: Text(provider.nextSchedule[index]['StartTime']))),
              ])),
            ) :
            const Center(child: Text('Upcoming schedule not Available')),
          ),
        ],
      ),
    );
  }
}

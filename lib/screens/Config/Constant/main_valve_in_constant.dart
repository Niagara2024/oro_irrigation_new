import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/time_picker.dart';



class MainValveConstant extends StatefulWidget {
  const MainValveConstant({super.key});

  @override
  State<MainValveConstant> createState() => _MainValveConstantState();
}

class _MainValveConstantState extends State<MainValveConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      if(constraints.maxWidth < 800){
        return MainValveConstant_M();
      }
      return  Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          dataRowHeight: 40.0,
          headingRowHeight: 40,
          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
          border: TableBorder.all(color: Colors.grey),
          columns: [
            DataColumn2(
              label: Text('Name'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Id'),
            ),
            DataColumn(
              label: Text('Line'),
            ),
            DataColumn(
              label: Text('Mode'),
            ),
            DataColumn(
              label: Text('Delay'),
            ),
          ],
          rows: [
            for(var i = 0;i < constantPvd.mainValveUpdated.length;i++)
              DataRow(cells: [
                DataCell(Text('${constantPvd.mainValveUpdated[i]['name']}')),
                DataCell(Text('${constantPvd.mainValveUpdated[i]['id']}')),
                DataCell(Text('${constantPvd.mainValveUpdated[i]['location']}')),
                DataCell(MyDropDown(initialValue: constantPvd.mainValveUpdated[i]['mode'], itemList: ['No delay','Open before','Open after'], pvdName: 'mainvalve/mode', index: i)),
                DataCell(mainValveDelay(context,constantPvd,overAllPvd,i)),
              ])
          ],
        ),
      );
    });

  }
}

Widget mainValveDelay(BuildContext context,constantPvd,overAllPvd,index){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.mainValveUpdated[index]['delay']}',
              onPressed: (){
                constantPvd.mainValveFunctionality(['mainvalve/delay',index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.mainValveUpdated[index]['delay']}',style: TextStyle(color: Colors.black87),)
  );
}


class MainValveConstant_M extends StatefulWidget {
  const MainValveConstant_M({super.key});

  @override
  State<MainValveConstant_M> createState() => _MainValveConstant_MState();
}

class _MainValveConstant_MState extends State<MainValveConstant_M> {
  int selected_M_Valve = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xfff3f3f3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white
            ),
            width: double.infinity,
            height: 60,
            child: Center(
              child: ListTile(
                title: Text('Main Valve'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/main_valve1.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selected_M_Valve + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.mainValveUpdated.length;i++)
                      PopupMenuItem(
                          value: i,
                          child: Text('${i+1}')
                      ),
                  ],
                  offset: Offset(0, 50),
                  color: Colors.white,
                  elevation: 2,
                  // on selected we show the dialog box
                  onSelected: (value) {
                    print('selected value  : $value');
                    setState(() {
                      selected_M_Valve = value;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 5,),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: MediaQuery.sizeOf(context).width/210,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.mode,color: myTheme.primaryColor,),
                          Text('MOde'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.mainValveUpdated[selected_M_Valve]['mode'],
                        underline: Container(),
                        items: ['No delay','Open before','Open after'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.mainValveFunctionality(['mainvalve/mode',selected_M_Valve,value!]);
                        },
                        // After selecting the desired option,it will
                        // change button value to selected value

                      ),

                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.mode,color: myTheme.primaryColor,),
                          Text('MOde'),
                        ],
                      ),
                      mainValveDelay(context, constantPvd, overAllPvd, selected_M_Valve)

                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade50,
                            Colors.white,
                          ]
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Name'),
                        ],
                      ),
                      Text('${constantPvd.mainValveUpdated[selected_M_Valve]['name']}')

                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade50,
                            Colors.white,
                          ]
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Id'),
                        ],
                      ),
                      Text('${constantPvd.mainValveUpdated[selected_M_Valve]['id']}')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
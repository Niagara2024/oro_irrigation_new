import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/main.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/time_picker.dart';



class IrrigationLinesConstant extends StatefulWidget {
  const IrrigationLinesConstant({super.key});

  @override
  State<IrrigationLinesConstant> createState() => _IrrigationLinesConstantState();
}

class _IrrigationLinesConstantState extends State<IrrigationLinesConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 900){
        return IrrigationLinesConstant_M();
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
                label: Text('Pump'),
              ),
              DataColumn(
                label: Text('Low flow delay'),
              ),
              DataColumn(
                label: Text('High flow delay'),
              ),
              DataColumn(
                label: Text('Low flow behavior'),
                numeric: true,
              ),
              DataColumn(
                label: Text('High flow behavior'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Leakage limit'),
                numeric: true,
              ),
            ],
            rows: [
              for(var i = 0;i < constantPvd.irrigationLineUpdated.length;i++)
                DataRow(cells: [
                  DataCell(Text('${constantPvd.irrigationLineUpdated[i]['name']}')),
                  DataCell(Text('${constantPvd.irrigationLineUpdated[i]['id']}')),
                  DataCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[i]['pump'], itemList: ['-','IP1','IP2','IP3'], pvdName: 'line/irrigationPump', index: i)),
                  DataCell(lowFlowDelay(context,constantPvd,overAllPvd,i)),
                  DataCell(highFlowDelay(context,constantPvd,overAllPvd,i)),
                  DataCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[i]['lowFlowBehavior'], itemList: ['Ignore','Do next','wait'], pvdName: 'line/lowFlowBehavior', index: i)),
                  DataCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[i]['highFlowBehavior'], itemList: ['Ignore','Do next','wait'], pvdName: 'line/highFlowBehavior', index: i)),
                  DataCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[i]['leakageLimit'], itemList: ['0','1','2','3','4','5','6','7','8','9','10'], pvdName: 'line/leakageLimit', index: i)),
                ])
            ],
        ),
      );
    });

  }
}

Widget lowFlowDelay(BuildContext context,constantPvd,overAllPvd,selectedLine){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.irrigationLineUpdated[selectedLine]['lowFlowDelay']}',
              onPressed: (){
                constantPvd.irrigationLineFunctionality(['line/lowFlowDelay',selectedLine,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.irrigationLineUpdated[selectedLine]['lowFlowDelay']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget highFlowDelay(BuildContext context,constantPvd,overAllPvd,selectedLine){
  return TextButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.transparent)
    ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.irrigationLineUpdated[selectedLine]['highFlowDelay']}',
              onPressed: (){
                constantPvd.irrigationLineFunctionality(['line/highFlowDelay',selectedLine,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.irrigationLineUpdated[selectedLine]['highFlowDelay']}',style: TextStyle(color: Colors.black87),)
  );
}

class IrrigationLinesConstant_M extends StatefulWidget {
  const IrrigationLinesConstant_M({super.key});

  @override
  State<IrrigationLinesConstant_M> createState() => _IrrigationLinesConstant_MState();
}

class _IrrigationLinesConstant_MState extends State<IrrigationLinesConstant_M> {
  int selectedLine = 0;
  double hrs = 0;
  double mins = 0;
  double secs = 0;

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
                title: Text('Irrigation Line'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/irrigation_line1.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedLine + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.irrigationLineUpdated.length;i++)
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
                      selectedLine = value;
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
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset('assets/images/irrigation_pump.png'),
                          ),
                          Text('Pump'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.irrigationLineUpdated[selectedLine]['pump'],
                        underline: Container(),
                        items: ['-','IP1','IP2','IP3'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.irrigationLineFunctionality(['line/irrigationPump',selectedLine,value!]);
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
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Low flow delay'),
                        ],
                      ),
                      lowFlowDelay(context,constantPvd,overAllPvd,selectedLine),

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
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('High flow delay'),
                        ],
                      ),
                      highFlowDelay(context,constantPvd,overAllPvd,selectedLine)
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
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Low flow behavior'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.irrigationLineUpdated[selectedLine]['lowFlowBehavior'],
                        underline: Container(),
                        items: ['Ignore','Do next','wait'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.irrigationLineFunctionality(['line/lowFlowBehavior',selectedLine,value!]);
                        },

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
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('High flow behavior'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.irrigationLineUpdated[selectedLine]['highFlowBehavior'],
                        underline: Container(),
                        items: ['Ignore','Do next','wait'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.irrigationLineFunctionality(['line/highFlowBehavior',selectedLine,value!]);
                        },

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
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Leakage limit'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.irrigationLineUpdated[selectedLine]['leakageLimit'],
                        underline: Container(),
                        items: ['0','1','2','3','4','5','6','7','8','9','10'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.irrigationLineFunctionality(['line/leakageLimit',selectedLine,value!]);
                        },
                      ),
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


/// Example without a datasource
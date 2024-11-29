import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
import '../../../main.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
import '../../../widgets/time_picker.dart';
import 'fertilizer_in_constant.dart';

class CriticalAlarmInConstant extends StatefulWidget {
  const CriticalAlarmInConstant({super.key});

  @override
  State<CriticalAlarmInConstant> createState() => _CriticalAlarmInConstantState();
}

class _CriticalAlarmInConstantState extends State<CriticalAlarmInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      var width = constraints.maxWidth;
      if(constraints.maxWidth < 900){
        return CriticalAlarmInConstantForMobile();
      }
      return myTable(
          [
            fixedTableCell_Text('Line','',80,width < 1100 ? constant_style : null,true),
            fixedTableCell_Text('Alarm type','lines',170,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Scan','time',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Alarm on','status',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('reset after','irrigation',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Auto reset','duration',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Threshold','',null,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Units','',80,width < 1100 ? constant_style : null),

          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.criticalAlarmUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.criticalAlarmUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: constantPvd.criticalAlarmUpdated[index]['alarm'].length * 40,
                          child: Center(child: Text('${constantPvd.criticalAlarmUpdated[index]['name']}')),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      width: 1
                                  )
                              )
                          ),
                        ),
                        Container(
                          width: 170,
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1))
                          ),
                          child: Column(
                            children: [
                              for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: Center(child: Text('${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['name']}')),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: i == constantPvd.criticalAlarmUpdated[index]['alarm'].length - 1 ? 0 : 1))
                                  ),
                                ),
                            ],
                          ),
                        ),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                CustomTimePickerSiva(additional : 'split',purpose: 'critical_alarm_scanTime/$index/$i', index: index, value: '${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['scanTime']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,),
                                null,
                                i == constantPvd.criticalAlarmUpdated[index]['alarm'].length -1 ? true : false
                            )
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                MyDropDown(initialValue: '${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['alarmOnStatus']}', itemList: ['Do Nothing','Stop Irrigation','Stop Fertigation','Skip Irrigation'], pvdName: 'critical_alarm_status/$index/$i', index: index),
                                // Text('${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['alarmOnStatus']}'),
                                null,
                                i == constantPvd.criticalAlarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                constantPvd.criticalAlarmUpdated[index]['alarm'][i]['resetAfterIrrigation'] == null
                                    ? Text('N/A') : MyDropDown(initialValue: '${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['resetAfterIrrigation']}', itemList: ['Yes', 'No'], pvdName: 'critical_alarm_reset_irrigation/$index/$i', index: index),
                                null,
                                i == constantPvd.criticalAlarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                CustomTimePickerSiva(additional : 'split',purpose: 'critical_alarm_auto_reset/$index/$i', index: index, value: '${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['autoResetDuration']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,),
                                null,
                                i == constantPvd.criticalAlarmUpdated[index]['alarm'].length -1 ? true : false
                            )                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                (constantPvd.criticalAlarmUpdated[index]['alarm'][i]['name'] == 'NO FLOW' || constantPvd.criticalAlarmUpdated[index]['alarm'][i]['name'] == 'NO POWER SUPPLY') ? Text('N/A') :
                                TextFieldForConstant(index: -1, initialValue: constantPvd.criticalAlarmUpdated[index]['alarm'][i]['threshold'], constantPvd: constantPvd, purpose: 'critical_alarm_threshold/$index/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),
                                null,
                                i == constantPvd.criticalAlarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                              border: Border(right : BorderSide(width: 1))
                          ),
                          child: Column(
                            children: [
                              for(var i = 0;i < constantPvd.criticalAlarmUpdated[index]['alarm'].length;i++)
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: Center(child: Text('${constantPvd.criticalAlarmUpdated[index]['alarm'][i]['unit']}')),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: i == constantPvd.criticalAlarmUpdated[index]['alarm'].length - 1 ? 0 : 1))
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )
      );
    });
  }
}

Widget scanTime(BuildContext context,constantPvd,overAllPvd,line,alarm){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.criticalAlarmUpdated[line]['alarm'][alarm]['scanTime']}',
              onPressed: (){
                constantPvd.criticalAlarmFunctionality(['critical_alarm_scanTime',line,alarm,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.criticalAlarmUpdated[line]['alarm'][alarm]['scanTime']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget autoReset(BuildContext context,constantPvd,overAllPvd,line,alarm){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.criticalAlarmUpdated[line]['alarm'][alarm]['autoResetDuration']}',
              onPressed: (){
                constantPvd.criticalAlarmFunctionality(['critical_alarm_auto_reset',line,alarm,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.criticalAlarmUpdated[line]['alarm'][alarm]['autoResetDuration']}',style: TextStyle(color: Colors.black87),)
  );
}


class CriticalAlarmInConstantForMobile extends StatefulWidget {
  const CriticalAlarmInConstantForMobile({super.key});

  @override
  State<CriticalAlarmInConstantForMobile> createState() => _CriticalAlarmInConstantForMobileState();
}

class _CriticalAlarmInConstantForMobileState extends State<CriticalAlarmInConstantForMobile> {
  int selected_Line = 0;
  int alarm_type = 0;
  dynamic valvesInSelectedLine = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
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
          Row(
            children: [
              Expanded(
                child: Container(
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
                        child: Text('${selected_Line + 1}',style: TextStyle(fontSize: 20),),
                        itemBuilder: (context) => [
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated.length;i++)
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
                          setState(() {
                            selected_Line = value;
                            alarm_type = 0;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                  ),
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: ListTile(
                      title: Text('Alarm'),
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.alarm),
                      ),
                      trailing:  PopupMenuButton<int>(
                        child: Text('${alarm_type + 1}',style: TextStyle(fontSize: 20),),
                        itemBuilder: (context) => [
                          for(var i = 0;i < constantPvd.criticalAlarmUpdated[selected_Line]['alarm'].length;i++)
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
                            alarm_type = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Scan time'),
                        ],
                      ),
                      scanTime(context, constantPvd, overAllPvd, selected_Line, alarm_type)


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
                          Text('Alarm on status'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['alarmOnStatus'],
                        underline: Container(),
                        items: ['Do Nothing','Stop Irrigation','Stop Fertigation','Skip Irrigation'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.criticalAlarmFunctionality(['critical_alarm_status',selected_Line,alarm_type,value!]);
                        },
                        // After selecting the desired option,it will
                        // change button value to selected value

                      ),
                    ],
                  ),
                ),
                if(constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['resetAfterIrrigation'] != null)
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
                          Text('Reset after irrigation'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['resetAfterIrrigation'],
                        underline: Container(),
                        items: ['Yes', 'No'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.criticalAlarmFunctionality(['critical_alarm_reset_irrigation',selected_Line,alarm_type,value!]);
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
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Auto reset duration'),
                        ],
                      ),
                      autoReset(context, constantPvd, overAllPvd, selected_Line, alarm_type)
                    ],
                  ),
                ),
                if(constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['name'] != 'NO FLOW' && constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['name'] != 'NO POWER SUPPLY')
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
                            Text('Threshold ${constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['unit']}'),
                          ],
                        ),
                        SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['threshold'], constantPvd: constantPvd, purpose: 'critical_alarm_threshold/$selected_Line/$alarm_type', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Alarm Name',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      Text('${constantPvd.criticalAlarmUpdated[selected_Line]['alarm'][alarm_type]['name']}')
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Line name',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      Text('${constantPvd.criticalAlarmUpdated[selected_Line]['name']}')
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
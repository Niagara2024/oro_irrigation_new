import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/widgets/time_picker.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
import 'fertilizer_in_constant.dart';


class AlarmInConstant extends StatefulWidget {
  const AlarmInConstant({super.key});

  @override
  State<AlarmInConstant> createState() => _AlarmInConstantState();
}

class _AlarmInConstantState extends State<AlarmInConstant> {


  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      var width = constraints.maxWidth;
      return myTable(
          [
            fixedTableCell_Text('Line','',80,width < 1100 ? constant_style : null),
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
                itemCount: constantPvd.alarmUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.alarmUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: constantPvd.alarmUpdated[index]['alarm'].length * 40,
                          child: Center(child: Text('${constantPvd.alarmUpdated[index]['name']}')),
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
                              for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: Center(child: Text('${constantPvd.alarmUpdated[index]['alarm'][i]['name']}')),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: i == constantPvd.alarmUpdated[index]['alarm'].length - 1 ? 0 : 1))
                                  ),
                                ),
                            ],
                          ),
                        ),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                CustomTimePickerSiva(additional : 'split',purpose: 'alarm_scanTime/$index/$i', index: index, value: '${constantPvd.alarmUpdated[index]['alarm'][i]['scanTime']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,),
                                null,
                                i == constantPvd.alarmUpdated[index]['alarm'].length -1 ? true : false
                            )
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                MyDropDown(initialValue: '${constantPvd.alarmUpdated[index]['alarm'][i]['alarmOnStatus']}', itemList: ['Do Nothing','Stop Irrigation','Stop Fertigation','Skip Irrigation'], pvdName: 'alarm_status/$index/$i', index: index),
                                // Text('${constantPvd.alarmUpdated[index]['alarm'][i]['alarmOnStatus']}'),
                                null,
                                i == constantPvd.alarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                constantPvd.alarmUpdated[index]['alarm'][i]['resetAfterIrrigation'] == null
                                    ? Text('N/A') : MyDropDown(initialValue: '${constantPvd.alarmUpdated[index]['alarm'][i]['resetAfterIrrigation']}', itemList: ['Yes', 'No'], pvdName: 'alarm_reset_irrigation/$index/$i', index: index),
                                null,
                                i == constantPvd.alarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                CustomTimePickerSiva(additional : 'split',purpose: 'alarm_auto_reset/$index/$i', index: index, value: '${constantPvd.alarmUpdated[index]['alarm'][i]['autoResetDuration']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,),
                                null,
                                i == constantPvd.alarmUpdated[index]['alarm'].length -1 ? true : false
                            )                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                            expandedForAlarmType(
                                (constantPvd.alarmUpdated[index]['alarm'][i]['name'] == 'NO FLOW' || constantPvd.alarmUpdated[index]['alarm'][i]['name'] == 'NO POWER SUPPLY') ? Text('N/A') :
                                TextFieldForConstant(index: -1, initialValue: constantPvd.alarmUpdated[index]['alarm'][i]['threshold'], constantPvd: constantPvd, purpose: 'alarm_threshold/$index/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),
                                null,
                                i == constantPvd.alarmUpdated[index]['alarm'].length -1 ? true : false)
                        ]),
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                              border: Border(right : BorderSide(width: 1))
                          ),
                          child: Column(
                            children: [
                              for(var i = 0;i < constantPvd.alarmUpdated[index]['alarm'].length;i++)
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: Center(child: Text('${constantPvd.alarmUpdated[index]['alarm'][i]['unit']}')),
                                  decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(width: i == constantPvd.alarmUpdated[index]['alarm'].length - 1 ? 0 : 1))
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
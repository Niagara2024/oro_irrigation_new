import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
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
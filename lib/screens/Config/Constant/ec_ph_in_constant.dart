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

class EcPhInConstant extends StatefulWidget {
  const EcPhInConstant({super.key});

  @override
  State<EcPhInConstant> createState() => _EcPhInConstantState();
}

class _EcPhInConstantState extends State<EcPhInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      var width = constraints.maxWidth;
      if(width < 1000){
        return FertilizerConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('Site','name'),
            expandedTableCell_Text('Select','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Control','cycle',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Delta','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Fine','tunning',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Coarse','tunning',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Deadband','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Integ','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Control','sensor',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Avg filt','speed',null,width < 1100 ? constant_style : null),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.ecPhUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.ecPhUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['name']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),),null,null,40 * constantPvd.ecPhUpdated[index]['setting'].length),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Checkbox(
                                  value: constantPvd.ecPhUpdated[index]['setting'][i]['active'],
                                  onChanged: (value){
                                    print(value);
                                    constantPvd.ecPhFunctionality(['activateEcPh',index,i,value]);
                                  },
                                ),
                                Text('${constantPvd.ecPhUpdated[index]['setting'][i]['name']}')
                              ],
                            ))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['controlCycle']}',style: TextStyle(color: Colors.black54),) :  CustomTimePickerSiva(purpose: 'ecPhControlCycle/$index/setting/$i', index: index, value: '${constantPvd.ecPhUpdated[index]['setting'][i]['controlCycle']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['delta']}',style: TextStyle(color: Colors.black54),) :  TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['delta']}', constantPvd: constantPvd, purpose: 'ecPhDelta/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['fineTunning']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['fineTunning']}', constantPvd: constantPvd, purpose: 'ecPhFineTunning/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['coarseTunning']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['coarseTunning']}', constantPvd: constantPvd, purpose: 'ecPhCoarseTunning/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['deadBand']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['deadBand']}', constantPvd: constantPvd, purpose: 'ecPhDeadBand/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['integ']}',style: TextStyle(color: Colors.black54),) : CustomTimePickerSiva(purpose: 'ecPhInteg/$index/setting/$i', index: index, value: '${constantPvd.ecPhUpdated[index]['setting'][i]['integ']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['senseOrAvg']}',style: TextStyle(color: Colors.black54),) : MyDropDown(initialValue: constantPvd.ecPhUpdated[index]['setting'][i]['senseOrAvg'], itemList: constantPvd.ecPhUpdated[index]['setting'][i]['sensorList'], pvdName: 'ecPhSenseOrAvg/$index/setting/$i', index: index))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterSpeed']}',style: TextStyle(color: Colors.black54),) : MyDropDown(initialValue: constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterSpeed'], itemList: constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterList'], pvdName: 'ecPhAvgFiltSpeed/$index/setting/$i', index: index))
                        ]),
                      ],
                    ),
                  );
                }),
          )
      );
    });
  }
}
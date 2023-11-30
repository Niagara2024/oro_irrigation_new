import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
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
      // if(width < 1000){
      //   return FertilizerConstant_M();
      // }
      return myTable(
          [expandedTableCell_Text('Site','name'),
            fixedTableCell_Text('Used in','lines',80,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Fertilizer','(injector)',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Name','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Dosing','meter',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Nominal','flow(l/h)',null,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Injector','mode',150,width < 1100 ? constant_style : null),
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
                        expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['name']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),),null,null,40 * constantPvd.ecPhUpdated[index]['fertilizer'].length),
                        fixedSizeCustomCell(Text('${constantPvd.ecPhUpdated[index]['location'] == '' ? 'null' : constantPvd.ecPhUpdated[index]['location']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),), 80,40 * constantPvd.ecPhUpdated[index]['fertilizer'].length as double,false),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['fertilizer'][i]['id']}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['fertilizer'][i]['name']}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['fertilizer'][i]['fertilizerMeter']}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.ecPhUpdated[index]['fertilizer'][i]['nominalFlow'], constantPvd: constantPvd, purpose: 'ecPh_nominal_flow/$index/fertilizer/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        Container(
                          width: 150,
                          child: Column(
                            children: [
                              for(var i = 0;i < constantPvd.ecPhUpdated[index]['fertilizer'].length;i++)
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: Center(
                                    child: MyDropDown(initialValue: constantPvd.ecPhUpdated[index]['fertilizer'][i]['injectorMode'], itemList: ['Concentration','PH_controlled','EC_controlled','Regular'], pvdName: 'ecPh_injector_mode/$index/fertilizer/$i', index: index),
                                  ),
                                )
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';


class MoistureSensorInConstant extends StatefulWidget {
  const MoistureSensorInConstant({super.key});

  @override
  State<MoistureSensorInConstant> createState() => _MoistureSensorInConstantState();
}

class _MoistureSensorInConstantState extends State<MoistureSensorInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){

      return myTable(
          [expandedTableCell_Text('Name','','first'),
            expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Line',''),
            expandedTableCell_Text('high','low'),
            expandedTableCell_Text('value',''),
            expandedTableCell_Text('minimum',''),
            expandedTableCell_Text('maximum',''),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.moistureSensorUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.moistureSensorUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.moistureSensorUpdated[index]['name']}'),'first'),
                        expandedCustomCell(Text('${constantPvd.moistureSensorUpdated[index]['id']}'),),
                        expandedCustomCell(Text('${constantPvd.moistureSensorUpdated[index]['location']}'),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.moistureSensorUpdated[index]['high/low'], itemList: const ['-','primary','secondary'], pvdName: 'moistureSensor_high_low', index: index),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[index]['value'], constantPvd: constantPvd, purpose: 'moistureSensor_value/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'moistureSensor_minimum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'moistureSensor_maximum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}

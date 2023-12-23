import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';


class LevelSensorInConstant extends StatefulWidget {
  const LevelSensorInConstant({super.key});

  @override
  State<LevelSensorInConstant> createState() => _LevelSensorInConstantState();
}

class _LevelSensorInConstantState extends State<LevelSensorInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){

      return myTable(
          [expandedTableCell_Text('Name','','first'),
            expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Line',''),
            expandedTableCell_Text('high','low'),
            expandedTableCell_Text('UNITS',''),
            expandedTableCell_Text('BASE',''),
            expandedTableCell_Text('minimum',''),
            expandedTableCell_Text('maximum',''),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.levelSensorUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.levelSensorUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.levelSensorUpdated[index]['name']}'),'first'),
                        expandedCustomCell(Text('${constantPvd.levelSensorUpdated[index]['id']}'),),
                        expandedCustomCell(Text('${constantPvd.levelSensorUpdated[index]['location']}'),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.levelSensorUpdated[index]['high/low'], itemList: const ['-','top','middle','bottom'], pvdName: 'levelSensor_high_low', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.levelSensorUpdated[index]['units'], itemList: ['bar','dS/m'], pvdName: 'levelSensor/units', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.levelSensorUpdated[index]['base'], itemList: ['Current','Voltage'], pvdName: 'levelSensor/base', index: index),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'levelSensor_minimum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'levelSensor_maximum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}
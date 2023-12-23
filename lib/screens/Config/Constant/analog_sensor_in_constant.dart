import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';



class AnalogSensorConstant extends StatefulWidget {
  const AnalogSensorConstant({super.key});

  @override
  State<AnalogSensorConstant> createState() => _AnalogSensorConstantState();
}

class _AnalogSensorConstantState extends State<AnalogSensorConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 900){
        return AnalogSensorConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Name',''),
            expandedTableCell_Text('TYPE',''),
            expandedTableCell_Text('UNITS',''),
            expandedTableCell_Text('BASE',''),
            expandedTableCell_Text('MINIMUM',''),
            expandedTableCell_Text('MAXIMUM',''),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.analogSensorUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.analogSensorUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.analogSensorUpdated[index]['id']}'),),
                        expandedCustomCell(Text('${constantPvd.analogSensorUpdated[index]['name']}'),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['type'], itemList: ['Soil Moisture','Soil Temperature','Rainfall','Windspeed','Wind Direction','Leaf Wetness','Humidity','Lux Sensor','Co2 Sensor','LDR'], pvdName: 'analogSensor/type', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['units'], itemList: ['bar','dS/m'], pvdName: 'analogSensor/units', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['base'], itemList: ['Current','Voltage'], pvdName: 'analogSensor/base', index: index),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'analogSensor_minimum_v/${index}/6', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'analogSensor_maximum_v/${index}/7', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });
  }
}

class AnalogSensorConstant_M extends StatefulWidget {
  const AnalogSensorConstant_M({super.key});

  @override
  State<AnalogSensorConstant_M> createState() => _AnalogSensorConstant_MState();
}

class _AnalogSensorConstant_MState extends State<AnalogSensorConstant_M> {
  int selectedSensor = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 30,
              color: myTheme.primaryColor,
              width : double.infinity,
              child: Center(child: Text('Select sensor',style: TextStyle(color: Colors.white),))
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: constantPvd.analogSensor.length,
                itemBuilder: (BuildContext context,int index){
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 60,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 40,
                              child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedSensor = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.analogSensor.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                    color: selectedSensor == index ? myTheme.primaryColor : Colors.blue.shade100,
                                  ),
                                  child: Center(child: Text('${index + 1}',style: TextStyle(color: selectedSensor == index ? Colors.white : null),)),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 3,),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black
                                  ),
                                ),
                                SizedBox(width: 3,),
                              ],
                            )
                          ],
                        ),
                      ),
                      if(constantPvd.analogSensor.length - 1 != index)
                        Text('-')
                    ],
                  );
                }),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 30,
              color: myTheme.primaryColor,
              width : double.infinity,
              child: Center(child: Text('Analog sensor ${selectedSensor + 1}',style: TextStyle(color: Colors.white),))
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // color: Color(0XFFF3F3F3)
              ),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    returnMyListTile('ID', Text('${constantPvd.analogSensor[selectedSensor][0]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Name', Text('${constantPvd.analogSensor[selectedSensor][1]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('TYPE', fixedContainer(MyDropDown(initialValue: constantPvd.analogSensor[selectedSensor][2], itemList: ['Pressure IN','Pressure OUT','EC','PH','Level','Valve Pressure','Soil Moisture','Soil Temperature'], pvdName: 'analogSensor/type', index: selectedSensor),)),
                    returnMyListTile('UNITS', fixedContainer(MyDropDown(initialValue: constantPvd.analogSensor[selectedSensor][3], itemList: ['Bar','dS/m'], pvdName: 'analogSensor/units', index: selectedSensor),)),
                    returnMyListTile('DATA SOURCE', fixedContainer(MyDropDown(initialValue: constantPvd.analogSensor[selectedSensor][5], itemList: ['Current','Voltage'], pvdName: 'analogSensor/base', index: selectedSensor),)),
                    returnMyListTile('MINIMUM', TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensor[selectedSensor][6], constantPvd: constantPvd, purpose: 'analogSensor_minimum_v/${selectedSensor}/6', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                    returnMyListTile('MAXIMUM', TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensor[selectedSensor][7], constantPvd: constantPvd, purpose: 'analogSensor_maximum_v/${selectedSensor}/7', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
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
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['type'], itemList: ['Soil Moisture','Soil Temperature','Rainfall','Windspeed','Wind Direction','Leaf Wetness','Humidity','Lux Sensor','Co2 Sensor','LDR','Radiation set'], pvdName: 'analogSensor/type', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['units'], itemList: ['bar','dS/m'], pvdName: 'analogSensor/units', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensorUpdated[index]['base'], itemList: ['Current','Voltage'], pvdName: 'analogSensor/base', index: index),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'analogSensor_minimum_v/${index}/6', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'analogSensor_maximum_v/${index}/7', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
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
  int selectedAnalogSensor = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    if(constantPvd.analogSensorUpdated.isEmpty){
      return Container();
    }
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
                title: Text('Pump'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/analog_sensor.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedAnalogSensor + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.analogSensorUpdated.length;i++)
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
                      selectedAnalogSensor = value;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.production_quantity_limits,color: myTheme.primaryColor,),
                          Text('Type',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.analogSensorUpdated[selectedAnalogSensor]['type'],
                        underline: Container(),
                        items: ['Soil Moisture','Soil Temperature','Rainfall','Windspeed','Wind Direction','Leaf Wetness','Humidity','Lux Sensor','Co2 Sensor','LDR','Radiation set'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.analogSensorFunctionality(['analogSensor/type',selectedAnalogSensor,value!]);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Units',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.analogSensorUpdated[selectedAnalogSensor]['units'],
                        underline: Container(),
                        items: ['bar','dS/m'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.analogSensorFunctionality(['analogSensor/units',selectedAnalogSensor,value!]);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('Base',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.analogSensorUpdated[selectedAnalogSensor]['base'],
                        underline: Container(),
                        items: ['Current','Voltage'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.analogSensorFunctionality(['analogSensor/base',selectedAnalogSensor,value!]);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('Minimum',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[selectedAnalogSensor]['minimum'], constantPvd: constantPvd, purpose: 'analogSensor_minimum_v/${selectedAnalogSensor}/6', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
                      )
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('Maximum',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.analogSensorUpdated[selectedAnalogSensor]['maximum'], constantPvd: constantPvd, purpose: 'analogSensor_maximum_v/${selectedAnalogSensor}/7', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
                      )
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
                          Text('Name',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      Text('${constantPvd.waterMeterUpdated[selectedAnalogSensor]['name']}')
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
                          Icon(Icons.location_pin,color: myTheme.primaryColor,),
                          Text('Id',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      Text('${constantPvd.waterMeterUpdated[selectedAnalogSensor]['id']}')

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

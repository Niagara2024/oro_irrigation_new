import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
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
      if(constraints.maxWidth < 900){
        return MoistureSensorInConstant_M();
      }
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
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.moistureSensorUpdated[index]['units'], itemList: ['bar','dS/m'], pvdName: 'moistureSensor/units', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.moistureSensorUpdated[index]['base'], itemList: ['Current','Voltage'], pvdName: 'moistureSensor/base', index: index),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'moistureSensor_minimum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'moistureSensor_maximum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}

class MoistureSensorInConstant_M extends StatefulWidget {
  const MoistureSensorInConstant_M({super.key});

  @override
  State<MoistureSensorInConstant_M> createState() => _MoistureSensorInConstant_MState();
}

class _MoistureSensorInConstant_MState extends State<MoistureSensorInConstant_M> {
  int selectedMoistureSensor = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    if(constantPvd.moistureSensorUpdated.isEmpty){
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
                title: Text('Moisture Sensor'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/moisture_sensor.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedMoistureSensor + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.moistureSensorUpdated.length;i++)
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
                      selectedMoistureSensor = value;
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
                          Text('High or Low',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.moistureSensorUpdated[selectedMoistureSensor]['high/low'],
                        underline: Container(),
                        items: ['-','primary','secondary'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.moistureSensorFunctionality(['moistureSensor_high_low',selectedMoistureSensor,value!]);
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
                        value: constantPvd.moistureSensorUpdated[selectedMoistureSensor]['units'],
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
                          constantPvd.moistureSensorFunctionality(['moistureSensor/units',selectedMoistureSensor,value!]);
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
                        value: constantPvd.moistureSensorUpdated[selectedMoistureSensor]['base'],
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
                          constantPvd.moistureSensorFunctionality(['moistureSensor/base',selectedMoistureSensor,value!]);
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
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[selectedMoistureSensor]['minimum'], constantPvd: constantPvd, purpose: 'moistureSensor_minimum_v/$selectedMoistureSensor', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
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
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.moistureSensorUpdated[selectedMoistureSensor]['maximum'], constantPvd: constantPvd, purpose: 'moistureSensor_maximum_v/$selectedMoistureSensor', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
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
                      Text('${constantPvd.moistureSensorUpdated[selectedMoistureSensor]['name']}')
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
                      Text('${constantPvd.moistureSensorUpdated[selectedMoistureSensor]['id']}')

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

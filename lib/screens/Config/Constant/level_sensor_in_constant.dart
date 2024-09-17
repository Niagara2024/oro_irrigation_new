import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
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
      if(constraints.maxWidth < 900){
        return LevelSensorInConstant_M();
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
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[index]['minimum'], constantPvd: constantPvd, purpose: 'levelSensor_minimum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[index]['maximum'], constantPvd: constantPvd, purpose: 'levelSensor_maximum_v/$index', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}


class LevelSensorInConstant_M extends StatefulWidget {
  const LevelSensorInConstant_M({super.key});

  @override
  State<LevelSensorInConstant_M> createState() => _LevelSensorInConstant_MState();
}

class _LevelSensorInConstant_MState extends State<LevelSensorInConstant_M> {
  int selectedLevelSensor = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    if(constantPvd.levelSensorUpdated.isEmpty){
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
                title: Text('Level Sensor'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/level_sensor.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedLevelSensor + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.levelSensorUpdated.length;i++)
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
                      selectedLevelSensor = value;
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
                        value: constantPvd.levelSensorUpdated[selectedLevelSensor]['high/low'],
                        underline: Container(),
                        items: ['-','top','middle','bottom'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.levelSensorFunctionality(['levelSensor_high_low',selectedLevelSensor,value!]);
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
                        value: constantPvd.levelSensorUpdated[selectedLevelSensor]['units'],
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
                          constantPvd.levelSensorFunctionality(['levelSensor/units',selectedLevelSensor,value!]);
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
                        value: constantPvd.levelSensorUpdated[selectedLevelSensor]['base'],
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
                          constantPvd.levelSensorFunctionality(['levelSensor/base',selectedLevelSensor,value!]);
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
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[selectedLevelSensor]['minimum'], constantPvd: constantPvd, purpose: 'levelSensor_minimum_v/$selectedLevelSensor', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
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
                          child: TextFieldForConstant(index: -1, initialValue: constantPvd.levelSensorUpdated[selectedLevelSensor]['maximum'], constantPvd: constantPvd, purpose: 'levelSensor_maximum_v/$selectedLevelSensor', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],)
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
                      Text('${constantPvd.levelSensorUpdated[selectedLevelSensor]['name']}')
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
                      Text('${constantPvd.levelSensorUpdated[selectedLevelSensor]['id']}')

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
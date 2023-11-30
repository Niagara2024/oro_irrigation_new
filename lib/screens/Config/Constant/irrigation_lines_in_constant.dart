import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/time_picker.dart';



class IrrigationLinesConstant extends StatefulWidget {
  const IrrigationLinesConstant({super.key});

  @override
  State<IrrigationLinesConstant> createState() => _IrrigationLinesConstantState();
}

class _IrrigationLinesConstantState extends State<IrrigationLinesConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 800){
        return IrrigationLinesConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('Name','','first',null),
            expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Pump',''),
            expandedTableCell_Text('Low flow','delay'),
            expandedTableCell_Text('High flow','delay'),
            expandedTableCell_Text('Low flow','behavior'),
            expandedTableCell_Text('High flow','behavior'),
            expandedTableCell_Text('Leakage','limit')],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.irrigationLineUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.irrigationLineUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.irrigationLineUpdated[index]['name']}',),'first',null),
                        expandedCustomCell(Text('${constantPvd.irrigationLineUpdated[index]['id']}'),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[index]['pump'], itemList: ['-','IP1','IP2','IP3'], pvdName: 'line/irrigationPump', index: index),),
                        expandedCustomCell(CustomTimePickerSiva(purpose: 'line/lowFlowDelay', index: index, value: '${constantPvd.irrigationLineUpdated[index]['lowFlowDelay']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
                        expandedCustomCell(CustomTimePickerSiva(purpose: 'line/highFlowDelay', index: index, value: '${constantPvd.irrigationLineUpdated[index]['highFlowDelay']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[index]['lowFlowBehavior'], itemList: ['Ignore','Do next','wait'], pvdName: 'line/lowFlowBehavior', index: index),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.irrigationLineUpdated[index]['highFlowBehavior'], itemList: ['Ignore','Do next','wait'], pvdName: 'line/highFlowBehavior', index: index),),
                        expandedCustomCell(CustomTimePickerSiva(purpose: 'line/leakageLimit', index: index, value: '${constantPvd.irrigationLineUpdated[index]['leakageLimit']}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: 'pulse', CustomList: [0,10], displayAM_PM: false,)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}

class IrrigationLinesConstant_M extends StatefulWidget {
  const IrrigationLinesConstant_M({super.key});

  @override
  State<IrrigationLinesConstant_M> createState() => _IrrigationLinesConstant_MState();
}

class _IrrigationLinesConstant_MState extends State<IrrigationLinesConstant_M> {
  int selectedLine = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 30,
              color: myTheme.primaryColor,
              width : double.infinity,
              child: Center(child: Text('Select line',style: TextStyle(color: Colors.white),))
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: constantPvd.irrigationLines.length,
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
                                    selectedLine = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.irrigationLines.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                    color: selectedLine == index ? myTheme.primaryColor : Colors.blue.shade100,
                                  ),
                                  child: Center(child: Text('${index + 1}',style: TextStyle(color: selectedLine == index ? Colors.white : null),)),
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
                      if(constantPvd.irrigationLines.length - 1 != index)
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
              child: Center(child: Text('Line ${selectedLine + 1}',style: TextStyle(color: Colors.white),))
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
                    returnMyListTile('Name', Text('${constantPvd.irrigationLines[selectedLine][1]}',style: TextStyle(fontSize: 14),)),
                    returnMyListTile('ID', Text('${selectedLine + 1}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Pump', fixedContainer(MyDropDown(initialValue: constantPvd.irrigationLines[selectedLine][2], itemList: ['IP1','IP2','IP3'], pvdName: 'line/irrigationPump', index: selectedLine))),
                    returnMyListTile('Low flow delay', CustomTimePickerSiva(purpose: 'line/lowFlowDelay', index: selectedLine, value: '${constantPvd.irrigationLines[selectedLine][3]}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
                    returnMyListTile('High flow delay', CustomTimePickerSiva(purpose: 'line/highFlowDelay', index: selectedLine, value: '${constantPvd.irrigationLines[selectedLine][4]}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
                    returnMyListTile('Low flow behavior', fixedContainer(MyDropDown(initialValue: constantPvd.irrigationLines[selectedLine][5], itemList: ['Ignore','Do next','wait'], pvdName: 'line/lowFlowBehavior', index: selectedLine))),
                    returnMyListTile('High flow behavior', fixedContainer(MyDropDown(initialValue: constantPvd.irrigationLines[selectedLine][6], itemList: ['Ignore','Do next','wait'], pvdName: 'line/highFlowBehavior', index: selectedLine))),
                    returnMyListTile('Leakage limit', CustomTimePickerSiva(purpose: 'line/leakageLimit', index: selectedLine, value: '${constantPvd.irrigationLines[selectedLine][7]}', displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: 'pulse', CustomList: [0,10], displayAM_PM: false,)),
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


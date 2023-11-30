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



class MainValveConstant extends StatefulWidget {
  const MainValveConstant({super.key});

  @override
  State<MainValveConstant> createState() => _MainValveConstantState();
}

class _MainValveConstantState extends State<MainValveConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      if(constraints.maxWidth < 800){
        return MainValveConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('Name','','first'),
            expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Line',''),
            expandedTableCell_Text('Mode',''),
            expandedTableCell_Text('Delay',''),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.mainValveUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.mainValveUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.mainValveUpdated[index]['name']}'),'first'),
                        expandedCustomCell(Text('${constantPvd.mainValveUpdated[index]['id']}'),),
                        expandedCustomCell(Text('${constantPvd.mainValveUpdated[index]['location']}'),),
                        expandedCustomCell(MyDropDown(initialValue: constantPvd.mainValveUpdated[index]['mode'], itemList: ['No delay','Open before','Open after'], pvdName: 'mainvalve/mode', index: index),),
                        expandedCustomCell(CustomTimePickerSiva(purpose: 'mainvalve/delay', index: index, value: '${constantPvd.mainValveUpdated[index]['delay']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}

class MainValveConstant_M extends StatefulWidget {
  const MainValveConstant_M({super.key});

  @override
  State<MainValveConstant_M> createState() => _MainValveConstant_MState();
}

class _MainValveConstant_MState extends State<MainValveConstant_M> {
  int selected_M_Valve = 0;
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
              child: Center(child: Text('Select Main valve',style: TextStyle(color: Colors.white),))
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: constantPvd.mainValve.length,
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
                                    selected_M_Valve = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.mainValve.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                    color: selected_M_Valve == index ? myTheme.primaryColor : Colors.blue.shade100,
                                  ),
                                  child: Center(child: Text('${index + 1}',style: TextStyle(color: selected_M_Valve == index ? Colors.white : null),)),
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
                      if(constantPvd.mainValve.length - 1 != index)
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
              child: Center(child: Text('Main valve ${selected_M_Valve + 1}',style: TextStyle(color: Colors.white),))
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // color: Color(0XFFF3F3F3)
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    returnMyListTile('Name', Text('${constantPvd.mainValve[selected_M_Valve][1]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('ID', Text('${selected_M_Valve + 1}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Line', Text('${constantPvd.mainValve[selected_M_Valve][2]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Pump', fixedContainer(MyDropDown(initialValue: constantPvd.mainValve[selected_M_Valve][3], itemList: ['No delay','Open before','Open after'], pvdName: 'mainvalve/mode', index: selected_M_Valve))),
                    returnMyListTile('Low flow delay', CustomTimePickerSiva(purpose: 'mainvalve/delay', index: selected_M_Valve, value: '${constantPvd.mainValve[selected_M_Valve][4]}', displayHours: true, displayMins: true, displaySecs: false, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,)),
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


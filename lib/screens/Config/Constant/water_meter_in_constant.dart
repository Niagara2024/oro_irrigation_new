import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';



class WaterMeterConstant extends StatefulWidget {
  const WaterMeterConstant({super.key});

  @override
  State<WaterMeterConstant> createState() => _WaterMeterConstantState();
}

class _WaterMeterConstantState extends State<WaterMeterConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 800){
        return WaterMeterConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('ID',''),
            expandedTableCell_Text('Location',''),
            expandedTableCell_Text('Name',''),
            expandedTableCell_Text('Ratio','l/pulse'),
            expandedTableCell_Text('Maximum','flow l/hr'),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.waterMeterUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.waterMeterUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.waterMeterUpdated[index]['id']}'),),
                        expandedCustomCell(Text('${constantPvd.waterMeterUpdated[index]['location']}'),),
                        expandedCustomCell(Text('${constantPvd.waterMeterUpdated[index]['name']}'),),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[index]['ratio'], constantPvd: constantPvd, purpose: 'wm_ratio/${index}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[index]['maximumFlow'], constantPvd: constantPvd, purpose: 'maximum_flow/${index}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      ],
                    ),
                  );
                }),
          )
      );
    });

  }
}

class WaterMeterConstant_M extends StatefulWidget {
  const WaterMeterConstant_M({super.key});

  @override
  State<WaterMeterConstant_M> createState() => _WaterMeterConstant_MState();
}

class _WaterMeterConstant_MState extends State<WaterMeterConstant_M> {
  int selectedWaterMeter = 0;
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
              child: Center(child: Text('Select water meter',style: TextStyle(color: Colors.white),))
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: constantPvd.waterMeter.length,
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
                                    selectedWaterMeter = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.waterMeter.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                    color: selectedWaterMeter == index ? myTheme.primaryColor : Colors.blue.shade100,
                                  ),
                                  child: Center(child: Text('${index + 1}',style: TextStyle(color: selectedWaterMeter == index ? Colors.white : null),)),
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
                      if(constantPvd.waterMeter.length - 1 != index)
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
              child: Center(child: Text('Water meter ${selectedWaterMeter + 1}',style: TextStyle(color: Colors.white),))
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
                    returnMyListTile('ID', Text('${selectedWaterMeter + 1}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Location', Text('${constantPvd.waterMeter[selectedWaterMeter][1]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Name', Text('${constantPvd.waterMeter[selectedWaterMeter][2]}',style: TextStyle(fontSize: 14))),
                    returnMyListTile('Ratio l/pulse', TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeter[selectedWaterMeter][3], constantPvd: constantPvd, purpose: 'wm_ratio/${selectedWaterMeter}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                    returnMyListTile('Maximum flow l/hr', TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeter[selectedWaterMeter][4], constantPvd: constantPvd, purpose: 'maximum_flow/${selectedWaterMeter}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
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


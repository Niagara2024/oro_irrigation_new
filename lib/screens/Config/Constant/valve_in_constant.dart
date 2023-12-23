import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/widgets/drop_down_button.dart';
import 'package:provider/provider.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/my_number_picker.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
import '../../../widgets/time_picker.dart';


class ValveConstant extends StatefulWidget {
  const ValveConstant({super.key});

  @override
  State<ValveConstant> createState() => _ValveConstantState();
}

class _ValveConstantState extends State<ValveConstant> {


  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 800){
        return ValveConstant_M();
      }
      return myTable(
        [expandedTableCell_Text('Valve','','first'),
          expandedTableCell_Text('Name',''),
          expandedTableCell_Text('Default','dosage'),
          expandedTableCell_Text('Nominal','flow(l/h)'),
          expandedTableCell_Text('Minimum','flow(l/h)'),
          expandedTableCell_Text('Maximum','flow(l/h)'),
          expandedTableCell_Text('Fill-up','delay(min)'),
          expandedTableCell_Text('Area','(Dunam)'),
          expandedTableCell_Text('Crop','factor(%)'),
        ],
        Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for(var i = 0;i < constantPvd.valveUpdated.length;i++)
                      Column(
                        children: [
                          Container(
                            color: Colors.indigo.shade100,
                            height: 30,
                            width: double.infinity,
                            child: Center(child: Text('${constantPvd.valveUpdated[i]['name']}',style: TextStyle(color: Colors.black87),)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
                                      for(var k = 0;k < constantPvd.valveUpdated[i]['valve'].length;k++)
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border(bottom: BorderSide(width: 1),top: BorderSide(width: k == 0 ? 1 : 0))
                                          ),
                                          child: Row(
                                            children: [
                                              expandedCustomCell(Text('${k+1}'),'first',k % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50),
                                              expandedCustomCell(Text('${constantPvd.valveUpdated[i]['valve'][k]['name']}')),
                                              expandedCustomCell(MyDropDown(initialValue: '${constantPvd.valveUpdated[i]['valve'][k]['defaultDosage']}', itemList: ['Time','Quantity'], pvdName: 'valve_defaultDosage/${i}/${k}', index: i)),
                                              expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[i]['valve'][k]['nominalFlow'], constantPvd: constantPvd, purpose: 'valve_nominal_flow/${i}/${k}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                                              expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[i]['valve'][k]['minimumFlow'], constantPvd: constantPvd, purpose: 'valve_minimum_flow/${i}/${k}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                                              expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[i]['valve'][k]['maximumFlow'], constantPvd: constantPvd, purpose: 'valve_maximum_flow/${i}/${k}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                                              expandedCustomCell(CustomTimePickerSiva(purpose: 'valve_fillUpDelay/${i}/${k}', index: k, value: '${constantPvd.valveUpdated[i]['valve'][k]['fillUpDelay']}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',)),
                                              expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[i]['valve'][k]['area'], constantPvd: constantPvd, purpose: 'valve_area/${i}/${k}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],)),
                                              expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[i]['valve'][k]['cropFactor'], constantPvd: constantPvd, purpose: 'valve_crop_factor/${i}/${k}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                                            ],
                                          ),
                                        )
                                    ],
                                  )
                              )
                            ],
                          )
                        ],
                      )
                    // for(var j in constantPvd.valve[i].entries)

                  ],
                ),
              ),
            )
        ),
      );
    });
  }
}

class ValveConstant_M extends StatefulWidget {
  const ValveConstant_M({super.key});

  @override
  State<ValveConstant_M> createState() => _ValveConstant_MState();
}

class _ValveConstant_MState extends State<ValveConstant_M> {
  int selected_Line = 0;
  int selected_valve = 0;
  dynamic valvesInSelectedLine = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (mounted) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    //     for(var i in constantPvd.valve[selected_Line].entries){
    //       valvesInSelectedLine = i.value;
    //     }
    //     print(valvesInSelectedLine);
    //   });
    // }
  }
  void _showTimePicker(BuildContext context,ConstantProvider constantPvd, OverAllUse overAllPvd) async {
    overAllPvd.editTimeAll();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text(
                'Select line',style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: MyTimePicker(displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: '', CustomList: [1,constantPvd.valve.length], displayAM_PM: false,),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  selected_Line = overAllPvd.other - 1;
                });
                Navigator.pop(context);
              },
              child: Text('OK',style: TextStyle(color: myTheme.primaryColor,fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    print('constantPvd.valve[selected_Line].keys : ${constantPvd.valve[selected_Line].keys}');
    setState(() {
      for(var i in constantPvd.valve[selected_Line].entries){
        valvesInSelectedLine = i.value;
      }
    });
    return LayoutBuilder(builder: (context,constraints){
      return Column(
        children: [
          SizedBox(height: 5,),
          ElevatedButton(
            style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(300, 40)),
                backgroundColor: MaterialStateProperty.all(myTheme.primaryColor)
            ),
            onPressed: (){
              _showTimePicker(context,constantPvd,overAllPvd);
            },
            child: Text('Click to select line',style: TextStyle(color: Colors.yellow, fontSize: 16),),
          ),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            height: 30,
            color: myTheme.primaryColor,
            width: double.infinity,
            child: Center(
              child: Text('Select valve in line ${selected_Line + 1}', style: TextStyle(color: Colors.white)),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: double.infinity,
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: valvesInSelectedLine.length,
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
                                    selected_valve = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : valvesInSelectedLine.length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                    color: selected_valve == index ? myTheme.primaryColor : Colors.blue.shade100,
                                  ),
                                  child: Center(child: Text('${index + 1}',style: TextStyle(color: selected_valve == index ? Colors.white : null),)),
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
                      if(valvesInSelectedLine.length - 1 != index)
                        Text('-')
                    ],
                  );
                }),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            height: 30,
            color: myTheme.primaryColor,
            width: double.infinity,
            child: Center(
              child: Text('Valve ${selected_valve + 1} in line ${selected_Line + 1}', style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for(var i in constantPvd.valve[selected_Line].entries)
                      Column(
                        children: [
                          returnMyListTile('Default dosage', CustomTimePickerSiva(purpose: 'valve_defaultDosage/${selected_Line}/${i.key}/${selected_valve}', index: selected_valve, value: '${valvesInSelectedLine[selected_valve][3]}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',)),
                          returnMyListTile('Nominal flow(l/h)',  TextFieldForConstant(index: -1, initialValue: valvesInSelectedLine[selected_valve][4], constantPvd: constantPvd, purpose: 'valve_nominal_flow/${selected_Line}/${i.key}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                          returnMyListTile('Minimum flow(l/h)', TextFieldForConstant(index: -1, initialValue: valvesInSelectedLine[selected_valve][5], constantPvd: constantPvd, purpose: 'valve_minimum_flow/${selected_Line}/${i.key}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),),
                          returnMyListTile('Maximum flow(l/h)', TextFieldForConstant(index: -1, initialValue: valvesInSelectedLine[selected_valve][6], constantPvd: constantPvd, purpose: 'valve_maximum_flow/${selected_Line}/${i.key}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                          returnMyListTile('Fill-up delay(min)', CustomTimePickerSiva(purpose: 'valve_fillUpDelay/${selected_Line}/${i.key}/${selected_valve}', index: selected_valve, value: '${valvesInSelectedLine[selected_valve][7]}', displayHours: false, displayMins: true, displaySecs: false, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',)),
                          returnMyListTile('Area (Dunam)', TextFieldForConstant(index: -1, initialValue: valvesInSelectedLine[selected_valve][8], constantPvd: constantPvd, purpose: 'valve_area/${selected_Line}/${i.key}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],)),
                          returnMyListTile('Crop factor(%)', TextFieldForConstant(index: -1, initialValue: valvesInSelectedLine[selected_valve][9], constantPvd: constantPvd, purpose: 'valve_crop_factor/${selected_Line}/${i.key}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                        ],
                      )

                  ],
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
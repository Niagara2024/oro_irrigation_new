import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/widgets/drop_down_button.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
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

Widget fillUpDelay(BuildContext context,constantPvd,overAllPvd,line,valve){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.valveUpdated[line]['valve'][valve]['fillUpDelay']}',
              onPressed: (){
                constantPvd.valveFunctionality(['fillUpDelay',line,valve,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.valveUpdated[line]['valve'][valve]['fillUpDelay']}',style: TextStyle(color: Colors.black87),)
  );
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
  }
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);

    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xfff3f3f3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                  ),
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: ListTile(
                      title: Text('Irrigation Line'),
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/irrigation_line1.png'),
                      ),
                      trailing:  PopupMenuButton<int>(
                        child: Text('${selected_Line + 1}',style: TextStyle(fontSize: 20),),
                        itemBuilder: (context) => [
                          for(var i = 0;i < constantPvd.valveUpdated.length;i++)
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
                          print('selected value  : $value');
                          setState(() {
                            selected_Line = value;
                            selected_valve = 0;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                  ),
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: ListTile(
                      title: Text('Valve'),
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset('assets/images/valve1.png'),
                      ),
                      trailing:  PopupMenuButton<int>(
                        child: Text('${selected_valve + 1}',style: TextStyle(fontSize: 20),),
                        itemBuilder: (context) => [
                          for(var i = 0;i < constantPvd.valveUpdated[selected_Line]['valve'].length;i++)
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
                          print('selected value  : $value');
                          setState(() {
                            selected_valve = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Default dosage'),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['defaultDosage'],
                        underline: Container(),
                        items: ['Time','Quantity'].map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.valveFunctionality(['valve_defaultDosage',selected_valve,selected_valve,value!]);
                        },
                        // After selecting the desired option,it will
                        // change button value to selected value

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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Nominal flow'),
                        ],
                      ),
                      SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['nominalFlow'], constantPvd: constantPvd, purpose: 'valve_nominal_flow/${selected_Line}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('Minimum flow'),
                        ],
                      ),
                      SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['minimumFlow'], constantPvd: constantPvd, purpose: 'valve_minimum_flow/${selected_Line}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))                    ],
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('maximum flow'),
                        ],
                      ),
                      SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['maximumFlow'], constantPvd: constantPvd, purpose: 'valve_maximum_flow/${selected_Line}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Fill up delay'),
                        ],
                      ),
                      fillUpDelay(context, constantPvd, overAllPvd, selected_Line, selected_valve),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Area'),
                        ],
                      ),
                      SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['area'], constantPvd: constantPvd, purpose: 'valve_area/$selected_Line/$selected_valve', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],))
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Crop factor'),
                        ],
                      ),
                      SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.valveUpdated[selected_Line]['valve'][selected_valve]['cropFactor'], constantPvd: constantPvd, purpose: 'valve_crop_factor/${selected_Line}/${selected_valve}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
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
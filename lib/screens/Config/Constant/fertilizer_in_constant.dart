import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/widgets/time_picker.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/my_number_picker.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';

class FertilizerConstant extends StatefulWidget {
  const FertilizerConstant({super.key});

  @override
  State<FertilizerConstant> createState() => _FertilizerConstantState();
}

class _FertilizerConstantState extends State<FertilizerConstant> {


  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      var width = constraints.maxWidth;
      if(width < 1000){
        return FertilizerConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('Site','name'),
            fixedTableCell_Text('Used in','lines',80,width < 1100 ? constant_style : null),
            fixedTableCell_Text('No flow','behavior',200,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Fertilizer','(injector)',width < 1100 ? constant_style : null),
            expandedTableCell_Text('Name','',width < 1100 ? constant_style : null),
            expandedTableCell_Text('Dosing','meter',width < 1100 ? constant_style : null),
            expandedTableCell_Text('Ratio','(l/pulse)',width < 1100 ? constant_style : null),
            expandedTableCell_Text('Shortest','pulse(sec)',width < 1100 ? constant_style : null),
            expandedTableCell_Text('Nominal','flow(l/h)',width < 1100 ? constant_style : null),
            fixedTableCell_Text('Injector','mode',150,width < 1100 ? constant_style : null),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.fertilizer.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.fertilizer.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor,
                        border: Border(bottom: BorderSide(width: 0.5,color: Colors.black))
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.fertilizer[index][0]}',style: width < 1100 ? constant_style : TextStyle(color: Colors.white),),),
                        fixedSizeCustomCell(Text('${constantPvd.fertilizer[index][1]}',style: width < 1100 ? constant_style : TextStyle(color: Colors.white),), 80),
                        fixedSizeCustomCell(Container(color: Colors.white,margin: EdgeInsets.all(5),child: MyDropDown(initialValue: constantPvd.fertilizer[index][2], itemList: ['Stop Faulty Fertilizer','Stop Fertigation','Stop Irrigation','Inform Only'], pvdName: 'fertilizer/noFlowBehavior', index: index)), 200),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(Text('${constantPvd.fertilizer[index][3][i][0]}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(Text('${constantPvd.fertilizer[index][3][i][1]}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(Text('${constantPvd.fertilizer[index][3][i][2]}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black),),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizer[index][3][i][3], constantPvd: constantPvd, purpose: 'fertilizer_ratio/${index}/3/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_shortestPulse/${index}/3/${i}', index: index, value: '${constantPvd.fertilizer[index][3][i][4]}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                            expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizer[index][3][i][5], constantPvd: constantPvd, purpose: 'fertilizer_nominal_flow/${index}/3/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        Container(
                          width: 150,
                          child: Column(
                            children: [
                              for(var i = 0;i < constantPvd.fertilizer[index][3].length;i++)
                                Container(
                                  color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                  width: double.infinity,
                                  height: 60,
                                  child: Center(
                                    child: MyDropDown(initialValue: constantPvd.fertilizer[index][3][i][6], itemList: ['Concentration','PH_controlled','EC_controlled','Regular'], pvdName: 'fertilizer_injector_mode/${index}/3/${i}', index: index),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )
      );
    });
  }
}

TextStyle constant_style = TextStyle(fontSize: 12,color: Colors.white);
TextStyle constant_style1 = TextStyle(fontSize: 12,color: Colors.black);

class FertilizerConstant_M extends StatefulWidget {
  const FertilizerConstant_M({super.key});

  @override
  State<FertilizerConstant_M> createState() => _FertilizerConstant_MState();
}

class _FertilizerConstant_MState extends State<FertilizerConstant_M> {
  int selectedSite = 0;
  int selectedFertilizer = 0;
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 5,),
            ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(300, 40)),
                  backgroundColor: MaterialStateProperty.all(myTheme.primaryColor)
              ),
              onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text('Select site',style: TextStyle(color: Colors.black),),
                    content: DropDownValue(),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                      ),
                      TextButton(
                        onPressed: (){
                          constantPvd.fertilizerFunctionality(['fertilizer/noFlowBehavior',overAllPvd.other - 1,constantPvd.dropDownValue!]);
                          setState(() {
                            selectedSite = overAllPvd.other - 1;
                            selectedFertilizer = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('OK',style: TextStyle(color: myTheme.primaryColor,fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                });
                },
              child: Text('Click to select site',style: TextStyle(color: Colors.yellow,fontSize: 16),),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 30,
              color: myTheme.primaryColor,
              width: double.infinity,
              child: Center(
                child: Text('Select fertilizer in site ${selectedSite + 1}', style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              width: double.infinity,
              height: 50,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: constantPvd.fertilizer[selectedSite][3].length,
                  itemBuilder: (BuildContext context,int index){
                    print(constantPvd.fertilizer[selectedSite][3].length);
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
                                      selectedFertilizer = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: index == 0 ? BorderRadius.only(topLeft: Radius.circular(20)) : constantPvd.fertilizer[selectedSite][3].length -1 == index ? BorderRadius.only(topRight: Radius.circular(20)) : BorderRadius.circular(5),
                                      color: selectedFertilizer == index ? myTheme.primaryColor : Colors.blue.shade50,
                                    ),
                                    child: Center(child: Text('${index + 1}',style: TextStyle(color: selectedFertilizer == index ? Colors.white : null),)),
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
                        if(constantPvd.fertilizer[selectedSite][3].length -1 != index)
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
                child: Text('Fertilizer ${selectedFertilizer + 1} in site ${selectedSite + 1}', style: TextStyle(color: Colors.white)),
              ),
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      returnMyListTile('Site name', Text('${constantPvd.fertilizer[selectedSite][0]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('Used in lines', Text('${constantPvd.fertilizer[selectedSite][1]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('No flow behavior', Text('${constantPvd.fertilizer[selectedSite][2]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('Fertilizer', Text('${constantPvd.fertilizer[selectedSite][3][selectedFertilizer][0]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('Name', Text('${constantPvd.fertilizer[selectedSite][3][selectedFertilizer][1]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('Dosing meter', Text('${constantPvd.fertilizer[selectedSite][3][selectedFertilizer][2]}',style: TextStyle(fontSize: 14))),
                      returnMyListTile('Ratio (l/pulse)', TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizer[selectedSite][3][selectedFertilizer][3], constantPvd: constantPvd, purpose: 'fertilizer_ratio/${selectedSite}/3/${selectedFertilizer}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      returnMyListTile('Shortest pulse(sec)', CustomTimePickerSiva(purpose: 'fertilizer_shortestPulse/${selectedSite}/3/${selectedFertilizer}', index: selectedSite, value: '${constantPvd.fertilizer[selectedSite][3][selectedFertilizer][4]}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',)),
                      returnMyListTile('Nominal flow(l/h)', TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizer[selectedSite][3][selectedFertilizer][5], constantPvd: constantPvd, purpose: 'fertilizer_nominal_flow/${selectedSite}/3/${selectedFertilizer}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                      returnMyListTile('Injector mode', fixedContainer(MyDropDown(initialValue: constantPvd.fertilizer[selectedSite][3][selectedFertilizer][6], itemList: ['Concentration','PH_controlled','EC_controlled','Regular'], pvdName: 'fertilizer_injector_mode/${selectedSite}/3/${selectedFertilizer}', index: selectedSite))),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
class DropDownValue extends StatefulWidget {
  const DropDownValue({super.key});

  @override
  State<DropDownValue> createState() => _DropDownValueState();
}

class _DropDownValueState extends State<DropDownValue> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      width: double.infinity,
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyTimePicker(displayHours: false, displayMins: false, displaySecs: false, displayCustom: true, CustomString: '', CustomList: [1,constantPvd.fertilizer.length], displayAM_PM: false,),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5),
            ),
            child: Center(
              child: ListTile(
                focusColor: Colors.transparent,
                selectedColor: Colors.transparent,
                tileColor: Colors.transparent,
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Center(
                    child: Icon(Icons.account_balance_wallet_outlined),
                  ),
                ),
                contentPadding: EdgeInsets.all(0),
                title: Text('No flow behavior',style: TextStyle(fontSize: 12),),
                trailing: Container(
                  width: 170,
                    height: 40,
                    child: MyDropDown(initialValue: constantPvd.dropDownValue, itemList:['Stop Faulty Fertilizer','Stop Fertigation','Stop Irrigation','Inform Only'], pvdName: 'editDropDownValue', index: -1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
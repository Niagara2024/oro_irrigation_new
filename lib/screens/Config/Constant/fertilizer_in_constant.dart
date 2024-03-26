import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/widgets/time_picker.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
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
          [
            fixedTableCell_Text('Site','name',110,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Used in','lines',80,width < 1100 ? constant_style : null),
            fixedTableCell_Text('No flow','behavior',200,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Minimal','on time',90,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Minimal','off time',90,width < 1100 ? constant_style : null),
            fixedTableCell_Text('water flow','stability time',90,width < 1100 ? constant_style : null),
            fixedTableCell_Text('Booster off','delay',90,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Name','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Ratio','(l/pulse)',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Shortest','pulse(sec)',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Nominal','flow(l/h)',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Injector','Mode',null,width < 1100 ? constant_style : null),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.fertilizerUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.fertilizerUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        fixedSizeCustomCell(Text('${constantPvd.fertilizerUpdated[index]['name']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),), 110,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(Text('${constantPvd.fertilizerUpdated[index]['location'] == '' ? 'null' : constantPvd.fertilizerUpdated[index]['location']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),), 80,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(Container(color: Colors.white,margin: EdgeInsets.all(5),child: MyDropDown(initialValue: constantPvd.fertilizerUpdated[index]['noFlowBehavior'], itemList: ['Stop Faulty Fertilizer','Stop Fertigation','Stop Irrigation','Inform Only'], pvdName: 'fertilizer/noFlowBehavior', index: index)), 200,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_minimalOnTime/$index', index: index, value: '${constantPvd.fertilizerUpdated[index]['minimalOnTime']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',), 90,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_minimalOffTime/$index', index: index, value: '${constantPvd.fertilizerUpdated[index]['minimalOffTime']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',), 90,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_waterFlowStabilityTime/$index', index: index, value: '${constantPvd.fertilizerUpdated[index]['waterFlowStabilityTime']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',), 90,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        fixedSizeCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_boosterOffDelay/$index', index: index, value: '${constantPvd.fertilizerUpdated[index]['boosterOffDelay']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',), 90,40 * constantPvd.fertilizerUpdated[index]['fertilizer'].length as double,false),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizerUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(Text('${constantPvd.fertilizerUpdated[index]['fertilizer'][i]['name']}',style: width < 1100 ? constant_style1 : TextStyle(color: Colors.black,fontSize: 12),))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizerUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizerUpdated[index]['fertilizer'][i]['ratio'], constantPvd: constantPvd, purpose: 'fertilizer_ratio/${index}/fertilizer/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizerUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(CustomTimePickerSiva(purpose: 'fertilizer_shortestPulse/${index}/fertilizer/${i}', index: index, value: '${constantPvd.fertilizerUpdated[index]['fertilizer'][i]['shortestPulse']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',),null,i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100)
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizerUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizerUpdated[index]['fertilizer'][i]['nominalFlow'], constantPvd: constantPvd, purpose: 'fertilizer_nominalFlow/${index}/fertilizer/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.fertilizerUpdated[index]['fertilizer'].length;i++)
                            expandedCustomCell(MyDropDown(initialValue: constantPvd.fertilizerUpdated[index]['fertilizer'][i]['injectorMode'], itemList: ['Concentration','Ec controlled','Ph controlled','Regular'], pvdName: 'fertilizer_injectorMode/$index/fertilizer/$i', index: index))
                        ]),

                      ],
                    ),
                  );
                }),
          )
      );
    });
  }
}

Widget minimalOnTime(BuildContext context,constantPvd,overAllPvd,site){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.fertilizerUpdated[site]['minimalOnTime']}',
              onPressed: (){
                constantPvd.fertilizerFunctionality(['fertilizer_minimalOnTime',site,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.fertilizerUpdated[site]['minimalOnTime']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget minimalOffTime(BuildContext context,constantPvd,overAllPvd,site){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.fertilizerUpdated[site]['minimalOffTime']}',
              onPressed: (){
                constantPvd.fertilizerFunctionality(['fertilizer_minimalOffTime',site,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.fertilizerUpdated[site]['minimalOffTime']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget waterFlow(BuildContext context,constantPvd,overAllPvd,site){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.fertilizerUpdated[site]['waterFlowStabilityTime']}',
              onPressed: (){
                constantPvd.fertilizerFunctionality(['fertilizer_waterFlowStabilityTime',site,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.fertilizerUpdated[site]['waterFlowStabilityTime']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget boosterOffDelay(BuildContext context,constantPvd,overAllPvd,site){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.fertilizerUpdated[site]['boosterOffDelay']}',
              onPressed: (){
                constantPvd.fertilizerFunctionality(['fertilizer_boosterOffDelay',site,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.fertilizerUpdated[site]['boosterOffDelay']}',style: TextStyle(color: Colors.black87),)
  );
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

    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xfff3f3f3),
      child: SingleChildScrollView(
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
                  title: Text('Site'),
                  leading: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset('assets/images/central_fertilizer_site2.png'),
                  ),
                  trailing:  PopupMenuButton<int>(
                    child: Text('${selectedSite + 1}',style: TextStyle(fontSize: 20),),
                    itemBuilder: (context) => [
                      for(var i = 0;i < constantPvd.fertilizerUpdated.length;i++)
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
                        selectedSite = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 5,),
            SizedBox(
              height: 320,
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
                            Text('Ratio',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        DropdownButton(
                          focusColor: Colors.transparent,
                          // style: ioText,
                          value: constantPvd.fertilizerUpdated[selectedSite]['noFlowBehavior'],
                          underline: Container(),
                          items: ['Stop Faulty Fertilizer','Stop Fertigation','Stop Irrigation','Inform Only'].map((dynamic items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Container(
                                  child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            constantPvd.fertilizerFunctionality(['fertilizer/noFlowBehavior',selectedSite,value!]);
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
                            Text('minimal on time',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        minimalOnTime(context, constantPvd, overAllPvd, selectedSite)
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
                            Text('minimal off time',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        minimalOffTime(context, constantPvd, overAllPvd, selectedSite)
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
                            Text('water flow time',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        waterFlow(context, constantPvd, overAllPvd, selectedSite)
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
                            Text('Booster off delay',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        boosterOffDelay(context, constantPvd, overAllPvd, selectedSite)
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                            Text('Name'),
                          ],
                        ),
                        Text('${constantPvd.fertilizerUpdated[selectedSite]['name']}')
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: constantPvd.fertilizerUpdated[selectedSite]['fertilizer'].length,
                  itemBuilder: (context,index){
                  return InkWell(
                    onTap: (){
                      setState(() {
                        selectedFertilizer = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedFertilizer == index ? myTheme.primaryColor : Colors.white,
                      ),
                      child: Center(child: Text('${constantPvd.fertilizerUpdated[selectedSite]['fertilizer'][selectedFertilizer]['name']}',style: TextStyle(color: selectedFertilizer == index ? Colors.white : Colors.black87),)),
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      width: 150,
                      height: 50,
                    ),
                  );
              }),
            ),
            SizedBox(
              height: 320,
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
                            Text('Ratio',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),

                        SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizerUpdated[selectedSite]['fertilizer'][selectedFertilizer]['ratio'], constantPvd: constantPvd, purpose: 'fertilizer_ratio/${selectedSite}/fertilizer/${selectedFertilizer}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))                      ],
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
                            Text('shortest pulse',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        DropdownButton(
                          focusColor: Colors.transparent,
                          // style: ioText,
                          value: constantPvd.fertilizerUpdated[selectedSite]['fertilizer'][selectedFertilizer]['shortestPulse'],
                          underline: Container(),
                          items: ['1','2','3','4','5','6','7','8','9','10'].map((dynamic items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Container(
                                  child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            constantPvd.fertilizerFunctionality(['fertilizer_shortestPulse',selectedSite,'fertilizer',selectedFertilizer,value!]);
                          },
                        ),
                      ]
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
                            Text('nominal flow',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        SizedBox(width:60,height:55,child: TextFieldForConstant(index: -1, initialValue: constantPvd.fertilizerUpdated[selectedSite]['fertilizer'][selectedFertilizer]['nominalFlow'], constantPvd: constantPvd, purpose: 'fertilizer_nominalFlow/${selectedSite}/fertilizer/${selectedFertilizer}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))                      ],
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
                            Text('Injector mode',style: TextStyle(color: myTheme.primaryColor),),
                          ],
                        ),
                        DropdownButton(
                          focusColor: Colors.transparent,
                          // style: ioText,
                          value: constantPvd.fertilizerUpdated[selectedSite]['fertilizer'][selectedFertilizer]['injectorMode'],
                          underline: Container(),
                          items: ['Concentration','Ec controlled','Ph controlled','Regular'].map((dynamic items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Container(
                                  child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            constantPvd.fertilizerFunctionality(['fertilizer_injectorMode',selectedSite,'fertilizer',selectedFertilizer,value!]);
                          },
                        ),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                            Text('Fertilizer name'),
                          ],
                        ),
                        Text('${constantPvd.fertilizerUpdated[selectedSite]['name']}')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
import '../../../main.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/HoursMinutesSeconds.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
import '../../../widgets/time_picker.dart';
import 'fertilizer_in_constant.dart';

class EcPhInConstant extends StatefulWidget {
  const EcPhInConstant({super.key});

  @override
  State<EcPhInConstant> createState() => _EcPhInConstantState();
}

class _EcPhInConstantState extends State<EcPhInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (BuildContext context,BoxConstraints constraints){
      var width = constraints.maxWidth;
      if(width < 1000){
        return EcPhInConstant_M();
      }
      return myTable(
          [expandedTableCell_Text('Site','name'),
            expandedTableCell_Text('Select','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Control','cycle',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Delta','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Fine','tunning',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Coarse','tunning',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Deadband','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Integ','',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Control','sensor',null,width < 1100 ? constant_style : null),
            expandedTableCell_Text('Avg filt','speed',null,width < 1100 ? constant_style : null),
          ],
          Expanded(
            child: ListView.builder(
                itemCount: constantPvd.ecPhUpdated.length,
                itemBuilder: (BuildContext context,int index){
                  return Container(
                    margin: index == constantPvd.ecPhUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1)),
                      color: Colors.white70,
                    ),
                    child: Row(
                      children: [
                        expandedCustomCell(Text('${constantPvd.ecPhUpdated[index]['name']}',style: width < 1100 ? constant_style : TextStyle(color: Colors.black),),null,null,40 * constantPvd.ecPhUpdated[index]['setting'].length),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Checkbox(
                                  value: constantPvd.ecPhUpdated[index]['setting'][i]['active'],
                                  onChanged: (value){
                                    print(value);
                                    constantPvd.ecPhFunctionality(['activateEcPh',index,i,value]);
                                  },
                                ),
                                Text('${constantPvd.ecPhUpdated[index]['setting'][i]['name']}')
                              ],
                            ))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['controlCycle']}',style: TextStyle(color: Colors.black54),) :  CustomTimePickerSiva(purpose: 'ecPhControlCycle/$index/setting/$i', index: index, value: '${constantPvd.ecPhUpdated[index]['setting'][i]['controlCycle']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['delta']}',style: TextStyle(color: Colors.black54),) :  TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['delta']}', constantPvd: constantPvd, purpose: 'ecPhDelta/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['fineTunning']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['fineTunning']}', constantPvd: constantPvd, purpose: 'ecPhFineTunning/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['coarseTunning']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['coarseTunning']}', constantPvd: constantPvd, purpose: 'ecPhCoarseTunning/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['deadBand']}',style: TextStyle(color: Colors.black54),) : TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[index]['setting'][i]['deadBand']}', constantPvd: constantPvd, purpose: 'ecPhDeadBand/$index/setting/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['integ']}',style: TextStyle(color: Colors.black54),) : CustomTimePickerSiva(purpose: 'ecPhInteg/$index/setting/$i', index: index, value: '${constantPvd.ecPhUpdated[index]['setting'][i]['integ']}', displayHours: false, displayMins: false, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['senseOrAvg']}',style: TextStyle(color: Colors.black54),) : MyDropDown(initialValue: constantPvd.ecPhUpdated[index]['setting'][i]['senseOrAvg'], itemList: constantPvd.ecPhUpdated[index]['setting'][i]['sensorList'], pvdName: 'ecPhSenseOrAvg/$index/setting/$i', index: index))
                        ]),
                        expandedNestedCustomCell([
                          for(var i = 0;i < constantPvd.ecPhUpdated[index]['setting'].length;i++)
                            expandedCustomCell(constantPvd.ecPhUpdated[index]['setting'][i]['active'] == false ? Text('${constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterSpeed']}',style: TextStyle(color: Colors.black54),) : MyDropDown(initialValue: constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterSpeed'], itemList: constantPvd.ecPhUpdated[index]['setting'][i]['avgFilterList'], pvdName: 'ecPhAvgFiltSpeed/$index/setting/$i', index: index))
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

Widget controlCycle(BuildContext context,constantPvd,overAllPvd,site,index){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.ecPhUpdated[site]['setting'][index]['controlCycle']}',
              onPressed: (){
                constantPvd.ecPhFunctionality(['ecPhControlCycle',site,'setting',index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.ecPhUpdated[site]['setting'][index]['controlCycle']}',style: TextStyle(color: Colors.black87),)
  );
}
Widget integ(BuildContext context,constantPvd,overAllPvd,site,index){
  return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
      ),
      onPressed: ()async{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: HoursMinutesSeconds(
              initialTime: '${constantPvd.ecPhUpdated[site]['setting'][index]['integ']}',
              onPressed: (){
                constantPvd.ecPhFunctionality(['ecPhInteg',site,'setting',index,'${overAllPvd.hrs < 10 ? '0' :''}${overAllPvd.hrs}:${overAllPvd.min < 10 ? '0' :''}${overAllPvd.min}:${overAllPvd.sec < 10 ? '0' :''}${overAllPvd.sec}']);
                Navigator.pop(context);
              },
            ),
          );
        });
      },
      child: Text('${constantPvd.ecPhUpdated[site]['setting'][index]['integ']}',style: TextStyle(color: Colors.black87),)
  );
}


class EcPhInConstant_M extends StatefulWidget {
  const EcPhInConstant_M({super.key});

  @override
  State<EcPhInConstant_M> createState() => _EcPhInConstant_MState();
}

class _EcPhInConstant_MState extends State<EcPhInConstant_M> {
  int selectedSite = 0;
  int segmentedControlGroupValue = 0;
  Map<int, Widget> myTabs = <int, Widget>{
    0: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Ec",style: TextStyle(color: Colors.white),),
    ),
    1: const Padding(
      padding: EdgeInsets.all(5),
      child: Text("Ph",style: TextStyle(color: Colors.white)),
    ),
  };
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
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white
            ),
            width: double.infinity,
            height: 60,
            child: Center(
              child: ListTile(
                title: Text('Fertilizer site'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/ec_sensor1.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedSite + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.ecPhUpdated.length;i++)
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
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: MediaQuery.sizeOf(context).width/210,
              children: <Widget>[
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)
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
                          Text('${constantPvd.ecPhUpdated[selectedSite]['setting'][i]['name']} Active',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      Checkbox(
                        value: constantPvd.ecPhUpdated[selectedSite]['setting'][i]['active'],
                        onChanged: (value){
                          constantPvd.ecPhFunctionality(['activateEcPh',selectedSite,i,value]);
                        },
                      )
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)
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
                      controlCycle(context, constantPvd, overAllPvd, selectedSite, i)
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('delta',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        child: TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[selectedSite]['setting'][i]['delta']}', constantPvd: constantPvd, purpose: 'ecPhDelta/$selectedSite/setting/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],),
                      ),
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('Fine tunning',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        child: TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[selectedSite]['setting'][i]['fineTunning']}', constantPvd: constantPvd, purpose: 'ecPhFineTunning/$selectedSite/setting/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
                      ),
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('Coarse tunning',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        child: TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[selectedSite]['setting'][i]['coarseTunning']}', constantPvd: constantPvd, purpose: 'ecPhCoarseTunning/$selectedSite/setting/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
                      ),
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('Deadband',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                          height: 60,
                          child: TextFieldForConstant(index: -1, initialValue: '${constantPvd.ecPhUpdated[selectedSite]['setting'][i]['deadBand']}', constantPvd: constantPvd, purpose: 'ecPhDeadBand/$selectedSite/setting/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
                      ),
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('Integ',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      integ(context, constantPvd, overAllPvd, selectedSite, i)
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('sensor or avg',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.ecPhUpdated[selectedSite]['setting'][i]['senseOrAvg'],
                        underline: Container(),
                        items: (constantPvd.ecPhUpdated[selectedSite]['setting'][i]['sensorList'] as List<dynamic>).map((dynamic items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Container(
                                child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          constantPvd.ecPhFunctionality(['ecPhSenseOrAvg',selectedSite,'setting',i,value!]);
                        },
                      ),
                    ],
                  ),
                ),
                for(var i = 0;i < constantPvd.ecPhUpdated[selectedSite]['setting'].length;i++)

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
                          Text('Avg filt speed',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      DropdownButton(
                        focusColor: Colors.transparent,
                        // style: ioText,
                        value: constantPvd.ecPhUpdated[selectedSite]['setting'][i]['avgFilterSpeed'],
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
                          constantPvd.ecPhFunctionality(['ecPhAvgFiltSpeed',selectedSite,'setting',i,value!]);
                        },
                      ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../state_management/config_maker_provider.dart';



class CentralDosingTable extends StatefulWidget {
  const CentralDosingTable({super.key});

  @override
  State<CentralDosingTable> createState() => _CentralDosingTableState();
}

class _CentralDosingTableState extends State<CentralDosingTable> {

  bool selectButton = false;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        margin: (MediaQuery.of(context).orientation == Orientation.portrait ||  kIsWeb ) ? null : EdgeInsets.only(right: 70),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(configPvd.c_dosingSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.c_dosingSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.centralDosingFunctionality(['c_dosingSelection',value]);
                            });
                          }
                      ),
                      Text('Select')
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            configPvd.centralDosingFunctionality(['c_dosingSelectAll',false]);
                            configPvd.centralDosingFunctionality(['c_dosingSelection',false]);
                            configPvd.cancelSelection();
                          }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.c_dosingSelection == false)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.centralDosingFunctionality(['addCentralDosing']);
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500), // Adjust the duration as needed
                        curve: Curves.easeInOut, // Adjust the curve as needed
                      );
                    },
                    icon: Icon(Icons.add),
                  ),
                if(configPvd.c_dosingSelection == false)
                  IconButton(
                    splashColor: Colors.grey,
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Add batch',style: TextStyle(color: Colors.black),),
                          content: AddBatchCD(),
                        );
                      });
                    },
                    icon: Icon(Icons.batch_prediction),
                  ),

                if(configPvd.c_dosingSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.centralDosingFunctionality(['c_dosingSelection',false]);
                      configPvd.centralDosingFunctionality(['deleteCentralDosing']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                if(configPvd.c_dosingSelection == true)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.c_dosingSelectAll,
                          onChanged: (value){
                            setState(() {
                              configPvd.centralDosingFunctionality(['c_dosingSelectAll',value]);
                            });
                          }
                      ),
                      Text('All')
                    ],
                  ),

              ],
            ),
            SizedBox(height: 5,),
            Container(
              width: width-20,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('#',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalCentralDosing})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Injector',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalInjector})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Dosing',style: TextStyle(color: Colors.white),),
                          Text('Meter(${configPvd.totalDosingMeter})',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Booster',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalBooster})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                  itemCount: configPvd.centralDosing.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor,
                        border: Border(bottom: BorderSide(width: 0.5,color: Colors.white))
                      ),
                      margin: index == configPvd.centralDosing.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      width: width-20,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(configPvd.c_dosingSelection == true || configPvd.c_dosingSelectAll == true)
                                      Checkbox(
                                        fillColor: MaterialStateProperty.all(Colors.white),
                                          checkColor: myTheme.primaryColor,
                                          value: configPvd.centralDosing[index][configPvd.centralDosing[index].length - 1][0] == 'select' ? true : false,
                                          onChanged: (value){
                                            configPvd.centralDosingFunctionality(['selectCentralDosing',index]);
                                          }),
                                    Text('${index + 1}',style: TextStyle(color: Colors.white),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.centralDosing[index].length - 1;i ++)
                                      Container(
                                          child: Center(child: Text('${configPvd.centralDosing[index][i][0]}')),
                                        height: 60,
                                      )
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.centralDosing[index].length - 1;i ++)
                                      Container(
                                        height: 60,
                                        child: (configPvd.totalDosingMeter == 0 && configPvd.centralDosing[index][i][1] == false) ?
                                        Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                        Checkbox(
                                            value: configPvd.centralDosing[index][i][1],
                                            onChanged: (value){
                                              configPvd.centralDosingFunctionality(['editDosingMeter',index,i,value]);
                                            }),
                                      ),
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.centralDosing[index].length - 1;i ++)
                                      Container(
                                        height: 60,
                                        child: (configPvd.totalBooster == 0 && configPvd.centralDosing[index][i][2] == false) ?
                                        Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                        Checkbox(
                                            value: configPvd.centralDosing[index][i][2],
                                            onChanged: (value){
                                              configPvd.centralDosingFunctionality(['editBooster',index,i,value]);
                                            }),
                                      ),
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }
}

class AddBatchCD extends StatefulWidget {
  const AddBatchCD({super.key});

  @override
  State<AddBatchCD> createState() => _AddBatchCDState();
}

class _AddBatchCDState extends State<AddBatchCD> {
  int totalSite = 0;
  String injector = '-';
  bool d_meter = false;
  bool d_meter_value = false;
  bool booster = false;
  bool booster_value = false;
  FocusNode myFocus = FocusNode();
  late TextEditingController myController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myController = TextEditingController();
    if(myFocus.hasFocus == false){
      if(myController.text == ''){
        totalSite = 0;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      width: double.infinity,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('No of dosing sites : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    child: TextFormField(
                      focusNode: myFocus,
                      controller: myController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      onFieldSubmitted: (value){
                        if(value == ''){
                          myController.text = '1';
                        }
                      },
                      maxLength: 2,
                      onChanged: (value){
                        setState(() {
                          injector = '-';
                          booster_value = false;
                          d_meter_value = false;
                        });
                        if(value == '0' ){
                          myController.text = '1';
                        }
                        var total = configPvd.totalCentralDosing - int.parse(myController.text == '' ? '0' : myController.text);
                        int value1 = 0;
                        if(total < 0){
                          value1 = int.parse(myController.text) + total;
                          myController.text = value1.toString();
                        }
                        setState(() {
                          totalSite = int.parse(myController.text == '' ? '0' : myController.text);
                        });
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                  ),
                  Text('(${configPvd.totalCentralDosing})')
                ],
              ),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('No of injector per site : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              DropdownButton(
                value: injector,
                underline: Container(),
                items: getList(configPvd).map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Container(
                        child: Text(items,style: TextStyle(fontSize: 12),)
                    ),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    injector = newValue!;
                  });
                },
              )

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dosing meter per injector : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              give_D_meter(configPvd) == false ?
              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
              Checkbox(
                  value: d_meter_value,
                  onChanged: (value){
                    setState(() {
                      d_meter_value = value!;
                    });
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booster per injector : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              give_booster(configPvd) == false ?
              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
              Checkbox(
                  value: booster_value,
                  onChanged: (value){
                    setState(() {
                      booster_value = value!;
                    });
                  }),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: (){
                  Navigator.pop(context);
                  setState(() {
                    totalSite = 0;
                    injector = '-';
                    d_meter = false;
                    d_meter_value = false;
                    booster = false;
                    booster_value = false;
                  });
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.white),)
              ),
              ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                  onPressed: (){
                    configPvd.centralDosingFunctionality(['addBatch_CD',totalSite,int.parse(injector),d_meter_value,booster_value]);
                    setState(() {
                      totalSite = 0;
                      injector = '-';
                      d_meter = false;
                      d_meter_value = false;
                      booster = false;
                      booster_value = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Add',style: TextStyle(color: Colors.white))
              ),
            ],
          )
        ],
      ),
    );
  }
  List<String> getList(ConfigMakerProvider configPvd) {
    List<String> myList = ['-'];
    if(totalSite != 0){
      for(var i = 0;i < 6;i++){
        if(totalSite * (i+1) <= configPvd.totalInjector){
          myList.add('${i+1}');
        }
      }
    }
    return myList;
  }
  bool give_D_meter(ConfigMakerProvider configPvd){
    if(injector != '-'){
      if(configPvd.totalDosingMeter - (totalSite * int.parse(injector))  < 0){
        setState(() {
          d_meter = false;
        });
      }else{
        setState(() {
          d_meter = true;
        });
      }
    }

    return d_meter;
  }
  bool give_booster(ConfigMakerProvider configPvd){
    if(injector != '-'){
      if(configPvd.totalBooster - (totalSite * int.parse(injector))  < 0){
        setState(() {
          booster = false;
        });
      }else{
        setState(() {
          booster = true;
        });
      }
    }

    return booster;
  }
}


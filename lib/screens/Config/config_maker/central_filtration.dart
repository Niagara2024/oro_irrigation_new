import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_config.dart';


class CentralFiltrationTable extends StatefulWidget {
  const CentralFiltrationTable({super.key});

  @override
  State<CentralFiltrationTable> createState() => _CentralFiltrationTableState();
}

class _CentralFiltrationTableState extends State<CentralFiltrationTable> {
  bool selectButton = false;
  ScrollController scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text = '1';
  }

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
                if(configPvd.centralFiltrationSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.centralFiltrationSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',value]);
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
                            configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',false]);
                            configPvd.centralFiltrationFunctionality(['centralFiltrationSelectAll',false]);
                            configPvd.cancelSelection();
                          }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.centralFiltrationSelection == false)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.centralFiltrationFunctionality(['addCentralFiltration']);
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500), // Adjust the duration as needed
                        curve: Curves.easeInOut, // Adjust the curve as needed
                      );
                    },
                    icon: Icon(Icons.add),
                  ),
                if(configPvd.centralFiltrationSelection == false)
                  IconButton(
                    splashColor: Colors.grey,
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){

                    },
                    icon: Icon(Icons.batch_prediction),
                  ),

                if(configPvd.centralFiltrationSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',false]);
                      configPvd.centralFiltrationFunctionality(['deleteCentralFiltration']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                if(configPvd.centralFiltrationSelection == true)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.centralFiltrationSelectAll,
                          onChanged: (value){
                            setState(() {
                              configPvd.centralFiltrationFunctionality(['centralFiltrationSelectAll',value]);
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
                  Container(
                    width: 60,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('#',style: TextStyle(color: Colors.white),),
                        Text('(${configPvd.totalCentralFiltration})',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Filters',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalFilter})',style: TextStyle(color: Colors.white),),
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
                          Text('D.stream',style: TextStyle(color: Colors.white),),
                          Text('Valve(${configPvd.total_D_s_valve})',style: TextStyle(color: Colors.white)),
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
                          Text('P_Sense',style: TextStyle(color: Colors.white),),
                          Text('in(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
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
                          Text('P_Sense',style: TextStyle(color: Colors.white),),
                          Text('out(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
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
                  itemCount: configPvd.centralFiltration.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: index == configPvd.centralFiltration.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                      width: width-20,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(configPvd.centralFiltrationSelection == true || configPvd.centralFiltrationSelectAll == true)
                                    Checkbox(
                                        value: configPvd.centralFiltration[index][configPvd.centralFiltration[index].length - 1][0] == 'select' ? true : false,
                                        onChanged: (value){
                                          configPvd.centralFiltrationFunctionality(['selectCentralFiltration',index,value]);
                                        }),
                                  Text('${index + 1}'),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                width: double.infinity,
                                height: 60,
                                child: Center(
                                  child: TextFieldForConfig(index: index, initialValue: configPvd.centralFiltration[index][0],  purpose: 'centralFiltrationFunctionality', config: configPvd,),
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_D_s_valve == 0 && configPvd.centralFiltration[index][1] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.centralFiltration[index][1],
                                  onChanged: (value){
                                    configPvd.centralFiltrationFunctionality(['editDownStreamValve',index,value]);
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_p_sensor == 0 && configPvd.centralFiltration[index][2] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.centralFiltration[index][2],
                                  onChanged: (value){
                                  configPvd.centralFiltrationFunctionality(['editPressureSensor',index,value]);
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_p_sensor == 0 && configPvd.centralFiltration[index][3] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.centralFiltration[index][3],
                                  onChanged: (value){
                                    configPvd.centralFiltrationFunctionality(['editPressureSensor_out',index,value]);
                                  }),
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

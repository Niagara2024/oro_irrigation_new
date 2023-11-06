import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../constants/theme.dart';



class LocalDosingTable extends StatefulWidget {
  const LocalDosingTable({super.key});

  @override
  State<LocalDosingTable> createState() => _LocalDosingTableState();
}

class _LocalDosingTableState extends State<LocalDosingTable> {
  ScrollController scrollController = ScrollController();
  bool selectButton = false;
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
                if(configPvd.l_dosingSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.l_dosingSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.localDosingFunctionality(['edit_l_DosingSelection',value]);
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
                            configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
                            configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',false]);
                            configPvd.cancelSelection();
                          }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.l_dosingSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orange)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
                      configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
                      configPvd.localDosingFunctionality(['deleteLocalDosing']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                // if(configPvd.l_dosingSelectAll == true)
                //   Row(
                //     children: [
                //       Checkbox(
                //           value: configPvd.l_dosingSelectAll,
                //           onChanged: (value){
                //             setState(() {
                //               configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',value]);
                //             });
                //           }
                //       ),
                //       Text('All')
                //     ],
                //   ),

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
                          Text('Line',style: TextStyle(color: Colors.white),),
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
                  itemCount: configPvd.localDosing.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor,
                          border: Border(bottom: BorderSide(width: 0.5,color: Colors.white))
                      ),
                      margin: index == configPvd.localDosing.length - 1 ? EdgeInsets.only(bottom: 60) : null,

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
                                    if(configPvd.l_dosingSelection == true || configPvd.l_dosingSelectAll == true)
                                      Checkbox(
                                          fillColor: MaterialStateProperty.all(Colors.white),
                                          checkColor: myTheme.primaryColor,
                                          value: configPvd.localDosing[index][configPvd.localDosing[index].length - 1][0] == 'select' ? true : false,
                                          onChanged: (value){
                                            configPvd.localDosingFunctionality(['selectLocalDosing',index]);
                                          }),
                                    Text('${configPvd.localDosing[index][configPvd.localDosing[index].length - 1][1]}',style: TextStyle(color: Colors.white),),
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
                                    for(var i = 0; i< configPvd.localDosing[index].length - 1;i ++)
                                      Container(
                                        child: Center(child: Text('${configPvd.localDosing[index][i][0]}')),
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
                                    for(var i = 0; i< configPvd.localDosing[index].length - 1;i ++)
                                      Container(
                                        height: 60,
                                        child: (configPvd.totalDosingMeter == 0 && configPvd.localDosing[index][i][1] == false) ?
                                        Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                        Checkbox(
                                            value: configPvd.localDosing[index][i][1],
                                            onChanged: (value){
                                              configPvd.localDosingFunctionality(['editDosingMeter',index,i,value]);
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
                                    for(var i = 0; i< configPvd.localDosing[index].length - 1;i ++)
                                      Container(
                                        height: 60,
                                        child: (configPvd.totalBooster == 0 && configPvd.localDosing[index][i][2] == false) ?
                                        Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                        Checkbox(
                                            value: configPvd.localDosing[index][i][2],
                                            onChanged: (value){
                                              configPvd.localDosingFunctionality(['editBoosterPump',index,i,value]);
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
  // Widget build(BuildContext context) {
  //   var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
  //   return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
  //     var width = constraint.maxWidth;
  //     return Container(
  //       margin: MediaQuery.of(context).orientation == Orientation.portrait ? null : EdgeInsets.only(right: 70),
  //       width: double.infinity,
  //       height: double.infinity,
  //       padding: EdgeInsets.all(10.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               if(configPvd.l_dosingSelection == false)
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                         value: configPvd.l_dosingSelection,
  //                         onChanged: (value){
  //                           setState(() {
  //                             configPvd.localDosingFunctionality(['edit_l_DosingSelection',value]);
  //                           });
  //                         }
  //                     ),
  //                     Text('Select')
  //                   ],
  //                 )
  //               else
  //                 Row(
  //                   children: [
  //                     IconButton(
  //                         onPressed: (){
  //                           configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
  //                           configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',false]);
  //                           configPvd.cancelSelection();
  //                         }, icon: Icon(Icons.cancel_outlined)),
  //                     Text('${configPvd.selection}')
  //                   ],
  //                 ),
  //               if(configPvd.l_dosingSelection == true)
  //                 IconButton(
  //                   color: Colors.black,
  //                   style: ButtonStyle(
  //                       backgroundColor: MaterialStateProperty.all(liteYellow)
  //                   ),
  //                   highlightColor: myTheme.primaryColor,
  //                   onPressed: (){
  //                     configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
  //                     configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
  //                     configPvd.localDosingFunctionality(['deleteLocalDosing']);
  //                     configPvd.cancelSelection();
  //                   },
  //                   icon: Icon(Icons.delete_forever),
  //                 ),
  //               if(configPvd.l_dosingSelectAll == true)
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                         value: configPvd.l_dosingSelectAll,
  //                         onChanged: (value){
  //                           setState(() {
  //                             configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',value]);
  //                           });
  //                         }
  //                     ),
  //                     Text('All')
  //                   ],
  //                 ),
  //
  //             ],
  //           ),
  //           Container(
  //             width: width-20,
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     width: double.infinity,
  //                     height: 60,
  //                     child: Center(
  //                       child: Text('#',style: TextStyle(color: Colors.white),),
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: myTheme.primaryColor
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     width: double.infinity,
  //                     height: 60,
  //                     child: Column(
  //                       children: [
  //                         Text('Injector',style: TextStyle(color: Colors.white),),
  //                         Text('(${configPvd.totalInjector})',style: TextStyle(color: Colors.white),),
  //                       ],
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: myTheme.primaryColor
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     width: double.infinity,
  //                     height: 60,
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text('Dosing',style: TextStyle(color: Colors.white),),
  //                         Text('Meter(${configPvd.totalDosingMeter})',style: TextStyle(color: Colors.white),),
  //                       ],
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: myTheme.primaryColor
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     width: double.infinity,
  //                     height: 60,
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text('Booster',style: TextStyle(color: Colors.white),),
  //                         Text('Pump(${configPvd.totalBooster})',style: TextStyle(color: Colors.white),),
  //                       ],
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: myTheme.primaryColor
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               controller: scrollController,
  //                 itemCount: configPvd.localDosing.length,
  //                 itemBuilder: (BuildContext context, int index){
  //                   return Container(
  //                     margin: index == configPvd.localDosing.length - 1 ? EdgeInsets.only(bottom: 60) : null,
  //                     color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
  //                     width: width-20,
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: Container(
  //                             width: double.infinity,
  //                             height: 60,
  //                             child: Center(
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   if(configPvd.l_dosingSelection == true)
  //                                     Checkbox(
  //                                         value: configPvd.localDosing[index][4] == 'select' ? true : false,
  //                                         onChanged: (value){
  //                                           configPvd.localDosingFunctionality(['selectLocalDosing',index,value]);
  //                                         }),
  //                                   Text('${configPvd.localDosing[index][0]}'),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             width: double.infinity,
  //                             height: 60,
  //                             child: Center(
  //                               child: Text('${configPvd.localDosing[index][1]}'),
  //                             ),
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             width: double.infinity,
  //                             height: 60,
  //                             child: Checkbox(
  //                                 value: configPvd.localDosing[index][2],
  //                                 onChanged: (value){
  //                                   configPvd.localDosingFunctionality(['editDosingMeter',index,value]);
  //                                 }),
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             width: double.infinity,
  //                             height: 60,
  //                             child: Checkbox(
  //                                 value: configPvd.localDosing[index][3],
  //                                 onChanged: (value){
  //                                   configPvd.localDosingFunctionality(['editBoosterPump',index,value]);
  //                                 }),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }
}

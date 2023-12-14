import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/drop_down_button.dart';

class MappingOfInputsTable extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  MappingOfInputsTable({super.key,required this.configPvd});

  @override
  State<MappingOfInputsTable> createState() => _MappingOfInputsTableState();
}

class _MappingOfInputsTableState extends State<MappingOfInputsTable> {
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context,constrainst){
      var width = constrainst.maxWidth;
      return Container(
        color: Color(0xFFF3F3F3),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 5,right: 5,top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Obj',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                            left: BorderSide(width: 1),
                          )
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
                          Text('RTU',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('R.no',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I/P',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I-Type',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 5,right: 5),
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: getIrrigationLine(irrigationLine(configPvd),configPvd),
                      ),
                      Column(
                        children: getCentralDosing(centralDosing(configPvd),configPvd),
                      ),
                      Column(
                        children: getCentralFiltration(centralFiltration(configPvd),configPvd),
                      ),
                      Column(
                        children: getSourcePump(sourcePump(configPvd),configPvd),
                      ),
                      Column(
                        children: getIrrigationPump(irrigationPump(configPvd),configPvd),
                      ),
                      Column(
                        children: getAnalogSensor(analogSensor(configPvd),configPvd),
                      ),
                      Column(
                        children: getContact(contact(configPvd),configPvd),
                      ),
                      SizedBox(height: 150,),
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
  List<Widget> getIrrigationLine(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: configPvd.irrigationLines[myList[i]['map'][j]['line']]['myRTU_list'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNo(i,configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getCentralDosing(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: ['-','ORO RTU','ORO Smart RTU','ORO Switch'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getCentralFiltration(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
        for(var j = 0;j < myList[i]['map'].length;j++){
          widgetList.add(
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1)),
                  color: j % 2 == 0 ? Colors.white : Colors.white70,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: ['-','ORO RTU','ORO Smart RTU','ORO Switch'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                          ),
                        )
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                          ),
                        )
                    ),
                  ],
                ),
              )
          );
        }
      }

    }
    return widgetList;
  }
  List<Widget> getSourcePump(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                      )
                  ),
                  if(myList[i]['map'][j]['connection'] == 'waterMeter')
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: myList[i]['map'][j]['oroPump'] == false ? ['-','ORO RTU','ORO Smart RTU','ORO Switch'] : ['-','ORO PUMP'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    )
                  else
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: Text('${myList[i]['map'][j]['rtu']}',style: TextStyle(fontSize: 11),),
                          ),
                        )
                    ),
                  if(myList[i]['map'][j]['connection'] == 'waterMeter')
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    )
                  else
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: Text('${myList[i]['map'][j]['rfNo']}',style: TextStyle(fontSize: 11),),
                          ),
                        )
                    ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: myList[i]['map'][j]['connection'] == 'waterMeter'
                              ?
                          getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count'])
                              :
                          myList[i]['map'][j]['connection'].contains('c')
                              ?
                          getInPutForct(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['pump'],myList[i]['map'][j]['connection'])
                              :
                          getInPutForSp(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['pump'],myList[i]['map'][j]['connection']),
                              pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getIrrigationPump(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ${myList[i]['map'][j]['count'] == -1 ? '' : myList[i]['map'][j]['count'] + 1}')),
                      )
                  ),
                  if(myList[i]['map'][j]['connection'] == 'waterMeter')
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                              child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: myList[i]['map'][j]['oroPump'] == false ? ['-','ORO RTU','ORO Smart RTU','ORO Switch'] : ['-','ORO PUMP'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                          ),
                        )
                    )
                  else
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: Text('${myList[i]['map'][j]['rtu']}',style: TextStyle(fontSize: 11),),
                          ),
                        )
                    ),
                  if(myList[i]['map'][j]['connection'] == 'waterMeter')
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                          ),
                        )
                    )
                  else
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                          ),
                          height: 40,
                          child: Center(
                            child: Text('${myList[i]['map'][j]['rfNo']}',style: TextStyle(fontSize: 11),),
                          ),
                        )
                    ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: myList[i]['map'][j]['connection'] == 'waterMeter'
                              ?
                          getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count'])
                              :
                          myList[i]['map'][j]['connection'].contains('c')
                              ?
                          getInPutForct(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['pump'],myList[i]['map'][j]['connection'])
                              :
                          getInPutForIp(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['pump'],myList[i]['map'][j]['connection']),
                              pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getAnalogSensor(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: ['-','ORO RTU','ORO Smart RTU','ORO Switch'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<Widget> getContact(List<Map<String,dynamic>> myList,ConfigMakerProvider configPvd){
    List<Widget> widgetList = [];
    for(var i = 0;i < myList.length;i++){
      if(myList[i]['map'].length != 0){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text('${myList[i]['name']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
              ),
            )
        );
      }
      for(var j = 0;j < myList[i]['map'].length;j++){
        widgetList.add(
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1)),
                color: j % 2 == 0 ? Colors.white : Colors.white70,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(child: Text('${myList[i]['map'][j]['name']} ')),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                            child: MyDropDown(initialValue: '${myList[i]['map'][j]['rtu']}', itemList: ['-','ORO RTU','ORO Smart RTU','ORO Switch'], pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rtu', index: -1)
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['rfNo']}', itemList: getrefNoForOthers(configPvd,'${myList[i]['map'][j]['rtu']}'), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/rfNo', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input']}', itemList: getInPut(configPvd,'${myList[i]['map'][j]['rtu']}','${myList[i]['map'][j]['rfNo']}','${myList[i]['map'][j]['input']}',myList[i]['map'][j]['count']), pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input', index: -1),
                        ),
                      )
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(right: BorderSide(width: 1),top: BorderSide(width: j == 0 ? 1 : 0))
                        ),
                        height: 40,
                        child: Center(
                          child: MyDropDown(initialValue: '${myList[i]['map'][j]['input_type']}', itemList: configPvd.i_o_types, pvdName: '${myList[i]['map'][j]['type']}/${i}/${myList[i]['map'][j]['connection']}/${myList[i]['map'][j]['count']}/input_type', index: -1),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    }
    return widgetList;
  }
  List<String> getrefNoForOthers(ConfigMakerProvider configPvd,String title){
    List<String> myList = ['-'];
    if(title == 'ORO Smart RTU'){
      var list = configPvd.oSrtu;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO Switch'){
      var list = configPvd.oSwitch;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO Sense'){
      var list = configPvd.oSense;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO RTU'){
      var list = configPvd.oRtu;
      for(var i in list){
        myList.add('$i');
      }
    }else if(title == 'ORO PUMP'){
      var list = configPvd.oPump;
      for(var i in list){
        myList.add('$i');
      }
    }
    return myList;
  }
  List<String> getrefNo(int line,ConfigMakerProvider configPvd,String title){
    print('line : $line');
    print(title);
    List<String> myList = ['-'];
    if(title == 'ORO Smart RTU'){
      for(var i in configPvd.irrigationLines[line]['myOroSmartRtu']){
        myList.add('${i}');
      }
    }else if(title == 'ORO Switch'){
      for(var i in configPvd.irrigationLines[line]['myOROswitch']){
        myList.add('${i}');
      }
    }else if(title == 'ORO Sense'){
      for(var i in configPvd.irrigationLines[line]['myOROsense']){
        myList.add('${i}');
      }
    }else if(title == 'ORO RTU'){
      for(var i in configPvd.irrigationLines[line]['myRTU']){
        myList.add('${i}');
      }
    }
    print('myList : ${myList}');
    return myList;
  }
  List<String> filterInPut(List<dynamic> data,String rtu,String rf,String input){
    List<String> list = [];
    for(var i in data){
      print('data : $data');
      print(rtu);
      print(rf);
      print(input);
      if((i['rtu'] == rtu) && (i['rfNo'] == rf)){
        if(i['input'] != '-' && input != i['input']){
          list.add(i['input']);
        }
      }
    }
    return list;
  }

  List<String> getInPutForSp(ConfigMakerProvider configPvd,String rtu, String rf, String input,int index ,String connection) {
    print('connection : ${connection}');
    List<String> myList = ['-','1','2','3','4'];
    if(configPvd.sourcePumpUpdated[index]['TopTankHigh'] != null){
      if(configPvd.sourcePumpUpdated[index]['TopTankHigh'].isNotEmpty){
        if(configPvd.sourcePumpUpdated[index]['TopTankHigh']['input'] != '-' && configPvd.sourcePumpUpdated[index]['TopTankHigh']['input'] != input){
          if(rtu != 'TopTankHigh'){
            myList.remove(configPvd.sourcePumpUpdated[index]['TopTankHigh']['input']);
          }
        }
      }
    }
    if(configPvd.sourcePumpUpdated[index]['TopTankLow'] != null){
      if(configPvd.sourcePumpUpdated[index]['TopTankLow'].isNotEmpty){
        if(configPvd.sourcePumpUpdated[index]['TopTankLow']['input'] != '-' && configPvd.sourcePumpUpdated[index]['TopTankLow']['input'] != input){
          if(rtu != 'TopTankLow'){
            myList.remove(configPvd.sourcePumpUpdated[index]['TopTankLow']['input']);
          }
        }
      }
    }
    if(configPvd.sourcePumpUpdated[index]['SumpTankHigh'] != null){
      if(configPvd.sourcePumpUpdated[index]['SumpTankHigh'].isNotEmpty){
        if(configPvd.sourcePumpUpdated[index]['SumpTankHigh']['input'] != '-' && configPvd.sourcePumpUpdated[index]['SumpTankHigh']['input'] != input){
          if(rtu != 'SumpTankHigh'){
            myList.remove(configPvd.sourcePumpUpdated[index]['SumpTankHigh']['input']);
          }
        }
      }
    }
    if(configPvd.sourcePumpUpdated[index]['SumpTankLow'] != null){
      if(configPvd.sourcePumpUpdated[index]['SumpTankLow'].isNotEmpty){
        if(configPvd.sourcePumpUpdated[index]['SumpTankLow']['input'] != '-' && configPvd.sourcePumpUpdated[index]['SumpTankLow']['input'] != input){
          if(rtu != 'SumpTankLow'){
            myList.remove(configPvd.sourcePumpUpdated[index]['SumpTankLow']['input']);
          }
        }
      }
    }
    print('for pump : ${myList}');
    return rf == '-' ? ['-'] : myList;
  }
  List<String> getInPutForIp(ConfigMakerProvider configPvd,String rtu, String rf, String input,int index ,String connection) {
    print('connection : ${connection}');
    List<String> myList = ['-','1','2','3','4'];
    if(configPvd.irrigationPumpUpdated[index]['TopTankHigh'] != null){
      if(configPvd.irrigationPumpUpdated[index]['TopTankHigh'].isNotEmpty){
        if(configPvd.irrigationPumpUpdated[index]['TopTankHigh']['input'] != '-' && configPvd.irrigationPumpUpdated[index]['TopTankHigh']['input'] != input){
          if(rtu != 'TopTankHigh'){
            myList.remove(configPvd.irrigationPumpUpdated[index]['TopTankHigh']['input']);
          }
        }
      }
    }
    if(configPvd.irrigationPumpUpdated[index]['TopTankLow'] != null){
      if(configPvd.irrigationPumpUpdated[index]['TopTankLow'].isNotEmpty){
        if(configPvd.irrigationPumpUpdated[index]['TopTankLow']['input'] != '-' && configPvd.irrigationPumpUpdated[index]['TopTankLow']['input'] != input){
          if(rtu != 'TopTankLow'){
            myList.remove(configPvd.irrigationPumpUpdated[index]['TopTankLow']['input']);
          }
        }
      }
    }
    if(configPvd.irrigationPumpUpdated[index]['SumpTankHigh'] != null){
      if(configPvd.irrigationPumpUpdated[index]['SumpTankHigh'].isNotEmpty){
        if(configPvd.irrigationPumpUpdated[index]['SumpTankHigh']['input'] != '-' && configPvd.irrigationPumpUpdated[index]['SumpTankHigh']['input'] != input){
          if(rtu != 'SumpTankHigh'){
            myList.remove(configPvd.irrigationPumpUpdated[index]['SumpTankHigh']['input']);
          }
        }
      }
    }
    if(configPvd.irrigationPumpUpdated[index]['SumpTankLow'] != null){
      if(configPvd.irrigationPumpUpdated[index]['SumpTankLow'].isNotEmpty){
        if(configPvd.irrigationPumpUpdated[index]['SumpTankLow']['input'] != '-' && configPvd.irrigationPumpUpdated[index]['SumpTankLow']['input'] != input){
          if(rtu != 'SumpTankLow'){
            myList.remove(configPvd.irrigationPumpUpdated[index]['SumpTankLow']['input']);
          }
        }
      }
    }
    print('for pump : ${myList}');
    return rf == '-' ? ['-'] : myList;
  }
  List<String> getInPutForct(ConfigMakerProvider configPvd,String rtu, String rf, String input,int index ,String connection) {
    print('connection : ${connection}');
    List<String> myList = ['-','1','2','3',];
    for(var i in configPvd.sourcePumpUpdated){
      if(i['c1'] != null){
        if(i['c1'].isNotEmpty){
          if(i['c1']['rfNo'] != '-' && i['c1']['input'] != '-'){
            if(rf == i['c1']['rfNo']){
              if(input != i['c1']['input']){
                myList.remove(i['c1']['input']);
              }
            }
          }
        }
      }
      if(i['c2'] != null){
        if(i['c2'].isNotEmpty){
          if(i['c2']['rfNo'] != '-' && i['c2']['input'] != '-'){
            if(rf == i['c2']['rfNo']){
              if(input != i['c2']['input']){
                myList.remove(i['c2']['input']);
              }
            }
          }
        }
      }
      if(i['c3'] != null){
        if(i['c3'].isNotEmpty){
          if(i['c3']['rfNo'] != '-' && i['c3']['input'] != '-'){
            if(rf == i['c3']['rfNo']){
              if(input != i['c3']['input']){
                myList.remove(i['c3']['input']);
              }
            }
          }
        }
      }
    }
    for(var i in configPvd.irrigationPumpUpdated){
      if(i['c1'] != null){
        if(i['c1'].isNotEmpty){
          if(i['c1']['rfNo'] != '-' && i['c1']['input'] != '-'){
            if(rf == i['c1']['rfNo']){
              if(input != i['c1']['input']){
                myList.remove(i['c1']['input']);
              }
            }
          }
        }
      }
      if(i['c2'] != null){
        if(i['c2'].isNotEmpty){
          if(i['c2']['rfNo'] != '-' && i['c2']['input'] != '-'){
            if(rf == i['c2']['rfNo']){
              if(input != i['c2']['input']){
                myList.remove(i['c2']['input']);
              }
            }
          }
        }
      }
      if(i['c3'] != null){
        if(i['c3'].isNotEmpty){
          if(i['c3']['rfNo'] != '-' && i['c3']['input'] != '-'){
            if(rf == i['c3']['rfNo']){
              if(input != i['c3']['input']){
                myList.remove(i['c3']['input']);
              }
            }
          }
        }
      }
    }
    return rf == '-' ? ['-'] : myList;
  }
  List<String> getInPut(ConfigMakerProvider configPvd,String rtu, String rf, String input,int index) {
    print('getInPut function');
    List<String> myList = [];
    List<String> filterList = [];
    if(rtu == 'ORO RTU'){
      for(var i = 0;i < 8;i++){
        myList.add('${i+1}');
      }
    }else if(rtu == 'ORO PUMP'){
      for(var i = 0;i < 4;i++){
        myList.add('${i+1}');
      }
    }else if(rtu == 'ORO Switch'){
      for(var i = 0;i < 4;i++){
        myList.add('${i+1}');
      }
    }else if(rtu == 'ORO Sense'){
      for(var i = 0;i < 4;i++){
        myList.add('${i+1}');
      }
    }else if(rtu == 'ORO Smart RTU'){
      for(var i = 0;i < 16;i++){
        myList.add('${i+1}');
      }
    }
    if(rtu != '-' && rf != '-'){
      for(var i in configPvd.sourcePumpUpdated){
        if(i['waterMeter'].isNotEmpty){
          filterList.addAll(filterInPut([i['waterMeter']],rtu,rf,input));
        }
      }
      for(var i in configPvd.irrigationPumpUpdated){
        if(i['waterMeter'].isNotEmpty){
          filterList.addAll(filterInPut([i['waterMeter']],rtu,rf,input));
        }
      }
      for(var i in configPvd.centralFiltrationUpdated){
        filterList.addAll(filterInPut([i['pressureIn']],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureOut']],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureSwitch']],rtu,rf,input));
        filterList.addAll(filterInPut([i['diffPressureSensor']],rtu,rf,input));
      }

      for(var i in configPvd.centralDosingUpdated){
        filterList.addAll(filterInPut(i['ecConnection'],rtu,rf,input));
        filterList.addAll(filterInPut(i['phConnection'],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureSwitch']],rtu,rf,input));
        for(var j in i['injector']){
          if(j['dosingMeter'].isNotEmpty){
            filterList.addAll(filterInPut([j['dosingMeter']],rtu,rf,input));
          }
        }
      }
      for(var i in configPvd.irrigationLines){
        filterList.addAll(filterInPut(i['moistureSensorConnection'],rtu,rf,input));
        filterList.addAll(filterInPut(i['levelSensorConnection'],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureIn']],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureOut']],rtu,rf,input));
      }
      filterList.addAll(filterInPut(configPvd.totalAnalogSensor,rtu,rf,input));
      filterList.addAll(filterInPut(configPvd.totalContact,rtu,rf,input));
      for(var i in configPvd.localDosingUpdated){
        filterList.addAll(filterInPut(i['ecConnection'],rtu,rf,input));
        filterList.addAll(filterInPut(i['phConnection'],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureSwitch']],rtu,rf,input));
        for(var j in i['injector']){
          if(j['dosingMeter'].isNotEmpty){
            filterList.addAll(filterInPut([j['dosingMeter']],rtu,rf,input));
          }
        }
      }
      for(var i in configPvd.localFiltrationUpdated){
        filterList.addAll(filterInPut([i['pressureIn']],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureOut']],rtu,rf,input));
        filterList.addAll(filterInPut([i['pressureSwitch']],rtu,rf,input));
        filterList.addAll(filterInPut([i['diffPressureSensor']],rtu,rf,input));

      }
    }
    print('filter : ${filterList}');
    for(var i in filterList){
      if(myList.contains(i)){
        myList.remove(i);
      }
    }
    myList.insert(0, '-');
    print('muList : ${myList}');
    return myList;
  }
  List<Map<String,dynamic>> irrigationLine(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.irrigationLines.length;i++){
      myList.add(
          {
            'name' : 'Irrigation Line ${i+1}',
            'map' : [],
          }
      );
      for(var moistureSenor = 0;moistureSenor < configPvd.irrigationLines[i]['moistureSensorConnection'].length;moistureSenor++){
        myList[i]['map'].add(
            {
              'name' : 'moisture sensor',
              'type' : 'm_i_line',
              'line' : i,
              'count' : moistureSenor,
              'connection' : 'moistureSensorConnection',
              'sNo' :  configPvd.irrigationLines[i]['moistureSensorConnection'][moistureSenor]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['moistureSensorConnection'][moistureSenor]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['moistureSensorConnection'][moistureSenor]['rfNo'],
              'input' : configPvd.irrigationLines[i]['moistureSensorConnection'][moistureSenor]['input'],
              'input_type' : configPvd.irrigationLines[i]['moistureSensorConnection'][moistureSenor]['input_type'],
            }
        );
      }
      for(var levelSenor = 0;levelSenor < configPvd.irrigationLines[i]['levelSensorConnection'].length;levelSenor++){
        myList[i]['map'].add(
            {
              'name' : 'level sensor',
              'type' : 'm_i_line',
              'line' : i,
              'count' : levelSenor,
              'connection' : 'levelSensorConnection',
              'sNo' :  configPvd.irrigationLines[i]['levelSensorConnection'][levelSenor]['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['levelSensorConnection'][levelSenor]['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['levelSensorConnection'][levelSenor]['rfNo'],
              'input' : configPvd.irrigationLines[i]['levelSensorConnection'][levelSenor]['input'],
              'input_type' : configPvd.irrigationLines[i]['levelSensorConnection'][levelSenor]['input_type'],
            }
        );
      }
      if(configPvd.irrigationLines[i]['pressureIn'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'Press In',
              'type' : 'm_i_line',
              'line' : i,
              'count' : -1,
              'connection' : 'pressureIn',
              'sNo' :  configPvd.irrigationLines[i]['pressureIn']['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['pressureIn']['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['pressureIn']['rfNo'],
              'input' : configPvd.irrigationLines[i]['pressureIn']['input'],
              'input_type' : configPvd.irrigationLines[i]['pressureIn']['input_type'],
            }
        );
      }
      if(configPvd.irrigationLines[i]['pressureOut'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'Press Out',
              'type' : 'm_i_line',
              'line' : i,
              'count' : -1,
              'connection' : 'pressureOut',
              'sNo' :  configPvd.irrigationLines[i]['pressureOut']['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['pressureOut']['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['pressureOut']['rfNo'],
              'input' : configPvd.irrigationLines[i]['pressureOut']['input'],
              'input_type' : configPvd.irrigationLines[i]['pressureOut']['input_type'],
            }
        );
      }
      if(configPvd.irrigationLines[i]['water_meter'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'water meter',
              'type' : 'm_i_line',
              'line' : i,
              'count' : -1,
              'connection' : 'water_meter',
              'sNo' :  configPvd.irrigationLines[i]['water_meter']['sNo'],
              'rtu' :  configPvd.irrigationLines[i]['water_meter']['rtu'],
              'rfNo' : configPvd.irrigationLines[i]['water_meter']['rfNo'],
              'input' : configPvd.irrigationLines[i]['water_meter']['input'],
              'input_type' : configPvd.irrigationLines[i]['water_meter']['input_type'],
            }
        );
      }

      if(configPvd.irrigationLines[i]['Local_dosing_site'] == true){
        localDosing : for(var ld = 0;ld < configPvd.localDosingUpdated.length;ld++){
          if(configPvd.localDosingUpdated[ld]['sNo'] == configPvd.irrigationLines[i]['sNo']){
            for(var ec = 0;ec < configPvd.localDosingUpdated[ld]['ecConnection'].length;ec++){
              myList[i]['map'].add(
                  {
                    'name' : 'Ec sensor',
                    'type' : 'm_i_localDosing',
                    'line' : i,
                    'count' : ec,
                    'connection' : 'ecConnection',
                    'sNo' :  configPvd.localDosingUpdated[ld]['ecConnection'][ec]['sNo'],
                    'rtu' :  configPvd.localDosingUpdated[ld]['ecConnection'][ec]['rtu'],
                    'rfNo' : configPvd.localDosingUpdated[ld]['ecConnection'][ec]['rfNo'],
                    'input' : configPvd.localDosingUpdated[ld]['ecConnection'][ec]['input'],
                    'input_type' : configPvd.localDosingUpdated[ld]['ecConnection'][ec]['input_type'],
                  }
              );
            }
            for(var ph = 0;ph < configPvd.localDosingUpdated[ld]['phConnection'].length;ph++){
              myList[i]['map'].add(
                  {
                    'name' : 'Ph sensor',
                    'type' : 'm_i_localDosing',
                    'line' : i,
                    'count' : ph,
                    'connection' : 'phConnection',
                    'sNo' :  configPvd.localDosingUpdated[ld]['phConnection'][ph]['sNo'],
                    'rtu' :  configPvd.localDosingUpdated[ld]['phConnection'][ph]['rtu'],
                    'rfNo' : configPvd.localDosingUpdated[ld]['phConnection'][ph]['rfNo'],
                    'input' : configPvd.localDosingUpdated[ld]['phConnection'][ph]['input'],
                    'input_type' : configPvd.localDosingUpdated[ld]['phConnection'][ph]['input_type'],
                  }
              );
            }
            for(var inj = 0;inj < configPvd.localDosingUpdated[ld]['injector'].length;inj++){
              if(configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter'].isNotEmpty){
                myList[i]['map'].add(
                    {
                      'name' : 'dosing meter',
                      'type' : 'm_i_localDosing',
                      'line' : i,
                      'count' : inj,
                      'connection' : 'injector-dosingMeter',
                      'sNo' :  configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter']['sNo'],
                      'rtu' :  configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter']['rtu'],
                      'rfNo' : configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter']['rfNo'],
                      'input' : configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter']['input'],
                      'input_type' : configPvd.localDosingUpdated[ld]['injector'][inj]['dosingMeter']['input_type'],
                    }
                );
              }
            }
            if(configPvd.localDosingUpdated[ld]['pressureSwitch'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'press switch',
                    'type' : 'm_i_localDosing',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'pressureSwitch',
                    'sNo' :  configPvd.localDosingUpdated[ld]['pressureSwitch']['sNo'],
                    'rtu' :  configPvd.localDosingUpdated[ld]['pressureSwitch']['rtu'],
                    'rfNo' : configPvd.localDosingUpdated[ld]['pressureSwitch']['rfNo'],
                    'input' : configPvd.localDosingUpdated[ld]['pressureSwitch']['input'],
                    'input_type' : configPvd.localDosingUpdated[ld]['pressureSwitch']['input_type'],
                  }
              );
            }
            break localDosing;
          }
        }
      }
      if(configPvd.irrigationLines[i]['local_filtration_site'] == true){
        localFiltration : for(var ld = 0;ld < configPvd.localFiltrationUpdated.length;ld++){
          if(configPvd.localFiltrationUpdated[ld]['sNo'] == configPvd.irrigationLines[i]['sNo']){
            if(configPvd.localFiltrationUpdated[ld]['pressureIn'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'press In',
                    'type' : 'm_i_localFiltration',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'pressureIn',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['pressureIn']['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['pressureIn']['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['pressureIn']['rfNo'],
                    'input' : configPvd.localFiltrationUpdated[ld]['pressureIn']['input'],
                    'input_type' : configPvd.localFiltrationUpdated[ld]['pressureIn']['input_type'],
                  }
              );
            }
            if(configPvd.localFiltrationUpdated[ld]['pressureOut'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'press Out',
                    'type' : 'm_i_localFiltration',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'pressureOut',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['pressureOut']['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['pressureOut']['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['pressureOut']['rfNo'],
                    'input' : configPvd.localFiltrationUpdated[ld]['pressureOut']['input'],
                    'input_type' : configPvd.localFiltrationUpdated[ld]['pressureOut']['input_type'],
                  }
              );
            }
            if(configPvd.localFiltrationUpdated[ld]['pressureSwitch'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'press switch',
                    'type' : 'm_i_localFiltration',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'pressureSwitch',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['pressureSwitch']['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['pressureSwitch']['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['pressureSwitch']['rfNo'],
                    'input' : configPvd.localFiltrationUpdated[ld]['pressureSwitch']['input'],
                    'input_type' : configPvd.localFiltrationUpdated[ld]['pressureSwitch']['input_type'],
                  }
              );
            }
            if(configPvd.localFiltrationUpdated[ld]['diffPressureSensor'].isNotEmpty){
              myList[i]['map'].add(
                  {
                    'name' : 'D.Press sensor',
                    'type' : 'm_i_localFiltration',
                    'line' : i,
                    'count' : -1,
                    'connection' : 'diffPressureSensor',
                    'sNo' :  configPvd.localFiltrationUpdated[ld]['diffPressureSensor']['sNo'],
                    'rtu' :  configPvd.localFiltrationUpdated[ld]['diffPressureSensor']['rtu'],
                    'rfNo' : configPvd.localFiltrationUpdated[ld]['diffPressureSensor']['rfNo'],
                    'input' : configPvd.localFiltrationUpdated[ld]['diffPressureSensor']['input'],
                    'input_type' : configPvd.localFiltrationUpdated[ld]['diffPressureSensor']['input_type'],
                  }
              );
            }

            break localFiltration;
          }
        }
      }
      print('mylist : ${jsonEncode(myList)}');
    }
    return myList;
  }
  List<Map<String,dynamic>> centralDosing(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.centralDosingUpdated.length;i++){
      myList.add(
          {
            'name' : 'Central Dosing Site ${i+1}',
            'map' : [],
          }
      );
      for(var ec = 0;ec < configPvd.centralDosingUpdated[i]['ecConnection'].length;ec++){
        myList[i]['map'].add(
            {
              'name' : 'Ec sensor',
              'type' : 'm_i_centralDosing',
              'line' : i,
              'count' : ec,
              'connection' : 'ecConnection',
              'sNo' :  configPvd.centralDosingUpdated[i]['ecConnection'][ec]['sNo'],
              'rtu' :  configPvd.centralDosingUpdated[i]['ecConnection'][ec]['rtu'],
              'rfNo' : configPvd.centralDosingUpdated[i]['ecConnection'][ec]['rfNo'],
              'input' : configPvd.centralDosingUpdated[i]['ecConnection'][ec]['input'],
              'input_type' : configPvd.centralDosingUpdated[i]['ecConnection'][ec]['input_type'],
            }
        );
      }
      for(var ph = 0;ph < configPvd.centralDosingUpdated[i]['phConnection'].length;ph++){
        myList[i]['map'].add(
            {
              'name' : 'Ph sensor',
              'type' : 'm_i_centralDosing',
              'line' : i,
              'count' : ph,
              'connection' : 'phConnection',
              'sNo' :  configPvd.centralDosingUpdated[i]['phConnection'][ph]['sNo'],
              'rtu' :  configPvd.centralDosingUpdated[i]['phConnection'][ph]['rtu'],
              'rfNo' : configPvd.centralDosingUpdated[i]['phConnection'][ph]['rfNo'],
              'input' : configPvd.centralDosingUpdated[i]['phConnection'][ph]['input'],
              'input_type' : configPvd.centralDosingUpdated[i]['phConnection'][ph]['input_type'],
            }
        );
      }
      if(configPvd.centralDosingUpdated[i]['pressureSwitch'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'press switch',
              'type' : 'm_i_centralDosing',
              'site' : i,
              'count' : -1,
              'connection' : 'pressureSwitch',
              'sNo' :  configPvd.centralDosingUpdated[i]['pressureSwitch']['sNo'],
              'rtu' :  configPvd.centralDosingUpdated[i]['pressureSwitch']['rtu'],
              'rfNo' : configPvd.centralDosingUpdated[i]['pressureSwitch']['rfNo'],
              'input' : configPvd.centralDosingUpdated[i]['pressureSwitch']['input'],
              'input_type' : configPvd.centralDosingUpdated[i]['pressureSwitch']['input_type'],
            }
        );
      }
      for(var inj = 0;inj < configPvd.centralDosingUpdated[i]['injector'].length;inj++){
        if(configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter'].isNotEmpty){
          myList[i]['map'].add(
              {
                'name' : 'dosing meter',
                'type' : 'm_i_centralDosing',
                'site' : i,
                'count' : inj,
                'connection' : 'injector-dosingMeter',
                'sNo' :  configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter']['sNo'],
                'rtu' :  configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter']['rtu'],
                'rfNo' : configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter']['rfNo'],
                'input' : configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter']['input'],
                'input_type' : configPvd.centralDosingUpdated[i]['injector'][inj]['dosingMeter']['input_type'],
              }
          );
        }
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> centralFiltration(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.centralFiltrationUpdated.length;i++){
      myList.add(
          {
            'name' : 'Central Filtration Site ${i+1}',
            'map' : [],
          }
      );
      if(configPvd.centralFiltrationUpdated[i]['pressureIn'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'press In',
              'type' : 'm_i_centralFiltration',
              'site' : i,
              'count' : -1,
              'connection' : 'pressureIn',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['pressureIn']['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['pressureIn']['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['pressureIn']['rfNo'],
              'input' : configPvd.centralFiltrationUpdated[i]['pressureIn']['input'],
              'input_type' : configPvd.centralFiltrationUpdated[i]['pressureIn']['input_type'],
            }
        );
      }
      if(configPvd.centralFiltrationUpdated[i]['pressureOut'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'press Out',
              'type' : 'm_i_centralFiltration',
              'site' : i,
              'count' : -1,
              'connection' : 'pressureOut',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['pressureOut']['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['pressureOut']['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['pressureOut']['rfNo'],
              'input' : configPvd.centralFiltrationUpdated[i]['pressureOut']['input'],
              'input_type' : configPvd.centralFiltrationUpdated[i]['pressureOut']['input_type'],
            }
        );
      }
      if(configPvd.centralFiltrationUpdated[i]['pressureSwitch'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'press switch',
              'type' : 'm_i_centralFiltration',
              'site' : i,
              'count' : -1,
              'connection' : 'pressureSwitch',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['pressureSwitch']['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['pressureSwitch']['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['pressureSwitch']['rfNo'],
              'input' : configPvd.centralFiltrationUpdated[i]['pressureSwitch']['input'],
              'input_type' : configPvd.centralFiltrationUpdated[i]['pressureSwitch']['input_type'],
            }
        );
      }
      if(configPvd.centralFiltrationUpdated[i]['diffPressureSensor'].isNotEmpty){
        myList[i]['map'].add(
            {
              'name' : 'D.Press sensor',
              'type' : 'm_i_centralFiltration',
              'site' : i,
              'count' : -1,
              'connection' : 'diffPressureSensor',
              'sNo' :  configPvd.centralFiltrationUpdated[i]['diffPressureSensor']['sNo'],
              'rtu' :  configPvd.centralFiltrationUpdated[i]['diffPressureSensor']['rtu'],
              'rfNo' : configPvd.centralFiltrationUpdated[i]['diffPressureSensor']['rfNo'],
              'input' : configPvd.centralFiltrationUpdated[i]['diffPressureSensor']['input'],
              'input_type' : configPvd.centralFiltrationUpdated[i]['diffPressureSensor']['input_type'],
            }
        );
      }
    }
    return myList;
  }
  List<Map<String,dynamic>> sourcePump(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.sourcePumpUpdated.length;i++){
      myList.add(
          {
            'name' : 'Source Pump ${i+1}',
            'map' : [],
          }
      );
      if(configPvd.sourcePumpUpdated[i]['waterMeter'].isNotEmpty){
        myList[i]['map'].add(
            {
              'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
              'name' : 'water meter',
              'type' : 'm_i_sourcePump',
              'pump' : i,
              'count' : -1,
              'connection' : 'waterMeter',
              'sNo' :  configPvd.sourcePumpUpdated[i]['waterMeter']['sNo'],
              'rtu' :  configPvd.sourcePumpUpdated[i]['waterMeter']['rtu'],
              'rfNo' : configPvd.sourcePumpUpdated[i]['waterMeter']['rfNo'],
              'input' : configPvd.sourcePumpUpdated[i]['waterMeter']['input'],
              'input_type' : configPvd.sourcePumpUpdated[i]['waterMeter']['input_type']
            }
        );
      }
      if(configPvd.sourcePumpUpdated[i]['TopTankHigh'] != null){
        if(configPvd.sourcePumpUpdated[i]['TopTankHigh'].isNotEmpty){
          print('it is not empty');
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'Tt high',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'TopTankHigh',
                'sNo' :  configPvd.sourcePumpUpdated[i]['TopTankHigh']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['TopTankHigh']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['TopTankHigh']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['TopTankHigh']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['TopTankHigh']['input_type']
              }
          );
        }
      }
      if(configPvd.sourcePumpUpdated[i]['TopTankLow'] != null){
        if(configPvd.sourcePumpUpdated[i]['TopTankLow'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'Tt low',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'TopTankLow',
                'sNo' :  configPvd.sourcePumpUpdated[i]['TopTankLow']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['TopTankLow']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['TopTankLow']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['TopTankLow']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['TopTankLow']['input_type']
              }
          );
        }
      }
      if(configPvd.sourcePumpUpdated[i]['SumpTankHigh'] != null){
        if(configPvd.sourcePumpUpdated[i]['SumpTankHigh'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'St high',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'SumpTankHigh',
                'sNo' :  configPvd.sourcePumpUpdated[i]['SumpTankHigh']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['SumpTankHigh']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['SumpTankHigh']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['SumpTankHigh']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['SumpTankHigh']['input_type']
              }
          );
        }
      }
      if(configPvd.sourcePumpUpdated[i]['SumpTankLow'] != null){
        if(configPvd.sourcePumpUpdated[i]['SumpTankLow'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'St low',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'SumpTankLow',
                'sNo' :  configPvd.sourcePumpUpdated[i]['SumpTankLow']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['SumpTankLow']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['SumpTankLow']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['SumpTankLow']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['SumpTankLow']['input_type']
              }
          );
        }
      }
      print('i went');
      print(myList);
      if(configPvd.sourcePumpUpdated[i]['c1'] != null){
        if(configPvd.sourcePumpUpdated[i]['c1'].isNotEmpty){
          print(configPvd.sourcePumpUpdated[i]['c1']);
          print(myList);
          print(myList[i]);
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c1',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c1',
                'sNo' :  configPvd.sourcePumpUpdated[i]['c1']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['c1']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['c1']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['c1']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['c1']['input_type']
              }
          );
        }
      }
      if(configPvd.sourcePumpUpdated[i]['c2'] != null){
        if(configPvd.sourcePumpUpdated[i]['c2'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c2',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c2',
                'sNo' :  configPvd.sourcePumpUpdated[i]['c2']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['c2']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['c2']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['c2']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['c2']['input_type']
              }
          );
        }
      }
      if(configPvd.sourcePumpUpdated[i]['c3'] != null){
        if(configPvd.sourcePumpUpdated[i]['c3'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.sourcePumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c3',
                'type' : 'm_i_sourcePump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c3',
                'sNo' :  configPvd.sourcePumpUpdated[i]['c3']['sNo'],
                'rtu' :  configPvd.sourcePumpUpdated[i]['c3']['rtu'],
                'rfNo' : configPvd.sourcePumpUpdated[i]['c3']['rfNo'],
                'input' : configPvd.sourcePumpUpdated[i]['c3']['input'],
                'input_type' : configPvd.sourcePumpUpdated[i]['c3']['input_type']
              }
          );
        }
      }

    }
    print('see : ${myList}');
    return myList;
  }
  List<Map<String,dynamic>> irrigationPump(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    for(var i = 0;i < configPvd.irrigationPumpUpdated.length;i++){
      if(configPvd.irrigationPumpUpdated[i]['waterMeter'].isNotEmpty
          ||
          (configPvd.irrigationPumpUpdated[i]['TopTankHigh'] != null && configPvd.irrigationPumpUpdated[i]['TopTankHigh'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['TopTankLow'] != null && configPvd.irrigationPumpUpdated[i]['TopTankLow'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['SumpTankHigh'] != null && configPvd.irrigationPumpUpdated[i]['SumpTankHigh'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['SumpTankLow'] != null && configPvd.irrigationPumpUpdated[i]['SumpTankLow'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['c1'] != null && configPvd.irrigationPumpUpdated[i]['c1'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['c2'] != null && configPvd.irrigationPumpUpdated[i]['c2'].isNotEmpty)
          ||
          (configPvd.irrigationPumpUpdated[i]['c3'] != null && configPvd.irrigationPumpUpdated[i]['c3'].isNotEmpty)
      ){
        print('yes it came');
        myList.add(
            {
              'name' : 'Irrigation Pump ${i+1}',
              'map' : [],
            }
        );
      }
      if(configPvd.irrigationPumpUpdated[i]['waterMeter'].isNotEmpty){
        myList[i]['map'].add(
            {
              'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
              'name' : 'water meter',
              'type' : 'm_i_irrigationPump',
              'pump' : i,
              'count' : -1,
              'connection' : 'waterMeter',
              'sNo' :  configPvd.irrigationPumpUpdated[i]['waterMeter']['sNo'],
              'rtu' :  configPvd.irrigationPumpUpdated[i]['waterMeter']['rtu'],
              'rfNo' : configPvd.irrigationPumpUpdated[i]['waterMeter']['rfNo'],
              'input' : configPvd.irrigationPumpUpdated[i]['waterMeter']['input'],
              'input_type' : configPvd.irrigationPumpUpdated[i]['waterMeter']['input_type']
            }
        );
      }
      if(configPvd.irrigationPumpUpdated[i]['TopTankHigh'] != null){
        if(configPvd.irrigationPumpUpdated[i]['TopTankHigh'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'Tt high',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'TopTankHigh',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['TopTankHigh']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['TopTankHigh']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['TopTankHigh']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['TopTankHigh']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['TopTankHigh']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['TopTankLow'] != null){
        if(configPvd.irrigationPumpUpdated[i]['TopTankLow'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'Tt low',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'TopTankLow',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['TopTankLow']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['TopTankLow']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['TopTankLow']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['TopTankLow']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['TopTankLow']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['SumpTankHigh'] != null){
        if(configPvd.irrigationPumpUpdated[i]['SumpTankHigh'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'St high',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'SumpTankHigh',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['SumpTankHigh']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['SumpTankHigh']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['SumpTankHigh']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['SumpTankHigh']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['SumpTankHigh']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['SumpTankLow'] != null){
        if(configPvd.irrigationPumpUpdated[i]['SumpTankLow'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'St low',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'SumpTankLow',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['SumpTankLow']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['SumpTankLow']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['SumpTankLow']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['SumpTankLow']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['SumpTankLow']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['c1'] != null){
        if(configPvd.irrigationPumpUpdated[i]['c1'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c1',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c1',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['c1']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['c1']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['c1']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['c1']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['c1']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['c2'] != null){
        if(configPvd.irrigationPumpUpdated[i]['c2'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c2',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c2',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['c2']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['c2']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['c2']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['c2']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['c2']['input_type']
              }
          );
        }
      }
      if(configPvd.irrigationPumpUpdated[i]['c3'] != null){
        if(configPvd.irrigationPumpUpdated[i]['c3'].isNotEmpty){
          myList[i]['map'].add(
              {
                'oroPump' : configPvd.irrigationPumpUpdated[i]['oro_pump'] == true ? true : false,
                'name' : 'c3',
                'type' : 'm_i_irrigationPump',
                'pump' : i,
                'count' : -1,
                'connection' : 'c3',
                'sNo' :  configPvd.irrigationPumpUpdated[i]['c3']['sNo'],
                'rtu' :  configPvd.irrigationPumpUpdated[i]['c3']['rtu'],
                'rfNo' : configPvd.irrigationPumpUpdated[i]['c3']['rfNo'],
                'input' : configPvd.irrigationPumpUpdated[i]['c3']['input'],
                'input_type' : configPvd.irrigationPumpUpdated[i]['c3']['input_type']
              }
          );
        }
      }

    }
    print('myLIST : $myList');
    return myList;
  }
  List<Map<String,dynamic>> analogSensor(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    myList.add(
        {
          'name' : 'Analog Sensors',
          'map' : [],
        }
    );
    for(var i = 0;i < configPvd.totalAnalogSensor.length;i++){
      myList[0]['map'].add(
          {
            'name' : 'AS ${i+1}',
            'type' : 'm_i_analogSensor',
            'sensor' : i,
            'count' : i,
            'connection' : 'totalAnalogSensor',
            'sNo' :  configPvd.totalAnalogSensor[i]['sNo'],
            'rtu' :  configPvd.totalAnalogSensor[i]['rtu'],
            'rfNo' : configPvd.totalAnalogSensor[i]['rfNo'],
            'input' : configPvd.totalAnalogSensor[i]['input'],
            'input_type' : configPvd.totalAnalogSensor[i]['input_type']
          }
      );


    }
    print('myLIST : $myList');
    return myList;
  }
  List<Map<String,dynamic>> contact(ConfigMakerProvider configPvd){
    List<Map<String,dynamic>> myList = [];
    myList.add(
        {
          'name' : 'Contacts',
          'map' : [],
        }
    );
    for(var i = 0;i < configPvd.totalContact.length;i++){
      myList[0]['map'].add(
          {
            'name' : 'CNT ${i+1}',
            'type' : 'm_i_contact',
            'sensor' : i,
            'count' : i,
            'connection' : 'totalAnalogSensor',
            'sNo' :  configPvd.totalContact[i]['sNo'],
            'rtu' :  configPvd.totalContact[i]['rtu'],
            'rfNo' : configPvd.totalContact[i]['rfNo'],
            'input' : configPvd.totalContact[i]['input'],
            'input_type' : configPvd.totalContact[i]['input_type']
          }
      );
    }
    print('myLIST : $myList');
    return myList;
  }

}

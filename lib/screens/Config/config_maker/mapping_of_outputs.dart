import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../constants/theme.dart';
import '../../../widgets/drop_down_button.dart';



class MappingOfOutputsTable extends StatefulWidget {
  ConfigMakerProvider configPvd;
  MappingOfOutputsTable({super.key,required this.configPvd});

  @override
  State<MappingOfOutputsTable> createState() => _MappingOfOutputsTableState();
}

class _MappingOfOutputsTableState extends State<MappingOfOutputsTable> {
  bool odd = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
        configPvd.refreshMapOfOutputs();

      });
    }
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context,constrainst){
      var width = constrainst.maxWidth;
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
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
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                if(width < 400)
                  Container(
                    width: 150,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('RTU',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  )
                else
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
                          color: myTheme.primaryColor
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
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('O/P',style: TextStyle(color: Colors.white),),
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
            child: Container(
              padding: EdgeInsets.only(left: 10,right: 10),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for(var i = 0; i < configPvd.mappingOfOutputs.length;i++)
                        for(var j in configPvd.mappingOfOutputs[i].entries)
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Irrigation line${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                                for(var k = 0;k < j.value['valve'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFind(j.value,j.value['valve'][k][0]),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text(j.value['valve'][k][0].split(':')[1])),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['valve'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['valve'][k][1])['list'], pvdName: 'm_o_valve/${i}/${j.key}/valve/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['valve'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['valve'][k][1])['list'], pvdName: 'm_o_valve/${i}/${j.key}/valve/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['valve'][k][1],j.value['valve'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['valve'][k][1],j.value['valve'][k][2]])['list'], pvdName: 'm_o_valve/${i}/${j.key}/valve/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['valve'][k][0], j.value['valve'][k][1],j.value['valve'][k][2],j.value['valve'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['valve'][k][0], j.value['valve'][k][1], j.value['valve'][k][2], j.value['valve'][k][3] ])['list'], pvdName: 'm_o_valve/${i}/${j.key}/valve/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                for(var k = 0;k < j.value['main_valve'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFind(j.value,j.value['main_valve'][k][0]),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text(j.value['main_valve'][k][0].split(':')[1])),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['main_valve'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['main_valve'][k][1])['list'], pvdName: 'm_o_main_valve/${i}/${j.key}/main_valve/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['main_valve'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['main_valve'][k][1])['list'], pvdName: 'm_o_main_valve/${i}/${j.key}/main_valve/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['main_valve'][k][1],j.value['main_valve'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['main_valve'][k][1],j.value['main_valve'][k][2]])['list'], pvdName: 'm_o_main_valve/${i}/${j.key}/main_valve/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['main_valve'][k][0], j.value['main_valve'][k][1],j.value['main_valve'][k][2],j.value['main_valve'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['main_valve'][k][0], j.value['main_valve'][k][1], j.value['main_valve'][k][2], j.value['main_valve'][k][3] ])['list'], pvdName: 'm_o_main_valve/${i}/${j.key}/main_valve/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                for(var k = 0;k < j.value['injector'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFind(j.value,j.value['injector'][k][0]),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('inj${k+1}')),
                                            // child: Center(child: Text('${j.value['injector'][k][0]}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['injector'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['injector'][k][1])['list'], pvdName: 'm_o_injector/${i}/${j.key}/injector/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['injector'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['injector'][k][1])['list'], pvdName: 'm_o_injector/${i}/${j.key}/injector/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['injector'][k][1],j.value['injector'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['injector'][k][1],j.value['injector'][k][2]])['list'], pvdName: 'm_o_injector/${i}/${j.key}/injector/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['injector'][k][0], j.value['injector'][k][1],j.value['injector'][k][2],j.value['injector'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['injector'][k][0], j.value['injector'][k][1], j.value['injector'][k][2], j.value['injector'][k][3] ])['list'], pvdName: 'm_o_injector/${i}/${j.key}/injector/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                for(var k = 0;k < j.value['Booster'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFind(j.value,j.value['Booster'][k][0]),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('Bstr${k+1}')),
                                            // child: Center(child: Text('${j.value['injector'][k][0]}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['Booster'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['Booster'][k][1])['list'], pvdName: 'm_o_Booster/${i}/${j.key}/Booster/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['Booster'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['Booster'][k][1])['list'], pvdName: 'm_o_Booster/${i}/${j.key}/Booster/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['Booster'][k][1],j.value['Booster'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['Booster'][k][1],j.value['Booster'][k][2]])['list'], pvdName: 'm_o_Booster/${i}/${j.key}/Booster/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['Booster'][k][0], j.value['Booster'][k][1],j.value['Booster'][k][2],j.value['Booster'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['Booster'][k][0], j.value['Booster'][k][1], j.value['Booster'][k][2], j.value['Booster'][k][3] ])['list'], pvdName: 'm_o_Booster/${i}/${j.key}/Booster/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                for(var k = 0;k < j.value['filter'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFind(j.value,j.value['filter'][k][0]),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text(j.value['filter'][k][0].split(':')[1])),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['filter'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['filter'][k][1])['list'], pvdName: 'm_o_filter/${i}/${j.key}/filter/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['filter'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['filter'][k][1])['list'], pvdName: 'm_o_filter/${i}/${j.key}/filter/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['filter'][k][1],j.value['filter'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['filter'][k][1],j.value['filter'][k][2]])['list'], pvdName: 'm_o_filter/${i}/${j.key}/filter/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['filter'][k][0], j.value['filter'][k][1],j.value['filter'][k][2],j.value['filter'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['filter'][k][0], j.value['filter'][k][1], j.value['filter'][k][2], j.value['filter'][k][3] ])['list'], pvdName: 'm_o_filter/${i}/${j.key}/filter/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                j.value['D_valve'].length == 0 ? Container() : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorsFind(j.value,j.value['D_valve'][0]),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('D_V')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_valve'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_valve'][1])['list'], pvdName: 'm_o_D_valve/${i}/${j.key}/D_valve/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_valve'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_valve'][1])['list'], pvdName: 'm_o_D_valve/${i}/${j.key}/D_valve/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['D_valve'][1],j.value['D_valve'][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['D_valve'][1],j.value['D_valve'][2]])['list'], pvdName: 'm_o_D_valve/${i}/${j.key}/D_valve/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['D_valve'][0], j.value['D_valve'][1],j.value['D_valve'][2],j.value['D_valve'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['D_valve'][0], j.value['D_valve'][1], j.value['D_valve'][2], j.value['D_valve'][3] ])['list'], pvdName: 'm_o_D_valve/${i}/${j.key}/D_valve/3', index: -1,),
                                      ),
                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                      for(var i = 0;i < configPvd.CD_for_MO.length;i++)
                        for(var j in configPvd.CD_for_MO[i].entries)
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Central Dosing Site ${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                                for(var k = 0;k < j.value['injector'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFindForCD(j.value,'inj${k}'),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('injector${j.value['injector'][k][0]}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: j.value['injector'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CD_injector/${i}/${j.key}/injector/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: j.value['injector'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CD_injector/${i}/${j.key}/injector/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['injector'][k][2], itemList: getRFnos(configPvd,j.value['injector'][k][1]), pvdName: 'm_o_CD_injector/${i}/${j.key}/injector/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['injector'][k][4], j.value['injector'][k][1],j.value['injector'][k][2],j.value['injector'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['injector'][k][4], j.value['injector'][k][1],j.value['injector'][k][2],j.value['injector'][k][3] ])['list'], pvdName: 'm_o_CD_injector/${i}/${j.key}/injector/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                for(var k = 0;k < j.value['booster'].length;k++)
                                  if(j.value['booster'][k][0] == true)
                                    Container(
                                    height: 50,
                                      decoration: BoxDecoration(
                                        color: colorsFindForCD(j.value,'bp${k}'),
                                      ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('booster${k + 1}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: j.value['booster'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CD_booster/${i}/${j.key}/booster/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: j.value['booster'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CD_booster/${i}/${j.key}/booster/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['booster'][k][2], itemList: getRFnos(configPvd,j.value['booster'][k][1]), pvdName: 'm_o_CD_booster/${i}/${j.key}/booster/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['booster'][k][4], j.value['booster'][k][1],j.value['booster'][k][2],j.value['booster'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['booster'][k][4], j.value['booster'][k][1],j.value['booster'][k][2],j.value['booster'][k][3] ])['list'], pvdName: 'm_o_CD_booster/${i}/${j.key}/booster/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      for(var i = 0;i < configPvd.CF_for_MO.length;i++)
                        for(var j in configPvd.CF_for_MO[i].entries)
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Central Filtration Site ${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                                for(var k = 0;k < j.value['filter'].length;k++)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFindForCF(j.value,'filt${k}'),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('filter${j.value['filter'][k][0]}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: j.value['filter'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CF_filter/${i}/${j.key}/filter/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: j.value['filter'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CF_filter/${i}/${j.key}/filter/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['filter'][k][2], itemList: getRFnos(configPvd,j.value['filter'][k][1]), pvdName: 'm_o_CF_filter/${i}/${j.key}/filter/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['filter'][k][4], j.value['filter'][k][1],j.value['filter'][k][2],j.value['filter'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['filter'][k][4], j.value['filter'][k][1],j.value['filter'][k][2],j.value['filter'][k][3] ])['list'], pvdName: 'm_o_CF_filter/${i}/${j.key}/filter/${k}/3', index: -1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                j.value['D_S_valve'].length == 0 || j.value['D_S_valve'][0] == false ? Container() : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorsFindForCF(j.value,'d_v1'),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('DV')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: j.value['D_S_valve'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CF_D_valve/${i}/${j.key}/D_S_valve/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['D_S_valve'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_CF_D_valve/${i}/${j.key}/D_S_valve/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['D_S_valve'][2], itemList: getRFnos(configPvd,j.value['D_S_valve'][1]), pvdName: 'm_o_CF_D_valve/${i}/${j.key}/D_S_valve/2', index: -1,),
                                      ),
                                      Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['D_S_valve'][4], j.value['D_S_valve'][1],j.value['D_S_valve'][2],j.value['D_S_valve'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['D_S_valve'][4], j.value['D_S_valve'][1],j.value['D_S_valve'][2],j.value['D_S_valve'][3] ])['list'], pvdName: 'm_o_CF_D_valve/${i}/${j.key}/D_S_valve/3', index: -1,),
                                      ),

                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                      configPvd.SP_MO.length == 0 ? Container() : Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Source Pumps',style: TextStyle(color: Colors.white),),),
                      ),
                      for(var i = 0;i < configPvd.SP_MO.length;i++)
                        for(var j in configPvd.SP_MO[i].entries)
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                j.value['pump'].length == 0 ? Container() : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('Pump ${i+1}')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: j.value['pump'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_SP/${i}/${j.key}/pump/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['pump'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_SP/${i}/${j.key}/pump/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['pump'][2], itemList: getRFnos(configPvd,j.value['pump'][1]), pvdName: 'm_o_SP/${i}/${j.key}/pump/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['pump'][4], j.value['pump'][1],j.value['pump'][2],j.value['pump'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['pump'][4], j.value['pump'][1],j.value['pump'][2],j.value['pump'][3] ])['list'], pvdName: 'm_o_SP/${i}/${j.key}/pump/3', index: -1,),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      configPvd.IP_MO.length == 0 ? Container() :Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Irrigation Pumps',style: TextStyle(color: Colors.white),),),
                      ),
                      for(var i = 0;i < configPvd.IP_MO.length;i++)
                        for(var j in configPvd.IP_MO[i].entries)
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                j.value['pump'].length == 0 ? Container() : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('Pump ${i+1}')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: j.value['pump'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_IP/${i}/${j.key}/pump/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['pump'][1], itemList: getRTUs(configPvd), pvdName: 'm_o_IP/${i}/${j.key}/pump/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['pump'][2], itemList: getRFnos(configPvd,j.value['pump'][1]), pvdName: 'm_o_IP/${i}/${j.key}/pump/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['pump'][4], j.value['pump'][1],j.value['pump'][2],j.value['pump'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[ j.value['pump'][4], j.value['pump'][1],j.value['pump'][2],j.value['pump'][3] ])['list'], pvdName: 'm_o_IP/${i}/${j.key}/pump/3', index: -1,),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      configPvd.totalFan.length == 0 ? Container() : Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Fan',style: TextStyle(color: Colors.white),),),
                      ),
                      for(var i = 0;i < configPvd.totalFan.length;i++)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('Fan${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: configPvd.totalFan[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_fan/${i}/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalFan[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_fan/${i}/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalFan[i][2], itemList: getRFnos(configPvd,configPvd.totalFan[i][1]), pvdName: 'm_o_fan/${i}/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalFan[i][configPvd.totalFan[i].length - 1], configPvd.totalFan[i][1], configPvd.totalFan[i][2], configPvd.totalFan[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalFan[i][configPvd.totalFan[i].length - 1], configPvd.totalFan[i][1],configPvd.totalFan[i][2],configPvd.totalFan[i][3]])['list'], pvdName: 'm_o_fan/${i}/3', index: -1,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      configPvd.totalAgitator.length == 0 ? Container() : Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Agitator',style: TextStyle(color: Colors.white),),),
                      ),
                      for(var i = 0;i < configPvd.totalAgitator.length;i++)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('Agitator ${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: configPvd.totalAgitator[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_agitator/${i}/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalAgitator[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_agitator/${i}/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalAgitator[i][2], itemList: getRFnos(configPvd,configPvd.totalAgitator[i][1]), pvdName: 'm_o_agitator/${i}/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalAgitator[i][configPvd.totalAgitator[i].length - 1], configPvd.totalAgitator[i][1], configPvd.totalAgitator[i][2], configPvd.totalAgitator[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalAgitator[i][configPvd.totalAgitator[i].length - 1], configPvd.totalAgitator[i][1],configPvd.totalAgitator[i][2],configPvd.totalAgitator[i][3]])['list'], pvdName: 'm_o_agitator/${i}/3', index: -1,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      configPvd.totalFogger.length == 0 ? Container() : Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Fogger',style: TextStyle(color: Colors.white),),),
                      ),
                      for(var i = 0;i < configPvd.totalFogger.length;i++)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('Fogger ${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: configPvd.totalFogger[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_fogger/${i}/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalFogger[i][1], itemList: getRTUs(configPvd), pvdName: 'm_o_fogger/${i}/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalFogger[i][2], itemList: getRFnos(configPvd,configPvd.totalFogger[i][1]), pvdName: 'm_o_fogger/${i}/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalFogger[i][configPvd.totalFogger[i].length - 1], configPvd.totalFogger[i][1], configPvd.totalFogger[i][2], configPvd.totalFogger[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalFogger[i][configPvd.totalFogger[i].length - 1], configPvd.totalFogger[i][1],configPvd.totalFogger[i][2],configPvd.totalFogger[i][3]])['list'], pvdName: 'm_o_fogger/${i}/3', index: -1,),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                    ],
                  ),
              ),
            ),
          )
        ],
      );
    });

  }
  Map<String,dynamic> returnigListForRtu(String autoIncrement,ConfigMakerProvider configPvd,String value){
    List<String> list = [];
    String myValue = '';
    for(var i in configPvd.irrigationLines){
      if(i['autoIncrement'].toString() == autoIncrement){
        list = i['myRTU_list'];
      }
      if(!list.contains(value)){
        myValue = '-';
      }else{
        myValue = value;
      }
    }
    return {'initialValue' : myValue,'list' : list};
  }
  Map<String,dynamic> returnigListForRfNo(String autoIncrement,ConfigMakerProvider configPvd,List<String> valueList){
    List<String> list = ['-'];
    String myValue = '';
    for(var i in configPvd.irrigationLines){
      if(i['autoIncrement'].toString() == autoIncrement){
        if(valueList[0] == 'ORO RTU'){
          for(var i in i['myRTU']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Switch'){
          for(var i in i['myOROswitch']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Smart RTU'){
          for(var i in i['myOroSmartRtu']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Sense'){
          for(var i in i['myOROsense']){
            list.add(i.toString());
          }
        }
      }
      if(!list.contains(valueList[1])){
        myValue = '-';
      }else{
        myValue = valueList[1];
      }
    }
    return {'initialValue' : myValue,'list' : list};
  }
  Map<String,dynamic> returnigListForOutput(String autoIncrement,ConfigMakerProvider configPvd,List<String> valueList){
    List<String> list = ['-'];
    List<dynamic> overall = [];
    List<dynamic> overall_for_others = [];
    List<dynamic> overall_for_extra = [];

    String myValue = '-';
    if(valueList[1] == 'ORO Smart RTU'){
      if(valueList[2] != '-'){
        for(var i = 0;i < 16;i++){
          list.add('${i + 1}');
        }
      }
    }else if(valueList[1] == 'ORO RTU'){
      for(var i = 0;i < 8;i++){
        list.add('${i + 1}');
      }
    }else if(valueList[1] == 'ORO Switch'){
      for(var i = 0;i < 4;i++){
        list.add('${i + 1}');
      }
    }else if(valueList[1] == 'ORO Sense'){
      for(var i = 0;i < 4;i++){
        list.add('${i + 1}');
      }
    }
    for(var i in configPvd.CD_for_MO){
      for(var j in i.entries){
        for(var k in j.value['injector']){
          overall_for_others.add(k);
        }
        for(var k in j.value['booster']){
          overall_for_others.add(k);
        }

      }
    }
    for(var i in configPvd.CF_for_MO){
      for(var j in i.entries){
        for(var k in j.value['filter']){
          overall_for_others.add(k);
        }
        if(j.value['D_S_valve'].length != 0){
          overall_for_others.add(j.value['D_S_valve']);
        }
      }
    }
    for(var i in configPvd.SP_MO){
      for(var j in i.entries){
        if(j.value['pump'].length != 0){
          overall_for_others.add(j.value['pump']);
        }
      }
    }
    for(var i in configPvd.IP_MO){
      for(var j in i.entries){
        if(j.value['pump'].length != 0){
          overall_for_others.add(j.value['pump']);
        }
      }
    }

    for(var i in configPvd.previousDataOfM_O){
      for(var j in i.entries){
        for(var k in j.value['valve']){
          overall.add(k);
        }
        for(var k in j.value['main_valve']){
          overall.add(k);
        }
        for(var k in j.value['filter']){
          overall.add(k);
        }
        for(var k in j.value['injector']){
          overall.add(k);
        }
        for(var k in j.value['Booster']){
          overall.add(k);
        }
        if(j.value['D_valve'].length != 0){
          overall.add(j.value['D_valve']);
        }
      }
    }
    for(var i in configPvd.totalFan){
      overall_for_extra.add(i);
    }
    for(var i in configPvd.totalFogger){
      overall_for_extra.add(i);
    }
    for(var i in configPvd.totalAgitator){
      overall_for_extra.add(i);
    }
    for(var i in overall){
      if(i[0] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');

      }
    }
    for(var i in overall_for_others){
      if(i[4] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');
      }
    }
    for(var i in overall_for_extra){
      if(i[i.length - 1] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');
      }
    }
    myValue = valueList[3];
    return {'initialValue' : myValue,'list' : list};
  }
  List<String> getRTUs(ConfigMakerProvider configPvd){
    List<String> list = ['-'];
    if(configPvd.rtuForLine_others.length != 0){
      list.add('ORO RTU');
    }
    if(configPvd.switchForLine_others.length != 0){
      list.add('ORO Switch');
    }
    if(configPvd.OroSmartRtuForLine_others.length != 0){
      list.add('ORO Smart RTU');
    }
    if(configPvd.OroSenseForLine_others != 0){
      list.add('ORO Sense');
    }
    return list;
  }
  List<String> getRFnos(ConfigMakerProvider configPvd,String title){
    List<String> list = ['-'];
    if(title == 'ORO RTU'){
      for(var i in configPvd.rtuForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Switch'){
      for(var i in configPvd.switchForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Smart RTU'){
      for(var i in configPvd.OroSmartRtuForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Sense'){
      for(var i in configPvd.OroSenseForLine_others){
        list.add('${i}');
      }
    }
    return list;
  }
  Color colorsFind(Map<String,dynamic> object,String title){
    var myList = [];
    for(var i in object.entries){
      if(i.key == 'valve'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }

      }
      if(i.key == 'main_valve'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }

      }
      if(i.key == 'injector'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }

      }
      if(i.key == 'Booster'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }
      }
      if(i.key == 'filter'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }
      }
      if(i.key == 'D_valve'){
        if(i.value.length!= 0){
          myList.add(i.value);
        }
      }

    }
    for(var i = 0;i < myList.length;i++){
      if(myList[i][0] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }
  Color colorsFindForCD(Map<String,dynamic> object,String title){
    var myList = [];
    for(var k = 0;k < object['injector'].length;k++){
      myList.add('inj${k}');
    }
    for(var k = 0;k < object['injector'].length;k++){
      if(object['booster'][k][0] == true){
        myList.add('bp${k}');
      }
    }
    for(var i = 0;i < myList.length;i++){
      if(myList[i] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }
  Color colorsFindForCF(Map<String,dynamic> object,String title){
    var myList = [];
    for(var k = 0;k < object['filter'].length;k++){
      myList.add('filt${k}');
    }
    if(object['D_S_valve'][0] == true){
      myList.add('d_v1');
    }
    for(var i = 0;i < myList.length;i++){
      if(myList[i] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }

}

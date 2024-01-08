import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/start.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/weather_station.dart';
import 'package:provider/provider.dart';


import '../../../state_management/config_maker_provider.dart';
import 'central_dosing.dart';
import 'central_filtration.dart';
import 'finish.dart';
import 'irrigation_lines.dart';
import 'irrigation_pump.dart';
import 'local_dosing.dart';
import 'local_filtration.dart';
import 'mapping_of_inputs.dart';
import 'mapping_of_outputs.dart';

class ConfigMakerForWeb extends StatefulWidget {
  const ConfigMakerForWeb({super.key, required this.userID, required this.customerID, required this.siteId, required this.imeiNo});
  final int userID, siteId, customerID;
  final String imeiNo;

  @override
  State<ConfigMakerForWeb> createState() => _ConfigMakerForWebState();
}

class _ConfigMakerForWebState extends State<ConfigMakerForWeb> {
  int hoverTab = -1;
  @override

  Widget configTables(ConfigMakerProvider configPvd){
    switch(configPvd.selectedTab){
      case (0):{
        return StartPageConfigMaker();
      }
      case (1):{
        return  SourcePumpTable();
      }
      case (2):{
        return  IrrigationPumpTable();
      }
      case (3):{
        return   CentralDosingTable();
      }
      case (4):{
        return  CentralFiltrationTable();
      }
      case (5):{
        return  IrrigationLineTable();
      }
      case (6):{
        return  LocalDosingTable();
      }
      case (7):{
        return  LocalFiltrationTable();
      }
      case (8):{
        return  WeatherStationConfig();
      }
      case (9):{
        return  MappingOfOutputsTable(configPvd: configPvd,);
      }
      case (10):{
        return  MappingOfInputsTable(configPvd: configPvd,);
      }
      case (11):{
        return  FinishPageConfigMaker(userId: widget.userID, customerID: widget.customerID, controllerId: widget.siteId,imeiNo: widget.imeiNo,);
      }
      default : {
        Container();
      }
    }
    return Container();
  }

  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context,constrainst){
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.small(
                heroTag: 'btn 1',
                tooltip: 'Previous',
                backgroundColor: configPvd.selectedTab == 0 ? Colors.white54 : Colors.white,
                onPressed: configPvd.selectedTab == 0
                    ? null
                    : () {
                  if (configPvd.selectedTab != 0) {
                    configPvd.editSelectedTab(configPvd.selectedTab - 1);
                  }
                },
                child: const Icon(Icons.arrow_back_outlined),
              ),
              FloatingActionButton.small(
                heroTag: 'btn 2',
                tooltip: 'Next',
                // backgroundColor: configPvd.selectedTab == 11 ? Colors.white54 : myTheme1.colorScheme.primary,
                backgroundColor: configPvd.selectedTab == 11 ? Colors.white54 : Colors.white,
                onPressed: configPvd.selectedTab == 11
                    ? null
                    : () {
                  if (configPvd.selectedTab != 11) {
                    configPvd.editSelectedTab(configPvd.selectedTab + 1);
                  }
                },
                child: const Icon(Icons.arrow_forward_outlined),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.indigo.shade50,
                        Colors.white70,
                      ],
                    ),
                  ),
                  width: 220,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < configPvd.tabs.length; i++)
                          Column(
                            children: [
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    configPvd.selectedTab = i;
                                  });
                                  configPvd.editSelectedTab(configPvd.selectedTab);
                                  if(configPvd.selectedTab != 5){
                                    // configPvd.editLoadIL(false);
                                  }
                                },
                                onHover: (value){
                                  if(value == true){
                                    setState(() {
                                      hoverTab = i;
                                    });
                                  }else{
                                    setState(() {
                                      hoverTab = -1;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: hoverTab == i ||configPvd.selectedTab == i ? myTheme.primaryColor : null,
                                  ),
                                  // padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  width: double.infinity,
                                  child: Row(
                                      children: [
                                        SizedBox(width: 20,),
                                        Icon(configPvd.tabs[i][2],color: hoverTab == i ? Colors.white : configPvd.selectedTab == i ? Colors.white : Colors.black87,),
                                        SizedBox(width: 20,),
                                        Text('${configPvd.tabs[i][0]} ${configPvd.tabs[i][1]}',style: TextStyle(color: hoverTab == i ? Colors.white : configPvd.selectedTab == i ? Colors.white : Colors.black87,fontWeight: FontWeight.bold),)
                                      ]
                                  ),
                                )
                              ),
                            ],
                          ),

                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: configTables(configPvd),
                  ),
                ),
              ],
            ),
          ),

        ),
      );
    });

  }
}

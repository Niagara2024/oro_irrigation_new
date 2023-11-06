import 'package:flutter/material.dart';
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
  const ConfigMakerForWeb({super.key, required this.customerId, required this.controllerId, required this.userId, required this.imeiNumber});
  final int customerId, controllerId, userId;
  final String imeiNumber;

  @override
  State<ConfigMakerForWeb> createState() => _ConfigMakerForWebState();
}

class _ConfigMakerForWebState extends State<ConfigMakerForWeb>
{
  int selectedTab = 0;
  int hoverTab = -1;
  Widget configTables(ConfigMakerProvider configPvd)
  {
    switch(selectedTab){
      case (0):{
        return const StartPageConfigMaker();
      }
      case (1):{
        return  const SourcePumpTable();
      }
      case (2):{
        return  const IrrigationPumpTable();
      }
      case (3):{
        return   const CentralDosingTable();
      }
      case (4):{
        return  const CentralFiltrationTable();
      }
      case (5):{
        return  const IrrigationLineTable();
      }
      case (6):{
        return  const LocalDosingTable();
      }
      case (7):{
        return  const LocalFiltrationTable();
      }
      case (8):{
        return  const WeatherStationConfig();
      }
      case (9):{
        return  MappingOfOutputsTable(configPvd: configPvd,);
      }
      case (10):{
        return  MappingOfInputsTable(configPvd: configPvd,);
      }
      case (11):{
        return  FinishPageConfigMaker(customerId: widget.customerId, controllerId: widget.controllerId, userId: widget.userId, imeiNo: widget.imeiNumber,);
      }
      default : {
        Container();
      }
    }
    return Container();
  }

  Widget build(BuildContext context)
  {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context, constrainst)
    {
      return Container(
        width: double.infinity,
        color: myTheme.primaryColor.withOpacity(0.5),
        height: double.infinity,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: constrainst.maxWidth < 1200 ? 180 : 300,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 20,),
                    for (var i = 0; i < configPvd.tabs.length; i++)
                      Column(
                        children: [
                          InkWell(
                            onTap: (){
                              setState(() {
                                selectedTab = i;
                              });
                              configPvd.editInitialIndex(selectedTab);
                              if(selectedTab != 5){
                                configPvd.editLoadIL(false);
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
                            child: constrainst.maxWidth > 1200 ? Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: hoverTab == i ||selectedTab == i ? Colors.white : null,
                              ),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(2),
                              width: double.infinity,
                              child: Row(
                                  mainAxisAlignment: constrainst.maxWidth > 1200 ? MainAxisAlignment.start : MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20,),
                                    Icon(configPvd.tabs[i][2],color: hoverTab == i ? myTheme.primaryColor : selectedTab == i ? myTheme.primaryColor : Colors.white,),
                                    SizedBox(width: 20,),
                                    Text('${configPvd.tabs[i][0]} ${configPvd.tabs[i][1]}',style: TextStyle(color: hoverTab == i ? myTheme.primaryColor : selectedTab == i ? myTheme.primaryColor : Colors.white),)
                                  ]
                              ),
                            ) : Container(
                              width: double.infinity,
                              child: Column(
                                  mainAxisAlignment: constrainst.maxWidth > 1200 ? MainAxisAlignment.start : MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: (selectedTab == i || hoverTab == i) ? Colors.white : null,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      width: 50,
                                      padding: EdgeInsets.all(5),
                                      child: Center(
                                        child: Icon(configPvd.tabs[i][2],color: selectedTab == i ? Colors.black : hoverTab == i ? Colors.black45 : Colors.white,),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Text('${configPvd.tabs[i][0]} ${configPvd.tabs[i][1]}',style: TextStyle(color: Colors.white,fontSize: 14),),
                                    SizedBox(height: 5,)

                                  ]
                              ),
                            ),
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
      );
    });

  }
}

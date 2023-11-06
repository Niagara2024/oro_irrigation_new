// import 'dart:html';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/start.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/weather_station.dart';
import 'package:provider/provider.dart';

import '../../../constants/http_service.dart';
import '../../../state_management/config_maker_provider.dart';
import 'central_dosing.dart';
import 'central_filtration.dart';
import 'config_web.dart';
import 'finish.dart';
import 'irrigation_lines.dart';
import 'irrigation_pump.dart';
import 'local_dosing.dart';
import 'local_filtration.dart';
import 'mapping_of_inputs.dart';
import 'mapping_of_outputs.dart';


class ConfigMakerScreen extends StatefulWidget {
  const ConfigMakerScreen({super.key, required this.userID, required this.customerID, required this.siteID, required this.imeiNumber});
  final int userID, customerID, siteID;
  final String imeiNumber;

  @override
  State<ConfigMakerScreen> createState() => _ConfigMakerScreenState();
}

class _ConfigMakerScreenState extends State<ConfigMakerScreen> with SingleTickerProviderStateMixin{
  int selectedTab = 0;
  late TabController controller;

  @override
  void initState()
  {
    super.initState();
    controller = TabController(length: 12, vsync: this, initialIndex: 0);
    controller.addListener(_handleTabSelection);
    getProductLimit();
  }

  Future<void> getProductLimit() async
  {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    //configPvd.clearConfig();

    Map<String, Object> body = {"userId" : widget.customerID, "controllerId" : widget.siteID};
    print(body);
    final response = await HttpService().postRequest("getUserConfigMaker", body);
    if (response.statusCode == 200)
    {
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      configPvd.fetchAll(jsonData['data']);
      print('finish');
    }
    else{
      //_showSnackBar(response.body);
    }
  }


  @override
  void dispose() {
    // Dispose of your TabController and other resources here
    controller.dispose();
    super.dispose();
  }

  void _handleTabSelection()
  {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    setState(() {
      selectedTab = controller.index; // Store the selected tab index
    });
    configPvd.editInitialIndex(selectedTab);
    if(selectedTab != 5){
      configPvd.editLoadIL(false);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints)
    {
      if(constraints.maxWidth < 1000)
      {
        return DefaultTabController(
            length: configPvd.tabs.length,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0,1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          blurStyle: BlurStyle.outer,
                          color: Colors.black12
                      )
                    ],
                  ),
                  child: TabBar(
                    labelPadding: EdgeInsets.all(0),
                    controller: controller,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: [
                      for (var i = 0; i < configPvd.tabs.length; i++)
                        MediaQuery.of(context).orientation == Orientation.portrait ? Container(
                            height: 100,
                            width: 100,
                            child: Tab(
                              child: Container(
                                margin: EdgeInsets.all(5),
                                width: double.infinity,
                                decoration: selectedTab == i ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.blue
                                ) : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // color: selectedTab != i ? Colors.yellow : null,
                                      ),
                                      child: Icon(configPvd.tabs[i][2],size: selectedTab == i ? 30 : null,),
                                      padding: selectedTab == i ? EdgeInsets.all(2) : EdgeInsets.all(8),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${configPvd.tabs[i][0]}',
                                          style: TextStyle(color: Colors.black, fontSize: selectedTab == i ? 14 : 12),
                                        ),
                                        Text(
                                          '${configPvd.tabs[i][1]}',
                                          style: TextStyle(color: Colors.black, fontSize: selectedTab == i ? 14 : 12),
                                        ),

                                      ],
                                    )

                                  ],
                                ),
                              ),
                            )
                        ) : Container(
                          width: 200,
                          height: 40,
                          child: Tab(
                            child: Container(
                              margin: EdgeInsets.all(5),
                              width: double.infinity,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(configPvd.tabs[i][2]),
                                    Text('${configPvd.tabs[i][0]} ${configPvd.tabs[i][1]}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller,
                    children: [
                      StartPageConfigMaker(),
                      SourcePumpTable(),
                      IrrigationPumpTable(),
                      CentralDosingTable(),
                      CentralFiltrationTable(),
                      IrrigationLineTable(),
                      LocalDosingTable(),
                      LocalFiltrationTable(),
                      WeatherStationConfig(),
                      MappingOfOutputsTable(configPvd: configPvd,),
                      MappingOfInputsTable(configPvd: configPvd),
                      FinishPageConfigMaker(customerId: widget.customerID, controllerId: widget.siteID, userId: widget.userID, imeiNo: widget.imeiNumber,),
                    ],
                  ),
                )
              ],
            )
        );
      }else{
        return ConfigMakerForWeb(customerId: widget.customerID, controllerId: widget.siteID, userId: widget.userID, imeiNumber: widget.imeiNumber,);
      }
    },);
  }
}


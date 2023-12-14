// import 'dart:html';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
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
  const ConfigMakerScreen({super.key, required this.userId, required this.customerId, required this.controllerId, required this.imeiNumber});
  final int userId, customerId, controllerId;
  final String imeiNumber;

  @override
  State<ConfigMakerScreen> createState() => _ConfigMakerScreenState();
}

class _ConfigMakerScreenState extends State<ConfigMakerScreen> with SingleTickerProviderStateMixin{
  int selectedTab = 0;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    controller = TabController(length: 12, vsync: this, initialIndex: 0);
    controller.addListener(_handleTabSelection);
    getProductLimit(configPvd);

  }
  @override
  void dispose() {
    // Dispose of your TabController and other resources here
    controller.dispose();

    super.dispose();
  }
  void getProductLimit(ConfigMakerProvider configPvd)async{
    HttpService service = HttpService();
    // var response = await service.postRequest('getUserConfigMaker', {'userId' : 21,'controllerId' : 22});
    // var jsonData = response.body;
    // var myData = jsonDecode(jsonData);
    // print(myData);
    // configPvd.fetchAll(myData['data']);
  }

  void _handleTabSelection() {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    setState(() {
      selectedTab = controller.index; // Store the selected tab index
    });
    configPvd.editInitialIndex(selectedTab);
    if(selectedTab != 5){
      // configPvd.editLoadIL(false);
    }
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if(constraints.maxWidth < 1000){
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: (MediaQuery.of(context).orientation == Orientation.portrait || kIsWeb) ? null : 30,
            title: const Text('Config Maker'),
          ),
          body: DefaultTabController(
              length: configPvd.tabs.length,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    //color: Color(0XFFF3F3F3),
                    child: TabBar(
                        controller: controller,
                        indicatorColor: myTheme.primaryColor,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                        isScrollable: true,
                        tabs: [
                          for(var i = 0;i < configPvd.tabs.length;i++)
                            Tab(
                              text: '${configPvd.tabs[i][0]} ${configPvd.tabs[i][1]}',
                            ),
                        ]
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        const StartPageConfigMaker(),
                        const SourcePumpTable(),
                        const IrrigationPumpTable(),
                        const CentralDosingTable(),
                        const CentralFiltrationTable(),
                        const IrrigationLineTable(),
                        const LocalDosingTable(),
                        const LocalFiltrationTable(),
                        const WeatherStationConfig(),
                        MappingOfOutputsTable(configPvd: configPvd,),
                        MappingOfInputsTable(configPvd: configPvd),
                        //FinishPageConfigMaker(customerId: widget.customerID, controllerId: widget.siteID, userId: widget.userID, imeiNo: widget.imeiNumber,),
                      ],
                    ),
                  )
                ],
              )
          ),
        );
      }else{
        return  ConfigMakerForWeb(userID: widget.userId, customerID: widget.customerId, siteId: widget.controllerId,);
      }
    },);
  }
}


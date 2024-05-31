import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../Models/product_limit_model.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/config_maker_provider.dart';
import 'config_maker/config_maker.dart';
import 'config_screen.dart';
import 'dealer_definition_config.dart';

class ProductLimits extends StatefulWidget {
  const ProductLimits({Key? key, required this.userID,  required this.customerID, required this.userType, required this.inputCount, required this.siteName, required this.controllerId, required this.deviceId, required this.outputCount, required this.myCatIds}) : super(key: key);
  final int userID, customerID, userType, inputCount,outputCount, controllerId;
  final String siteName, deviceId;
  final List<int> myCatIds;


  @override
  State<ProductLimits> createState() => _ProductLimitsState();
}

class _ProductLimitsState extends State<ProductLimits> with SingleTickerProviderStateMixin {

  int filledOutputCount = 0;
  int filledInputCount = 0;
  int currentTxtFldVal = 0;
  List<MdlProductLimit> productLimits = <MdlProductLimit>[];

  var myControllers = [];
  bool visibleLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    getProductLimits();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      if(_tabController.index==0){
        getProductLimits();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in myControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> getProductLimits() async
  {
    indicatorViewShow();
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic> body = {"userId" : widget.customerID, "controllerId" : widget.controllerId};
    final response = await HttpService().postRequest("getUserProductLimit", body);
    if (response.statusCode == 200)
    {
      print(response.body);
      productLimits.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        myControllers = [];
        filledOutputCount = 0;
        filledInputCount = 0;
        for (int i = 0; i < cntList.length; i++) {
          bool existsInCategory = widget.myCatIds.any((value) => cntList[i]['category'].contains(value.toString()));
          if (existsInCategory) {
            productLimits.add(MdlProductLimit.fromJson(cntList[i]));
            myControllers.add(TextEditingController(text: "${cntList[i]['quantity']}"));
            int quantity = cntList[i]['quantity']!;
            if(cntList[i]['connectionType'] == 'Output'){
              filledOutputCount += quantity;
            }else if(cntList[i]['connectionType']=='Input'){
              filledInputCount += quantity;
            }else{
              //other common count...
            }
          } else {
            print("None of the values");
          }
        }
      }
      setState(() {
        productLimits;
        indicatorViewHide();
      });

    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> updateProductLimit() async
  {
    for (int i=0; i < productLimits.length; i++) {
      if(myControllers[i].text==""){
        myControllers[i].text = "0";
      }
      productLimits[i].quantity = int.parse(myControllers[i].text);
    }

    Map<String, dynamic> body = {
      "userId": widget.customerID,
      "controllerId": widget.controllerId,
      "productLimit": productLimits,
      "createUser": widget.userID,
    };
    final response = await HttpService().postRequest("createUserProductLimit", body);
    if(response.statusCode == 200)
    {
      var data = jsonDecode(response.body);
      if(data["code"]==200) {
        _showSnackBar(data["message"]);
      }
      else{
        _showSnackBar(data["message"]);
      }
    }
  }


  @override
  Widget build(BuildContext context)
  {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteName),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(text: 'Product limit'),
              Tab(text: 'Config maker'),
              Tab(text: 'Others'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  height: mediaQuery.size.height-230,
                  color:  Colors.white,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            itemCount: productLimits.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsetsDirectional.all(5.0),
                                decoration:  BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black38, // Border color
                                    width: 1.0,          // Border width
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded (
                                      flex:1,
                                      child : Container(
                                        constraints: const BoxConstraints.expand(),
                                        decoration: BoxDecoration(
                                          color: myTheme.primaryColor.withOpacity(0.2),
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircleAvatar(radius: 17,
                                            backgroundImage: productLimits[index].product == 'Valve'?
                                            const AssetImage('assets/images/valve_gray.png'):
                                            productLimits[index].product == 'Main Valve'?
                                            const AssetImage('assets/images/main_valve.png'):
                                            productLimits[index].product == 'Source Pump'?
                                            const AssetImage('assets/images/source_pump.png'):
                                            productLimits[index].product == 'Irrigation Pump'?
                                            const AssetImage('assets/images/irrigation_pump.png'):
                                            productLimits[index].product == 'Analog Sensor'?
                                            const AssetImage('assets/images/analog_sensor.png'):
                                            productLimits[index].product == 'Level Sensor'?
                                            const AssetImage('assets/images/level_sensor.png'):
                                            productLimits[index].product == 'Booster Pump'?
                                            const AssetImage('assets/images/booster_pump.png'):
                                            productLimits[index].product == 'Central Fertilizer Site'?
                                            const AssetImage('assets/images/central_fertilizer_site.png'):
                                            productLimits[index].product == 'Central Filter Site'?
                                            const AssetImage('assets/images/central_filtration_site.png'):
                                            productLimits[index].product == 'Agitator'?
                                            const AssetImage('assets/images/agitator.png'):
                                            productLimits[index].product == 'Injector'?
                                            const AssetImage('assets/images/injector.png'):
                                            productLimits[index].product == 'Filter'?
                                            const AssetImage('assets/images/filter.png'):
                                            productLimits[index].product == 'Downstream Valve'?
                                            const AssetImage('assets/images/downstream_valve.png'):
                                            productLimits[index].product == 'Fan'?
                                            const AssetImage('assets/images/fan.png'):
                                            productLimits[index].product == 'Fogger'?
                                            const AssetImage('assets/images/fogger.png'):
                                            productLimits[index].product == 'Selector'?
                                            const AssetImage('assets/images/selector.png'):
                                            productLimits[index].product == 'Water Meter'?
                                            const AssetImage('assets/images/water_meter.png'):
                                            productLimits[index].product == 'Fertilizer Meter'?
                                            const AssetImage('assets/images/fertilizer_meter.png'):
                                            productLimits[index].product == 'Co2 Sensor'?
                                            const AssetImage('assets/images/co2.png'):
                                            productLimits[index].product == 'Pressure Switch'?
                                            const AssetImage('assets/images/pressure_switch.png'):
                                            productLimits[index].product == 'Pressure Sensor'?
                                            const AssetImage('assets/images/pressure_sensor.png'):
                                            productLimits[index].product == 'Pressure Sensor'?
                                            const AssetImage('assets/images/pressure_sensor.png'):
                                            productLimits[index].product == 'Differential Pressure Sensor'?
                                            const AssetImage('assets/images/differential_pressure_sensor.png'):
                                            productLimits[index].product == 'EC Sensor'?
                                            const AssetImage('assets/images/ec_sensor.png'):
                                            productLimits[index].product == 'PH Sensor'?
                                            const AssetImage('assets/images/ph_sensor.png'):
                                            productLimits[index].product == 'Temperature Sensor'?
                                            const AssetImage('assets/images/temperature_sensor.png'):
                                            productLimits[index].product == 'Soil Temperature Sensor'?
                                            const AssetImage('assets/images/soil_temperature_sensor.png'):
                                            productLimits[index].product == 'Wind Direction Sensor'?
                                            const AssetImage('assets/images/wind_direction_sensor.png'):
                                            productLimits[index].product == 'Wind Speed Sensor'?
                                            const AssetImage('assets/images/wind_speed_sensor.png'):
                                            productLimits[index].product == 'LUX Sensor'?
                                            const AssetImage('assets/images/lux_sensor.png'):
                                            productLimits[index].product == 'LDR Sensor'?
                                            const AssetImage('assets/images/ldr_sensor.png'):
                                            productLimits[index].product == 'Humidity Sensor'?
                                            const AssetImage('assets/images/humidity_sensor.png'):
                                            productLimits[index].product == 'Leaf Wetness Sensor'?
                                            const AssetImage('assets/images/leaf_wetness_sensor.png'):
                                            productLimits[index].product == 'Rain Gauge Sensor'?
                                            const AssetImage('assets/images/rain_gauge_sensor.png'):
                                            productLimits[index].product == 'Contact'?
                                            const AssetImage('assets/images/contact.png'):
                                            productLimits[index].product == 'Weather Station'?
                                            const AssetImage('assets/images/weather_station.png'):
                                            productLimits[index].product == 'Condition'?
                                            const AssetImage('assets/images/condition.png'):
                                            productLimits[index].product == 'Valve Group'?
                                            const AssetImage('assets/images/valve_group.png'):
                                            productLimits[index].product == 'Virtual Water Meter'?
                                            const AssetImage('assets/images/virtual_water_meter.png'):
                                            productLimits[index].product == 'Program'?
                                            const AssetImage('assets/images/programs.png'):
                                            productLimits[index].product == 'Radiation Set'?
                                            const AssetImage('assets/images/radiation_sets.png'):
                                            productLimits[index].product == 'Fertilizer Set'?
                                            const AssetImage('assets/images/fertilization_sets.png'):
                                            productLimits[index].product == 'Filter Set'?
                                            const AssetImage('assets/images/filter_sets.png'):
                                            const AssetImage('assets/images/water_source.png'),
                                            backgroundColor: Colors.transparent,

                                          ),
                                        ),
                                      ),),
                                    Expanded(
                                      flex :2,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: TextField(
                                              controller: myControllers[index],
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                labelText: productLimits[index].product,
                                              ),
                                              onTap: () {
                                                currentTxtFldVal = int.parse(myControllers[index].text);
                                                print(currentTxtFldVal);
                                              },
                                              onChanged: (input) async {
                                                await Future.delayed(const Duration(milliseconds: 50));
                                                filledOutputCount = 0;
                                                filledInputCount = 0;
                                                for (int i = 0; i < productLimits.length; i++) {
                                                  var controller = myControllers[i];
                                                  if (productLimits[i].connectionType == 'Output') {
                                                    filledOutputCount += int.tryParse(controller.text) ?? 0; // Accumulate value for 'Output'
                                                  } else if (productLimits[i].connectionType == 'Input') {
                                                    filledInputCount += int.tryParse(controller.text) ?? 0; // Accumulate value for 'Input'
                                                  } else {
                                                    // Handle other cases if needed
                                                  }
                                                }
                                                setState(() {
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),)
                                  ],
                                ),
                              );
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                              childAspectRatio: mediaQuery.size.width / 460,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        color: Colors.teal.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Total Output :'),
                            const SizedBox(width: 10,),
                            Text('${widget.outputCount}', style: const TextStyle(fontSize: 17),),
                            const SizedBox(width: 20,),
                            const Text('Remaining :'),
                            const SizedBox(width: 10,),
                            Text('${widget.outputCount - filledOutputCount}', style: TextStyle(fontSize: 17, color:
                            (widget.outputCount - filledOutputCount) >= 0 ? Colors.black: Colors.red)),
                            const Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: VerticalDivider(),
                            ),
                            const Text('Total Input :'),
                            const SizedBox(width: 10,),
                            Text('${widget.inputCount}', style: const TextStyle(fontSize: 17),),
                            const SizedBox(width: 20,),
                            const Text('Remaining :'),
                            const SizedBox(width: 10,),
                            Text('${widget.inputCount - filledInputCount}', style: TextStyle(fontSize: 17, color:
                            (widget.inputCount - filledInputCount) >= 0 ? Colors.black : Colors.red)),
                            const Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: VerticalDivider(),
                            ),
                            TextButton.icon(
                              onPressed: (){
                                updateProductLimit();
                              },
                              label: const Text('Save'),
                              icon: const Icon(
                                Icons.save_as_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                ConfigMakerScreen(userID: widget.userID, customerID: widget.customerID, siteID: widget.controllerId, imeiNumber: widget.deviceId,),
                ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.siteName, controllerId: widget.controllerId, imeiNumber: widget.deviceId,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}

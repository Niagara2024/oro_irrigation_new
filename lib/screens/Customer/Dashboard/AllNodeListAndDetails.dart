import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/theme.dart';

class AllNodeListAndDetails extends StatefulWidget {
  const AllNodeListAndDetails({Key? key, required this.userID, required this.customerID, required this.masterInx, required this.siteData}) : super(key: key);
  final int userID, customerID, masterInx;
  final DashboardModel siteData;

  @override
  State<AllNodeListAndDetails> createState() => _AllNodeListAndDetailsState();
}

class _AllNodeListAndDetailsState extends State<AllNodeListAndDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('All Node list and details'),
        actions: [
          IconButton(tooltip: 'Set serial for all nodes', onPressed: (){
            /*String payLoadFinal = jsonEncode({
              "2300": [
                {"2301": "${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].serialNumber}"},
              ]
            });*/
            //MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
          }, icon: const Icon(Icons.format_list_numbered)),
          const SizedBox(width: 5,),
          IconButton(tooltip: 'Test communication', onPressed: (){
            /*String payLoadFinal = jsonEncode({
              "2300": [
                {"2301": "${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].serialNumber}"},
              ]
            });*/
            //MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
          }, icon: const Icon(Icons.network_check)),
          const SizedBox(width: 10,)
        ],
      ),
      body: ListView(
        children: [
          for (int i = 0; i < widget.siteData.master[widget.masterInx].gemLive[0].nodeList.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: const RoundedRectangleBorder(),
                  surfaceTintColor: Colors.white,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    tileColor: myTheme.primaryColor.withOpacity(0.1),
                    title: Text(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].categoryName),
                    subtitle: Text(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].deviceId),
                    leading: const CircleAvatar(radius:10, backgroundColor: Colors.green,),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.solar_power_outlined),
                        const SizedBox(width: 5,),
                        Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                        const SizedBox(width: 5,),
                        const Icon(Icons.battery_3_bar_rounded),
                        Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                        const SizedBox(width: 5,),
                        IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                          String payLoadFinal = jsonEncode({
                            "2300": [
                              {"2301": "${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].serialNumber}"},
                            ]
                          });
                          MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
                        }, icon: const Icon(Icons.fact_check_outlined))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 5),
                        child: Text('Outputs', style: TextStyle(fontSize: 17, color: Colors.teal),),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].rlyStatus.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10,
                        ),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              surfaceTintColor: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey,
                                    child: Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].rlyStatus[index].rlyNo}', style: const TextStyle(color: Colors.black, fontSize: 12)),
                                  ),
                                  const SizedBox(height: 5,),
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(getImageForProduct(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].rlyStatus[index].name!)),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  Text(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].rlyStatus[index].name!, style: const TextStyle(color: Colors.black, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                        child: Text('Inputs', style: TextStyle(fontSize: 17, color: Colors.teal),),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10,
                        ),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              surfaceTintColor: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /*CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey,
                                    child: Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].id}', style: const TextStyle(color: Colors.black, fontSize: 12)),
                                  ),
                                  const SizedBox(height: 5,),*/

                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(getImageForProduct(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].Name!)),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  Container(width: 40, height: 14,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.yellow,
                                      ),
                                      child: Center(child: Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].Value}', style: const TextStyle(color: Colors.black, fontSize: 10)))
                                  ),
                                  /*Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: AssetImage(getImageForProduct(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].Name!)),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      Positioned(
                                        top: 40,
                                        left: 0,
                                        child: Container(width: 40, height: 14,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: Colors.yellow,
                                            ),
                                            child: Center(child: Text('${widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].Value}', style: const TextStyle(color: Colors.black, fontSize: 10)))
                                        ),
                                      ),
                                    ],
                                  ),*/
                                  const SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.siteData.master[widget.masterInx].gemLive[0].nodeList[i].sensor[index].Name!, style: const TextStyle(color: Colors.black, fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String getImageForProduct(String product) {
    String baseImgPath = 'assets/images/';
    String value = product.substring(0, 2);
    switch (value) {
      case 'VL':
        return '${baseImgPath}dl_valve.png';
      case 'MV':
        return '${baseImgPath}dl_main_valve.png';
      case 'SP':
        return '${baseImgPath}dl_source_pump.png';
      case 'IP':
        return '${baseImgPath}dl_irrigation_pump.png';
      case 'AS':
        return '${baseImgPath}dl_analog_sensor.png';
      case 'LS':
        return '${baseImgPath}dl_level_sensor.png';
      case 'FB':
        return '${baseImgPath}dl_booster_pump.png';
      case 'Central Filter Site':
        return '${baseImgPath}dl_central_filtration_site.png';
      case 'AG':
        return '${baseImgPath}dl_agitator.png';
      case 'Injector':
        return '${baseImgPath}dl_injector.png';
      case 'FL':
        return '${baseImgPath}dl_filter.png';
      case 'Downstream Valve':
        return '${baseImgPath}dl_downstream_valve.png';
      case 'Fan':
        return '${baseImgPath}dl_fan.png';
      case 'FB':
        return '${baseImgPath}dl_fogger.png';
      case 'SL':
        return '${baseImgPath}dl_selector.png';
      case 'Water Meter':
        return '${baseImgPath}dl_water_meter.png';
      case 'FM':
        return '${baseImgPath}dl_fertilizer_meter.png';
      case 'Co2 Sensor':
        return '${baseImgPath}dl_co2.png';
      case 'PSW':
        return '${baseImgPath}dl_pressure_switch.png';
      case 'LO':
        return '${baseImgPath}dl_pressure_sensor.png';
      case 'Differential Pressure Sensor':
        return '${baseImgPath}dl_differential_pressure_sensor.png';
      case 'EC':
        return '${baseImgPath}dl_ec_sensor.png';
      case 'PH':
        return '${baseImgPath}dl_ph_sensor.png';
      case 'Temperature':
        return '${baseImgPath}dl_temperature_sensor.png';
      case 'Soil Temperature Sensor':
        return '${baseImgPath}dl_soil_temperature_sensor.png';
      case 'Wind Direction Sensor':
        return '${baseImgPath}dl_wind_direction_sensor.png';
      case 'Wind Speed Sensor':
        return '${baseImgPath}dl_wind_speed_sensor.png';
      case 'LUX Sensor':
        return '${baseImgPath}dl_lux_sensor.png';
      case 'LDR Sensor':
        return '${baseImgPath}dl_ldr_sensor.png';
      case 'Humidity Sensor':
        return '${baseImgPath}dl_humidity_sensor.png';
      case 'Leaf Wetness Sensor':
        return '${baseImgPath}dl_leaf_wetness_sensor.png';
      case 'Rain Gauge Sensor':
        return '${baseImgPath}dl_rain_gauge_sensor.png';
      case 'Contact':
        return '${baseImgPath}dl_contact.png';
      case 'Weather Station':
        return '${baseImgPath}dl_weather_station.png';
      case 'Condition':
        return '${baseImgPath}dl_condition.png';
      case 'Valve Group':
        return '${baseImgPath}dl_valve_group.png';
      case 'Virtual Water Meter':
        return '${baseImgPath}dl_virtual_water_meter.png';
      case 'Program':
        return '${baseImgPath}dl_programs.png';
      case 'Radiation Set':
        return '${baseImgPath}dl_radiation_sets.png';
      case 'FC':
        return '${baseImgPath}dl_fertilization_sets.png';
      case 'Filter Set':
        return '${baseImgPath}dl_filter_sets.png';
      case 'SM':
        return '${baseImgPath}dl_moisture_sensor.png';
      case 'Float':
        return '${baseImgPath}dl_float.png';
      case 'Moisture Condition':
        return '${baseImgPath}dl_moisture_condition.png';
      case 'Tank Float':
        return '${baseImgPath}dl_tank_float.png';
      case 'Power Supply':
        return '${baseImgPath}dl_power_supply.png';
      case 'Level Condition':
        return '${baseImgPath}dl_level_condition.png';
      case 'Common Pressure Sensor':
        return '${baseImgPath}dl_common_pressure_sensor.png';
      case 'SW':
        return '${baseImgPath}dl_common_pressure_switch.png';
      default:
        return '${baseImgPath}dl_humidity_sensor.png';
    }
  }


}

import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import 'CentralFilter.dart';
import 'IrrigationPumpList.dart';


class MainLine extends StatefulWidget {
  const MainLine({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<MainLine> createState() => _MainLineState();
}

class _MainLineState extends State<MainLine> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('MAIN LINE - CENTRAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: widget.siteData.irrigationPump.isNotEmpty? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.siteData.irrigationPump.isNotEmpty? const IrrigationPumpList(): const SizedBox(),
                    widget.siteData.centralFilterSite.isNotEmpty? const CentralFilter(): const SizedBox(),
                    widget.siteData.centralFertilizerSite.isNotEmpty? const CentralFertilizer(): const SizedBox(),
                  ],
                ) :
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Main line installation pending', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}

class CentralFertilizer extends StatefulWidget {
  const CentralFertilizer({Key? key}) : super(key: key);

  @override
  State<CentralFertilizer> createState() => _CentralFertilizerState();
}

class _CentralFertilizerState extends State<CentralFertilizer> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);

    return provider.fertilizerCentral.isNotEmpty? Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 52),
            child: Container(
              width: 4,
              height: 175,
              color: Colors.black45,
            ),
          ),
          SizedBox(
            width: (provider.fertilizerCentral[0]['Fertilizer'].length * 75) + 150,
            height: 225,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 70,
                  height: 210,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset('assets/images/dp_fert_booster_pump.png'),
                      ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset('assets/images/dp_fert_nrv.png'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 210,
                  width: provider.fertilizerCentral[0]['Fertilizer'].length * 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.fertilizerCentral[0]['Fertilizer'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var fertilizer = provider.fertilizerCentral[0]['Fertilizer'][index];
                      return Row(
                        children: [
                          SizedBox(
                            width: 70, // Set the desired width for each fertilizer item
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: index==0?Image.asset('assets/images/dp_fert_first_tank.png',):
                                  index == provider.fertilizerCentral[0]['Fertilizer'].length - 1
                                      ? Image.asset('assets/images/dp_fert_last_tank.png',):
                                  Image.asset('assets/images/dp_fert_center_tank.png',),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Column(
                                    children: [
                                      PopupMenuButton(
                                        tooltip: 'Details',
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(provider.fertilizerCentral[0]['FertilizerSite'], style: const TextStyle(fontWeight: FontWeight.bold),),
                                                  const Divider(),
                                                  Text(fertilizer['Name']),
                                                ],
                                              ),
                                            ),
                                          ];
                                        },
                                        child : Stack(
                                          children: [
                                            buildFertCheImage(index, fertilizer['Status'], provider.fertilizerCentral[0]['Fertilizer'].length),
                                            Positioned(
                                              top: 47.8,
                                              left: 10,
                                              child: fertilizer['DurationLeft']!='00:00:00'? fertilizer['Status'] == (index+1) ? Container(
                                                color: Colors.greenAccent,
                                                width: 50,
                                                child: Center(
                                                  child: Text(fertilizer['DurationLeft'], style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  ),
                                                ),
                                              ) :
                                              const SizedBox(): const SizedBox(),
                                            ),
                                            /*Positioned(
                                              top: 0,
                                              left: 25,
                                              child: provider.filtersCentral[i]['PrsIn']!='-'? Container(
                                                  decoration: const BoxDecoration(
                                                    color:Colors.yellow,
                                                    borderRadius: BorderRadius.all(Radius.circular(2)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 3,right: 3),
                                                    child: Text('${provider.filtersCentral[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                                  )
                                              ):
                                              const SizedBox(),
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                                index==0 ? SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Selector'),
                                      Container(
                                        color: Colors.green.shade100,
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Center(child: const Text('1', style: TextStyle(fontSize: 17),)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) :
                                const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 210,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset('assets/images/dp_agitator_right.png'),
                      ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Container(
                          color: Colors.green.shade100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('EC Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const Text('0.00', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                              const Text('EC Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const Text('0.00', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Container(
                          color: Colors.orange.shade100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('PH Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const Text('0.00', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                              const Text('PH Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              const Text('0.00', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ) :
    const SizedBox();
  }

  Widget buildFertCheImage(int cIndex, int status, int cheLength) {
    String imageName;

    if(cIndex == cheLength - 1){
      imageName='dp_fert_channel_last';
    }else{
      imageName='dp_fert_channel_center';
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      default:
        imageName += '_r.png';
    }

    return Image.asset('assets/images/$imageName');

  }

}
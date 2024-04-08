import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/data_convertion.dart';
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

  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
                      provider.fertilizerCentral[0]['Booster'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: 70,
                        child: provider.fertilizerCentral[0]['Booster'][0]['Status'] ==1 ?
                        Image.asset('assets/images/dp_fert_booster_pump_g.png') :
                        provider.fertilizerCentral[0]['Booster'][0]['Status']==2 ?
                        Image.asset('assets/images/dp_fert_booster_pump_y.png') :
                        Image.asset('assets/images/dp_fert_booster_pump.png'),
                      ) :
                      const SizedBox(),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset('assets/images/dp_fert_nrv.png'),
                      ),
                      const SizedBox(
                        width: 70,
                        height: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 5,),
                            Text('Channel', style: TextStyle(fontSize: 10),),
                            SizedBox(height: 5,),
                            Text('Set', style: TextStyle(fontSize: 10),),
                            SizedBox(height: 5,),
                            Text('Flow(L/h)', style: TextStyle(fontSize: 10),),
                          ],
                        ),
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
                                  child: Stack(
                                    children: [
                                      buildFertCheImage(index, fertilizer['Status'], provider.fertilizerCentral[0]['Fertilizer'].length),
                                      Positioned(
                                        top: 0,
                                        left: 10,
                                        child: fertilizer['Status'] !=0 ? Container(
                                          color: Colors.greenAccent,
                                          width: 50,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                                ? fertilizer['DurationLeft']
                                                : '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' , style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ) :
                                        const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 5,),
                                      Text(fertilizer['Name'], style: TextStyle(fontSize: 10),),
                                      SizedBox(height: 5,),
                                      Text(fertilizer['FertMethod']=='1'? fertilizer['Duration']:'${fertilizer['Qty']} L', style: TextStyle(fontSize: 10),),
                                      SizedBox(height: 5,),
                                      Text('${fertilizer['Qty']}', style: TextStyle(fontSize: 10),),
                                    ],
                                  ),
                                ),
                                /*index==0 ? SizedBox(
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
                                          child: Center(child: Text(provider.fertilizerCentral[0]['FertilizerTankSelector'].isNotEmpty? provider.fertilizerCentral[0]['FertilizerTankSelector'][0]['Name'] :'0', style: const TextStyle(fontSize: 17),)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ) :
                                const SizedBox(),*/
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
                        width: 75,
                        height: 65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.green.shade500,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade200,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                                ),
                                width: 70, height: 20,
                                child: const Center(child: Text('EC',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                              ),
                              SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)),
                                  const Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                              SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)),
                                  const Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: 75,
                        height: 65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.orange.shade500,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade200,
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                                ),
                                width: 75, height: 20,
                                child: const Center(child: Text('PH',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                              ),
                              SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)),
                                  const Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                              SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10)),
                                  const Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
      case 3:
        imageName += '.png';
        break;
      default:
        imageName += '_r.png';
    }

    return Image.asset('assets/images/$imageName');

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.fertilizerCentral[0]['Fertilizer'].length; i++) {

          if(provider.fertilizerCentral[0]['Fertilizer'][i]['Status']!=0){

            if(provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']=='1' ||
                provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']=='3')
            {
              List<String> parts = provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft'].split(':');
              int hours = int.parse(parts[0]);
              int minutes = int.parse(parts[1]);
              int seconds = int.parse(parts[2]);

              if (seconds > 0) {
                seconds--;
              } else {
                if (minutes > 0) {
                  minutes--;
                  seconds = 59;
                } else {
                  if (hours > 0) {
                    hours--;
                    minutes = 59;
                    seconds = 59;
                  }
                }
              }

              String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
              if(provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']=='3')
              {
                double onTime = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime']);
                double offTime = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime']);

                if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'] == null) {
                  provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'];
                }
                if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'] == null) {
                  provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'];
                }
                if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'] == null) {
                  provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerCentral[0]['Fertilizer'][i]['Status'];
                }

                if(onTime.toInt()>0){
                  int updatedOnTime = onTime.toInt() - 1;
                  provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                  setState(() {
                    provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                    provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'];
                  });
                }else if(offTime.toInt()>0){
                  int updatedOffTime = offTime.toInt() - 1;
                  provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                  setState(() {
                    provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 3;
                  });
                  if(updatedOffTime==0){
                    provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'];
                    provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'];
                  }
                }
              }
              else
              {
                if(provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft']!='00:00:00'){
                  setState(() {
                    provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                  });
                }
              }
            }
            else
            {
              double qtyDouble = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['Qty']);
              int roundedQty = qtyDouble.round();
              double qtyLeftDouble = provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'];
              int roundedQtyLeft = qtyLeftDouble.round();

              if(roundedQty >= roundedQtyLeft) {
                setState(() {
                  if(provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']=='4' ||
                      provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']=='5') {
                    double onTime = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime']);
                    double offTime = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime']);

                    if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'] == null) {
                      provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'];
                    }
                    if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'] == null) {
                      provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'];
                    }
                    if (provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'] == null) {
                      provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerCentral[0]['Fertilizer'][i]['Status'];
                    }

                    if(onTime.round()>0){
                      int updatedOnTime = onTime.round() - 1;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                      setState(() {
                        double remainQty = provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'];
                        double flowRate = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['FlowRate']);
                        remainQty = remainQty - flowRate;
                        provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                        provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalStatus'];
                        if(offTime.round() <=0){
                          provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'];
                          provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'];
                        }
                      });
                    }else if(offTime.round()>0){
                      int updatedOffTime = offTime.round() - 1;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                      setState(() {
                        provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 3;
                      });
                      if(updatedOffTime==0){
                        provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'];
                        provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'];
                      }
                    }else{
                      //provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'];
                     // provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'];
                    }

                  }
                  else{
                    double remainQty = provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'];
                    double flowRate = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['FlowRate']);
                    remainQty = remainQty - flowRate;
                    provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                  }

                });
              }else{
                setState(() {
                  provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'] = provider.fertilizerCentral[0]['Fertilizer'][i]['Qty'];
                });
              }
            }
            /*else if(['3','4','5'].contains(provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']))
            {
              print('proportionate : ${provider.fertilizerCentral[0]['Fertilizer'][i]['FertMethod']}');
              setState(() {

                dynamic onOffMode = provider.fertilizerCentral[0]['Fertilizer'][i]['onOffMode'];
                if(onOffMode == null){
                  provider.fertilizerCentral[0]['Fertilizer'][i]['onOffMode'] = 1;
                  provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] = 0;
                  provider.fertilizerCentral[0]['Fertilizer'][i]['statusFromNode'] = 0;
                  provider.fertilizerCentral[0]['Fertilizer'][i]['totalSeconds'] = DataConvert().parseTimeString(provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft']);
                }else{
                  if(provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] == 1){
                    provider.fertilizerCentral[0]['Fertilizer'][i]['statusFromNode'] = 1;
                  }
                  int statusFromNode = provider.fertilizerCentral[0]['Fertilizer'][i]['statusFromNode'];
                  if(onOffMode == 1){
                    if(provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] < double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime']).toInt()){
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] += 1;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['totalSeconds'] -= 1;
                      double remainQty = provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'];
                      double flowRate = double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['FlowRate']);
                      remainQty = remainQty - flowRate;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['QtyLeft'] = remainQty;
                      //var totalSeconds = DataConvert().parseTimeString(provider.fertilizerCentral[0]['Fertilizer'][i]['DurationLeft']);
                      provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = statusFromNode == 0 ? 2 : 1;
                    }else{
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffMode'] = 2;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] = 0;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 3;
                    }

                  }else{
                    if(provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] < double.parse(provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime']).toInt()){
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] += 1;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 3;
                    }else{
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffMode'] = 1;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['onOffValue'] = 0;
                      provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = statusFromNode == 0 ? 2 : 1;
                    }
                  }
                }
              });
            }*/

          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }

}
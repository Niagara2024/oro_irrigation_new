import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../state_management/MqttPayloadProvider.dart';


class PumpLineCentral extends StatefulWidget {
  const PumpLineCentral({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<PumpLineCentral> createState() => _PumpLineCentralState();
}

class _PumpLineCentralState extends State<PumpLineCentral> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child : ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, left: 5),
                        child: widget.siteData.irrigationPump.isNotEmpty? SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  provider.irrigationPump.isNotEmpty? SizedBox(
                                    width: 52.50,
                                    height: 70,
                                    child : Stack(
                                      children: [
                                        Image.asset('assets/images/dp_sump.png'),
                                      ],
                                    ),
                                  ):
                                  const SizedBox(),
                                  widget.siteData.irrigationPump.isNotEmpty? const DisplayIrrigationPump() : const SizedBox(),
                                  provider.payload2408.isNotEmpty? const DisplaySensor() : const SizedBox(),
                                  widget.siteData.centralFilterSite.isNotEmpty? const DisplayFilter(): const SizedBox(),
                                  provider.irrigationPump.isNotEmpty? SizedBox(
                                    width: 28,
                                    height: 70,
                                    child : Stack(
                                      children: [
                                        Image.asset('assets/images/joining_line.png',),
                                      ],
                                    ),
                                  ):
                                  const SizedBox(),
                                  widget.siteData.centralFertilizerSite.isNotEmpty? const DisplayFertilizer(): const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ):
                        const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('CENTRAL SITE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class DisplayIrrigationPump extends StatefulWidget {
  const DisplayIrrigationPump({Key? key}) : super(key: key);

  @override
  State<DisplayIrrigationPump> createState() => _DisplayIrrigationPumpState();
}

class _DisplayIrrigationPumpState extends State<DisplayIrrigationPump> {

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
    return provider.irrigationPump.isNotEmpty? SizedBox(
      width: provider.irrigationPump.length * 70,
      height: 90,
      child: ListView.builder(
        itemCount: provider.irrigationPump.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: displayIrrigationPumpIcon(index, provider.irrigationPump[index]['Status']),
                  ),
                  provider.irrigationPump[index]['OnDelayLeft'] !='00:00:00'?
                  Positioned(
                    top: 47.7,
                    left: 10,
                    child: Container(
                      color: Colors.greenAccent,
                      width: 50,
                      child: Center(
                        child: Text(provider.irrigationPump[index]['OnDelayLeft'], style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ) :
                  const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 20,
                child: Center(
                  child: Text(provider.irrigationPump[index]['Name'], style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ) : const SizedBox();

  }

  Widget displayIrrigationPumpIcon(int cIndex, int status) {
    String imageName = 'dp_irr_pump';
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

  /*Widget displayIrrigationPumpIcon(int cIndex, int status, int irPumpLength) {
    String imageName;
    if (irPumpLength == 1) {
      imageName = 'dp_irr_pump_1';
    } else if (irPumpLength == 2) {
      imageName = cIndex == 0 ? 'dp_irr_pump_2' : 'dp_irr_pump_3';
    } else {
      switch (irPumpLength) {
        case 3:
          imageName = cIndex == 0 ? 'dp_irr_pump_2' : (cIndex == 1 ? 'dp_irr_pump_2' : 'dp_irr_pump_3');
          break;
        case 4:
          imageName = cIndex == 0 ? 'dp_irr_pump_2' : (cIndex == 1 ? 'dp_irr_pump_2' : (cIndex == 2 ? 'dp_irr_pump_2' : 'dp_irr_pump_3'));
          break;
        default:
          imageName = 'dp_irr_pump_3';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.gif';
        break;
      case 2:
        imageName += '_y.gif';
        break;
      default:
        imageName += '_r.gif';
    }

    if(imageName.contains('.png')){
      return Image.asset('assets/images/$imageName');
    }
    return Image.asset('assets/GifFile/$imageName');
  }*/

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.irrigationPump.length; i++) {
          if(provider.irrigationPump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.irrigationPump[i]['OnDelayLeft'].split(':');
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
            if(provider.irrigationPump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.irrigationPump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }
}


class DisplaySensor extends StatelessWidget {
  const DisplaySensor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    Map<String, dynamic> jsonData = provider.payload2408[0];
    double totalWidth = 0.0;

    for( var key in jsonData.keys){
      dynamic value = jsonData[key];
      if(key!='Line'){
        if(value!='-'){
          totalWidth += 70;
        }
      }
    }
    //print(totalWidth);

    return jsonData.isNotEmpty  ? SizedBox(
      width: totalWidth,
      height: 85,
      child: ListView.builder(
        itemCount: jsonData.keys.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String key = jsonData.keys.elementAt(index);
          dynamic value = jsonData[key];
          print(value);
          return index!=0 && value !='-' ? Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: key=='PrsIn' || key=='PrsOut' ? Image.asset('assets/images/dp_prs_sensor.png') : Image.asset('assets/images/dp_flowmeter.png'),
                  ),
                  Positioned(
                    top: 42,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 15,
                      decoration: BoxDecoration(
                        color:Colors.yellow,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.grey, width: .50,),
                      ),
                      child: Center(
                        child: Text('$value', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 57,
                    left: 0,
                    child: SizedBox(
                      width: 70,
                      child: Center(
                        child: Text(jsonData['Line'], style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ):
          const SizedBox();
        },
      ),
    ) : const SizedBox();

    /*return provider.payload2408.isNotEmpty? SizedBox(
      width: provider.payload2408.length * 70,
      height: 85,
      child: ListView.builder(
        itemCount: provider.payload2408.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Image.asset('assets/images/dp_prs_sensor.png'),
              ),
              Positioned(
                top: 47.7,
                left: 18,
                child: Container(
                  color: Colors.greenAccent,
                  width: 35,
                  child: Center(
                    child: Text(provider.payload2408[index]['PrsIn'], style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 65,
                left: 0,
                child: SizedBox(
                  width: 70,
                  child: Center(
                    child: Text(provider.payload2408[index]['Line'], style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ) : const SizedBox();*/

  }
}


class DisplayFilter extends StatefulWidget {
  const DisplayFilter({Key? key}) : super(key: key);

  @override
  State<DisplayFilter> createState() => _DisplayFilterState();
}

class _DisplayFilterState extends State<DisplayFilter> {
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

    return provider.filtersCentral.isNotEmpty? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int i=0; i<provider.filtersCentral.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.filtersCentral[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersCentral[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
              SizedBox(
                height: 90,
                width: provider.filtersCentral[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: provider.filtersCentral[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: buildFilterImage(flIndex, provider.filtersCentral[i]['FilterStatus'][flIndex]['Status']),
                            ),
                            Positioned(
                              top: 40,
                              left: 10,
                              child: provider.filtersCentral[i]['DurationLeft']!='00:00:00'? provider.filtersCentral[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 50,
                                child: Center(
                                  child: Text(provider.filtersCentral[i]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: provider.filtersCentral[i]['PrsIn']!='-' && provider.filtersCentral[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${provider.filtersCentral[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(provider.filtersCentral[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              provider.filtersCentral[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersCentral[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
      ],
    ) :
    const SizedBox();

  }

  Widget buildFilterImage(int cIndex, int status) {
    String imageName = 'dp_filter';
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

  /*Widget buildFilterImage(int cIndex, int status) {
    String imageName = 'dp_filter';

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.gif';
        break;
      case 2:
        imageName += '_y.gif';
        break;
      default:
        imageName += '_r.gif';
    }
    if(imageName.contains('.png')){
      return Image.asset('assets/images/$imageName');
    }
    return Image.asset('assets/GifFile/$imageName');

  }*/

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        if(provider.filtersCentral.isNotEmpty) {
          if(provider.filtersCentral[0]['DurationLeft']!='00:00:00'){
            List<String> parts = provider.filtersCentral[0]['DurationLeft'].split(':');
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
            setState(() {
              provider.filtersCentral[0]['DurationLeft'] = updatedDurationQtyLeft;
            });
          }
        }
      }
      catch(e){
        print(e);
      }
    });
  }

}

class DisplayFertilizer extends StatefulWidget {
  const DisplayFertilizer({Key? key}) : super(key: key);

  @override
  State<DisplayFertilizer> createState() => _DisplayFertilizerState();
}

class _DisplayFertilizerState extends State<DisplayFertilizer> {

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
    print('fertilizerCentral:${provider.fertilizerCentral}');

    return provider.fertilizerCentral.isNotEmpty? Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<provider.fertilizerCentral.length; fIndex++)
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      provider.fertilizerCentral[fIndex]['Booster'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: 70,
                        child: provider.fertilizerCentral[fIndex]['Booster'][0]['Status'] ==1 ?
                        Image.asset('assets/images/dp_fert_booster_pump_g.png'):
                        provider.fertilizerCentral[fIndex]['Booster'][0]['Status']==2 ?
                        Image.asset('assets/images/dp_fert_booster_pump_y.png') :
                        provider.fertilizerCentral[fIndex]['Booster'][0]['Status']==3 ?
                        Image.asset('assets/images/dp_fert_booster_pump_r.png'):
                        Image.asset('assets/images/dp_fert_booster_pump.png'),
                      ) :
                      const SizedBox(),
                      SizedBox(
                          width: 70,
                          height: 70,
                          child : Stack(
                            children: [
                              Image.asset('assets/images/dp_fert_nrv.png'),
                              Positioned(
                                top: 15,
                                left: 15,
                                child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Text('Selector' , style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 30,
                                left: 15,
                                child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                  decoration: BoxDecoration(
                                    color: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][fIndex]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: 50,
                                  height: 25,
                                  child: Center(
                                    child: Text(provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][fIndex]['Status']!=0?
                                    provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][fIndex]['Name'] : '--' , style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                  SizedBox(
                    width: provider.fertilizerCentral[fIndex]['Fertilizer'].length * 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.fertilizerCentral[fIndex]['Fertilizer'].length,
                      itemBuilder: (BuildContext context, int index) {
                        var fertilizer = provider.fertilizerCentral[fIndex]['Fertilizer'][index];
                        double fertilizerQty = 0.0;
                        var qtyValue = fertilizer['Qty'];
                        if (qtyValue != null) {
                          bool isString = fertilizer['Qty'] is String;
                          if(isString){
                            fertilizerQty = double.parse(fertilizer['Qty']);
                          }else{
                            fertilizerQty = fertilizer['Qty'];
                          }
                        }

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
                                    child: index == 0 && provider.fertilizerCentral[fIndex]['Fertilizer'].length!=1
                                        ? provider.fertilizerCentral[fIndex]['Agitator'].isNotEmpty
                                        ? Image.asset('assets/images/dp_fert_first_tank.png')
                                        : Image.asset('assets/images/dp_fert_first_tank1.png')
                                        : index == provider.fertilizerCentral[fIndex]['Fertilizer'].length - 1
                                        ? provider.fertilizerCentral[fIndex]['Agitator'].isNotEmpty
                                        ? Image.asset('assets/images/dp_fert_last_tank.png')
                                        : Image.asset('assets/images/dp_fert_last_tank1.png')
                                        : provider.fertilizerCentral[fIndex]['Agitator'].isNotEmpty
                                        ? Image.asset('assets/images/dp_fert_center_tank.png')
                                        : Image.asset('assets/images/dp_fert_first_tank1.png'),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        buildFertCheImage(index, fertilizer['Status'], provider.fertilizerCentral[fIndex]['Fertilizer'].length),
                                        Positioned(
                                          top: 0,
                                          left: 10,
                                          child: fertilizer['Status'] !=0
                                              &&
                                              fertilizer['FertSelection'] !='_'
                                              &&
                                              fertilizer['DurationLeft'] !='00:00:00'
                                              ?
                                          Container(
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
                                ],
                              ),
                            ),
                          ],
                        );
                        /*return Text('data');*/
                      },
                    ),
                  ),
                  provider.fertilizerCentral[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset('assets/images/dp_agitator_right.png'),
                  ) :
                  const SizedBox(),
                  SizedBox(
                    width: provider.fertilizerCentral[fIndex]['Fertilizer'].length * 70 + 70,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 40, right: 10),
                          child: SizedBox(
                            width: 60,
                            height: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 6,),
                                Text('Channel', style: TextStyle(fontSize: 10),),
                                SizedBox(height: 7,),
                                Text('Set', style: TextStyle(fontSize: 10),),
                                SizedBox(height: 7,),
                                Text('Flow(L/h)', style: TextStyle(fontSize: 10),),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    provider.fertilizerCentral[fIndex]['EcSet']!=0 ? const Row(
                                      children: [
                                        Text('EC : ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        SizedBox(width: 5,),
                                        Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                        Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        SizedBox(width: 10,),
                                        Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                        Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ) :
                                    const SizedBox(),
                                    const SizedBox(height: 5,),
                                    provider.fertilizerCentral[fIndex]['PhSet']!=0 ? const Row(
                                      children: [
                                        Text('PH : ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        SizedBox(width: 5,),
                                        Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                        Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        SizedBox(width: 10,),
                                        Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                        Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ) :
                                    const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: provider.fertilizerCentral[fIndex]['Fertilizer'].length * 70,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.fertilizerCentral[fIndex]['Fertilizer'].length,
                                itemBuilder: (BuildContext context, int index) {
                                  var fertilizer = provider.fertilizerCentral[fIndex]['Fertilizer'][index];
                                  double fertilizerQty = 0.0;
                                  var qtyValue = fertilizer['Qty'];
                                  if (qtyValue != null) {
                                    bool isString = fertilizer['Qty'] is String;
                                    if(isString){
                                      fertilizerQty = double.parse(fertilizer['Qty']);
                                    }else{
                                      fertilizerQty = fertilizer['Qty'];
                                    }
                                  }
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 3),
                                        Text(fertilizer['Name'], style: const TextStyle(fontSize: 10),),
                                        const Divider(height: 7),
                                        Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                        '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(fontSize: 10),),
                                        const Divider(height: 7),
                                        Text('${fertilizer['FlowRate_LpH']}', style: const TextStyle(fontSize: 10),),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ) :
    const SizedBox();

    return provider.fertilizerCentral.isNotEmpty? Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                provider.fertilizerCentral[0]['Booster'].isNotEmpty ? SizedBox(
                  width: 70,
                  height: 70,
                  child: provider.fertilizerCentral[0]['Booster'][0]['Status'] ==1 ?
                  Image.asset('assets/images/dp_fert_booster_pump_g.png'):
                  provider.fertilizerCentral[0]['Booster'][0]['Status']==2 ?
                  Image.asset('assets/images/dp_fert_booster_pump_y.png') :
                  provider.fertilizerCentral[0]['Booster'][0]['Status']==3 ?
                  Image.asset('assets/images/dp_fert_booster_pump_r.png'):
                  Image.asset('assets/images/dp_fert_booster_pump.png'),
                ) :
                const SizedBox(),
                SizedBox(
                    width: 70,
                    height: 70,
                    child : Stack(
                      children: [
                        Image.asset('assets/images/dp_fert_nrv.png'),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: provider.fertilizerCentral[0]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                            width: 50,
                            child: Center(
                              child: Text('Selector' , style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                          ) :
                          const SizedBox(),
                        ),
                        Positioned(
                          top: 30,
                          left: 15,
                          child: provider.fertilizerCentral[0]['FertilizerTankSelector'].isNotEmpty ? Container(
                            decoration: BoxDecoration(
                              color: provider.fertilizerCentral[0]['FertilizerTankSelector'][0]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: 50,
                            height: 25,
                            child: Center(
                              child: Text(provider.fertilizerCentral[0]['FertilizerTankSelector'][0]['Status']!=0?
                              provider.fertilizerCentral[0]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                          ) :
                          const SizedBox(),
                        ),
                      ],
                    )
                ),
              ],
            ),
            SizedBox(
              width: provider.fertilizerCentral[0]['Fertilizer'].length * 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.fertilizerCentral[0]['Fertilizer'].length,
                itemBuilder: (BuildContext context, int index) {
                  var fertilizer = provider.fertilizerCentral[0]['Fertilizer'][index];
                  double fertilizerQty = 0.0;
                  var qtyValue = fertilizer['Qty'];
                  if (qtyValue != null) {
                    bool isString = fertilizer['Qty'] is String;
                    if(isString){
                      fertilizerQty = double.parse(fertilizer['Qty']);
                    }else{
                      fertilizerQty = fertilizer['Qty'];
                    }
                  }

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
                              child: index == 0 && provider.fertilizerCentral[0]['Fertilizer'].length!=1
                                  ? provider.fertilizerCentral[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_first_tank.png')
                                  : Image.asset('assets/images/dp_fert_first_tank1.png')
                                  : index == provider.fertilizerCentral[0]['Fertilizer'].length - 1
                                  ? provider.fertilizerCentral[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_last_tank.png')
                                  : Image.asset('assets/images/dp_fert_last_tank1.png')
                                  : provider.fertilizerCentral[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_center_tank.png')
                                  : Image.asset('assets/images/dp_fert_first_tank1.png'),
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
                                    child: fertilizer['Status'] !=0
                                        &&
                                        fertilizer['FertSelection'] !='_'
                                        &&
                                        fertilizer['DurationLeft'] !='00:00:00'
                                        ?
                                    Container(
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
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            provider.fertilizerCentral[0]['Agitator'].isNotEmpty ? SizedBox(
              width: 70,
              height: 70,
              child: Image.asset('assets/images/dp_agitator_right.png'),
            ) :
            const SizedBox(),
            SizedBox(
              width: provider.fertilizerCentral[0]['Fertilizer'].length * 70 + 70,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40, right: 10),
                    child: SizedBox(
                      width: 60,
                      height: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 6,),
                          Text('Channel', style: TextStyle(fontSize: 10),),
                          SizedBox(height: 7,),
                          Text('Set', style: TextStyle(fontSize: 10),),
                          SizedBox(height: 7,),
                          Text('Flow(L/h)', style: TextStyle(fontSize: 10),),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              provider.fertilizerCentral[0]['EcSet']!=0 ? const Row(
                                children: [
                                  Text('EC : ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(width: 5,),
                                  Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                  Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(width: 10,),
                                  Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                  Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ) :
                              const SizedBox(),
                              const SizedBox(height: 5,),
                              provider.fertilizerCentral[0]['PhSet']!=0 ? const Row(
                                children: [
                                  Text('PH : ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(width: 5,),
                                  Text('Actual : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                  Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(width: 10,),
                                  Text('Target : ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                                  Text('0.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ) :
                              const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: provider.fertilizerCentral[0]['Fertilizer'].length * 70,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.fertilizerCentral[0]['Fertilizer'].length,
                          itemBuilder: (BuildContext context, int index) {
                            var fertilizer = provider.fertilizerCentral[0]['Fertilizer'][index];
                            double fertilizerQty = 0.0;
                            var qtyValue = fertilizer['Qty'];
                            if (qtyValue != null) {
                              bool isString = fertilizer['Qty'] is String;
                              if(isString){
                                fertilizerQty = double.parse(fertilizer['Qty']);
                              }else{
                                fertilizerQty = fertilizer['Qty'];
                              }
                            }
                            return Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 3),
                                  Text(fertilizer['Name'], style: const TextStyle(fontSize: 10),),
                                  const Divider(height: 7),
                                  Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                  '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(fontSize: 10),),
                                  const Divider(height: 7),
                                  Text('${fertilizer['FlowRate_LpH']}', style: const TextStyle(fontSize: 10),),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
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
                    provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 4;
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
                        provider.fertilizerCentral[0]['Fertilizer'][i]['Status'] = 4;
                      });
                      if(updatedOffTime==0){
                        provider.fertilizerCentral[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOnTime'];
                        provider.fertilizerCentral[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerCentral[0]['Fertilizer'][i]['OriginalOffTime'];
                      }
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
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }

}

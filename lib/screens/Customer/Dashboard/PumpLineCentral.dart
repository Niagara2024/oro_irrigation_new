import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/AppImages.dart';
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
                  width: MediaQuery.sizeOf(context).width,
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
                        padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
                        child: provider.irrigationPump.isNotEmpty? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                provider.sourcePump.isNotEmpty? Padding(
                                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                                  child: const DisplaySourcePump(),
                                ):
                                const SizedBox(),
                                provider.irrigationPump.isNotEmpty? Padding(
                                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                                  child: SizedBox(
                                    width: 52.50,
                                    height: 70,
                                    child : Stack(
                                      children: [
                                        provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                                        Image.asset('assets/images/dp_sump.png'),
                                      ],
                                    ),
                                  ),
                                ):
                                const SizedBox(),
                                provider.irrigationPump.isNotEmpty? Padding(
                                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                                  child: const DisplayIrrigationPump(),
                                ):
                                const SizedBox(),
                                for(int i=0; i<provider.payload2408.length; i++)
                                  provider.payload2408.isNotEmpty?  Padding(
                                    padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                                    child: DisplaySensor(crInx: i),
                                  ) : const SizedBox(),
                                provider.filtersCentral.isNotEmpty? Padding(
                                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                                  child: const DisplayFilter(),
                                ): const SizedBox(),
                                provider.fertilizerCentral.isNotEmpty? const DisplayFertilizer(): const SizedBox(),
                              ],
                            ),
                          ],
                        ):
                        const SizedBox(height: 20,),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: provider.fertilizerCentral.isNotEmpty?20:5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade200,
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

class DisplaySourcePump extends StatefulWidget {
  const DisplaySourcePump({Key? key}) : super(key: key);

  @override
  State<DisplaySourcePump> createState() => _DisplaySourcePumpState();
}

class _DisplaySourcePumpState extends State<DisplaySourcePump> {

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
    return SizedBox(
      width: provider.sourcePump.length * 70,
      height: 90,
      child: ListView.builder(
        itemCount: provider.sourcePump.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppImages.getAsset('sourcePump', provider.sourcePump[index]['Status'],''),
                  ),
                  provider.sourcePump[index]['OnDelayLeft'] !='00:00:00'?
                  Positioned(
                    top: 48,
                    left: 10,
                    child: Container(
                      color: Colors.greenAccent,
                      width: 50,
                      child: Center(
                        child: Text(provider.sourcePump[index]['OnDelayLeft'], style: const TextStyle(
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
                  child: Text(provider.sourcePump[index]['Name'], style: const TextStyle(
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
    );
  }


  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.sourcePump.length; i++) {
          if(provider.sourcePump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.sourcePump[i]['OnDelayLeft'].split(':');
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
            if(provider.sourcePump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.sourcePump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
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
    return SizedBox(
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
                    child: AppImages.getAsset('irrigationPump', provider.irrigationPump[index]['Status'],''),
                  ),
                  provider.irrigationPump[index]['OnDelayLeft'] !='00:00:00'?
                  Positioned(
                    top: 48,
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
    );

  }


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
  const DisplaySensor({Key? key, required this.crInx}) : super(key: key);
  final int crInx;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    Map<String, dynamic> jsonData = provider.payload2408[crInx];
    double totalWidth = 0.0;

    for( var key in jsonData.keys){
      dynamic value = jsonData[key];
      if((key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='_'){
        if(value!='_'){
          totalWidth += 70;
        }
      }
    }

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
          return (key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='_' ? Column(
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

    return Row(
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
                              child: AppImages.getAsset('filter', provider.filtersCentral[i]['FilterStatus'][flIndex]['Status'],''),
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
    );

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for(int fIndex=0; fIndex<provider.filtersCentral.length; fIndex++){
          if(provider.filtersCentral[fIndex]['DurationLeft']!='00:00:00'){

            List<String> parts = provider.filtersCentral[fIndex]['DurationLeft'].split(':');
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
            if(updatedDurationQtyLeft!='00:00:00'){
              setState(() {
                provider.filtersCentral[fIndex]['DurationLeft'] = updatedDurationQtyLeft;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<provider.fertilizerCentral.length; fIndex++)
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                        width: 70,
                        height: 140,
                        child : Stack(
                          children: [
                            AppImages.getAsset('booster', provider.fertilizerCentral[fIndex]['Booster'][0]['Status'],''),
                            Positioned(
                              top: 70,
                              left: 15,
                              child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                width: 50,
                                child: Center(
                                  child: Text('Selector' , style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(),
                            ),
                            Positioned(
                              top: 85,
                              left: 18,
                              child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                decoration: BoxDecoration(
                                  color: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                width: 45,
                                height: 22,
                                child: Center(
                                  child: Text(provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                  provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
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
                ),//booster
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
                        if(fertilizer['Qty'] is String){
                          fertilizerQty = double.parse(fertilizer['Qty']);
                        }else if(fertilizer['Qty'] is int){
                          fertilizerQty = fertilizer['Qty'].toDouble();
                        }else{
                          fertilizerQty = fertilizer['Qty'];
                        }
                      }

                      var fertilizerLeftVal = fertilizer['QtyLeft'];
                      if (fertilizerLeftVal != null) {
                        if(fertilizerLeftVal is String){
                          fertilizer['QtyLeft'] = double.parse(fertilizer['QtyLeft']);
                        }else if(fertilizer['Qty'] is int){
                          fertilizer['QtyLeft'] = fertilizer['QtyLeft'].toDouble();
                        }else{
                          fertilizer['QtyLeft'] = fertilizer['QtyLeft'];
                        }
                      }

                     // print('QtyLeft :${fertilizer['QtyLeft']}');

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
                                  height: 140,
                                  child: Stack(
                                    children: [
                                      buildFertCheImage(index, fertilizer['Status'], provider.fertilizerCentral[fIndex]['Fertilizer'].length, provider.fertilizerCentral[fIndex]['Agitator']),
                                      Positioned(
                                        top: 34,
                                        left: 5,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.lightBlueAccent,
                                          child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                            '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
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
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text('${fertilizer['FlowRate_LpH']}-lph', style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 103,
                                        left: 0,
                                        child: fertilizer['Status'] !=0
                                            &&
                                            fertilizer['FertSelection'] !='_'
                                            &&
                                            fertilizer['DurationLeft'] !='00:00:00'
                                            ?
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 50,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                                ? fertilizer['DurationLeft']
                                                : fertilizer['QtyLeft'] != null ? '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' :'00.0 L' , style: const TextStyle(
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
                  width: 59,
                  height: 101,
                  child: buildAgitatorImage(provider.fertilizerCentral[fIndex]['Agitator'][0]['Status']),
                ) :
                const SizedBox(),
                SizedBox(
                  width: 70,
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.fertilizerCentral[fIndex]['Ec'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerCentral[fIndex]['Ec'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerCentral[fIndex]['Ec'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ec'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ec'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                      provider.fertilizerCentral[fIndex]['Ph'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerCentral[fIndex]['Ph'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerCentral[fIndex]['Ph'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ph'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ph'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget buildFertCheImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_fert_channel_last_aj';
      }else{
        imageName='dp_fert_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_fert_channel_first_aj';
        }else{
          imageName='dp_fert_channel_center_aj';
        }
      }else{
        imageName='dp_fert_channel_center';
      }
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

  Widget buildAgitatorImage(int status) {
    String imageName ='dp_agitator_right';
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
        for (var central in provider.fertilizerCentral) {
          central['Fertilizer'].forEach((fertilizer) {
            int ferMethod = fertilizer['FertMethod'] is int
                ? fertilizer['FertMethod']
                : int.parse(fertilizer['FertMethod']);

            if (fertilizer['Status'] != 0 && ferMethod == 1) {
              //fertilizer time base
              List<String> parts = fertilizer['DurationLeft'].split(':');
              String updatedDurationQtyLeft = formatDuration(parts);
              setState(() {
                fertilizer['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 2) {
              //fertilizer flow base
              double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
              double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
              qtyLeftDouble -= flowRate;
              qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
              setState(() {
                fertilizer['QtyLeft'] = qtyLeftDouble;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 3){
              //fertilizer proposal time base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                List<String> parts = fertilizer['DurationLeft'].split(':');
                String updatedDurationQtyLeft = formatDuration(parts);
                fcOnTimeRd--;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['DurationLeft'] = updatedDurationQtyLeft;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 4){
              //fertilizer proposal qty base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 5){
              //fertilizer pro qty per 1000 Lit
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else{
              //print('ferMethod 6');
            }
          });
        }
      }
      catch(e){
        print(e);
      }

    });
  }

  String formatDuration(List<String> parts) {
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
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double convertQtyLeftToDouble(dynamic qtyLeftValue) {
    double qtyLeftDouble = 0.00;
    if (qtyLeftValue is int) {
      qtyLeftDouble = qtyLeftValue.toDouble();
    } else if (qtyLeftValue is String) {
      qtyLeftDouble = double.tryParse(qtyLeftValue) ?? 0.00;
    } else if (qtyLeftValue is double) {
      qtyLeftDouble = qtyLeftValue;
    } else {
      qtyLeftDouble = 0.00;
    }
    return qtyLeftDouble;
  }

  double convertFlowValueToDouble(dynamic flowValue) {
    double flowRate = 0.00;
    if (flowValue is int) {
      flowRate = flowValue.toDouble();
    } else if (flowValue is String) {
      flowRate = double.tryParse(flowValue) ?? 0.00;
    } else if (flowValue is double) {
      flowRate = flowValue;
    } else {
      flowRate = 0.00; // Default value in case the type is unknown
    }
    return flowRate;
  }

}

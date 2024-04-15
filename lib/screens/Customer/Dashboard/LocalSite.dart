import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class LocalSite extends StatefulWidget {
  const LocalSite({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<LocalSite> createState() => _LocalSiteState();
}

class _LocalSiteState extends State<LocalSite> {


  @override
  Widget build(BuildContext context) {
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
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child : ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, left: 5),
                        child: widget.siteData.localFilter.isNotEmpty ||widget.siteData.localFertilizer.isNotEmpty? SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widget.siteData.localFilter.isNotEmpty? const LocalFilter(): const SizedBox(),
                                  widget.siteData.localFertilizer.isNotEmpty? const DisplayFertilizer(): const SizedBox(),
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
                top: 7.5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: myTheme.primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: const Text('LOCAL SITE',  style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.siteData.localFilter.isNotEmpty? const LocalFilter(): const SizedBox(),
          widget.siteData.localFertilizer.isNotEmpty? const DisplayFertilizer(): const SizedBox(),
        ],
      ),
    );

  }
}

class LocalFilter extends StatefulWidget {
  const LocalFilter({Key? key}) : super(key: key);

  @override
  State<LocalFilter> createState() => _LocalFilterState();
}

class _LocalFilterState extends State<LocalFilter> {
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

    return provider.filtersLocal.isNotEmpty? Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(int i=0; i<provider.filtersLocal.length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider.filtersLocal[i]['PrsIn']!='-'?
                SizedBox(
                  width: 70,
                  height: 160,
                  child: Column(
                    children: [
                      Image.asset('assets/images/dp_prs_sensor.png',),
                      const Text('Prs In',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                      Text('${double.parse(provider.filtersLocal[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ) :
                const SizedBox(),
                SizedBox(
                  width: 70,
                  height: provider.filtersLocal[i]['FilterStatus'].length * 75,
                  child: ListView.builder(
                    itemCount: provider.filtersLocal[i]['FilterStatus'].length,
                    itemBuilder: (BuildContext context, int flIndex) {
                      return Column(
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
                                      Text(provider.filtersLocal[i]['FilterSite'], style: const TextStyle(fontWeight: FontWeight.bold),),
                                      const Divider(),
                                      Text(provider.filtersLocal[i]['FilterStatus'][flIndex]['Name']),
                                      Text('${provider.filtersLocal[i]['FilterStatus'][flIndex]['Status']}'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            child : Stack(
                              children: [
                                buildFilterImage(flIndex, provider.filtersLocal[i]['FilterStatus'][flIndex]['Status'], provider.filtersLocal[i]['FilterStatus'].length),
                                Positioned(
                                  top: 47.8,
                                  left: 10,
                                  child: provider.filtersLocal[i]['DurationLeft']!='00:00:00'? provider.filtersLocal[i]['Status'] == (flIndex+1) ? Container(
                                    color: Colors.greenAccent,
                                    width: 50,
                                    child: Center(
                                      child: Text(provider.filtersLocal[i]['DurationLeft'], style: const TextStyle(
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
                                  left: 25,
                                  child: provider.filtersLocal[i]['PrsIn']!='-'? Container(
                                      decoration: const BoxDecoration(
                                        color:Colors.yellow,
                                        borderRadius: BorderRadius.all(Radius.circular(2)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 3,right: 3),
                                        child: Text('${provider.filtersLocal[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                      )
                                  ):
                                  const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                provider.filtersLocal[i]['PrsOut'] != '-'?
                SizedBox(
                  width: 70,
                  height: 160,
                  child: Column(
                    children: [
                      Image.asset('assets/images/dp_prs_sensor.png',),
                      const Text('Prs Out',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                      Text('${double.parse(provider.filtersLocal[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ) :
                const SizedBox(),
              ],
            ),
        ],
      ),
    ) :
    const SizedBox();
  }

  Widget buildFilterImage(int cIndex, int status, int filterLength) {
    String imageName;
    if (filterLength == 1) {
      imageName = 'dp_filter';
    } else if (filterLength == 2) {
      imageName = cIndex == 0 ? 'dp_filter_1' : 'dp_filter_3';
    } else {
      switch (filterLength) {
        case 3:
          imageName = cIndex == 0 ? 'dp_filter_1' : (cIndex == 1 ? 'dp_filter_2' : 'dp_filter_3');
          break;
        case 4:
          imageName = cIndex == 0 ? 'dp_filter_1' : (cIndex == 1 ? 'dp_filter_2' : (cIndex == 2 ? 'dp_filter_2' : 'dp_filter_3'));
          break;
        default:
          imageName = 'dp_filter_3';
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

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        if(provider.filtersLocal.isNotEmpty) {
          if(provider.filtersLocal[0]['DurationLeft']!='00:00:00'){
            print('Duration Left updating....');
            List<String> parts = provider.filtersLocal[0]['DurationLeft'].split(':');
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
              provider.filtersLocal[0]['DurationLeft'] = updatedDurationQtyLeft;
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

    return provider.fertilizerLocal.isNotEmpty? Align(
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
                provider.fertilizerLocal[0]['Booster'].isNotEmpty ? SizedBox(
                  width: 70,
                  height: 70,
                  child: provider.fertilizerLocal[0]['Booster'][0]['Status'] ==1 ?
                  Image.asset('assets/images/dp_fert_booster_pump_g.png') :
                  provider.fertilizerLocal[0]['Booster'][0]['Status']==2 ?
                  Image.asset('assets/images/dp_fert_booster_pump_y.png') :
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
                          child: provider.fertilizerLocal[0]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
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
                          child: provider.fertilizerLocal[0]['FertilizerTankSelector'].isNotEmpty ? Container(
                            color: Colors.greenAccent,
                            width: 50,
                            height: 25,
                            child: Center(
                              child: Text('00' , style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
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
              width: provider.fertilizerLocal[0]['Fertilizer'].length * 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.fertilizerLocal[0]['Fertilizer'].length,
                itemBuilder: (BuildContext context, int index) {
                  var fertilizer = provider.fertilizerLocal[0]['Fertilizer'][index];
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
                              child: index == 0 && provider.fertilizerLocal[0]['Fertilizer'].length!=1
                                  ? provider.fertilizerLocal[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_first_tank.png')
                                  : Image.asset('assets/images/dp_fert_first_tank1.png')
                                  : index == provider.fertilizerLocal[0]['Fertilizer'].length - 1
                                  ? provider.fertilizerLocal[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_last_tank.png')
                                  : Image.asset('assets/images/dp_fert_last_tank1.png')
                                  : provider.fertilizerLocal[0]['Agitator'].isNotEmpty
                                  ? Image.asset('assets/images/dp_fert_center_tank.png')
                                  : Image.asset('assets/images/dp_fert_center_tank1.png'),
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Stack(
                                children: [
                                  buildFertCheImage(index, fertilizer['Status'], provider.fertilizerLocal[0]['Fertilizer'].length),
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
            provider.fertilizerLocal[0]['Agitator'].isNotEmpty ? SizedBox(
              width: 70,
              height: 70,
              child: Image.asset('assets/images/dp_agitator_right.png'),
            ) :
            const SizedBox(),
            SizedBox(
              width: provider.fertilizerLocal[0]['Fertilizer'].length * 70 + 70,
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
                              provider.fertilizerLocal[0]['EcSet']!=0 ? const Row(
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
                              provider.fertilizerLocal[0]['PhSet']!=0 ? const Row(
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
                        width: provider.fertilizerLocal[0]['Fertilizer'].length * 70,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.fertilizerLocal[0]['Fertilizer'].length,
                          itemBuilder: (BuildContext context, int index) {
                            var fertilizer = provider.fertilizerLocal[0]['Fertilizer'][index];
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
        for (int i = 0; i < provider.fertilizerLocal[0]['Fertilizer'].length; i++) {

          if(provider.fertilizerLocal[0]['Fertilizer'][i]['Status']!=0){

            if(provider.fertilizerLocal[0]['Fertilizer'][i]['FertMethod']=='1' ||
                provider.fertilizerLocal[0]['Fertilizer'][i]['FertMethod']=='3')
            {
              List<String> parts = provider.fertilizerLocal[0]['Fertilizer'][i]['DurationLeft'].split(':');
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
              if(provider.fertilizerLocal[0]['Fertilizer'][i]['FertMethod']=='3')
              {
                double onTime = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime']);
                double offTime = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime']);

                if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'] == null) {
                  provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'];
                }
                if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'] == null) {
                  provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'];
                }
                if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'] == null) {
                  provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerLocal[0]['Fertilizer'][i]['Status'];
                }

                if(onTime.toInt()>0){
                  int updatedOnTime = onTime.toInt() - 1;
                  provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                  setState(() {
                    provider.fertilizerLocal[0]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                    provider.fertilizerLocal[0]['Fertilizer'][i]['Status'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'];
                  });
                }else if(offTime.toInt()>0){
                  int updatedOffTime = offTime.toInt() - 1;
                  provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                  setState(() {
                    provider.fertilizerLocal[0]['Fertilizer'][i]['Status'] = 3;
                  });
                  if(updatedOffTime==0){
                    provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'];
                    provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'];
                  }
                }
              }
              else
              {
                if(provider.fertilizerLocal[0]['Fertilizer'][i]['DurationLeft']!='00:00:00'){
                  setState(() {
                    provider.fertilizerLocal[0]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                  });
                }
              }
            }
            else
            {
              double qtyDouble = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['Qty']);
              int roundedQty = qtyDouble.round();
              double qtyLeftDouble = provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'];
              int roundedQtyLeft = qtyLeftDouble.round();

              if(roundedQty >= roundedQtyLeft) {
                setState(() {
                  if(provider.fertilizerLocal[0]['Fertilizer'][i]['FertMethod']=='4' ||
                      provider.fertilizerLocal[0]['Fertilizer'][i]['FertMethod']=='5') {
                    double onTime = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime']);
                    double offTime = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime']);

                    if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'] == null) {
                      provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'];
                    }
                    if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'] == null) {
                      provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'];
                    }
                    if (provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'] == null) {
                      provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerLocal[0]['Fertilizer'][i]['Status'];
                    }

                    if(onTime.round()>0){
                      int updatedOnTime = onTime.round() - 1;
                      provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                      setState(() {
                        double remainQty = provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'];
                        double flowRate = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['FlowRate']);
                        remainQty = remainQty - flowRate;
                        provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                        provider.fertilizerLocal[0]['Fertilizer'][i]['Status'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalStatus'];
                        if(offTime.round() <=0){
                          provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'];
                          provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'];
                        }
                      });
                    }else if(offTime.round()>0){
                      int updatedOffTime = offTime.round() - 1;
                      provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                      setState(() {
                        provider.fertilizerLocal[0]['Fertilizer'][i]['Status'] = 3;
                      });
                      if(updatedOffTime==0){
                        provider.fertilizerLocal[0]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOnTime'];
                        provider.fertilizerLocal[0]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[0]['Fertilizer'][i]['OriginalOffTime'];
                      }
                    }

                  }
                  else{
                    double remainQty = provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'];
                    double flowRate = double.parse(provider.fertilizerLocal[0]['Fertilizer'][i]['FlowRate']);
                    remainQty = remainQty - flowRate;
                    provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                  }

                });
              }else{
                setState(() {
                  provider.fertilizerLocal[0]['Fertilizer'][i]['QtyLeft'] = provider.fertilizerLocal[0]['Fertilizer'][i]['Qty'];
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

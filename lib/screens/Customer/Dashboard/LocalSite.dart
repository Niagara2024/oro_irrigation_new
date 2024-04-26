import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/AppImages.dart';
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
    final provider = Provider.of<MqttPayloadProvider>(context);
    return provider.filtersLocal.isNotEmpty || provider.fertilizerLocal.isNotEmpty? Padding(
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
                                provider.filtersLocal.isNotEmpty? Padding(
                                  padding: EdgeInsets.only(top: provider.fertilizerLocal.isNotEmpty?38.4:0),
                                  child: const LocalFilter(),
                                ) : const SizedBox(),
                                provider.fertilizerLocal.isNotEmpty? const DisplayFertilizer(): const SizedBox(),

                              ],
                            ),
                          ],
                        ):
                        const SizedBox(height: 20),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: provider.filtersLocal.isNotEmpty && provider.fertilizerLocal.isNotEmpty?20:5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('LOCAL SITE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    ) : const SizedBox();

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

    return Row(
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
                          child: Text('${double.parse(provider.filtersLocal[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
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
                width: provider.filtersLocal[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: provider.filtersLocal[i]['FilterStatus'].length,
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
                              child: buildFilterImage(flIndex, provider.filtersLocal[i]['FilterStatus'][flIndex]['Status']),
                            ),
                            Positioned(
                              top: 40,
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
                              left: 45,
                              child: provider.filtersLocal[i]['PrsIn']!='-' && provider.filtersLocal[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${provider.filtersLocal[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
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
                            child: Text(provider.filtersLocal[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
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
              provider.filtersLocal[i]['PrsOut'] != '-'?
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
                          child: Text('${double.parse(provider.filtersLocal[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<provider.fertilizerLocal.length; fIndex++)
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
                            AppImages.getAsset('booster', provider.fertilizerLocal[fIndex]['Booster'][0]['Status']),
                            Positioned(
                              top: 70,
                              left: 15,
                              child: provider.fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
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
                              child: provider.fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                decoration: BoxDecoration(
                                  color: provider.fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                width: 45,
                                height: 22,
                                child: Center(
                                  child: Text(provider.fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                  provider.fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
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
                  width: provider.fertilizerLocal[fIndex]['Fertilizer'].length * 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.fertilizerLocal[fIndex]['Fertilizer'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var fertilizer = provider.fertilizerLocal[fIndex]['Fertilizer'][index];
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
                                  height: 140,
                                  child: Stack(
                                    children: [
                                      buildFertCheImage(index, fertilizer['Status'], provider.fertilizerLocal[fIndex]['Fertilizer'].length, provider.fertilizerLocal[fIndex]['Agitator']),
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
                provider.fertilizerLocal[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                  width: 59,
                  height: 101,
                  child: buildAgitatorImage(provider.fertilizerLocal[fIndex]['Agitator'][0]['Status']),
                ) :
                const SizedBox(),
                SizedBox(
                  width: 70,
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.fertilizerLocal[fIndex]['Ec'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerLocal[fIndex]['Ec'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerLocal[fIndex]['Ec'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerLocal[fIndex]['Ec'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerLocal[fIndex]['Ec'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                      provider.fertilizerLocal[fIndex]['Ph'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerLocal[fIndex]['Ph'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerLocal[fIndex]['Ph'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerLocal[fIndex]['Ph'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerLocal[fIndex]['Ph'][index]['Status'], style: TextStyle(fontSize: 10))),
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
        for(int fIndex=0; fIndex<provider.fertilizerLocal.length; fIndex++){
          for (int i = 0; i < provider.fertilizerLocal[fIndex]['Fertilizer'].length; i++) {
            if(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status']!=0){

              if(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FertMethod']=='1' ||
                  provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FertMethod']=='3')
              {
                List<String> parts = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['DurationLeft'].split(':');
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
                if(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FertMethod']=='3')
                {
                  double onTime = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime']);
                  double offTime = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime']);

                  if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'] == null) {
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'];
                  }
                  if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'] == null) {
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'];
                  }
                  if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'] == null) {
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'];
                  }

                  if(onTime.toInt()>0){
                    int updatedOnTime = onTime.toInt() - 1;
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                    setState(() {
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'];
                    });
                  }else if(offTime.toInt()>0){
                    int updatedOffTime = offTime.toInt() - 1;
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                    setState(() {
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'] = 4;
                    });
                    if(updatedOffTime==0){
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'];
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'];
                    }
                  }
                }
                else
                {
                  if(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['DurationLeft']!='00:00:00'){
                    setState(() {
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['DurationLeft'] = updatedDurationQtyLeft;
                    });
                  }
                }
              }
              else
              {
                double qtyDouble = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Qty']);
                int roundedQty = qtyDouble.round();
                double qtyLeftDouble = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'];
                int roundedQtyLeft = qtyLeftDouble.round();

                if(roundedQty >= roundedQtyLeft) {
                  setState(() {
                    if(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FertMethod']=='4' ||
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FertMethod']=='5') {
                      double onTime = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime']);
                      double offTime = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime']);

                      if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'] == null) {
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'];
                      }
                      if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'] == null) {
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'];
                      }
                      if (provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'] == null) {
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'];
                      }

                      if(onTime.round()>0){
                        int updatedOnTime = onTime.round() - 1;
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'] = updatedOnTime.toString();
                        setState(() {
                          double remainQty = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'];
                          double flowRate = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FlowRate']);
                          remainQty = remainQty - flowRate;
                          provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                          provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalStatus'];
                          if(offTime.round() <=0){
                            provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'];
                            provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'];
                          }
                        });
                      }else if(offTime.round()>0){
                        int updatedOffTime = offTime.round() - 1;
                        provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'] = updatedOffTime.toString();
                        setState(() {
                          provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Status'] = 4;
                        });
                        if(updatedOffTime==0){
                          provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OnTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOnTime'];
                          provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OffTime'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['OriginalOffTime'];
                        }
                      }

                    }
                    else{
                      double remainQty = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'];
                      double flowRate = double.parse(provider.fertilizerLocal[fIndex]['Fertilizer'][i]['FlowRate']);
                      remainQty = remainQty - flowRate;
                      provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'] = remainQty > 0 ? remainQty : 0;
                    }

                  });
                }else{
                  setState(() {
                    provider.fertilizerLocal[fIndex]['Fertilizer'][i]['QtyLeft'] = provider.fertilizerLocal[fIndex]['Fertilizer'][i]['Qty'];
                  });
                }
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

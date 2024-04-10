import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';


class MainLineLocal extends StatefulWidget {
  const MainLineLocal({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<MainLineLocal> createState() => _MainLineLocalState();
}

class _MainLineLocalState extends State<MainLineLocal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.siteData.localFilter.isNotEmpty? const LocalFilter(): const SizedBox(),
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

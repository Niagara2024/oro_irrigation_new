import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/MqttPayloadProvider.dart';

class CentralFilter extends StatefulWidget {
  const CentralFilter({Key? key}) : super(key: key);

  @override
  State<CentralFilter> createState() => _CentralFilterState();
}

class _CentralFilterState extends State<CentralFilter> {
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

    return provider.filters.isNotEmpty? Column(
      children: [
        Column(
          children: [
            SizedBox(
              width: 70,
              height: provider.filters[0]['FilterStatus'].length * 75,
              child: ListView.builder(
                itemCount: provider.filters[0]['FilterStatus'].length,
                itemBuilder: (BuildContext context, int index) {
                  if (index < provider.filters[0]['FilterStatus'].length) {
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
                                    Text(provider.filters[0]['FilterSite'], style: const TextStyle(fontWeight: FontWeight.bold),),
                                    const Divider(),
                                    Text(provider.filters[0]['FilterStatus'][index]['Name']),
                                    Text('${provider.filters[0]['FilterStatus'][index]['Status']}'),
                                  ],
                                ),
                              ),
                            ];
                          },
                          child : Stack(
                            children: [
                              buildFilterImage(index, provider.filters[0]['FilterStatus'][index]['Status'], provider.filters[0]['FilterStatus'].length),
                              Positioned(
                                top: 47.8,
                                left: 13,
                                child: provider.filters[0]['DurationLeft']!='00:00:00'? provider.filters[0]['Status'] == (index+1)? Container(
                                  color: Colors.greenAccent,
                                  width: 50,
                                  child: Text(provider.filters[0]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ):
                                const SizedBox(): const SizedBox(),
                              ),
                            ],
                          ),
                          /*child: buildFilterImage(index, provider.filters[0]['FilterStatus'][index]['Status'], provider.filters[0]['FilterStatus'].length),*/
                        ),
                      ],
                    ); // Replace 'yourKey' with the key from your API response
                  } else {
                    return const Text(''); // or any placeholder/error message
                  }
                },
              ),
            ),
            Text('${provider.filters[0]['DpValue']}'),
          ],
        ),
      ],
    ) :
    const SizedBox();
  }

  Widget buildFilterImage(int cIndex, int status, int filterLength) {
    String imageName;
    if (filterLength == 1) {
      imageName = 'dp_filter';
    } else if (filterLength == 2) {
      imageName = cIndex == 0 ? 'dp_filter1' : 'dp_filter3';
    } else {
      switch (filterLength) {
        case 3:
          imageName = cIndex == 0 ? 'dp_filter1' : (cIndex == 1 ? 'dp_filter2' : 'dp_filter3');
          break;
        case 4:
          imageName = cIndex == 0 ? 'dp_filter1' : (cIndex == 1 ? 'dp_filter2' : (cIndex == 2 ? 'dp_filter2' : 'dp_filter3'));
          break;
        default:
          imageName = 'dp_filter3';
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
        if(provider.filters.isNotEmpty) {
          if(provider.filters[0]['DurationLeft']!='00:00:00'){
            print('Duration Left updating....');
            List<String> parts = provider.filters[0]['DurationLeft'].split(':');
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
              provider.filters[0]['DurationLeft'] = updatedDurationQtyLeft;
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
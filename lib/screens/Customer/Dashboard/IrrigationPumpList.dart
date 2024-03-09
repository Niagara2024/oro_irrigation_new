import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/MqttPayloadProvider.dart';

class IrrigationPumpList extends StatefulWidget {
  const IrrigationPumpList({Key? key}) : super(key: key);

  @override
  State<IrrigationPumpList> createState() => _IrrigationPumpListState();
}

class _IrrigationPumpListState extends State<IrrigationPumpList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);

    return provider.irrigationPump.isNotEmpty? SizedBox(
      width: 70,
      height: provider.irrigationPump.length * 72,
      child: ListView.builder(
        itemCount: provider.irrigationPump.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < provider.irrigationPump.length) {
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
                            Text(provider.irrigationPump[index]['Name'], style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: buildIrPumpImage(index, provider.irrigationPump[index]['Status'], provider.irrigationPump.length),
                ),
              ],
            ); // Replace 'yourKey' with the key from your API response
          } else {
            return Text(''); // or any placeholder/error message
          }
        },
      ),
    ):
    const SizedBox();
  }

  Widget buildIrPumpImage(int cIndex, int status, int irPumpLength) {
    String imageName;
    if (irPumpLength == 1) {
      imageName = 'dp_irr_pump';
    } else if (irPumpLength == 2) {
      imageName = cIndex == 0 ? 'dp_irr_pump_1' : 'dp_irr_pump_3';
    } else {
      switch (irPumpLength) {
        case 3:
          imageName = cIndex == 0 ? 'dp_irr_pump_1' : (cIndex == 1 ? 'dp_irr_pump_2' : 'dp_irr_pump_3');
          break;
        case 4:
          imageName = cIndex == 0 ? 'dp_irr_pump_1' : (cIndex == 1 ? 'dp_irr_pump_2' : (cIndex == 2 ? 'dp_irr_pump_2' : 'dp_irr_pump_3'));
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

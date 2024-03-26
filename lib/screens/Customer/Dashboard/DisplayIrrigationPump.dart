import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';

class DisplayIrrigationPump extends StatelessWidget
{
  const DisplayIrrigationPump({Key? key, required this.irrigationPump}) : super(key: key);
  final List<IrrigationPump> irrigationPump;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: irrigationPump.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/irrigation_pump.png'),
              backgroundColor: Colors.transparent,
              child: IconButton(
                  hoverColor: Colors.transparent,
                  tooltip: '${irrigationPump[index].name}\n${irrigationPump[index].location}',
                  onPressed: (){},
                  icon: const Text('      ')
              ),
            ),
            Text(irrigationPump[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';

class DisplayMainValve extends StatelessWidget
{
  const DisplayMainValve({Key? key, required this.mainValve}) : super(key: key);
  final List<MainValve> mainValve;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: mainValve.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/main_valve.png'),
              backgroundColor: Colors.transparent,
            ),
            Text(mainValve[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}
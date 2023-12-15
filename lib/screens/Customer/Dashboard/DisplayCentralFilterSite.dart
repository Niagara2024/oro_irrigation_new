import 'package:flutter/material.dart';
import '../../../Models/Customer/Dashboard/CentralFilterSite.dart';

class DisplayCentralFilterSite extends StatelessWidget
{
  const DisplayCentralFilterSite({super.key, required this.centralFilterSite});
  final List<CentralFilterSite> centralFilterSite;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: centralFilterSite.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/central_filtration.png'),
              backgroundColor: Colors.transparent,
              child: IconButton(
                  hoverColor: Colors.transparent,
                  tooltip: '${centralFilterSite[index].name}\n${centralFilterSite[index].location}',
                  onPressed: (){},
                  icon: const Text('      ')
              ),
            ),
            Text(centralFilterSite[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}
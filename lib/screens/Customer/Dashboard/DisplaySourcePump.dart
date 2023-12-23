import 'package:flutter/material.dart';
import '../../../Models/Customer/Dashboard/SourcePump.dart';

class DisplaySourcePump extends StatelessWidget
{
  const DisplaySourcePump({Key? key, required this.sourcePump, required this.type}) : super(key: key);
  final List<SourcePump> sourcePump;
  final int type;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: sourcePump.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/source_pump.png'),
              backgroundColor: type==0? Colors.transparent :
              sourcePump[index].selected? Colors.green.shade100 :
              Colors.transparent,
              child: IconButton(
                hoverColor: Colors.transparent,
                tooltip: sourcePump[index].name,
                onPressed: (){
                  sourcePump[index].selected = true;
                }, icon: const Text('    '),
              ),
            ),
            Text(sourcePump[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}
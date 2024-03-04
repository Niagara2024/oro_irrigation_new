import 'package:flutter/material.dart';
import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';

class DisplayCentralFertilizerSite extends StatelessWidget
{
  const DisplayCentralFertilizerSite({super.key, required this.centralFertilizationSite});
  final List<FertilizerModel> centralFertilizationSite;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: centralFertilizationSite.length,
      itemBuilder: (context, index) {
        List<FertilizerChanel> fertilizers = centralFertilizationSite[index].fertilizer;
        return Card(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.asset('assets/images/central_dosing.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(centralFertilizationSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                        Text(centralFertilizationSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                        Text('Location : ${centralFertilizationSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.sizeOf(context).width-1070,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                      child: Text('Chanel', style: TextStyle(fontSize: 11),),
                    ),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width-740,
                        height: 46,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Divider(),
                            ),
                            SizedBox(
                              width: 310,
                              height: 30,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: fertilizers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Column(
                                          children: [
                                            const VerticalDivider(),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor: Colors.grey,
                                              child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<FertilizerChanel>> groupFertilizerChanelByLocation(List<FertilizerChanel> fertChanel) {
    Map<String, List<FertilizerChanel>> groupedFertChanel = {};
    for (var fertChanel in fertChanel) {
      if (!groupedFertChanel.containsKey(fertChanel.location)) {
        groupedFertChanel[fertChanel.location] = [];
      }
      groupedFertChanel[fertChanel.location]!.add(fertChanel);
    }
    return groupedFertChanel;
  }
}
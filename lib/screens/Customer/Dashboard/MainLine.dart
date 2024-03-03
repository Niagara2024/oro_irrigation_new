import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class MainLine extends StatefulWidget {
  const MainLine({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<MainLine> createState() => _MainLineState();
}

class _MainLineState extends State<MainLine> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                const ListTile(
                  title: Text('Main Line'),
                ),
                widget.siteData.irrigationPump.isNotEmpty
                    ||widget.siteData.centralFilterSite.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 49.5,
                        height: 145,
                        child: ListView.builder(
                          itemCount: widget.siteData.irrigationPump.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < widget.siteData.irrigationPump.length) {
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
                                              Text(widget.siteData.irrigationPump[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                              const Divider(),
                                              Text('ID : ${widget.siteData.irrigationPump[index].id}'),
                                              Text('Location : ${widget.siteData.irrigationPump[index].location}'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                    child: widget.siteData.irrigationPump.length ==1?
                                    Image.asset('assets/images/dp_irr_pump.png'):
                                    widget.siteData.irrigationPump.length==2 && index==0?
                                    Image.asset('assets/images/dp_irr_pump_1.png'):
                                    widget.siteData.irrigationPump.length==2 && index==1?
                                    Image.asset('assets/images/dp_irr_pump_3.png'):
                                    widget.siteData.irrigationPump.length==3 && index==0?
                                    Image.asset('assets/images/dp_irr_pump_1.png'):
                                    widget.siteData.irrigationPump.length==3 && index==1?
                                    Image.asset('assets/images/dp_irr_pump_2.png'):
                                    Image.asset('assets/images/dp_irr_pump_3.png'),
                                  ),
                                ],
                              ); // Replace 'yourKey' with the key from your API response
                            } else {
                              return Text(''); // or any placeholder/error message
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 49.5,
                        height: 145,
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                PopupMenuButton(
                                  tooltip: 'Details',
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                            Divider(),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                  child: Image.asset('assets/images/dp_prs_sensor.png',),
                                ),
                                const Text('Prs In',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                                const Text('7.0 bar',style: TextStyle(fontSize: 10),),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 49.5,
                        height: 145,
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < widget.siteData.centralFilterSite.length) {
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
                                              Text(widget.siteData.centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                              const Divider(),
                                              Text('ID : ${widget.siteData.centralFilterSite[index].id}'),
                                              Text('Location : ${widget.siteData.centralFilterSite[index].location}'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                    child: Image.asset('assets/images/dp_filter.png',),
                                  ),
                                ],
                              ); // Replace 'yourKey' with the key from your API response
                            } else {
                              return const Text(''); // or any placeholder/error message
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 49.5,
                        height: 145,
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                PopupMenuButton(
                                  tooltip: 'Details',
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                            Divider(),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                  child: Image.asset('assets/images/dp_prs_sensor.png',),
                                ),
                                const Text('Prs Out',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                                const Text('6.2 bar',style: TextStyle(fontSize: 10),),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ):
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    Text('No Device Available'),
                  ],
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 0),
          Expanded(
            flex :1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Dosing Recipes - NPK1'),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      const SizedBox(width : 40, child: Icon(Icons.account_tree_rounded)),
                      const SizedBox(width: 10,),
                      const Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('EC',style: TextStyle(fontSize: 10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                Text('00.0',style: TextStyle(fontSize: 10)),
                                SizedBox(width: 5,),
                                Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                Text('00.0',style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('PH',style: TextStyle(fontSize: 10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                Text('00.0',style: TextStyle(fontSize: 10)),
                                SizedBox(width: 5,),
                                Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                Text('00.0',style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width : 40, child: Image.asset('assets/images/injector.png',)),
                    ],),
                ),
                Flexible(
                    flex: 2,
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 400,
                      dataRowHeight: 20.0,
                      headingRowHeight: 20,
                      headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                      columns: const [
                        DataColumn2(
                            label: Center(child: Text('Channel', style: TextStyle(fontSize: 10),)),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('1', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('2', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('3', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('4', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('5', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('6', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('7', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 37
                        ),
                        DataColumn2(
                            label: Center(child: Text('8', style: TextStyle(fontSize: 10),)),
                            fixedWidth: 30
                        ),
                      ],
                      rows: List<DataRow>.generate(5, (index) => DataRow(cells: [
                        DataCell(Center(child: Text(index==0? 'Open(%)':index==1?'Flow(l/h)':index==2?'Qty Delivered': index==3?'Time Delivered':'Set Point',
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                        DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      ])),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

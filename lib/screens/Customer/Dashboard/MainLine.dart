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

    return Row(
      children: [
        SizedBox(
          width: 280,
          child: Column(
            children: [
              widget.siteData.irrigationPump.isNotEmpty
                  ||widget.siteData.centralFilterSite.isNotEmpty?
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    height: widget.siteData.irrigationPump.length * 72,
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
                                child: buildIrrigationPumpImage(index),
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
                    width: 70,
                    height: 160,
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
                  widget.siteData.centralFilterSite.isNotEmpty? SizedBox(
                    width: 70,
                    height: widget.siteData.centralFilterSite[0].filter.length * 75,
                    child: ListView.builder(
                      itemCount: widget.siteData.centralFilterSite[0].filter.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < widget.siteData.centralFilterSite[0].filter.length) {
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
                                          Text(widget.siteData.centralFilterSite[0].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                          const Divider(),
                                          Text('ID : ${widget.siteData.centralFilterSite[0].filter[index].id}'),
                                          Text('Location : ${widget.siteData.centralFilterSite[0].filter[index].location}'),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                                child: buildFilterImage(index),
                              ),
                            ],
                          ); // Replace 'yourKey' with the key from your API response
                        } else {
                          return const Text(''); // or any placeholder/error message
                        }
                      },
                    ),
                  ):
                  const SizedBox(),
                  SizedBox(
                    width: 70,
                    height: 160,
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
    );
  }

  Widget buildIrrigationPumpImage(int index) {
    Widget child;
    if (widget.siteData.irrigationPump.length == 1) {
      child = Image.asset('assets/images/dp_irr_pump.png');
    } else if (widget.siteData.irrigationPump.length == 2) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_irr_pump_1.png');
      } else {
        child = Image.asset('assets/images/dp_irr_pump_3.png');
      }
    } else if (widget.siteData.irrigationPump.length == 3) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_irr_pump_1.png');
      } else if (index == 1) {
        child = Image.asset('assets/images/dp_irr_pump_2.png');
      } else {
        child = Image.asset('assets/images/dp_irr_pump_3.png');
      }
    } else if (widget.siteData.irrigationPump.length == 4) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_irr_pump_1.png');
      } else if (index == 1) {
        child = Image.asset('assets/images/dp_irr_pump_2.png');
      }else if (index == 2) {
        child = Image.asset('assets/images/dp_irr_pump_2.png');
      } else {
        child = Image.asset('assets/images/dp_irr_pump_3.png');
      }
    } else {
      child = Image.asset('assets/images/dp_irr_pump_3.png');
    }

    return child;
  }

  Widget buildFilterImage(int index) {
    Widget child;
    if (widget.siteData.centralFilterSite[0].filter.length == 1) {
      child = Image.asset('assets/images/dp_filter.png');
    } else if (widget.siteData.centralFilterSite[0].filter.length == 2) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_filter1.png');
      } else {
        child = Image.asset('assets/images/dp_filter3.png');
      }
    } else if (widget.siteData.centralFilterSite[0].filter.length == 3) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_filter1.png');
      } else if (index == 1) {
        child = Image.asset('assets/images/dp_filter2.png');
      } else {
        child = Image.asset('assets/images/dp_filter3.png');
      }
    } else if (widget.siteData.centralFilterSite[0].filter.length == 4) {
      if (index == 0) {
        child = Image.asset('assets/images/dp_filter1.png');
      } else if (index == 1) {
        child = Image.asset('assets/images/dp_filter2.png');
      }else if (index == 2) {
        child = Image.asset('assets/images/dp_filter2.png');
      } else {
        child = Image.asset('assets/images/dp_filter3.png');
      }
    } else {
      child = Image.asset('assets/images/dp_filter3.png');
    }

    return child;
  }

}
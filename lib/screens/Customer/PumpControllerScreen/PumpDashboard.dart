import 'package:flutter/material.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';

class PumpDashboard extends StatefulWidget {
  const PumpDashboard({Key? key, required this.siteData, required this.masterIndex}) : super(key: key);
  final DashboardModel siteData;
  final int masterIndex;

  @override
  State<PumpDashboard> createState() => _PumpDashboardState();
}

class _PumpDashboardState extends State<PumpDashboard> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffefefef),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: const Text('Signal strength and battery volt ------------------------------------>'),
                subtitle: const Text('Last Sync ------------------------------------>', style: TextStyle(fontWeight: FontWeight.normal),),
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.developer_board, color: Colors.white,),
                ),
                trailing: Column(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.signal_cellular_alt),
                          Text('70%'),
                          Icon(Icons.battery_3_bar_rounded),
                          Text('30%'),
                        ],
                      ),
                    ),
                    Text('${widget.siteData.master[widget.masterIndex].liveSyncDate} : '
                      '${widget.siteData.master[widget.masterIndex].liveSyncTime}', style: const TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),),
              Card(
                elevation: 2.0,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(05.0),
                ),
                child:  SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(flex:1, child: Container(
                        color: Colors.red.shade100,
                        child: const Center(child: Text('R : 102')),
                      )),
                      Flexible(flex:1, child: Container(
                        color: Colors.yellow.shade100,
                        child: const Center(child: Text('Y : 102')),
                      )),
                      Flexible(flex:1, child: Container(
                        color: Colors.blue.shade100,
                        child: const Center(child: Text('B : 102')),
                      )),
                    ],
                  ),
                )
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3.0,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(05.0),
                      ),
                      child:  Column(
                        children: [
                          const Flexible(
                            flex: 1,
                            child: Center(child: Image(image: AssetImage("assets/GifFile/motor_off_new.gif"), width: 100,)),
                          ),
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: [
                                const Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text('0.011 R', style: TextStyle(fontSize: 20),),
                                            Text('Voltage', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text('5.011 Y', style: TextStyle(fontSize: 20),),
                                            Text('Power', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Material(
                                          elevation: 8.0, // Add shadow elevation
                                          shape: const CircleBorder(), // Ensure the shadow has the same shape as the CircleAvatar
                                          child: CircleAvatar(
                                            radius: 40.0,
                                            backgroundColor: Colors.redAccent,
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 07,),
                                                IconButton(onPressed: (){}, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                                const Text('Stop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20,),
                                        Material(
                                          elevation: 8.0, // Add shadow elevation
                                          shape: CircleBorder(), // Ensure the shadow has the same shape as the CircleAvatar
                                          child: CircleAvatar(
                                            radius: 40.0,
                                            backgroundColor: Colors.green,
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 07,),
                                                IconButton(onPressed: (){}, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                                const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('0.011 R', style: TextStyle(fontSize: 20),),
                                            Text('Voltage', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('0.011 R', style: TextStyle(fontSize: 20),),
                                            Text('Voltage', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('0.011 R', style: TextStyle(fontSize: 20),),
                                            Text('Voltage', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




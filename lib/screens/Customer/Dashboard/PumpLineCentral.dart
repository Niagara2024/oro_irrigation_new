import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/AppImages.dart';
import '../../../state_management/DurationNotifier.dart';
import '../../../state_management/MqttPayloadProvider.dart';


class PumpLineCentral extends StatefulWidget {
  const PumpLineCentral({Key? key, required this.currentSiteData}) : super(key: key);
  final DashboardModel currentSiteData;

  @override
  State<PumpLineCentral> createState() => _PumpLineCentralState();
}

class _PumpLineCentralState extends State<PumpLineCentral> {

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: buildScaffoldWithTabs(),
        ),
      ),
      //child: SizedBox(width:500, height:500, child: buildScaffoldWithTabs()),
    );
  }

  Widget buildScaffoldWithTabs() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: widget.currentSiteData.master[0].irrigationLine.length,
        child: Column(
          children: [
            TabBar(
              indicatorColor: myTheme.primaryColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(color: myTheme.primaryColor),
              tabs: _buildTabs(),
            ),
            Expanded(
              child: TabBarView(
                children: _buildTabBarViews(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    return widget.currentSiteData.master[0].irrigationLine.map((line) => Tab(text: line.name)).toList();
  }

  List<Widget> _buildTabBarViews() {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return widget.currentSiteData.master[0].irrigationLine.map((line){
      return Column(
        children: [
          ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                child: provider.irrigationPump.isNotEmpty? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    provider.sourcePump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                      child: const DisplaySourcePump(),
                    ):
                    const SizedBox(),
                    provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                      child: SizedBox(
                        width: 52.50,
                        height: 70,
                        child : Stack(
                          children: [
                            provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                            Image.asset('assets/images/dp_sump.png'),
                          ],
                        ),
                      ),
                    ):
                    const SizedBox(),
                    provider.irrigationPump.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                      child: DisplayIrrigationPump(currentLineId: line.id, pumpList: widget.currentSiteData.master[0].liveData[0].pumpList,),
                    ):
                    const SizedBox(),
                    provider.filtersCentral.isNotEmpty? Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                      child: DisplayFilter(currentLineId: line.id,),
                    ): const SizedBox(),
                    for(int i=0; i<provider.payload2408.length; i++)
                      provider.payload2408.isNotEmpty?  Padding(
                        padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty?38.4:0),
                        child: provider.payload2408[i]['Line'].contains(line.id)? DisplaySensor(crInx: i):null,
                      ) : const SizedBox(),
                    provider.fertilizerCentral.isNotEmpty? const DisplayFertilizer(): const SizedBox(),
                    //local
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: provider.irrigationPump.isNotEmpty? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              provider.filtersLocal.isNotEmpty? Padding(
                                padding: EdgeInsets.only(top: provider.fertilizerLocal.isNotEmpty?38.4:0),
                                child: LocalFilter(currentLineId: line.id,),
                              ) : const SizedBox(),
                              provider.fertilizerLocal.isNotEmpty? DisplayLocalFertilizer(currentLineId: line.id,) : const SizedBox(),
                            ],
                          ),
                        ],
                      ):
                      const SizedBox(height: 20),
                    )
                  ],
                ):
                const SizedBox(height: 20),
              ),
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            width: MediaQuery.sizeOf(context).width-173,
            height: 60,
            child: Center(child: IrrigationLineView(line: line,)),
          ),
        ],
      );
    },
    ).toList();
  }

}

class IrrigationLineView extends StatefulWidget {
  final IrrigationLine line;
  const IrrigationLineView({super.key, required this.line});

  @override
  State<IrrigationLineView> createState() => _IrrigationLineViewState();
}

class _IrrigationLineViewState extends State<IrrigationLineView> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateDurationQtyLeft();
    });
  }

  void _updateDurationQtyLeft() {
    final currentSchedule = Provider.of<MqttPayloadProvider>(context, listen: false).currentSchedule;
    final durationNotifier = Provider.of<DurationNotifier>(context, listen: false);
    if(currentSchedule.isNotEmpty){
      for (int i = 0; i < currentSchedule.length; i++) {
        if (currentSchedule[i]['Duration_QtyLeft'] != null) {
          if ('${currentSchedule[i]['Duration_QtyLeft']}'.contains(':')) {
            List<String> parts = currentSchedule[i]['Duration_QtyLeft'].split(':');
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
            if (currentSchedule[i]['Duration_QtyLeft'] != '00:00:00') {
              durationNotifier.updateDuration(updatedDurationQtyLeft);
              currentSchedule[i]['Duration_QtyLeft'] = updatedDurationQtyLeft;
            } else {
              _timer?.cancel();
              durationNotifier.updateDuration('00:00:00');
              currentSchedule[i]['Duration_QtyLeft'] = '00:00:00';
            }
          } else {
            double remainFlow = 0.0;
            if (currentSchedule[i]['Duration_QtyLeft'] is int) {
              remainFlow = currentSchedule[i]['Duration_QtyLeft'].toDouble();
            } else if (currentSchedule[i]['Duration_QtyLeft'] is String) {
              remainFlow = double.parse(currentSchedule[i]['Duration_QtyLeft']);
            } else {
              remainFlow = currentSchedule[i]['Duration_QtyLeft'];
            }

            if (remainFlow > 0) {
              double flowRate = currentSchedule[i]['AverageFlowRate'] is String
                  ? double.parse(currentSchedule[i]['AverageFlowRate'])
                  : currentSchedule[i]['AverageFlowRate'];
              remainFlow -= flowRate;
              String formattedFlow = remainFlow.toStringAsFixed(2);
              durationNotifier.updateDuration(formattedFlow);
              currentSchedule[i]['Duration_QtyLeft'] = formattedFlow;
            } else {
              durationNotifier.updateDuration('0.00');
              currentSchedule[i]['Duration_QtyLeft'] = '0.00';
              _timer?.cancel();
            }
          }
        }
        else{
          durationNotifier.updateDuration('00000');
          currentSchedule[i]['Duration_QtyLeft'] = '00000';
          _timer?.cancel();
        }
      }
    }else{
      durationNotifier.updateDuration('00000');
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    _startTimer();
    return Row(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...widget.line.mainValve.map((mv) => MainValveWidget(mv: mv,  status: getStatusForMainValve(mv.hid, currentSchedule)),).toList(),
                  ...widget.line.valve.map((vl) => ValveWidget(vl: vl, status: getStatusForValve(vl.id, currentSchedule),)).toList(),
                ],
              ),
            ),
          ),
        ),

        Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            color:Colors.yellow.shade100,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            border: Border.all(color: Colors.grey, width: .50,),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Remaining : '),
              ValueListenableBuilder<String>(
                valueListenable: Provider.of<DurationNotifier>(context).leftDurationOrFlow,
                builder: (context, value, child) {
                  return Text(value, style: const TextStyle(fontSize: 20));
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  int getStatusForValve(String vlName, List<dynamic> currentSchedule) {
    for (final scheduleItem in currentSchedule) {
      if (scheduleItem['VL'] != null) {
        final vlList = scheduleItem['VL'] as List<dynamic>;
        final valve = vlList.firstWhere((v) => v['Name'] == vlName, orElse: () => null);
        if (valve != null) {
          return valve['Status'] ?? 0;
        }
      }
    }
    return 0;
  }

  int getStatusForMainValve(String mvlName, List<dynamic> currentSchedule) {
    for (final scheduleItem in currentSchedule) {
      if (scheduleItem['MV'] != null) {
        final mvlList = scheduleItem['MV'] as List<dynamic>;
        final mValve = mvlList.firstWhere((v) => v['Name'] == mvlName, orElse: () => null);
        if (mValve != null) {
          return mValve['Status'] ?? 0;
        }
      }
    }
    return 0;
  }
}


class MainValveWidget extends StatelessWidget {
  final MainValve mv;
  final int status;
  const MainValveWidget({super.key, required this.mv, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            width: 35,
            height: 35,
            status == 0
                ? 'assets/images/dp_main_valve_not_open.png'
                : status == 1
                ? 'assets/images/dp_main_valve_open.png'
                : status == 2
                ? 'assets/images/dp_main_valve_wait.png'
                : 'assets/images/dp_main_valve_closed.png',
          ),
          const SizedBox(height: 4),
          Text(mv.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}

class ValveWidget extends StatelessWidget {
  final Valve vl;
  final int status;
  const ValveWidget({super.key, required this.vl, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            width: 35,
            height: 35,
            status == 0
                ? 'assets/images/valve_gray.png'
                : status == 1
                ? 'assets/images/valve_green.png'
                : status == 2
                ? 'assets/images/valve_orange.png'
                : 'assets/images/valve_red.png',
          ),
          const SizedBox(height: 4),
          Text(vl.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}

class SensorWidget extends StatelessWidget {
  final dynamic sensor;
  const SensorWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(8.0),
      color: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sensor.name,
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              '(${sensor.type})',
              style: TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class DisplaySourcePump extends StatefulWidget {
  const DisplaySourcePump({Key? key}) : super(key: key);

  @override
  State<DisplaySourcePump> createState() => _DisplaySourcePumpState();
}

class _DisplaySourcePumpState extends State<DisplaySourcePump> {

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
    return SizedBox(
      width: provider.sourcePump.length * 70,
      height: 90,
      child: ListView.builder(
        itemCount: provider.sourcePump.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppImages.getAsset('sourcePump', provider.sourcePump[index]['Status'],''),
                  ),
                  provider.sourcePump[index]['OnDelayLeft'] !='00:00:00'?
                  Positioned(
                    top: 40,
                    left: 10,
                    child: Container(
                      color: Colors.greenAccent,
                      width: 50,
                      child: Center(
                        child: Text(provider.sourcePump[index]['OnDelayLeft'], style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ) :
                  const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 20,
                child: Center(
                  child: Text(provider.sourcePump[index]['Name'], style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.sourcePump.length; i++) {
          if(provider.sourcePump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.sourcePump[i]['OnDelayLeft'].split(':');
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
            if(provider.sourcePump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.sourcePump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }
}


class DisplayIrrigationPump extends StatefulWidget {
  const DisplayIrrigationPump({Key? key, required this.currentLineId, required this.pumpList}) : super(key: key);
  final String currentLineId;
  final List<PumpData> pumpList;

  @override
  State<DisplayIrrigationPump> createState() => _DisplayIrrigationPumpState();
}

class _DisplayIrrigationPumpState extends State<DisplayIrrigationPump> {

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updatePumpOnDelayTime();
    });
  }

  void _updatePumpOnDelayTime() {
    final irrigationPump = Provider.of<MqttPayloadProvider>(context, listen: false).irrigationPump;
    final onDelayNotifier = Provider.of<DurationNotifier>(context, listen: false);
    bool allOnDelayLeftZero = true;
    try {
      for (int i = 0; i < irrigationPump.length; i++) {
        if (irrigationPump[i]['OnDelayLeft'] != null) {
          List<String> parts = irrigationPump[i]['OnDelayLeft'].split(':');
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
          if (irrigationPump[i]['OnDelayLeft'] != '00:00:00') {
            irrigationPump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
            onDelayNotifier.updateOnDelayTime(updatedDurationQtyLeft);
            allOnDelayLeftZero = false;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (allOnDelayLeftZero) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final irrigationPump = Provider.of<MqttPayloadProvider>(context).irrigationPump;
    _startTimer();

    print(widget.pumpList);

    final List<Map<String, dynamic>> filteredPumps = irrigationPump
        .where((pump) => pump['Location'].contains(widget.currentLineId))
        .toList()
        .cast<Map<String, dynamic>>();

    return SizedBox(
      width: filteredPumps.length * 70,
      height: 90,
      child: ListView.builder(
        itemCount: filteredPumps.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppImages.getAsset('irrigationPump', filteredPumps[index]['Status'],''),
                  ),
                  filteredPumps[index]['OnDelayLeft'] != '00:00:00'?
                  Positioned(
                    top: 40,
                    left: 10,
                    child: Container(
                      color: Colors.greenAccent,
                      width: 50,
                      child: Center(
                        child: ValueListenableBuilder<String>(
                          valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                          builder: (context, value, child) {
                            return Text(value, style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ));
                          },
                        ),
                      ),
                    ),
                  ) :
                  const SizedBox(),
                ],
              ),
              SizedBox(
                width: 70,
                height: 20,
                child: Center(
                  child: Text(filteredPumps[index]['Name'], style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  /*void durationUpdatingFunction() {

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.irrigationPump.length; i++) {
          if(provider.irrigationPump[i]['OnDelayLeft']!=null){
            List<String> parts = provider.irrigationPump[i]['OnDelayLeft'].split(':');
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
            if(provider.irrigationPump[i]['OnDelayLeft']!='00:00:00'){
              setState(() {
                provider.irrigationPump[i]['OnDelayLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }*/
}


class DisplaySensor extends StatelessWidget {
  const DisplaySensor({Key? key, required this.crInx}) : super(key: key);
  final int crInx;

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);
    Map<String, dynamic> jsonData = provider.payload2408[crInx];
    double totalWidth = 0;

    for( var key in jsonData.keys){
      dynamic value = jsonData[key];
      if((key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='-'){
        if(value!='-'){
          totalWidth += 70;
        }
      }
    }

    return jsonData.isNotEmpty ? SizedBox(
      width: totalWidth,
      height: 85,
      child: ListView.builder(
        itemCount: jsonData.keys.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String key = jsonData.keys.elementAt(index);
          dynamic value = jsonData[key];
          return (key=='PrsIn'||key=='PrsOut'||key=='Watermeter') && value!='-' ? Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: key=='PrsIn' || key=='PrsOut' ? Image.asset('assets/images/dp_prs_sensor.png') : Image.asset('assets/images/dp_flowmeter.png'),
                  ),
                  Positioned(
                    top: 42,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 15,
                      decoration: BoxDecoration(
                        color:Colors.yellow,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(color: Colors.grey, width: .50,),
                      ),
                      child: Center(
                        child: Text('$value', style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 57,
                    left: 0,
                    child: SizedBox(
                      width: 70,
                      child: Center(
                        child: Text(jsonData['Line'], style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ):
          const SizedBox();
        },
      ),
    ) : const SizedBox();
  }
}


class DisplayFilter extends StatefulWidget {
  const DisplayFilter({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<DisplayFilter> createState() => _DisplayFilterState();
}

class _DisplayFilterState extends State<DisplayFilter> {
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

    MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);

    final List<Map<String, dynamic>> filteredCentralFilter = provider.filtersCentral
        .where((pump) => pump['Location'].contains(widget.currentLineId))
        .toList()
        .cast<Map<String, dynamic>>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int i=0; i<filteredCentralFilter.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filteredCentralFilter[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersCentral[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              const SizedBox(),
              SizedBox(
                height: 90,
                width: filteredCentralFilter[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: filteredCentralFilter[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: AppImages.getAsset('filter', filteredCentralFilter[i]['FilterStatus'][flIndex]['Status'],''),
                            ),
                            Positioned(
                              top: 40,
                              left: 10,
                              child: filteredCentralFilter[i]['DurationLeft']!='00:00:00'? filteredCentralFilter[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 50,
                                child: Center(
                                  child: Text(filteredCentralFilter[i]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: filteredCentralFilter[i]['PrsIn']!='-' && filteredCentralFilter[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filteredCentralFilter[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(filteredCentralFilter[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              filteredCentralFilter[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredCentralFilter[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
      ],
    );

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for(int fIndex=0; fIndex<provider.filtersCentral.length; fIndex++){
          if(provider.filtersCentral[fIndex]['DurationLeft']!='00:00:00'){

            List<String> parts = provider.filtersCentral[fIndex]['DurationLeft'].split(':');
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
            if(updatedDurationQtyLeft!='00:00:00'){
              setState(() {
                provider.filtersCentral[fIndex]['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
          }
        }
      }
      catch(e){
        print(e);
      }
    });
  }

}

class DisplayFertilizer extends StatefulWidget {
  const DisplayFertilizer({Key? key}) : super(key: key);

  @override
  State<DisplayFertilizer> createState() => _DisplayFertilizerState();
}

class _DisplayFertilizerState extends State<DisplayFertilizer> {

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<provider.fertilizerCentral.length; fIndex++)
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                        width: 70,
                        height: 140,
                        child : Stack(
                          children: [
                            AppImages.getAsset('booster', provider.fertilizerCentral[fIndex]['Booster'][0]['Status'],''),
                            Positioned(
                              top: 70,
                              left: 15,
                              child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                width: 50,
                                child: Center(
                                  child: Text('Selector' , style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(),
                            ),
                            Positioned(
                              top: 85,
                              left: 18,
                              child: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                decoration: BoxDecoration(
                                  color: provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                width: 45,
                                height: 22,
                                child: Center(
                                  child: Text(provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                  provider.fertilizerCentral[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
                SizedBox(
                  width: provider.fertilizerCentral[fIndex]['Fertilizer'].length * 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.fertilizerCentral[fIndex]['Fertilizer'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var fertilizer = provider.fertilizerCentral[fIndex]['Fertilizer'][index];
                      double fertilizerQty = 0.0;
                      var qtyValue = fertilizer['Qty'];
                      if(qtyValue != null) {
                        if(fertilizer['Qty'] is String){
                          fertilizerQty = double.parse(fertilizer['Qty']);
                        }else if(fertilizer['Qty'] is int){
                          fertilizerQty = fertilizer['Qty'].toDouble();
                        }else{
                          fertilizerQty = fertilizer['Qty'];
                        }
                      }

                      var fertilizerLeftVal = fertilizer['QtyLeft'];
                      if (fertilizerLeftVal != null) {
                        if(fertilizerLeftVal is String){
                          fertilizer['QtyLeft'] = double.parse(fertilizer['QtyLeft']);
                        }else if(fertilizer['Qty'] is int){
                          fertilizer['QtyLeft'] = fertilizer['QtyLeft'].toDouble();
                        }else{
                          fertilizer['QtyLeft'] = fertilizer['QtyLeft'];
                        }
                      }

                     // print('QtyLeft :${fertilizer['QtyLeft']}');

                      return Row(
                        children: [
                          SizedBox(
                            width: 70, // Set the desired width for each fertilizer item
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 140,
                                  child: Stack(
                                    children: [
                                      buildFertCheImage(index, fertilizer['Status'], provider.fertilizerCentral[fIndex]['Fertilizer'].length, provider.fertilizerCentral[fIndex]['Agitator']),
                                      Positioned(
                                        top: 34,
                                        left: 5,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.lightBlueAccent,
                                          child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                            '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 65,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text('${fertilizer['FlowRate_LpH']}-lph', style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 103,
                                        left: 0,
                                        child: fertilizer['Status'] !=0
                                            &&
                                            fertilizer['FertSelection'] !='_'
                                            &&
                                            fertilizer['DurationLeft'] !='00:00:00'
                                            ?
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 50,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                                ? fertilizer['DurationLeft']
                                                : fertilizer['QtyLeft'] != null ? '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' :'00.0 L' , style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ) :
                                        const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                      /*return Text('data');*/
                    },
                  ),
                ),
                provider.fertilizerCentral[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                  width: 59,
                  height: 101,
                  child: AppImages.getAsset('agitator', provider.fertilizerCentral[fIndex]['Agitator'][0]['Status'],''),
                ) :
                const SizedBox(),
                SizedBox(
                  width: 70,
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.fertilizerCentral[fIndex]['Ec'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerCentral[fIndex]['Ec'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerCentral[fIndex]['Ec'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ec'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ec'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                      provider.fertilizerCentral[fIndex]['Ph'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: provider.fertilizerCentral[fIndex]['Ph'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: provider.fertilizerCentral[fIndex]['Ph'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ph'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(provider.fertilizerCentral[fIndex]['Ph'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildFertCheImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_fert_channel_last_aj';
      }else{
        imageName='dp_fert_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_fert_channel_first_aj';
        }else{
          imageName='dp_fert_channel_center_aj';
        }
      }else{
        imageName='dp_fert_channel_center';
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
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/images/$imageName');

  }

  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (var central in provider.fertilizerCentral) {
          central['Fertilizer'].forEach((fertilizer) {
            int ferMethod = fertilizer['FertMethod'] is int
                ? fertilizer['FertMethod']
                : int.parse(fertilizer['FertMethod']);

            if (fertilizer['Status'] != 0 && ferMethod == 1) {
              //fertilizer time base
              List<String> parts = fertilizer['DurationLeft'].split(':');
              String updatedDurationQtyLeft = formatDuration(parts);
              setState(() {
                fertilizer['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 2) {
              //fertilizer flow base
              double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
              double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
              qtyLeftDouble -= flowRate;
              qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
              setState(() {
                fertilizer['QtyLeft'] = qtyLeftDouble;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 3){
              //fertilizer proposal time base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                List<String> parts = fertilizer['DurationLeft'].split(':');
                String updatedDurationQtyLeft = formatDuration(parts);
                fcOnTimeRd--;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['DurationLeft'] = updatedDurationQtyLeft;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 4){
              //fertilizer proposal qty base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 5){
              //fertilizer pro qty per 1000 Lit
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else{
              //print('ferMethod 6');
            }
          });
        }
      }
      catch(e){
        print(e);
      }

    });
  }

  String formatDuration(List<String> parts) {
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
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double convertQtyLeftToDouble(dynamic qtyLeftValue) {
    double qtyLeftDouble = 0.00;
    if (qtyLeftValue is int) {
      qtyLeftDouble = qtyLeftValue.toDouble();
    } else if (qtyLeftValue is String) {
      qtyLeftDouble = double.tryParse(qtyLeftValue) ?? 0.00;
    } else if (qtyLeftValue is double) {
      qtyLeftDouble = qtyLeftValue;
    } else {
      qtyLeftDouble = 0.00;
    }
    return qtyLeftDouble;
  }

  double convertFlowValueToDouble(dynamic flowValue) {
    double flowRate = 0.00;
    if (flowValue is int) {
      flowRate = flowValue.toDouble();
    } else if (flowValue is String) {
      flowRate = double.tryParse(flowValue) ?? 0.00;
    } else if (flowValue is double) {
      flowRate = flowValue;
    } else {
      flowRate = 0.00; // Default value in case the type is unknown
    }
    return flowRate;
  }

}

class LocalFilter extends StatefulWidget {
  const LocalFilter({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<LocalFilter> createState() => _LocalFilterState();
}

class _LocalFilterState extends State<LocalFilter> {
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
    MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);

    final List<Map<String, dynamic>> filteredLocalFilter = provider.filtersLocal
        .where((pump) => pump['Location'].contains(widget.currentLineId)).toList()
        .cast<Map<String, dynamic>>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int i=0; i<filteredLocalFilter.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filteredLocalFilter[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersCentral[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              const SizedBox(),
              SizedBox(
                height: 90,
                width: filteredLocalFilter[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: filteredLocalFilter[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: AppImages.getAsset('filter', filteredLocalFilter[i]['FilterStatus'][flIndex]['Status'],''),
                            ),
                            Positioned(
                              top: 40,
                              left: 10,
                              child: filteredLocalFilter[i]['DurationLeft']!='00:00:00'? filteredLocalFilter[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 50,
                                child: Center(
                                  child: Text(filteredLocalFilter[i]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: filteredLocalFilter[i]['PrsIn']!='-' && filteredLocalFilter[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filteredLocalFilter[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(filteredLocalFilter[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              filteredLocalFilter[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(filteredLocalFilter[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int i=0; i<provider.filtersLocal.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.filtersLocal[i]['PrsIn']!='-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersLocal[i]['PrsIn']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
              SizedBox(
                height: 90,
                width: provider.filtersLocal[i]['FilterStatus'].length * 70,
                child: ListView.builder(
                  itemCount: provider.filtersLocal[i]['FilterStatus'].length,
                  scrollDirection: Axis.horizontal,
                  //reverse: true,
                  itemBuilder: (BuildContext context, int flIndex) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: buildFilterImage(flIndex, provider.filtersLocal[i]['FilterStatus'][flIndex]['Status']),
                            ),
                            Positioned(
                              top: 40,
                              left: 10,
                              child: provider.filtersLocal[i]['DurationLeft']!='00:00:00'? provider.filtersLocal[i]['Status'] == (flIndex+1) ? Container(
                                color: Colors.greenAccent,
                                width: 50,
                                child: Center(
                                  child: Text(provider.filtersLocal[i]['DurationLeft'], style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(): const SizedBox(),
                            ),
                            Positioned(
                              top: 0,
                              left: 45,
                              child: provider.filtersLocal[i]['PrsIn']!='-' && provider.filtersLocal[i]['FilterStatus'].length-1==flIndex? Container(
                                width:25,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${provider.filtersLocal[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                ),

                              ) :
                              const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 70,
                          height: 20,
                          child: Center(
                            child: Text(provider.filtersLocal[i]['FilterStatus'][flIndex]['Name'], style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              provider.filtersLocal[i]['PrsOut'] != '-'?
              SizedBox(
                width: 70,
                height: 70,
                child : Stack(
                  children: [
                    Image.asset('assets/images/dp_prs_sensor.png',),
                    Positioned(
                      top: 42,
                      left: 5,
                      child: Container(
                        width: 60,
                        height: 17,
                        decoration: BoxDecoration(
                          color:Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50,),
                        ),
                        child: Center(
                          child: Text('${double.parse(provider.filtersLocal[i]['PrsOut']).toStringAsFixed(2)} bar', style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ) :
              const SizedBox(),
            ],
          ),
      ],
    );

  }

  Widget buildFilterImage(int cIndex, int status) {
    String imageName = 'dp_filter';

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
        if(provider.filtersLocal.isNotEmpty) {
          if(provider.filtersLocal[0]['DurationLeft']!='00:00:00'){
            print('Duration Left updating....');
            List<String> parts = provider.filtersLocal[0]['DurationLeft'].split(':');
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
              provider.filtersLocal[0]['DurationLeft'] = updatedDurationQtyLeft;
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

class DisplayLocalFertilizer extends StatefulWidget {
  const DisplayLocalFertilizer({Key? key, required this.currentLineId}) : super(key: key);
  final String currentLineId;

  @override
  State<DisplayLocalFertilizer> createState() => _DisplayLocalFertilizerState();
}

class _DisplayLocalFertilizerState extends State<DisplayLocalFertilizer> {

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
    MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);

    final List<Map<String, dynamic>> fertilizerLocal = provider.fertilizerLocal
        .where((pump) => pump['Location'].contains(widget.currentLineId)).toList()
        .cast<Map<String, dynamic>>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<fertilizerLocal.length; fIndex++)
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                fertilizerLocal[fIndex]['Booster']!= null && fertilizerLocal[fIndex]['Booster'].isNotEmpty? Column(
                  children: [
                    SizedBox(
                        width: 70,
                        height: 140,
                        child : Stack(
                          children: [
                            AppImages.getAsset('booster', fertilizerLocal[fIndex]['Booster'][0]['Status'],''),
                            Positioned(
                              top: 70,
                              left: 15,
                              child: fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? const SizedBox(
                                width: 50,
                                child: Center(
                                  child: Text('Selector' , style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  )),
                                ),
                              ) :
                              const SizedBox(),
                            ),
                            Positioned(
                              top: 85,
                              left: 18,
                              child: fertilizerLocal[fIndex]['FertilizerTankSelector'].isNotEmpty ? Container(
                                decoration: BoxDecoration(
                                  color: fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']!=0? Colors.greenAccent : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                width: 45,
                                height: 22,
                                child: Center(
                                  child: Text(fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Status']!=0?
                                  fertilizerLocal[fIndex]['FertilizerTankSelector'][0]['Name'] : '--' , style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                ),
                              ) :
                              const SizedBox(),
                            ),
                          ],
                        )
                    ),
                  ],
                ): const SizedBox(),
                SizedBox(
                  width: fertilizerLocal[fIndex]['Fertilizer'].length * 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fertilizerLocal[fIndex]['Fertilizer'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var fertilizer = fertilizerLocal[fIndex]['Fertilizer'][index];
                      double fertilizerQty = 0.0;
                      var qtyValue = fertilizer['Qty'];
                      if (qtyValue != null) {
                        bool isString = fertilizer['Qty'] is String;
                        if(isString){
                          fertilizerQty = double.parse(fertilizer['Qty']);
                        }else{
                          fertilizerQty = fertilizer['Qty'];
                        }
                      }

                      return Row(
                        children: [
                          SizedBox(
                            width: 70, // Set the desired width for each fertilizer item
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 140,
                                  child: Stack(
                                    children: [
                                      buildFertCheImage(index, fertilizer['Status'], fertilizerLocal[fIndex]['Fertilizer'].length, fertilizerLocal[fIndex]['Agitator']),
                                      Positioned(
                                        top: 34,
                                        left: 5,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.lightBlueAccent,
                                          child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'? fertilizer['Duration'] :
                                            '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 65,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text('${fertilizer['FlowRate_LpH']}-lph', style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 103,
                                        left: 0,
                                        child: fertilizer['Status'] !=0
                                            &&
                                            fertilizer['FertSelection'] !='_'
                                            &&
                                            fertilizer['DurationLeft'] !='00:00:00'
                                            ?
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          width: 50,
                                          child: Center(
                                            child: Text(fertilizer['FertMethod']=='1' || fertilizer['FertMethod']=='3'
                                                ? fertilizer['DurationLeft']
                                                : '${fertilizer['QtyLeft'].toStringAsFixed(2)} L' , style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            ),
                                          ),
                                        ) :
                                        const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                      /*return Text('data');*/
                    },
                  ),
                ),
                fertilizerLocal[fIndex]['Agitator'].isNotEmpty ? SizedBox(
                  width: 59,
                  height: 101,
                  child: AppImages.getAsset('agitator', fertilizerLocal[fIndex]['Agitator'][0]['Status'],''),
                ):
                const SizedBox(),
                SizedBox(
                  width: 70,
                  height: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fertilizerLocal[fIndex]['Ec'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: fertilizerLocal[fIndex]['Ec'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: fertilizerLocal[fIndex]['Ec'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(fertilizerLocal[fIndex]['Ec'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(fertilizerLocal[fIndex]['Ec'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                      fertilizerLocal[fIndex]['Ph'].isNotEmpty ? SizedBox(
                        width: 70,
                        height: fertilizerLocal[fIndex]['Ph'].length*35,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: fertilizerLocal[fIndex]['Ph'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(fertilizerLocal[fIndex]['Ph'][index]['Name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),)),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: Center(child: Text(fertilizerLocal[fIndex]['Ph'][index]['Status'], style: TextStyle(fontSize: 10))),
                                ),
                              ],
                            );
                            /*return Text('data');*/
                          },
                        ),
                      ) :
                      const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget buildFertCheImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_fert_channel_last_aj';
      }else{
        imageName='dp_fert_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_fert_channel_first_aj';
        }else{
          imageName='dp_fert_channel_center_aj';
        }
      }else{
        imageName='dp_fert_channel_center';
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
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/images/$imageName');

  }


  void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context,listen: false);
        final List<Map<String, dynamic>> fertilizerLocal = provider.fertilizerLocal
            .where((pump) => pump['Location'].contains(widget.currentLineId))
            .toList()
            .cast<Map<String, dynamic>>();


        for (var local in fertilizerLocal) {
          local['Fertilizer'].forEach((fertilizer) {
            int ferMethod = fertilizer['FertMethod'] is int
                ? fertilizer['FertMethod']
                : int.parse(fertilizer['FertMethod']);
            if (fertilizer['Status'] != 0 && ferMethod == 1) {
              //fertilizer time base
              List<String> parts = fertilizer['DurationLeft'].split(':');
              String updatedDurationQtyLeft = formatDuration(parts);
              setState(() {
                fertilizer['DurationLeft'] = updatedDurationQtyLeft;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 2) {
              //fertilizer flow base
              double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
              double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
              qtyLeftDouble -= flowRate;
              qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
              setState(() {
                fertilizer['QtyLeft'] = qtyLeftDouble;
              });
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 3){
              //fertilizer proposal time base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                List<String> parts = fertilizer['DurationLeft'].split(':');
                String updatedDurationQtyLeft = formatDuration(parts);
                fcOnTimeRd--;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['DurationLeft'] = updatedDurationQtyLeft;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 4){
              //fertilizer proposal qty base
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else if (fertilizer['Status'] != 0 && ferMethod == 5){
              //fertilizer pro qty per 1000 Lit
              double fcOnTime = convertQtyLeftToDouble(fertilizer['OnTime']);
              double fcOffTime = convertQtyLeftToDouble(fertilizer['OffTime']);
              int fcOnTimeRd = fcOnTime.round();
              int fcOffTimeRd = fcOffTime.round();

              if (fertilizer['OriginalOnTime'] == null) {
                fertilizer['OriginalOnTime'] = fertilizer['OnTime'];
              }
              if (fertilizer['OriginalOffTime'] == null) {
                fertilizer['OriginalOffTime'] = fertilizer['OffTime'];
              }
              if (fertilizer['OriginalStatus'] == null) {
                fertilizer['OriginalStatus'] = fertilizer['Status'];
              }

              if(fcOnTimeRd>0){
                fcOnTimeRd--;
                double qtyLeftDouble = convertQtyLeftToDouble(fertilizer['QtyLeft']);
                double flowRate = convertFlowValueToDouble(fertilizer['FlowRate']);
                qtyLeftDouble -= flowRate;
                qtyLeftDouble = qtyLeftDouble < 0 ? 0 : qtyLeftDouble;
                setState(() {
                  fertilizer['OnTime'] = '$fcOnTimeRd';
                  fertilizer['Status'] = fertilizer['OriginalStatus'];
                  fertilizer['QtyLeft'] = qtyLeftDouble;
                });
              }else if(fcOffTimeRd>0){
                fcOffTimeRd--;
                setState(() {
                  fertilizer['OffTime'] = '$fcOffTimeRd';
                  fertilizer['Status'] = 4;
                });

                if(fcOffTimeRd==0){
                  fertilizer['OnTime'] = fertilizer['OriginalOnTime'];
                  fertilizer['OffTime'] = fertilizer['OriginalOffTime'];
                }
              }
            }
            else{
              //print('ferMethod 6');
            }
          });
        }
      }
      catch(e){
        print(e);
      }

    });
  }

  String formatDuration(List<String> parts) {
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
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double convertQtyLeftToDouble(dynamic qtyLeftValue) {
    double qtyLeftDouble = 0.00;
    if (qtyLeftValue is int) {
      qtyLeftDouble = qtyLeftValue.toDouble();
    } else if (qtyLeftValue is String) {
      qtyLeftDouble = double.tryParse(qtyLeftValue) ?? 0.00;
    } else if (qtyLeftValue is double) {
      qtyLeftDouble = qtyLeftValue;
    } else {
      qtyLeftDouble = 0.00;
    }
    return qtyLeftDouble;
  }

  double convertFlowValueToDouble(dynamic flowValue) {
    double flowRate = 0.00;
    if (flowValue is int) {
      flowRate = flowValue.toDouble();
    } else if (flowValue is String) {
      flowRate = double.tryParse(flowValue) ?? 0.00;
    } else if (flowValue is double) {
      flowRate = flowValue;
    } else {
      flowRate = 0.00; // Default value in case the type is unknown
    }
    return flowRate;
  }

}

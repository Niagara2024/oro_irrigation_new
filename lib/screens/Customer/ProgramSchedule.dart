import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/ConfigDashboard/configMakerView.dart';
import 'package:oro_irrigation_new/screens/Customer/WeatherScreen.dart';
import 'package:oro_irrigation_new/screens/Customer/radiationsets.dart';
import 'package:oro_irrigation_new/screens/Customer/system_definition_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/virtual_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/watersourceUI.dart';

import 'FertilizerLibrary.dart';
import 'GlobalFertLimit.dart';
import 'Group/groupscreen.dart';
import 'IrrigationProgram/program_library.dart';
import 'IrrigationProgram/program_queue_screen.dart';
import 'ScheduleView.dart';
import 'backwash_ui.dart';
import 'conditionscreen.dart';
import 'frost_productionScreen.dart';

class ProgramSchedule extends StatefulWidget {
  const ProgramSchedule({
    Key? key,
    required this.customerID,
    required this.controllerID,
    required this.siteName,
    required this.imeiNumber,
    required this.userId,
  }) : super(key: key);

  final int userId, customerID, controllerID;
  final String siteName, imeiNumber;

  @override
  State<ProgramSchedule> createState() => _ProgramScheduleState();
}

class _ProgramScheduleState extends State<ProgramSchedule> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 15, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLANNING'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text :'Irrigation Program', icon: Icon(Icons.dashboard_outlined)),
            Tab(text :'Water source', icon: Icon(Icons.water)),
            Tab(text :'Virtual Water Meter', icon: Icon(Icons.gas_meter_outlined)),
            Tab(text :'Radiation set', icon: Icon(Icons.waves)),
            Tab(text :'Satellite', icon: Icon(Icons.satellite_outlined)),
            Tab(text :'Groups', icon: Icon(Icons.group_work_outlined)),
            Tab(text :'Conditions', icon: Icon(Icons.format_list_numbered)),
            Tab(text :'Frost Protection', icon: Icon(Icons.deblur_outlined)),
            Tab(text :'Filter Backwash', icon: Icon(Icons.filter_alt_outlined)),
            Tab(text :'Fertilizer set', icon: Icon(Icons.settings_outlined)),
            Tab(text :'Global Limit', icon: Icon(Icons.settings_outlined)),
            Tab(text :'Weather', icon: Icon(Icons.ac_unit_rounded)),
            Tab(text :'System Definition', icon: Icon(Icons.power_outlined)),
            Tab(text :'Program Queue', icon: Icon(Icons.question_answer_outlined)),
            Tab(text :'Schedule View', icon: Icon(Icons.question_answer_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProgramLibraryScreen(userId: widget.customerID, controllerId: widget.controllerID),
          watersourceUI(userId: widget.customerID, controllerId: widget.controllerID, deviceID: widget.imeiNumber,),
          VirtualMeterScreen(userId: widget.customerID, controllerId: widget.controllerID, deviceId: widget.imeiNumber,),
          RadiationsetUI(userId: widget.customerID, controllerId: widget.controllerID,deviceId:widget.imeiNumber,),
          const Center(child: Text('Satellite')),
          MyGroupScreen(userId: widget.customerID, controllerId: widget.controllerID),
          ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNumber),
          FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID,deviceID: widget.imeiNumber,),
          FilterBackwashUI(userId: widget.customerID, controllerId: widget.controllerID,deviceID: widget.imeiNumber,),
          FertilizerLibrary(userId: widget.userId, controllerId: widget.controllerID, customerID: widget.customerID),
          GlobalFertLimit(userId: widget.userId, controllerId: widget.controllerID, customerId: widget.customerID,),
          WeatherScreen(userId: widget.userId, controllerId: widget.controllerID),
          SystemDefinition(userId: widget.userId, controllerId: widget.controllerID),
          ProgramQueueScreen(userId: widget.userId, controllerId: widget.controllerID, cutomerId: widget.customerID,),
          ScheduleViewScreen(),
        ],
      ),
    );
  }
}
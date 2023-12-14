import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/radiationsets.dart';
import 'package:oro_irrigation_new/screens/Customer/virtual_screen.dart';

import 'Group/groupscreen.dart';
import 'IrrigationProgram/program_library.dart';
import 'backwash_ui.dart';
import 'conditionscreen.dart';
import 'frost_productionScreen.dart';

class ProgramSchedule extends StatefulWidget {
  const ProgramSchedule({Key? key, required this.customerID, required this.controllerID, required this.siteName, required this.imeiNumber}) : super(key: key);
  final int customerID, controllerID;
  final String siteName, imeiNumber;

  @override
  State<ProgramSchedule> createState() => _ProgramScheduleState();
}

class _ProgramScheduleState extends State<ProgramSchedule> {

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text (widget.siteName),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              // Handle item selection
              setState(() {
                _selectedIndex = index;
              });

            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.water_drop_outlined),
                label: Text('Irrigation program'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.water),
                label: Text('Water source'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.gas_meter_outlined),
                label: Text('Virtual Water\nMeter'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.waves),
                label: Text('Radiation sets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.satellite_outlined),
                label: Text('Satellite'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_work_outlined),
                label: Text('Groups'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.format_list_numbered),
                label: Text('Conditions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.deblur_outlined),
                label: Text('Frost protection\n& Rain delay'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.filter_alt_outlined),
                label: Text('Filter Backwash'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: _selectedIndex == 0 ? ProgramLibraryScreen(userId: widget.customerID, controllerId: widget.controllerID):
              _selectedIndex == 2 ? VirtualMeterScreen(userId: widget.customerID, controllerId: widget.controllerID):
              _selectedIndex == 3 ? RadiationsetUI(userId: widget.customerID, controllerId: widget.controllerID):
              _selectedIndex == 5 ? MyGroupScreen(userId: widget.customerID, controllerId: widget.controllerID) :
              _selectedIndex == 6 ? ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNumber):
              _selectedIndex == 7 ? FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID) :
              _selectedIndex == 8 ? FilterBackwashUI(userId: widget.customerID, controllerId: widget.controllerID) :Text('data')
            ),
          ),
        ],
      ),
    );
  }
}

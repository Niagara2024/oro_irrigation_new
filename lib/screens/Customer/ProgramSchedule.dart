import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/Models/WaterSource.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Customer/WeatherScreen.dart';
import 'package:oro_irrigation_new/screens/Customer/radiationsets.dart';
import 'package:oro_irrigation_new/screens/Customer/virtual_screen.dart';
import 'package:oro_irrigation_new/screens/Customer/watersourceUI.dart';

import 'FertilizerLibrary.dart';
import 'GlobalFertLimit.dart';
import 'Group/groupscreen.dart';
import 'IrrigationProgram/program_library.dart';
import 'backwash_ui.dart';
import 'conditionscreen.dart';
import 'frost_productionScreen.dart';

class ProgramSchedule extends StatefulWidget {
  const ProgramSchedule({Key? key, required this.customerID, required this.controllerID, required this.siteName, required this.imeiNumber, required this.userId}) : super(key: key);
  final int userId, customerID, controllerID;
  final String siteName, imeiNumber;

  @override
  State<ProgramSchedule> createState() => _ProgramScheduleState();
}

class _ProgramScheduleState extends State<ProgramSchedule> {

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

  Widget _centerWidget = const Center(child: Text('Dashboard'));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      //_centerWidget = Center(child: CustomerHome(customerID: widget.userID, type: 0, customerName: '', userID: widget.userID,));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PLANING'),),
      body: Stack(
        children: [
          MyProgramDrawer(
            onOptionSelected: (option) {
              setState(() {
                if (option == 'Dashboard') {
                  _centerWidget = const Center(child: Text('Dashboard'));
                }else if (option == 'Irrigation program') {
                  _centerWidget = ProgramLibraryScreen(userId: widget.customerID, controllerId: widget.controllerID);
                } else if (option == 'Water source') {
                  _centerWidget = watersourceUI(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Virtual Water Meter') {
                  _centerWidget = VirtualMeterScreen(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Radiation sets') {
                  _centerWidget = RadiationsetUI(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Satellite') {
                  _centerWidget = const Center(child: Text('Satellite'));
                }else if (option == 'Groups') {
                  _centerWidget = MyGroupScreen(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Conditions') {
                  _centerWidget = ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNumber);
                }else if (option == 'Frost protection & Rain delay') {
                  _centerWidget = FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Filter Backwash') {
                  _centerWidget = FilterBackwashUI(userId: widget.customerID, controllerId: widget.controllerID);
                }else if (option == 'Global Limit') {
                  _centerWidget = GlobalFertLimit(userId: widget.userId, controllerId: widget.controllerID, customerId: widget.customerID,);
                }else if (option == 'Weather') {
                  _centerWidget = WeatherScreen(userId: widget.userId, controllerId: widget.controllerID);
                }else {
                  _centerWidget = FertilizerLibrary(userId: widget.userId, controllerId: widget.controllerID, customerID: widget.customerID,);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 250),
            child: Container(
                color:Colors.white,
                child: _centerWidget
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text (widget.siteName),
      ),
      body: Row(
        children: [
          NavigationRail(
            minWidth: 150,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
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
                label: Text('Virtual Water Meter'),
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
                label: Text('Frost protection & Rain delay'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.filter_alt_outlined),
                label: Text('Filter Backwash'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.format_textdirection_r_to_l),
                label: Text('Fertilizer set'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('Global Limit'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0 ? ProgramLibraryScreen(userId: widget.customerID, controllerId: widget.controllerID):
            _selectedIndex == 1 ? watersourceUI(userId: widget.customerID, controllerId: widget.controllerID):
            _selectedIndex == 2 ? VirtualMeterScreen(userId: widget.customerID, controllerId: widget.controllerID):
            _selectedIndex == 3 ? RadiationsetUI(userId: widget.customerID, controllerId: widget.controllerID):
            _selectedIndex == 5 ? MyGroupScreen(userId: widget.customerID, controllerId: widget.controllerID) :
            _selectedIndex == 6 ? ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNumber):
            _selectedIndex == 7 ? FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID) :
            _selectedIndex == 8 ? FilterBackwashUI(userId: widget.customerID, controllerId: widget.controllerID):
            _selectedIndex == 9 ? GlobalFertLimit(userId: widget.userId, controllerId: widget.controllerID, customerId: widget.customerID,):
            _selectedIndex == 10 ? FertilizerLibrary(userId: widget.userId, controllerId: widget.controllerID, customerID: widget.customerID,) :Text('data'),
          ),
        ],
      ),
    );
  }
}

class MyProgramDrawer extends StatelessWidget {
  final Function(String) onOptionSelected;
  const MyProgramDrawer({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: myTheme.primaryColor.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: myTheme.primaryColor,),
            title: const Text('Dashboard', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Dashboard');
            },
          ),
          ListTile(
            leading: Icon(Icons.water_drop_outlined, color: myTheme.primaryColor,),
            title: const Text('Irrigation program', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Irrigation program');
            },
          ),
          ListTile(
            leading: Icon(Icons.water, color: myTheme.primaryColor,),
            title: const Text('Water source', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Water source');
            },
          ),
          ListTile(
            leading: Icon(Icons.gas_meter_outlined, color: myTheme.primaryColor,),
            title: const Text('Virtual Water Meter', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Virtual Water Meter');
            },
          ),
          ListTile(
            leading: Icon(Icons.waves, color: myTheme.primaryColor,),
            title: const Text('Radiation sets', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Radiation sets');
            },
          ),
          ListTile(
            leading: Icon(Icons.satellite_outlined, color: myTheme.primaryColor,),
            title: const Text('Satellite', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Satellite');
            },
          ),
          ListTile(
            leading: Icon(Icons.group_work_outlined, color: myTheme.primaryColor,),
            title: const Text('Groups', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Groups');
            },
          ),
          ListTile(
            leading: Icon(Icons.format_list_numbered, color: myTheme.primaryColor,),
            title: const Text('Conditions', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Conditions');
            },
          ),
          ListTile(
            leading: Icon(Icons.deblur_outlined, color: myTheme.primaryColor,),
            title: const Text('Frost protection & Rain delay', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Frost protection & Rain delay');
            },
          ),
          ListTile(
            leading: Icon(Icons.filter_alt_outlined, color: myTheme.primaryColor,),
            title: const Text('Filter Backwash', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Filter Backwash');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: myTheme.primaryColor,),
            title: const Text('Fertilizer set', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Fertilizer set');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: myTheme.primaryColor,),
            title: const Text('Global Limit', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Global Limit');
            },
          ),
          ListTile(
            leading: Icon(Icons.ac_unit_rounded, color: myTheme.primaryColor,),
            title: const Text('Weather', style: TextStyle(fontSize: 14)),
            onTap: () {
              onOptionSelected('Weather');
            },
          ),
          // Add more ListTile widgets for additional options
        ],
      ),
    );
  }
}

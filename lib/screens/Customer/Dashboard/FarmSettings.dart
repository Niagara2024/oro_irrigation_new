import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Config/names_form.dart';

class FarmSettings extends StatefulWidget {
  const FarmSettings({Key? key, required this.customerID, required this.siteID, required this.controllerID, required this.siteName, required this.imeiNo, required this.userId}) : super(key: key);
  final int userId, customerID, siteID, controllerID;
  final String siteName, imeiNo;

  @override
  State<FarmSettings> createState() => _FarmSettingsState();
}

class _FarmSettingsState extends State<FarmSettings> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            TabBar(
              indicatorColor: Colors.pinkAccent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'General'),
                Tab(text: 'Names'),
                Tab(text: 'Other Devices'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Widgets for Tab 1
                  Center(child: Text('Tab 1 Content')),
                  // Widgets for Tab 2
                  Center(child: Names(userID: widget.userId,  customerID: widget.customerID, controllerId: widget.controllerID)),
                  // Widgets for Tab 3
                  Center(child: Text('Tab 3 Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

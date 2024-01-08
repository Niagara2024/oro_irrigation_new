import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../Config/names_form.dart';

class FarmSettings extends StatefulWidget {
  const FarmSettings({Key? key, required this.customerID, required this.siteList}) : super(key: key);
  final int customerID;
  final List<DashboardModel> siteList;

  @override
  State<FarmSettings> createState() => _FarmSettingsState();
}



class _FarmSettingsState extends State<FarmSettings> {

  int siteIndex = 0;
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return visibleLoading? buildLoadingIndicator(visibleLoading, MediaQuery.sizeOf(context).width):
    DefaultTabController(
      length: widget.siteList.length, // Set the number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SETTINGS'),
          backgroundColor: myTheme.primaryColor,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // getControllerDashboardDetails(0, ddSelection);
              },
            ),
            const SizedBox(width: 10,),
          ],
          bottom: widget.siteList.length >1 ? TabBar(
            indicatorColor: const Color.fromARGB(255, 175, 73, 73),
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              for (var i = 0; i < widget.siteList.length; i++)
                Tab(text: widget.siteList[i].siteName ?? '',),
            ],
            onTap: (index) {
              siteIndex = index;
            },
          ) : null,
        ),
        body: DefaultTabController(
          length: 3, // Number of tabs
          child: Column(
            children: [
              const TabBar(
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
                    const Center(child: Text('Tab 1 Content')),
                    // Widgets for Tab 2
                    Center(child: Names(userID: widget.customerID,  customerID: widget.customerID, controllerId: widget.siteList[siteIndex].controllerId)),
                    // Widgets for Tab 3
                    const Center(child: Text('Tab 3 Content')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }
}

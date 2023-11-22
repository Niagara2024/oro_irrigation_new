import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/constant_tab_bar_view.dart';
import 'DataAc/data_acquisition_main.dart';
import 'Preference/preference_main_screen.dart';
import 'dealer_definition_config.dart';
import 'names_form.dart';


class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key, required this.userID, required this.customerID, required this.siteID, required this.siteName, required  this.controllerId, required this.imeiNumber,}) : super(key: key);
  final int userID, customerID, siteID, controllerId;
  final String siteName, imeiNumber;

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with SingleTickerProviderStateMixin
{
  static List<Object> configList = ['Names', 'Preferences','Constant', 'Dealer definition', 'Data acquisition','Geography'];
  final _configTabs = List.generate(configList.length, (index) => configList[index]);
  late final TabController _tabCont;

  @override
  void initState() {
    _tabCont = TabController(length: configList.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              DefaultTabController(
                length: configList.length, // Number of tabs
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabCont,
                      isScrollable: true,
                      tabs: [
                        ..._configTabs.map((label) => Tab(
                          icon: label =='Preferences'? const Icon(Icons.settings_outlined):
                          label =='Constant'? const Icon(Icons.menu_open):
                          label =='Dealer definition'? const Icon(Icons.perm_identity_outlined) :
                          label =='Data acquisition'? const Icon(Icons.dataset_linked_outlined):
                          label =='System'? const Icon(Icons.theaters_outlined):
                          label =='Names'? const Icon(Icons.drive_file_rename_outline):const Icon(Icons.location_on_outlined),
                          child: Text(label.toString(),),
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height-260,
                      child: TabBarView(
                        controller: _tabCont,
                        children: [
                          ..._configTabs.map((label) => ConfigPage(
                            label: label.toString(), userID: widget.userID, customerID: widget.customerID, siteID: widget.siteID, controllerId: widget.controllerId, imeiNumber: widget.imeiNumber,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteName, style: const TextStyle(color: Colors.white),), backgroundColor: const Color(0xFF0D5D9A),
        bottom: TabBar(
          controller: _tabCont,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          tabs: [
            ..._configTabs.map((label) => Tab(
                icon: label =='Preferences'? const Icon(Icons.settings_outlined):
                label =='Constant'? const Icon(Icons.menu_open):
                label =='Dealer definition'? const Icon(Icons.perm_identity_outlined) :
                label =='Data acquisition'? const Icon(Icons.dataset_linked_outlined):
                label =='System'? const Icon(Icons.theaters_outlined):
                label =='Names'? const Icon(Icons.drive_file_rename_outline):const Icon(Icons.location_on_outlined),
                child: Text(label.toString(),),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCont,
        children: [
          ..._configTabs.map((label) => ConfigPage(
              label: label.toString(), userID: widget.userID, customerID: widget.customerID, siteID: widget.siteID, controllerId: widget.controllerId, imeiNumber: widget.imeiNumber,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfigPage extends StatelessWidget
{
  const ConfigPage({Key? key, required this.label, required this.userID, required this.customerID, required this.siteID, required this.controllerId, required this.imeiNumber}) : super(key: key);
  final String label, imeiNumber;
  final int userID, customerID, siteID, controllerId;

  @override
  Widget build(BuildContext context)
  {
   if(label.toString()=='Names'){
      return Names(userID: userID,  customerID: customerID, groupID: controllerId);
    }else if(label.toString()=='Dealer definition'){
      return DealerDefinitionInConfig(userID: userID,  customerID: customerID, groupID: controllerId, imeiNo: imeiNumber,);
    }else if(label.toString()=='Preferences'){
      return PreferencesScreen(customerID: customerID, controllerID: controllerId, userID: userID,);
    }else if(label.toString()=='Data acquisition'){
      return DataAcquisitionMain(customerID: customerID, controllerID: controllerId, userId: userID,);
    }else if(label.toString()=='Constant'){
      return ConstantInConfig(userID: userID, customerID: customerID, siteID: controllerId);
    }

    return Center(child: Text('Page of $label'));
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/screens/Config/Preference/pump_screen.dart';
import 'package:oro_irrigation_new/screens/Config/Preference/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../constants/http_service.dart';
import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_snack_bar.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import 'contact_screen.dart';
import 'general_screen.dart';
import 'notification_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, this.customerID, this.controllerID, this.userID});

  final customerID,controllerID,userID;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> with TickerProviderStateMixin{
  late TabController _tabController;
  final HttpService httpService = HttpService();
  bool settingsSelected = false;
  // final MqttService mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    final preferencesMainProvider = Provider.of<PreferencesMainProvider>(context, listen: false);
    preferencesMainProvider.updateTabIndex(0);
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        preferencesMainProvider.preferencesDataFromApi(widget.customerID, widget.controllerID).then((value) {
          _tabController = TabController(
              length: preferencesMainProvider.label.length,
              vsync: this
          );
          _tabController.addListener(() {
            preferencesMainProvider.updateTabIndex(_tabController.index);
          });
          preferencesMainProvider.updatePumpIndex2(0);
          preferencesMainProvider.extractTotalPumpsInfo();
          preferencesMainProvider.settingsTabController = TabController(length: preferencesMainProvider.totalPumps.length, vsync: this)
            ..addListener(() {
              preferencesMainProvider.updatePumpIndex2(preferencesMainProvider.settingsTabController.index);
            });
          if(preferencesMainProvider.configuration!.settings!.isEmpty){
            preferencesMainProvider.initPumpSettingModel(preferencesMainProvider.configuration!.sourcePumpName);
            preferencesMainProvider.initPumpSettingModel(preferencesMainProvider.configuration!.irrigationPumpName);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    final preferencesProvider = Provider.of<PreferencesMainProvider>(context);

    if(preferencesProvider.configuration != null){
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return DefaultTabController(
              length: preferencesProvider.label.length,
              child: Scaffold(
                body: Row(
                  children: <Widget>[
                    constraints.maxWidth > 550 ? SizedBox(
                      width: (constraints.maxWidth > 550 || constraints.maxWidth <= 1050) ? constraints.maxWidth * 0.2 : constraints.maxWidth * 0.25,
                      child: Drawer(
                        child: ListView(
                          children: <Widget>[
                            for (int i = 0; i < preferencesProvider.label.length; i++) ...[
                              ListTile(
                                title: Text(
                                  preferencesProvider.label[i],
                                  style: TextStyle(color: _tabController.index == i ? Colors.white : null),
                                ),
                                leading: Icon(
                                  preferencesProvider.icons[i],
                                  color: _tabController.index == i ? Colors.white : null,
                                ),
                                onTap: () {
                                  _navigateToTab(i);
                                  if(preferencesProvider.label[i] == "Settings") {
                                    settingsSelected = true;
                                  } else {
                                    settingsSelected = false;
                                  }
                                },
                                selected: _tabController.index == i,
                                selectedTileColor: _tabController.index == i ? Theme.of(context).primaryColor : null,
                                hoverColor: _tabController.index == i ? Theme.of(context).primaryColor : null,
                              ),
                              if (preferencesProvider.label[i] == 'Settings') ...[
                                ...preferencesProvider.configuration!.settings!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final e = entry.value;
                                  final id = e.id;
                                  return Visibility(
                                    visible: settingsSelected,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: (constraints.maxWidth > 550 && constraints.maxWidth > 1050) ? 50 : 10),
                                      child: ListTile(
                                        title: Text(id),
                                        onTap: () {
                                          _navigateToPump(index);
                                        },
                                        selected: preferencesProvider.settingsTabController.index == index,
                                        // selectedTileColor: preferencesProvider.settingsTabController.index ==index ? Theme.of(context).hoverColor : null,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList()
                              ],
                            ],
                          ],
                        ),
                      ),
                    ) : Container(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          for(var i = 0; i < (preferencesProvider.label.length); i++)
                            _buildTabContent(i, preferencesProvider.configuration?.contactName.isNotEmpty,
                                preferencesProvider.configuration!.irrigationPumpName.isEmpty && preferencesProvider.configuration!.sourcePumpName.isEmpty)
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    final dataToSend = Provider.of<PreferencesMainProvider>(context, listen: false).configuration;
                    Map<String, dynamic> userData = {
                      "userId": widget.customerID,
                      "controllerId": widget.controllerID,
                      "createUser": widget.userID
                    };
                    userData.addAll(dataToSend!.toJson());
                    print(dataToSend.toMqtt());
                    // print(userData);
                    // print(dataToSend.eventNotifications.map((e) => e.value));
                    // mqttService.publish('get-tweet-response/86418005321234', '${dataToSend.toMqtt()}');
                    try {
                      final createUserPreference = await httpService.postRequest('createUserPreference', userData);
                      final message = jsonDecode(createUserPreference.body);
                      // print(createUserPreference.body);
                      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  message['message']));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  'Failed to update because of $error'));
                      print("Error: $error");
                    }
                  },
                  child: const Icon(Icons.send),
                ),
              ),
            );
          }
      );
    }
    else {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(semanticsLabel: "Loading")
        ),
      );
    }
  }

  Widget _buildTabContent(int index, contactsIsNotEmpty, pumpsEmpty) {
    if(pumpsEmpty) {
      switch (index) {
        case 0: return const GeneralScreen();
        default: return Container();
      }
    } else {
      if(contactsIsNotEmpty) {
        switch (index) {
          case 0: return const GeneralScreen();
          case 1: return const ContactsScreen();
          case 2: return const PumpScreen();
          case 3: return const SettingsScreen();
          case 4: return const NotificationScreen();
          default: return Container();
        }
      }
      else {
        switch (index) {
          case 0: return const GeneralScreen();
          case 1: return const SettingsScreen();
          case 2: return const NotificationScreen();
          default: return Container();
        }
      }
    }
  }

  void _navigateToTab(int tabIndex) {
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  void _navigateToPump(tabIndex) {
    final preferencesProvider = Provider.of<PreferencesMainProvider>(context, listen: false);
    if (preferencesProvider.settingsTabController != tabIndex) {
      preferencesProvider.settingsTabController.animateTo(tabIndex);
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

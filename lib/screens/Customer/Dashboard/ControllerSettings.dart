import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../Models/language.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../Config/names_form.dart';

class ControllerSettings extends StatefulWidget {
  const ControllerSettings({Key? key, required this.customerID, required this.siteData}) : super(key: key);
  final int customerID;
  final DashboardModel siteData;

  @override
  State<ControllerSettings> createState() => _ControllerSettingsState();
}



class _ControllerSettingsState extends State<ControllerSettings> {

  int siteIndex = 0;
  bool visibleLoading = false;

  final List<LanguageList> languageList = <LanguageList>[];
  String _mySelection = 'English';

  String selectedWeekday = 'Monday';
  List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String? selectedTime;
  List<String> utcTimes = [
    "+0",
    "+1",
    "+2",
    "+3",
    "+4",
    "+5",
    "+6",
    "+7",
    "+8",
    "+9",
    "+10",
    "+11",
    "+12",
    "+13",
    "-11",
    "-10",
    "-9",
    "-8",
    "-7",
    "-6",
    "-5",
    "-4",
    "-3",
    "-2",
    "-1",
  ];

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  Future<void> getLanguage() async
  {
    final response = await HttpService().postRequest("getLanguageByActive", {"active": '1'});
    if (response.statusCode == 200)
    {
      languageList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          languageList.add(LanguageList.fromJson(cntList[i]));
        }
        setState(() {
          languageList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return visibleLoading? buildLoadingIndicator(visibleLoading, MediaQuery.sizeOf(context).width):
    Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: [
            const ListTile(
              title: Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('Manage your controller settings and preference', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const TabBar(
              indicatorColor: Colors.pinkAccent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'General'),
                Tab(text: 'Preference'),
                Tab(text: 'Names'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildGeneralContent(),
                  const Center(child: Text('Tab 3 Content')),
                  Center(child: Names(userID: widget.customerID,  customerID: widget.customerID, controllerId: widget.siteData.controllerId)),
                ],
              ),
            ),
          ],
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

  Widget buildGeneralContent() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Controller Name'),
                    leading: Icon(Icons.developer_board, color: myTheme.primaryColor,),
                    trailing: SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Controller name',
                          suffixIcon: Icon(Icons.edit, color: myTheme.primaryColor,), // This adds a search icon as the trailing icon
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Model'),
                    leading: Icon(Icons.model_training, color: myTheme.primaryColor,),
                    trailing: const Text('wireless controller'),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Controller ID'),
                    leading: Icon(Icons.numbers_outlined, color: myTheme.primaryColor,),
                    trailing: const Text('A524C2124556'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Form Name'),
                    leading: Icon(Icons.area_chart_outlined, color: myTheme.primaryColor,),
                    trailing: SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your form name',
                          suffixIcon: Icon(Icons.edit, color: myTheme.primaryColor,), // This adds a search icon as the trailing icon
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Language'),
                    leading: Icon(Icons.language, color: myTheme.primaryColor,),
                    trailing: DropdownButton(
                      items: languageList.map((item) {
                        return DropdownMenuItem(
                          value: item.languageName,
                          child: Text(item.languageName),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          _mySelection = newVal!;
                        });
                      },
                      value: _mySelection,
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Week first day'),
                    leading: Icon(Icons.calendar_view_week, color: myTheme.primaryColor,),
                    trailing: DropdownButton<String>(
                      value: selectedWeekday,
                      hint: const Text('Select a weekday'),
                      onChanged: (String? newValue) { // Change the type to String?
                        if (newValue != null) { // Check if newValue is not null
                          setState(() {
                            selectedWeekday = newValue;
                          });
                        }
                      },
                      items: weekdays.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Current UTC Time'),
                    leading: Icon(Icons.date_range, color: myTheme.primaryColor,),
                    trailing: const Text('15:10:00'),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('Current Date'),
                    leading: Icon(Icons.date_range, color: myTheme.primaryColor,),
                    trailing: Text('13-05-2024'),
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: const Text('UTC'),
                    leading: Icon(Icons.timer_outlined, color: myTheme.primaryColor,),
                    trailing: DropdownButton<String>(
                      value: selectedTime,
                      hint: const Text('UTC time'),
                      onChanged: (String? newValue) { // Change the type to String?
                        if (newValue != null) { // Check if newValue is not null
                          setState(() {
                            selectedTime = newValue;
                          });
                        }
                      },
                      items: utcTimes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeChangeDialog extends StatefulWidget {
  final ThemeData initialTheme;
  const ThemeChangeDialog({super.key, required this.initialTheme});

  @override
  _ThemeChangeDialogState createState() => _ThemeChangeDialogState();
}

class _ThemeChangeDialogState extends State<ThemeChangeDialog> {
  late ThemeData _selectedTheme;

  @override
  void initState() {
    _selectedTheme = widget.initialTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            title: Container(
              color: Colors.cyan,
              width: 150,
              height: 75,
              child: const Center(child: Text('Theme cyan')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.yellow,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme yellow')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.green,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme green')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.pink,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme pink')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.purple,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme purple')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        MaterialButton(
          onPressed: () {
            // Update the theme and close the dialog
            //ThemeController().updateTheme(_selectedTheme);
            Navigator.pop(context);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}



import 'package:flutter/material.dart';

import '../../../../Models/Customer/Dashboard/PumpControllerModel/PumpSettingsMDL.dart';

class PumpCommonSettings extends StatefulWidget {
  const PumpCommonSettings({Key? key, required this.pumpControllerSettings}) : super(key: key);
  final PumpSettingsMDL pumpControllerSettings;

  @override
  State<PumpCommonSettings> createState() => _PumpCommonSettingsState();
}

class _PumpCommonSettingsState extends State<PumpCommonSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 0.0,
        ),
        itemCount: widget.pumpControllerSettings.commonPumpSetting?[0].settingList?.length ?? 0,
        itemBuilder: (context, index) {
          var settingGroup = widget.pumpControllerSettings.commonPumpSetting?[0].settingList?[index];
          String groupName = settingGroup?.name ?? 'Unknown Group';
          List<SettingCmm> settings = settingGroup?.setting ?? [];

          return Card(
            elevation: 1.0,
            margin: const EdgeInsets.all(5.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    groupName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: settings.map((setting) {
                      int widgetTypeId = setting.widgetTypeId ?? 0;
                      String title = setting.title ?? 'Unknown Title';
                      String iconCodePoint = setting.iconCodePoint ?? '0xe000';
                      String iconFontFamily = setting.iconFontFamily ?? 'MaterialIcons';
                      var value = setting.value;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Icon(
                            IconData(int.parse(iconCodePoint), fontFamily: iconFontFamily),
                          ),
                          title: Text(title),
                          trailing: SizedBox(
                            width: 100, // Adjust width as needed
                            child: _buildWidget(widgetTypeId, value),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWidget(int widgetTypeId, dynamic value) {
    switch (widgetTypeId) {
      case 1:
        return SizedBox(
          width: 100, // Adjust width as needed
          child: TextField(
            controller: TextEditingController(text: value?.toString() ?? ''),
          ),
        );
      case 2:
        return SizedBox(
          width: 50, // Adjust width as needed
          child: value.runtimeType==bool?Switch(
            value: value ?? false,
            onChanged: (bool newValue) {},
          ):
          Text('data'),
        );
      case 3:
        return SizedBox(
          width: 100, // Adjust width as needed
          child: ElevatedButton(
            onPressed: () {},
            child: Text(value?.toString() ?? 'Button'),
          ),
        );
      default:
        return Container(); // Use a constrained widget or size constraints
    }
  }
}

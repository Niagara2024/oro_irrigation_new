import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_animated_switcher.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import '../../../widgets/SCustomWidgets/custom_text_container.dart';
import '../../../widgets/SCustomWidgets/custom_time_picker.dart';
import '../../../widgets/SCustomWidgets/custom_train_widget.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final settingsProvider =  Provider.of<PreferencesMainProvider>(context, listen: false);
    settingsProvider.updatePumpIndex2(0);
    settingsProvider.extractTotalPumpsInfo();
    _tabController = TabController(length: settingsProvider.totalPumps.length, vsync: this)
      ..addListener(() {
        settingsProvider.updatePumpIndex2(_tabController.index);
      });
    if(settingsProvider.configuration!.settings!.isEmpty){
      settingsProvider.initPumpSettingModel(settingsProvider.configuration!.sourcePumpName);
      settingsProvider.initPumpSettingModel(settingsProvider.configuration!.irrigationPumpName);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<PreferencesMainProvider>(context);
    final selectedPumpIndex = settingsProvider.selectedPumpIndex2;
    final isScreenSizeLarge = MediaQuery.of(context).size.width >= 600;

    return DefaultTabController(
      length: settingsProvider.configuration!.settings!.length,
      initialIndex: selectedPumpIndex,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          CustomTrainWidget(
            title: 'Pumps',
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              indicatorColor: Colors.transparent,
              isScrollable: true,
              tabs: settingsProvider.configuration!.settings!.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final id = e.id;
                return CustomTab(
                  height: 65,
                  radius: 25,
                  content: id,
                  tabIndex: index,
                  selectedTabIndex: selectedPumpIndex,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: settingsProvider.configuration!.settings!.asMap().entries.map((entry) {
                var totalLength = 0;

                final int pumpIndex = entry.key;
                final pumpId = entry.value.id;
                return Column(
                  children: [
                    CustomTextContainer(
                      text: settingsProvider.totalPumpsName[pumpIndex]!,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: isScreenSizeLarge ? const EdgeInsets.symmetric(horizontal: 50) : const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: 1,
                            itemBuilder: (context, index){
                              return Column(
                                children: entry.value.pumpSettings.asMap().entries.map((settings) {
                                  final settingsIndex = settings.key;
                                  final value = settings.value;
                                  final settingsList = settings.value.setting;
                                  final entryList = settingsList.asMap().entries.toList();

                                  final isFirstItem = entryList.length == 1;
                                  final isLastItem = entryList.length == settingsList.length;

                                  final borderRadius = BorderRadius.only(
                                    topLeft: isFirstItem ? const Radius.circular(15) : Radius.zero,
                                    topRight: isFirstItem ? const Radius.circular(15) : Radius.zero,
                                    bottomLeft: isLastItem ? const Radius.circular(15) : Radius.zero,
                                    bottomRight: isLastItem ? const Radius.circular(15) : Radius.zero,
                                  );

                                  var length = 0;
                                  String sectionTitle = '';
                                  if(settings.value.type == '21'){
                                    sectionTitle = '2 Phase selection';
                                    length += settings.value.setting.length;
                                  }else if(settings.value.type == '22'){
                                    sectionTitle = 'Timer Setting';
                                    length += settings.value.setting.length;
                                  }else if(settings.value.type == '23'){
                                    sectionTitle = 'Current Setting';
                                    length += settings.value.setting.length;
                                  }else if(settings.value.type == '24'){
                                    sectionTitle = 'Voltage Setting';
                                    length += settings.value.setting.length;
                                  }else{
                                    sectionTitle = 'Additional Setting';
                                    length += settings.value.setting.length;
                                  }
                                  totalLength += length;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sectionTitle),
                                      ...value.setting.map((tile){
                                        final title = tile.title;
                                        final widgetType = tile.widgetTypeId;
                                        final itemIconCodePoint = tile.iconCodePoint;
                                        final itemIconFontFamily = tile.iconFontFamily;
                                        final value = tile.value;
                                        final itemIcon='';
                                        //final itemIcon = IconData(int.parse(itemIconCodePoint), fontFamily: itemIconFontFamily);
                                        final rtcSettings = tile.rtcSettings;
                                        final hidden = tile.hidden;

                                        Widget customWidget;

                                        switch(widgetType){
                                          case 1:
                                            if ((title == 'DRY RUN 3 PHASE') || (title == 'DRY RUN 2 PHASE') || (title == 'DRY RUN RESTART')) {
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: (title == 'DRY RUN 2 PHASE')
                                                    ? ((settingsProvider.getValueForIdentifier('DRY RUN', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('2 PHASE', pumpIndex) ?? false))
                                                    : (settingsProvider.getValueForIdentifier('DRY RUN', pumpIndex) ?? false),
                                                child: CustomTextFormTile(
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '000.0',
                                                    subtitle: title,
                                                    hintText: '000.0',
                                                    onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                    //icon: itemIcon,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s.]')),
                                                      LengthLimitingTextInputFormatter(5),
                                                    ],
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if((title == 'OVER LOAD 3 PHASE') || title == 'OVER LOAD 2 PHASE'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: (title == 'OVER LOAD 2 PHASE')
                                                    ? (settingsProvider.getValueForIdentifier('OVER LOAD', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('2 PHASE', pumpIndex) ?? false)
                                                    : settingsProvider.getValueForIdentifier('OVER LOAD', pumpIndex) ?? false,
                                                child: CustomTextFormTile(
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '000.0',
                                                  subtitle: title,
                                                  hintText: '000.0',
                                                  onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                  //icon: itemIcon,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.deny(RegExp('[^0-9\s.]')),
                                                    LengthLimitingTextInputFormatter(5),
                                                  ],
                                                ),
                                              );
                                            }
                                            else if((title == 'LOW VOLT 3 PHASE') || (title == 'DIFF LOW VOLT 3 PHASE') || title == 'LOW VOLT 2 PHASE' || title == 'DIFF LOW VOLT 2 PHASE'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: ((title == 'LOW VOLT 2 PHASE') || (title == 'DIFF LOW VOLT 2 PHASE'))
                                                    ? (settingsProvider.getValueForIdentifier('LOW VOLT', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('2 PHASE', pumpIndex) ?? false)
                                                    : settingsProvider.getValueForIdentifier('LOW VOLT', pumpIndex) ?? false,
                                                child: CustomTextFormTile(
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '000.0',
                                                    subtitle: title,
                                                    hintText: '000.0',
                                                    onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                    //icon: itemIcon,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s.]')),
                                                      LengthLimitingTextInputFormatter(5),
                                                    ],
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if((title == 'HIGH VOLT 3 PHASE') || (title == 'DIFF HIGH VOLT 3 PHASE') || title == 'HIGH VOLT 2 PHASE' || title == 'DIFF HIGH VOLT 2 PHASE'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: ((title == 'HIGH VOLT 2 PHASE') || (title == 'DIFF HIGH VOLT 2 PHASE'))
                                                    ? (settingsProvider.getValueForIdentifier('HIGH VOLT', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('2 PHASE', pumpIndex) ?? false)
                                                    : settingsProvider.getValueForIdentifier('HIGH VOLT', pumpIndex) ?? false,
                                                child: CustomTextFormTile(
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '000.0',
                                                    subtitle: title,
                                                    hintText: '000.0',
                                                    onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                    //icon: itemIcon,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s.]')),
                                                      LengthLimitingTextInputFormatter(5),
                                                    ],
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else{
                                              customWidget = CustomTextFormTile(
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '000.0',
                                                  subtitle: title,
                                                  hintText: '000.0',
                                                  onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                  //icon: itemIcon,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.deny(RegExp('[^0-9\s.]')),
                                                    LengthLimitingTextInputFormatter(5),
                                                  ],
                                                  borderRadius: BorderRadius.circular(15)
                                              );
                                            }
                                            break;
                                          case 2:
                                            if(title == 'DRY RUN RESTART' || title == 'DRY RUN OCCURRENCE'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('DRY RUN', pumpIndex) ?? false,
                                                child: CustomSwitchTile(
                                                    subtitle: title,
                                                    value: (settingsProvider.getValueForIdentifier(title, pumpIndex)) != '' ? (settingsProvider.getValueForIdentifier(title, pumpIndex)): false,
                                                    onChanged: (value) => settingsProvider.updateValueForIdentifier(title, value, pumpIndex),
                                                    //icon: itemIcon,
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else{
                                              customWidget = CustomSwitchTile(
                                                  subtitle: title,
                                                  value: (settingsProvider.getValueForIdentifier(title, pumpIndex)) != '' ? (settingsProvider.getValueForIdentifier(title, pumpIndex)) : false,
                                                  onChanged: (value) => settingsProvider.updateValueForIdentifier(title, value, pumpIndex),
                                                  //icon: itemIcon,
                                                  borderRadius: BorderRadius.circular(15)
                                              );
                                            }
                                            break;
                                          case 3:
                                            if(title == 'STARTING CAPACITOR TIMER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('STARTING CAPACITOR', pumpIndex) ?? false,
                                                child: CustomTimerTile(
                                                  subtitle: title,
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                  onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                  //icon: itemIcon,
                                                  isSeconds: true,
                                                ),
                                              );
                                            }
                                            else if(title == 'STARTER FEEDBACK DELAY TIMER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('STARTER FEEDBACK', pumpIndex) ?? false,
                                                child: CustomTimerTile(
                                                    subtitle: title,
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                    onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                    //icon: itemIcon,
                                                    isSeconds: true,
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if(title == 'MAXIMUM RUN TIMER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('MAXIMUM RUN TIMER ON/OFF', pumpIndex) ?? false,
                                                child: CustomTimerTile(
                                                    subtitle: title,
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                    onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                    //icon: itemIcon,
                                                    isSeconds: true,
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if(title == 'CYCLIC ON TIME' || title == 'CYCLIC OFF TIME'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('CYCLIC TIMER ON/OFF', pumpIndex) ?? false,
                                                child: CustomTimerTile(
                                                    subtitle: title,
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                    onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                   // icon: itemIcon,
                                                    isSeconds: true,
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if (title == "RTC TIMER" && value is List<dynamic>) {
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('RTC', pumpIndex) ?? false,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(child: Center(child: Text('RTC', style: Theme.of(context).textTheme.bodyLarge))),
                                                        Expanded(child: Center(child: Text('On Time', style: Theme.of(context).textTheme.bodyLarge))),
                                                        Expanded(child: Center(child: Text('Off Time', style: Theme.of(context).textTheme.bodyLarge))),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    Column(
                                                      children: rtcSettings?.map((e) {
                                                        final rtc = e.rtc;
                                                        return Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Expanded(child: Center(child: Text('$rtc', style: Theme.of(context).textTheme.bodyLarge))),
                                                                Expanded(child: Center(child: CustomTimePicker(
                                                                  initialTime: settingsProvider.getRtcOnTime(title, rtc, pumpIndex),
                                                                  onChanged: (newTime) => settingsProvider.updateRtcOnTime(title, rtc, newTime, pumpIndex),
                                                                  isSeconds: true,
                                                                ))),
                                                                Expanded(child: Center(child: CustomTimePicker(
                                                                  initialTime: settingsProvider.getRtcOffTime(title, rtc, pumpIndex),
                                                                  onChanged: (newTime) => settingsProvider.updateRtcOffTime(title, rtc, newTime, pumpIndex),
                                                                  isSeconds: true,
                                                                ))),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 15,),
                                                          ],
                                                        );
                                                      }).toList() ?? [const SizedBox()],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            else if(title == 'DRY RUN RESTART TIMER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: ((settingsProvider.getValueForIdentifier('DRY RUN RESTART', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('DRY RUN', pumpIndex) ?? false)),
                                                child: CustomTimerTile(
                                                    subtitle: title,
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                    onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                    //icon: itemIcon,
                                                    isSeconds: true,
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if(title == 'DRY RUN OCCURRENCE TIMER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: ((settingsProvider.getValueForIdentifier('DRY RUN OCCURRENCE', pumpIndex) ?? false) && (settingsProvider.getValueForIdentifier('DRY RUN', pumpIndex) ?? false)),
                                                child: CustomTimerTile(
                                                  subtitle: title,
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                  onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                  //icon: itemIcon,
                                                  isSeconds: true,
                                                ),
                                              );
                                            }
                                            else {
                                              customWidget = CustomTimerTile(
                                                  subtitle: title,
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) == '' ? '00:00:00' : settingsProvider.getValueForIdentifier(title, pumpIndex),
                                                  onChanged: (newTime) => settingsProvider.updateValueForIdentifier(title, newTime, pumpIndex),
                                                  isSeconds: true,
                                                  borderRadius: BorderRadius.circular(15)
                                              );
                                            }
                                            break;
                                          case 4:
                                            if(title == 'RUN DAYS' || title == 'SKIP DAYS'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('SCHEDULE BY DAYS', pumpIndex) ?? false,
                                                child: CustomTextFormTile(
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '00',
                                                    subtitle: title,
                                                    hintText: '00',
                                                    onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                    // icon: icon,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                                      LengthLimitingTextInputFormatter(2),
                                                    ],
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else if(title == 'DRY RUN OCCURRENCE NUMBER'){
                                              customWidget = CustomAnimatedSwitcher(
                                                condition: settingsProvider.getValueForIdentifier('DRY RUN OCCURRENCE', pumpIndex) ?? false,
                                                child: CustomTextFormTile(
                                                    initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '00',
                                                    subtitle: title,
                                                    hintText: '00',
                                                    onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                    // icon: icon,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                                      LengthLimitingTextInputFormatter(2),
                                                    ],
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                              );
                                            }
                                            else{
                                              customWidget = CustomTextFormTile(
                                                  initialValue: settingsProvider.getValueForIdentifier(title, pumpIndex) ?? '00',
                                                  subtitle: title,
                                                  hintText: '00',
                                                  onChanged: (newValue) => settingsProvider.updateValueForIdentifier(title, newValue, pumpIndex),
                                                  // icon: icon,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                                    LengthLimitingTextInputFormatter(2),
                                                  ],
                                                  borderRadius: BorderRadius.circular(15)
                                              );
                                            }
                                            break;
                                          default:
                                            customWidget = Text('Unsupported Widget Type: $widgetType');
                                            break;
                                        }

                                        return Visibility(
                                          visible: !hidden,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: borderRadius
                                            ),
                                            child: customWidget,
                                          ),
                                        );
                                      }),
                                      if(totalLength == 45)
                                        const SizedBox(height: 80,)
                                    ],
                                  );
                                }).toList(),
                              );
                            }
                        )
                    ),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

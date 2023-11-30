import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_alert_dialog.dart';
import '../../../widgets/SCustomWidgets/custom_date_picker.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import '../../../widgets/SCustomWidgets/custom_train_widget.dart';


class ScheduleScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const ScheduleScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with TickerProviderStateMixin {
  late TabController _tabController1;
  late TabController _tabController2;
  final TextEditingController _textEditingController = TextEditingController();
  String tempNoOfDays = '';

  Map<String, dynamic> runListRtc = {};
  Map<String, dynamic> byDaysRtc = {};

  @override
  void initState() {
    super.initState();

    final scheduleProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    // scheduleProvider.scheduleData();
    scheduleProvider.updateRtcIndex1(0);
    scheduleProvider.updateRtcIndex2(0);
    runListRtc = scheduleProvider.sampleScheduleModel != null
        ? scheduleProvider.sampleScheduleModel!.scheduleAsRunList.rtc
        : {
      "rtc1": {"onTime": "", "offTime": "", "interval": "", "noOfCycles": "", "maxTime": "", "condition": false},
      "rtc2": {"onTime": "", "offTime": "", "interval": "", "noOfCycles": "", "maxTime": "", "condition": false},
    };
    _tabController1 = TabController(length: runListRtc.length, vsync: this)..addListener(() {
      scheduleProvider.updateRtcIndex1(_tabController1.index);
    });
    byDaysRtc = scheduleProvider.sampleScheduleModel != null
        ? scheduleProvider.sampleScheduleModel!.scheduleByDays.rtc
        : {
      "rtc1": {"onTime": "", "offTime": "", "interval": "", "noOfCycles": "", "maxTime": "", "condition": false},
      "rtc2": {"onTime": "", "offTime": "", "interval": "", "noOfCycles": "", "maxTime": "", "condition": false},
    };
    _tabController2 = TabController(length: byDaysRtc.length, vsync: this)..addListener(() {
      scheduleProvider.updateRtcIndex2(_tabController2.index);
    });
  }

  @override
  void dispose() {
    _tabController1.dispose();
    _tabController2.dispose();
    super.dispose();
  }

  void addTab(rtcType) {
    final scheduleProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    setState(() {
      if (rtcType.length < 6) {
        rtcType.addAll({
          "rtc${rtcType.length + 1}": {"onTime": "00:00", "offTime": "00:00", "interval": "00:00", "noOfCycles": "00", "maxTime": "00:00", "condition": false}
        });
        if(rtcType == runListRtc) {
          _tabController1 = TabController(length: rtcType.length, vsync: this)..addListener(() {
            scheduleProvider.updateRtcIndex1(_tabController1.index);
          });
          _tabController1.animateTo(rtcType.length - 1);
        }
        else{
          _tabController2 = TabController(length: rtcType.length, vsync: this)..addListener(() {
            scheduleProvider.updateRtcIndex2(_tabController2.index);
          });
          _tabController2.animateTo(rtcType.length - 1);
        }
      } else {
        showAdaptiveDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: 'Warning',
              content: "Cannot add more than 6 RTC's",
              actions: [
                TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
              ],
            );
          },
        );
      }
    });
  }

  void deleteTab(rtcType) {
    final scheduleProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if (rtcType.length > 2) {
      setState(() {
        if(rtcType == runListRtc) {
          List<String> keys = runListRtc.keys.toList();
          keys.removeLast();
          runListRtc = {for (var e in keys) e: runListRtc[e]};
          _tabController1 = TabController(length: runListRtc.length, vsync: this)..addListener(() {
            scheduleProvider.updateRtcIndex1(_tabController1.index);
          });
          _tabController1.animateTo(runListRtc.length - 1);
        } else {
          List<String> keys = byDaysRtc.keys.toList();
          keys.removeLast();
          byDaysRtc = {for (var e in keys) e: byDaysRtc[e]};
          _tabController2 = TabController(length: byDaysRtc.length, vsync: this)..addListener(() {
            scheduleProvider.updateRtcIndex2(_tabController2.index);
          });
          _tabController2.animateTo(byDaysRtc.length - 1);
        }
      });
    } else {
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Warning',
            content: "Number of RTC's should be at least 2",
            actions: [
              TextButton(child: const Text("OK"), onPressed: () => Navigator.of(context).pop(),),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<IrrigationProgramMainProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: DropdownButton(
            underline: Container(),
            items: scheduleProvider.scheduleTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Center(child: Text(value)),
              );
            }).toList(),
            value: scheduleProvider.selectedScheduleType,
            onChanged: (newValue) => scheduleProvider.updateSelectedValue(newValue),
          ),
        ),
        const SizedBox(height: 10,),
        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
          buildScheduleWidgets(
            scheduleProvider,
            scheduleProvider.sampleScheduleModel!.scheduleAsRunList,
            _tabController1,
            _textEditingController,
            scheduleProvider.selectedRtcIndex1,
            runListRtc
          ),
        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[2])
          buildScheduleWidgets(
            scheduleProvider,
            scheduleProvider.sampleScheduleModel!.scheduleByDays,
            _tabController2,
            _textEditingController,
            scheduleProvider.selectedRtcIndex2,
            byDaysRtc
          ),
      ],
    );
  }

  Widget buildScheduleWidgets(scheduleProvider, scheduleType, tabController, textEditingController, selectedRtcIndex, rtcType){

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CustomTrainWidget(
                  title: 'RTC',
                  child: Expanded(
                    child: TabBar(
                      controller: tabController,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                      indicatorColor: Colors.transparent,
                      isScrollable: true,
                      tabs: [
                        ...rtcType.keys.map((rtc) {
                          final rtcIndex = rtcType.keys.toList().indexOf(rtc);
                          return CustomTab(
                            height: 65,
                            radius: 25,
                            content: (rtcIndex + 1).toString(),
                            tabIndex: rtcIndex,
                            selectedTabIndex: selectedRtcIndex,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor
                  ),child: IconButton(onPressed: () => addTab(rtcType), icon: const Icon(Icons.add, color: Colors.white,))),
                  const SizedBox(height: 10,),
                  Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor
                  ),child: IconButton(onPressed: () => deleteTab(rtcType), icon: const Icon(Icons.remove, color: Colors.white,))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...rtcType.entries.map((rtcValue) {
                  final selectedRtc = rtcType.keys.toList()[selectedRtcIndex];
                  if (rtcValue.key == selectedRtc) {
                    Map<String, dynamic> rtcValueString = rtcValue.value;
                    final scheduleData = scheduleType.schedule;

                    final onTime = (rtcValueString['onTime'] == null || rtcValueString['onTime'] == '')
                        ? '00:00'
                        : rtcValueString['onTime'];
                    final offTime = scheduleProvider.sampleScheduleModel?.defaultModel.rtcOffTime ? (rtcValueString['offTime'] == null || rtcValueString['offTime'] == '')
                        ? '00:00'
                        : rtcValueString['offTime'] : '00:00';
                    final interval = (rtcValueString['interval'] == null || rtcValueString['interval'] == '')
                        ? '00:00'
                        : rtcValueString['interval'];
                    final noOfCycles = (rtcValueString['noOfCycles'] == null || rtcValueString['noOfCycles'] == '')
                        ? '00'
                        : rtcValueString['noOfCycles'];
                    final maxTime = scheduleProvider.sampleScheduleModel?.defaultModel.rtcMaxTime ? (rtcValueString['maxTime'] == null || rtcValueString['maxTime'] == '')
                        ? '00:00'
                        : rtcValueString['maxTime'] : '00:00';
                    final condition = (rtcValueString['condition'] == null || rtcValueString['condition'] == '')
                        ? false
                        : rtcValueString['condition'];
                    final noOfDays = (scheduleData['noOfDays'] == null || scheduleData['noOfDays'] == '')
                        ? '0'
                        : scheduleData['noOfDays'];
                    final startDate = (scheduleData['startDate'] == null || scheduleData['startDate'] == '')
                        ? DateTime.now()
                        : scheduleData['startDate'];
                    final type = (scheduleData['type'] == null || scheduleData['type'] == '')
                        ? []
                        : scheduleData['type'];
                    final runListLimit = (scheduleProvider.sampleScheduleModel?.defaultModel.runListLimit == null || scheduleProvider.sampleScheduleModel?.defaultModel.runListLimit == '')
                        ? '0'
                        : scheduleProvider.sampleScheduleModel?.defaultModel.runListLimit;
                    final runDays = (scheduleData['runDays'] == null || scheduleData['runDays'] == '')
                        ? '00'
                        : scheduleData['runDays'];
                    final skipDays = (scheduleData['skipDays'] == null || scheduleData['skipDays'] == '')
                        ? '00'
                        : scheduleData['skipDays'];

                    List<String> days = List.generate(int.parse(noOfDays != '' ? noOfDays : '0'), (index) => 'DAY ${index + 1}');
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        const SizedBox(height: 10,),
                        Text('RTC ${selectedRtcIndex+1}'),
                        ...ListTile.divideTiles(
                            context: context,
                            tiles: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                ),
                                child: CustomTimerTile(
                                  subtitle: 'RTC ON TIME',
                                  initialValue: onTime,
                                  onChanged: (newTime){
                                    scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'onTime', scheduleType);
                                  },
                                  isSeconds: false,
                                  is24HourMode: false,
                                  icon: Icons.timer_outlined,
                                ),
                              ),
                              Visibility(
                                visible: scheduleProvider.sampleScheduleModel?.defaultModel.rtcOffTime,
                                child: Container(
                                  color: Colors.white,
                                  child: CustomTimerTile(
                                    subtitle: 'RTC OFF TIME',
                                    initialValue: offTime,
                                    onChanged: (newTime){
                                      scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'offTime', scheduleType);
                                    },
                                    isSeconds: false,
                                    is24HourMode: false,
                                    icon: Icons.timer_off_outlined,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: CustomTimerTile(
                                  subtitle: 'INTERVAL',
                                  initialValue: interval,
                                  onChanged: (newTime){
                                    scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'interval', scheduleType);
                                  },
                                  isSeconds: true,
                                  icon: Icons.av_timer_outlined,
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: CustomTextFormTile(
                                  subtitle: 'NO OF CYCLES',
                                  initialValue: noOfCycles,
                                  hintText: '00',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  onChanged: (newValue){
                                    scheduleProvider.updateRtcProperty(newValue, selectedRtc, 'noOfCycles', scheduleType);
                                  },
                                  icon: Icons.safety_check,
                                ),
                              ),
                              Visibility(
                                visible: scheduleProvider.sampleScheduleModel?.defaultModel.rtcOffTime,
                                child: Container(
                                  color: Colors.white,
                                  child: CustomTimerTile(
                                      subtitle: 'MAXIMUM TIME',
                                      initialValue: maxTime,
                                      onChanged: (newTime){
                                        scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'maxTime', scheduleType);
                                      },
                                      isSeconds: true,
                                      icon: Icons.share_arrival_time_rounded
                                  ),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                ),
                                child: CustomSwitchTile(
                                  title: 'CONDITIONS',
                                  onChanged: (newValue){
                                    scheduleProvider.updateRtcProperty(newValue, selectedRtc, 'condition', scheduleType);
                                  },
                                  icon: const Icon(Icons.fact_check, color: Colors.black,),
                                  value: condition,
                                ),
                              ),
                            ]
                        ).toList(),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          const SizedBox(height: 10,),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          ...ListTile.divideTiles(
                              context: context,
                              tiles: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                  ),
                                  child: CustomTile(
                                    title: 'Number of days',
                                    content: Icons.format_list_numbered,
                                    trailing: SizedBox(
                                      width: 50,
                                      child: InkWell(
                                        onTap: () {
                                          _textEditingController.text = noOfDays;
                                          _textEditingController.selection = TextSelection(
                                            baseOffset: 0,
                                            extentOffset: _textEditingController.text.length,
                                          );
                                          showAdaptiveDialog(
                                              context: context,
                                              builder: (ctx) => Consumer<IrrigationProgramMainProvider>(
                                                builder: (context, scheduleProvider, child) {
                                                  return AlertDialog(
                                                    title: const Text("Number of days"),
                                                    content: TextFormField(
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.deny(RegExp('[^0-9a-zA-Z\s]')),
                                                        LengthLimitingTextInputFormatter(2),
                                                      ],
                                                      controller: _textEditingController,
                                                      autofocus: true,
                                                      onChanged: (newValue) {
                                                        tempNoOfDays = newValue;
                                                        scheduleProvider.validateInputAndSetErrorText(tempNoOfDays, runListLimit);
                                                        scheduleProvider.initializeDropdownValues(
                                                            tempNoOfDays == '' ? '0' : tempNoOfDays, noOfDays, type);
                                                      },
                                                      decoration: InputDecoration(
                                                        errorText: scheduleProvider.errorText,
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () => Navigator.of(ctx).pop(),
                                                        child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          if (scheduleProvider.errorText == null) {
                                                            Navigator.of(context).pop();
                                                            scheduleProvider.updateNumberOfDays(tempNoOfDays, 'noOfDays', scheduleType);
                                                          }
                                                        },
                                                        child: const Text("OKAY"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              )
                                          );
                                        },
                                        child: Text(noOfDays, style: Theme.of(context).textTheme.bodyMedium,),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                                  ),
                                  child: CustomTile(
                                    title: 'Start date',
                                    content: Icons.calendar_month,
                                    trailing: IntrinsicWidth(
                                        child: DatePickerField(
                                          value: DateTime.parse(startDate),
                                          onChanged: (newDate) {
                                            scheduleProvider.updateStartDate(newDate, scheduleType);
                                          },
                                        )
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        const SizedBox(height: 10,),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          Visibility(
                            visible: noOfDays != '00',
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: CustomTile(
                                title: 'Set all days',
                                showCircleAvatar: false,
                                leading: const SizedBox.shrink(),
                                trailing: SizedBox(
                                  width: 250,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      for(int i = 0; i < 4; i++)
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: scheduleProvider.selectedButtonIndex == i
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).primaryColor,
                                          child: IconButton(
                                            icon: Icon([
                                              Icons.playlist_remove_outlined,
                                              Icons.timer, Icons.water_drop,
                                              Icons.local_florist_rounded,][i],
                                              color: scheduleProvider.selectedButtonIndex == i
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            onPressed: () {
                                              scheduleProvider.setAllSame(i);
                                            },
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          const SizedBox(height: 10,),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          ...ListTile.divideTiles(
                              context: context,
                              tiles: [
                                for(var i = 0; i < int.parse(noOfDays); i++)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: (i == (int.parse(noOfDays)) - 1)
                                          ? const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) : (i == 0)
                                          ? const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))
                                          : BorderRadius.zero,
                                    ),
                                    child: CustomDropdownTile(
                                      title: days[i],
                                      content: '${i+1}',
                                      dropdownItems: scheduleProvider.scheduleOptions,
                                      selectedValue: type[i],
                                      onChanged: (newValue) {
                                        scheduleProvider.updateDropdownValue(i, newValue);
                                      },
                                      includeNoneOption: false,
                                    ),
                                  ),
                              ]
                          ),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                          const SizedBox(height: 10,),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[2])
                          ...ListTile.divideTiles(
                              context: context,
                              tiles: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                  ),
                                  child: CustomTile(
                                    title: 'Start date',
                                    content: Icons.calendar_month,
                                    trailing: IntrinsicWidth(
                                        child: DatePickerField(
                                          value: DateTime.parse(startDate),
                                          onChanged: (newDate ) {
                                            scheduleProvider.updateStartDate(newDate, scheduleType);
                                          },
                                        )
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  child: CustomTextFormTile(
                                    subtitle: 'RUN DAYS',
                                    hintText: '00',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    initialValue: runDays,
                                    onChanged: (newValue){
                                      scheduleProvider.updateNumberOfDays(newValue, 'runDays', scheduleType);
                                    },
                                    icon: Icons.directions_run,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                  ),
                                  child: CustomTextFormTile(
                                    subtitle: 'SKIP DAYS',
                                    hintText: '00',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp('[^0-9\s]')),
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    initialValue: skipDays,
                                    onChanged: (newValue){
                                      scheduleProvider.updateNumberOfDays(newValue, 'noOfCycles', scheduleType);
                                    },
                                    icon: Icons.skip_next,
                                  ),
                                ),
                              ]
                          ),
                        if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[2])
                          const SizedBox(height: 10,),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }).toList()
              ],
            ),
          )
        ],
      ),
    );
  }
}

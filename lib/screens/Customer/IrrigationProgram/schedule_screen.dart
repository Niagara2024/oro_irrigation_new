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
    scheduleProvider.updateRtcIndex1(0);
    scheduleProvider.updateRtcIndex2(0);
    runListRtc = scheduleProvider.sampleScheduleModel!.scheduleAsRunList.rtc;
    _tabController1 = TabController(length: runListRtc.length, vsync: this)..addListener(() {
      scheduleProvider.updateRtcIndex1(_tabController1.index);
    });
    byDaysRtc = scheduleProvider.sampleScheduleModel!.scheduleByDays.rtc;
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
    if(rtcType.length > 2) {
      setState(() {
        if (rtcType.isNotEmpty) {
          rtcType.remove(rtcType.keys.last);

          if (rtcType == runListRtc) {
            _tabController1 = TabController(length: rtcType.length, vsync: this)..addListener(() {
              scheduleProvider.updateRtcIndex1(_tabController1.index);
            });
            _tabController1.animateTo(rtcType.length - 1);
          } else {
            _tabController2 = TabController(length: rtcType.length, vsync: this)..addListener(() {
              scheduleProvider.updateRtcIndex2(_tabController2.index);
            });
            _tabController2.animateTo(rtcType.length - 1);
          }
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
    return LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10,),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                surfaceTintColor: Colors.white,
                child: DropdownButton(
                  borderRadius: BorderRadius.circular(10),
                  underline: Container(),
                  items: scheduleProvider.scheduleTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(value),
                      )),
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
                    runListRtc,
                    constraints
                ),
              if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[2])
                buildScheduleWidgets(
                    scheduleProvider,
                    scheduleProvider.sampleScheduleModel!.scheduleByDays,
                    _tabController2,
                    _textEditingController,
                    scheduleProvider.selectedRtcIndex2,
                    byDaysRtc,
                    constraints
                ),
            ],
          );
        }
    );
  }

  Widget buildScheduleWidgets(scheduleProvider, scheduleType, tabController, textEditingController, selectedRtcIndex, rtcType, constraints){
    return Expanded(
      child: Padding(
        padding: constraints.maxWidth > 550 ? EdgeInsets.zero : EdgeInsets.zero,
        child: Column(
          children: [
            constraints.maxWidth < 550
                ? Row(
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
                    ElevatedButton(
                      onPressed: () => addTab(rtcType),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(const Size(30, 35)),
                      ),
                      child: const Text('+', style: TextStyle(fontSize: 20),),
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                        onPressed: () => deleteTab(rtcType),
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(const Size(30, 35)),
                        ),
                        child: const Text('-', style: TextStyle(fontSize: 20))
                    ),
                  ],
                ),
                const SizedBox(width: 5,)
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabBar(
                    controller: tabController,
                    dividerColor: Colors.transparent,
                    // labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    indicatorColor: Colors.transparent,
                    isScrollable: true,
                    tabs: [
                      ...rtcType.keys.map((rtc) {
                        final rtcIndex = rtcType.keys.toList().indexOf(rtc);
                        return Container(
                          width: constraints.maxWidth > 800 ? constraints.maxWidth * 0.07 : constraints.maxWidth * 0.05,
                          decoration: BoxDecoration(
                            border: Border.all(color: selectedRtcIndex == rtcIndex ? Theme.of(context).primaryColor : Colors.white),
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),

                          ),
                          child: Tab(
                            text: constraints.maxWidth > 800 ? 'RTC ${rtcIndex + 1}' : '${rtcIndex + 1}',
                          ),
                        );
                      }).toList(),
                    ]
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => addTab(rtcType),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(constraints.maxWidth * 0.1, 35)),
                      ),
                      child: constraints.maxWidth > 800 ? const Text('ADD') : const Text('+'),
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton(
                        onPressed: () => deleteTab(rtcType),
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(constraints.maxWidth * 0.1, 35)),
                        ),
                        child: constraints.maxWidth > 800 ? const Text('DELETE') : const Text('-')
                    ),
                    SizedBox(width: constraints.maxWidth * 0.03,)
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Padding(
                padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : EdgeInsets.zero,
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

                        // print(startDate);
                        // print(DateTime.parse(startDate));
                        // List<String> days = List.generate(int.parse(noOfDays != '' ? noOfDays : '0'), (index) => 'DAY ${index + 1}');
                        String getWeekday(int weekday) {
                          const daysInWeek = 7;
                          List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                          int adjustedWeekday = (weekday - 1 + daysInWeek) % daysInWeek;

                          // print(adjustedWeekday);
                          return weekdays[adjustedWeekday];
                        }

                        List<String> days2 = List.generate(int.parse(noOfDays != '' ? noOfDays : '0'), (index) {
                          DateTime currentDate = DateTime.parse(startDate).add(Duration(days: index));
                          return getWeekday(currentDate.weekday);
                        });

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          children: [
                            const SizedBox(height: 10,),
                            Text('RTC ${selectedRtcIndex+1}'),
                            Card(
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: Column(
                                children: [
                                  ...ListTile.divideTiles(
                                      context: context,
                                      tiles: [
                                        CustomTimerTile(
                                          subtitle: 'RTC ON TIME',
                                          initialValue: onTime,
                                          onChanged: (newTime){
                                            scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'onTime', scheduleType);
                                          },
                                          isSeconds: false,
                                          is24HourMode: true,
                                          isNative: true,
                                          icon: Icons.timer_outlined,
                                        ),
                                        Visibility(
                                          visible: scheduleProvider.sampleScheduleModel?.defaultModel.rtcOffTime,
                                          child: CustomTimerTile(
                                            subtitle: 'RTC OFF TIME',
                                            initialValue: offTime,
                                            onChanged: (newTime){
                                              scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'offTime', scheduleType);
                                            },
                                            isSeconds: false,
                                            is24HourMode: true,
                                            isNative: true,
                                            icon: Icons.timer_off_outlined,
                                          ),
                                        ),
                                        CustomTimerTile(
                                          subtitle: 'INTERVAL',
                                          initialValue: interval,
                                          onChanged: (newTime){
                                            scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'interval', scheduleType);
                                          },
                                          isSeconds: false,
                                          is24HourMode: true,
                                          isNative: true,
                                          icon: Icons.av_timer_outlined,
                                        ),
                                        CustomTextFormTile(
                                          subtitle: 'NO OF CYCLES',
                                          initialValue: noOfCycles,
                                          hintText: '00',
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          onChanged: (newValue){
                                            scheduleProvider.updateRtcProperty(newValue, selectedRtc, 'noOfCycles', scheduleType);
                                          },
                                          icon: Icons.safety_check,
                                        ),
                                        Visibility(
                                          visible: scheduleProvider.sampleScheduleModel?.defaultModel.rtcOffTime,
                                          child: CustomTimerTile(
                                            subtitle: 'MAXIMUM TIME',
                                            initialValue: maxTime,
                                            onChanged: (newTime){
                                              scheduleProvider.updateRtcProperty(newTime, selectedRtc, 'maxTime', scheduleType);
                                            },
                                            isSeconds: false,
                                            is24HourMode: true,
                                            isNative: true,
                                            icon: Icons.share_arrival_time_rounded,
                                          ),
                                        ),
                                        CustomSwitchTile(
                                          title: 'CONDITIONS',
                                          onChanged: (newValue){
                                            scheduleProvider.updateRtcProperty(newValue, selectedRtc, 'condition', scheduleType);
                                          },
                                          showCircleAvatar: true,
                                          icon: const Icon(Icons.fact_check, color: Colors.black,),
                                          value: condition,
                                        ),
                                      ]
                                  ).toList()
                                ],
                              ),
                            ),
                            if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                              const SizedBox(height: 10,),
                            if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                              Card(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Column(
                                  children: [
                                    ...ListTile.divideTiles(
                                        context: context,
                                        tiles: [
                                          CustomTile(
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
                                                                FilteringTextInputFormatter.deny(RegExp('[^0-9a-zA-Z]')),
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
                                          CustomTile(
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
                                        ]
                                    )
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10,),
                            if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                              Visibility(
                                visible: noOfDays != '00',
                                child: Card(
                                  surfaceTintColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: CustomTile(
                                    title: 'Set all days',
                                    showCircleAvatar: false,
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
                              Card(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Column(
                                  children: [
                                    ...ListTile.divideTiles(
                                        context: context,
                                        tiles: [
                                          for(var i = 0; i < int.parse(noOfDays); i++)
                                            CustomDropdownTile(
                                              title: days2[i],
                                              content: '${i+1}',
                                              dropdownItems: scheduleProvider.scheduleOptions,
                                              selectedValue: type[i],
                                              onChanged: (newValue) {
                                                scheduleProvider.updateDropdownValue(i, newValue);
                                              },
                                              includeNoneOption: false,
                                            ),
                                        ]
                                    )
                                  ],
                                ),
                              ),
                            if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[1])
                              const SizedBox(height: 10,),
                            if(scheduleProvider.selectedScheduleType == scheduleProvider.scheduleTypes[2])
                              Card(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Column(
                                  children: [
                                    ...ListTile.divideTiles(
                                        context: context,
                                        tiles: [
                                          CustomTile(
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
                                          CustomTextFormTile(
                                            subtitle: 'RUN DAYS',
                                            hintText: '00',
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                              LengthLimitingTextInputFormatter(2),
                                            ],
                                            initialValue: runDays,
                                            onChanged: (newValue){
                                              scheduleProvider.updateNumberOfDays(newValue, 'runDays', scheduleType);
                                            },
                                            icon: Icons.directions_run,
                                          ),
                                          CustomTextFormTile(
                                            subtitle: 'SKIP DAYS',
                                            hintText: '00',
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                                              LengthLimitingTextInputFormatter(2),
                                            ],
                                            initialValue: skipDays,
                                            onChanged: (newValue){
                                              scheduleProvider.updateNumberOfDays(newValue, 'skipDays', scheduleType);
                                            },
                                            icon: Icons.skip_next,
                                          ),
                                        ]
                                    )
                                  ],
                                ),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}

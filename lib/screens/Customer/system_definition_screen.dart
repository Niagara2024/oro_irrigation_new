import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/Customer/system_definition_model.dart';
import '../../constants/http_service.dart';
import '../../state_management/system_definition_provider.dart';
import '../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../widgets/SCustomWidgets/custom_native_time_picker.dart';
import '../../widgets/SCustomWidgets/custom_segmented_control.dart';
import '../../widgets/SCustomWidgets/custom_snack_bar.dart';


class SystemDefinition extends StatefulWidget {
  final dynamic userId;
  final dynamic controllerId;
  const SystemDefinition({super.key, required this.userId, required this.controllerId});

  @override
  State<SystemDefinition> createState() => _SystemDefinitionState();
}

class _SystemDefinitionState extends State<SystemDefinition> {
  final HttpService httpService = HttpService();
  final SystemDefinitionProvider systemDefinitionProvider = SystemDefinitionProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final systemDefinitionProvider = Provider.of<SystemDefinitionProvider>(context, listen: false);
    systemDefinitionProvider.getUserPlanningPowerSaver(widget.userId, widget.controllerId);
  }

  @override
  Widget build(BuildContext context) {
    final systemDefinitionProvider = Provider.of<SystemDefinitionProvider>(context);
    return (systemDefinitionProvider.energySaveSettings != null || systemDefinitionProvider.powerOffRecoveryModel != null)
        ? LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            body: constraints.maxWidth < 600 ?
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: CustomSegmentedControl(
                    segmentTitles: const {
                      0: 'Energy save functions',
                      1: 'Power off recovery  ',
                    },
                    groupValue: systemDefinitionProvider.selectedSegment,
                    onChanged: (value) => systemDefinitionProvider.updateSelectedSegment(value!),
                  ),
                ),
                if (systemDefinitionProvider.selectedSegment == 0)
                  Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          buildSwitchTile("Enable energy save function", systemDefinitionProvider.energySaveSettings!.energySaveFunction,
                                (newValue) => systemDefinitionProvider.updateValues(newValue, "energySaveFunction"),
                            Icons.energy_savings_leaf,
                          ),
                          const SizedBox(height: 5,),
                          if (systemDefinitionProvider.energySaveSettings!.energySaveFunction)
                            Column(
                              children: [
                                buildTimerTile("Start day time", systemDefinitionProvider.energySaveSettings!.startDayTime,
                                        (newValue) => systemDefinitionProvider.updateValues(newValue, "startDayTime"),
                                    Icons.start,
                                    false
                                ),
                                const SizedBox(height: 5,),
                                if (systemDefinitionProvider.energySaveSettings!.energySaveFunction)
                                  buildTimerTile("End day time", systemDefinitionProvider.energySaveSettings!.stopDayTime,
                                          (newValue) => systemDefinitionProvider.updateValues(newValue, "stopDayTime"),
                                      Icons.stop,
                                      false
                                  ),
                                const SizedBox(height: 5,),
                                buildSwitchTile("Pause mainline on energy save period", systemDefinitionProvider.energySaveSettings!.pauseMainLine,
                                      (newValue) => systemDefinitionProvider.updateValues(newValue, "pauseOnOff"), Icons.pause,
                                ),
                                const SizedBox(height: 5,),
                              ],
                            ),
                          if (systemDefinitionProvider.energySaveSettings!.pauseMainLine && systemDefinitionProvider.energySaveSettings!.energySaveFunction)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  for(var i = 0; i < 7; i++)
                                    buildDayTimePicker(
                                        systemDefinitionProvider.days[i],
                                        systemDefinitionProvider.daysFromAndToTimes()[i],
                                        systemDefinitionProvider.values[i],
                                        systemDefinitionProvider.isSelectedList()[i],
                                        constraints
                                    )
                                ],
                              ),
                            ),
                          const SizedBox(height: 80,),
                        ],
                      )
                  ),
                if(systemDefinitionProvider.selectedSegment == 1)
                  Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          buildTimerTile(
                              "When the power is out for longer than",
                              systemDefinitionProvider.powerOffRecoveryModel!.duration,
                                  (newValue) => systemDefinitionProvider.updateValues(newValue, "duration"),
                              Icons.timer,
                              true
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(systemDefinitionProvider.options.length, (index) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: systemDefinitionProvider.powerOffRecoveryModel!.selectedOption.contains(systemDefinitionProvider.options[index])
                                        ? true : false,
                                    onChanged: (newValue) {
                                      systemDefinitionProvider.updateCheckBoxesForOption(newValue, systemDefinitionProvider.options[index], index);
                                    },
                                  ),
                                  Text(systemDefinitionProvider.options[index]),
                                  const SizedBox(width: 20,)
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 80,),
                        ],
                      )
                  ),
              ],
            ) :
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text("Energy save functions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),)
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: constraints.maxWidth * 0.02,),
                              Checkbox(
                                  value: systemDefinitionProvider.energySaveSettings!.energySaveFunction,
                                  onChanged: (newValue) => systemDefinitionProvider.updateValues(newValue, "energySaveFunction")
                              ),
                              SizedBox(width: constraints.maxWidth * 0.02,),
                              const Text("Start day time"),
                              SizedBox(width: constraints.maxWidth * 0.05,),
                              buildTimePicker(systemDefinitionProvider.energySaveSettings!.startDayTime, (newValue) {
                                systemDefinitionProvider.updateValues(newValue, "startDayTime");
                              }, false),
                              SizedBox(width: constraints.maxWidth * 0.05),
                              const Text("Stop day time"),
                              SizedBox(width: constraints.maxWidth * 0.05,),
                              buildTimePicker(systemDefinitionProvider.energySaveSettings!.stopDayTime, (newValue) {
                                systemDefinitionProvider.updateValues(newValue, "stopDayTime");
                              },false),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              SizedBox(width: constraints.maxWidth * 0.02,),
                              Checkbox(
                                  value: systemDefinitionProvider.energySaveSettings!.energySaveFunction,
                                  onChanged: (newValue) => systemDefinitionProvider.updateValues(newValue, "energySaveFunction")
                              ),
                              SizedBox(width: constraints.maxWidth * 0.02,),
                              const Text("Pause mainline on energy save period"),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text("Days", style: Theme.of(context).textTheme.bodyLarge,),
                                  const SizedBox(height: 10,),
                                  Text("From", style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 10,),
                                  Text("To", style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                              for(var i = 0; i < 7; i++)
                                buildDayTimePicker(
                                    systemDefinitionProvider.days[i],
                                    systemDefinitionProvider.daysFromAndToTimes()[i],
                                    systemDefinitionProvider.values[i],
                                    systemDefinitionProvider.isSelectedList()[i],
                                    constraints
                                )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text("Power off recovery ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),)
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: constraints.maxWidth * 0.02,),
                                  const Text("When the power is out for longer than"),
                                  SizedBox(width: constraints.maxWidth * 0.02,),
                                  buildTimePicker(systemDefinitionProvider.powerOffRecoveryModel!.duration, (newValue) {
                                    systemDefinitionProvider.updateValues(newValue, "duration");
                                  }, true),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(systemDefinitionProvider.options.length, (index) {
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: systemDefinitionProvider.powerOffRecoveryModel!.selectedOption.contains(systemDefinitionProvider.options[index])
                                            ? true : false,
                                        onChanged: (newValue) {
                                          systemDefinitionProvider.updateCheckBoxesForOption(newValue, systemDefinitionProvider.options[index], index);
                                        },
                                      ),
                                      Text(systemDefinitionProvider.options[index]),
                                      const SizedBox(width: 20,)
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async{
                dynamic userData = {
                  "userId": widget.userId,
                  "controllerId": widget.controllerId,
                  "createUser": widget.userId,
                };
                dynamic dataToSend = {
                  "powerSaver" :{
                    "energySaveFunction":
                    systemDefinitionProvider.energySaveSettings!.toJson(),
                    "powerOffRecovery":
                    systemDefinitionProvider.powerOffRecoveryModel!.toJson(),
                  }
                };
                userData.addAll(dataToSend);
                // print(systemDefinitionProvider.energySaveSettings!.toMqtt());
                // print(systemDefinitionProvider.powerOffRecoveryModel!.toMqtt());
                dynamic dataToMqt = {
                  "2200": [
                    {
                      "2201": systemDefinitionProvider.energySaveSettings!.toMqtt(),
                      "2202": systemDefinitionProvider.powerOffRecoveryModel!.toMqtt()
                    }
                  ]
                };
                try {
                  final createUserPlanningPowerSaver = await httpService.postRequest('createUserPlanningPowerSaver', userData);
                  final response = jsonDecode(createUserPlanningPowerSaver.body);
                  if(createUserPlanningPowerSaver.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
                  print("Error: $error");
                }
              },
              child: const Icon(Icons.send),
            ),
          );
        })
        :const Scaffold(body: Center(child: CircularProgressIndicator(),),);
  }

  Widget buildTimePicker(String currentValue, Function(String) onTap, is24HourMode) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black54),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomNativeTimePicker(
          initialValue: currentValue,
          is24HourMode: is24HourMode,
          onChanged: (newTime ) => onTap(newTime)
      ),
    );
  }

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: CustomSwitchTile(
        title: title,
        showCircleAvatar: true,
        value: value,
        icon: Icon(icon, color: Colors.black),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildTimerTile(String subtitle, String initialValue, Function(String) onChanged, IconData icon, is24HourMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: CustomTimerTile(
        subtitle: subtitle,
        initialValue: initialValue,
        onChanged: onChanged,
        isSeconds: false,
        icon: icon,
        isNative: true,
        is24HourMode: is24HourMode,
      ),
    );
  }

  Widget buildDayTimePicker(String day, DayTimeRange dayTimeRange, dayCount, checkBoxValue, constraints) {
    return Consumer<SystemDefinitionProvider>(builder: (BuildContext dialogContext, systemDefinitionProvider, child) {
      return constraints.maxWidth < 600 ?
      CustomTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: day,
        trailing: SizedBox(
          width: constraints.maxWidth < 550 ? constraints.maxWidth * 0.55 : constraints.maxWidth * 0.25,
          child: buildTimeRow(
              dayTimeRange.from,
              dayTimeRange.to,
                  (newFrom, newTo) => systemDefinitionProvider.updateDayTimeRange(dayTimeRange, newFrom, newTo, ),
              checkBoxValue,
                  (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue),
              constraints
          ),
        ),
        content: dayCount,
      ) :
      Column(
        children: [
          Row(
            children: [
              Text(day, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
              Checkbox(value: checkBoxValue, onChanged: (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue))
            ],
          ),
          buildTimeRow(
              dayTimeRange.from,
              dayTimeRange.to,
                  (newFrom, newTo) => systemDefinitionProvider.updateDayTimeRange(dayTimeRange, newFrom, newTo),
              checkBoxValue,
                  (newValue) => systemDefinitionProvider.updateCheckBoxes(dayCount, newValue),
              constraints
          )
        ],
      );
    });
  }

  Widget buildTimeRow(String from, String to, Function(String, String) onChanged, bool checkBox, Function(bool?) onChangedBool, constraints) {
    return constraints.maxWidth < 550 ?
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: from, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(newTime, to)
          ),
        ),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: to, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(from, newTime)
          ),
        ),
        Checkbox(value: checkBox, onChanged: onChangedBool),
      ],
    ) :
    Column(
      children: [
        const SizedBox(height: 10,),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: from, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(newTime, to)
          ),
        ),
        const SizedBox(height: 10,),
        IgnorePointer(
          ignoring: !checkBox,
          child: CustomNativeTimePicker(
              initialValue: to, style: TextStyle(color: checkBox ? Colors.black : Colors.grey, fontSize: 16),
              is24HourMode: false,
              onChanged: (newTime ) => onChanged(from, newTime)
          ),
        )
      ],
    );
  }
}

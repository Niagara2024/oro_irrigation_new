import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../../state_management/scheule_view_provider.dart';
import '../../widgets/SCustomWidgets/custom_animated_switcher.dart';
import '../../widgets/SCustomWidgets/custom_date_picker.dart';
import '../../widgets/SCustomWidgets/custom_drop_down.dart';
import '../../widgets/SCustomWidgets/custom_snack_bar.dart';

class ScheduleViewScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int customerId;
  final String deviceId;
  const ScheduleViewScreen({super.key, required this.userId, required this.controllerId, required this.customerId, required this.deviceId});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  HttpService httpService = HttpService();
  late MQTTManager manager;
  late ScheduleViewProvider scheduleViewProvider;
  bool central = false;

  @override
  void initState() {
    super.initState();
    manager = MQTTManager();
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: false);
    scheduleViewProvider.payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 1500), () {
      scheduleViewProvider.requestScheduleData(widget.deviceId);
    }).then((value) => manager.subscribeToTopic("FirmwareToApp/${widget.deviceId}"));
    Future.delayed(const Duration(milliseconds: 2000), () {
      if(scheduleViewProvider.scheduleList.isNotEmpty) {
        scheduleViewProvider.scheduleList = scheduleViewProvider.scheduleList;
      } else {
        scheduleViewProvider.getUserSequencePriority(widget.userId, widget.controllerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    scheduleViewProvider = Provider.of<ScheduleViewProvider>(context, listen: true);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Schedule View"),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Text("Select a Date"),
                        const SizedBox(
                          width: 20,
                        ),
                        Card(
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DatePickerField(
                                  value: scheduleViewProvider.date,
                                  onChanged: (newDate) {
                                    Future.delayed(Duration.zero, () {
                                      scheduleViewProvider.scheduleList.clear();
                                      scheduleViewProvider.scheduleListFromMqtt.clear();
                                      setState(() {
                                        scheduleViewProvider.date = newDate;
                                      });
                                    }).then((value) => scheduleViewProvider.fetchDataAfterDelay(widget.deviceId, widget.userId, widget.controllerId));
                                  }),
                            )),
                      ],
                    ),
                    if(scheduleViewProvider.scheduleList.isNotEmpty)
                      Row(
                        children: [
                          const Text("Change To"),
                          const SizedBox(width: 20,),
                          Card(
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                height: 40,
                                width: 50,
                                child: CustomDropdownWidget(
                                  dropdownItems: scheduleViewProvider.scheduleList.map((e) => e["ScheduleOrder"].toString()).toList(),
                                  selectedValue: scheduleViewProvider.changeToValue != ""
                                      ? scheduleViewProvider.changeToValue : scheduleViewProvider.scheduleList[0]["ScheduleOrder"].toString(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      scheduleViewProvider.changeToValue = newValue!;
                                      int changeToIndex = scheduleViewProvider.scheduleList.indexWhere((element) => element["ScheduleOrder"].toString() == scheduleViewProvider.changeToValue);
                                      scheduleViewProvider.scheduleList = [
                                        ...scheduleViewProvider.scheduleList.sublist(changeToIndex),
                                        ...scheduleViewProvider.scheduleList.sublist(0, changeToIndex)
                                      ];
                                    });
                                  },
                                  includeNoneOption: false,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
                scheduleViewProvider.scheduleList.isNotEmpty ?
                Expanded(
                    child: ReorderableListView.builder(
                        itemCount: scheduleViewProvider.scheduleList.length,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = scheduleViewProvider.scheduleList.removeAt(oldIndex);
                            scheduleViewProvider.scheduleList.insert(newIndex, item);
                          });
                          scheduleViewProvider.changeToValue = scheduleViewProvider.scheduleList[0]["ScheduleOrder"].toString();
                        },
                        proxyDecorator: (widget, animation, index) {
                          return Transform.scale(
                            scale: 0.95,
                            child: widget,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final scheduleItem = scheduleViewProvider.scheduleList[index];
                          return Column(
                            key: ValueKey<int>(int.parse(scheduleItem["ScheduleOrder"].toString())),
                            children: [
                              buildScheduleList(scheduleViewProvider.scheduleList, index, scheduleViewProvider, constraints),
                              if(index == scheduleViewProvider.scheduleList.length - 1)
                                const SizedBox(height: 50,)
                            ],
                          );
                        }
                    )
                ): const Text("User schedule priority not found")
              ],
            ),
            floatingActionButton: MaterialButton(
              color: const Color(0xFFFFCB3A),
              splashColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
              ),
              onPressed: () async{
                var userData = {
                  "userId": widget.userId,
                  "controllerId": widget.controllerId,
                  "modifyUser": widget.customerId,
                  "sequence": scheduleViewProvider.scheduleList,
                  "scheduleDate": DateFormat('yyyy/MM/dd').format(scheduleViewProvider.date)
                };
                var listToMqtt = [];
                for (var i = 0; i < scheduleViewProvider.scheduleList.length; i++) {
                  final scheduleItem = scheduleViewProvider.scheduleList[i];
                  String scheduleMap = ""
                      "${scheduleItem["S_No"]},"
                      "${i+1},"
                      "${scheduleItem["ScaleFactor"]},"
                      "${scheduleItem["SkipFlag"]},"
                      "${scheduleItem["CentralFertOnOff"]},"
                      "${scheduleItem["CentralFertChannelSelection"]},"
                      "${scheduleItem["LocalFertOnOff"]},"
                      "${scheduleItem["LocalFertChannelSelection"]},"
                      "${scheduleItem["CentralFilterLimit"]},"
                      "${scheduleItem["CentralFilterSelection"]},"
                      "${scheduleItem["LocalFilterLimit"]},"
                      "${scheduleItem["LocalFilterSelection"]}"
                      "";
                  listToMqtt.add(scheduleMap);
                }
                var dataToHardware = {
                  "2700": [{
                    "2701": "${listToMqtt.join(";").toString()};"
                  }]
                };
                try {
                  final updateUserSequencePriority = await httpService.postRequest('updateUserSequencePriority', userData);
                  final response = jsonDecode(updateUserSequencePriority.body);
                  Future<void>.delayed(const Duration(milliseconds: 1500),() {
                    manager.publish(dataToHardware.toString(), "AppToFirmware/${widget.deviceId}");
                  });
                  if(updateUserSequencePriority.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: response['message']));
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'Failed to update because of $error'));
                  print("Error: $error");
                }
              },
              child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          );
        });
  }

  Widget buildScheduleList(scheduleItem, index, scheduleViewProvider, constraints, // Function(void Function()) setStateCallback
      ) {
    var method = scheduleItem[index]["IrrigationMethod"].toString();
    var inputValue = scheduleItem[index]["IrrigationDuration_Quantity"].toString();
    var completedValue = method == "1"
        ? scheduleItem[index]["IrrigationDurationCompleted"].toString()
        : scheduleItem[index]["IrrigationQuantityCompleted"].toString();
    var pumps = scheduleItem[index]['Pump'];
    var mainValves = scheduleItem[index]['MainValve'];
    var valves = scheduleItem[index]['SequenceData'];
    var toLeftDuration;
    var progressValue;
    if (method == "1") {
      List<String> inputTimeParts = inputValue.split(':');
      int inHours = int.parse(inputTimeParts[0]);
      int inMinutes = int.parse(inputTimeParts[1]);
      int inSeconds = int.parse(inputTimeParts[2]);

      List<String> timeComponents = completedValue.split(':');
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      Duration inDuration = Duration(hours: inHours, minutes: inMinutes, seconds: inSeconds);
      Duration completedDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);

      toLeftDuration = (inDuration - completedDuration).toString().substring(0,7);
      progressValue = completedDuration.inMilliseconds / inDuration.inMilliseconds;
    } else {
      progressValue = int.parse(completedValue) / int.parse(inputValue);
      toLeftDuration = int.parse(inputValue) - int.parse(completedValue);
    }
    var status = scheduleViewProvider.getStatusInfo(scheduleItem[index]["Status"].toString());
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      surfaceTintColor: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: constraints.maxWidth < 800 ? 100 : 90,
            decoration: BoxDecoration(
                color: status.color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).primaryColor, width: 0.5),
                            color: Colors.white),
                        child: Center(
                            child: Text(
                              scheduleItem[index]["S_No"].toString(),
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ))),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheduleItem[index]["ProgramName"],
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(scheduleItem[index]["ZoneName"]),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                status.statusString,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Completed: $completedValue",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "Actual: $inputValue",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "To left: $toLeftDuration",
                          style: const TextStyle(fontSize: 12),
                        ),
                        MouseRegion(
                          onHover: (onHover) {},
                          child: Tooltip(
                            message: completedValue,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(
                                    border:
                                    Border.all(width: 0.3, color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                child: LinearProgressIndicator(
                                  value: progressValue.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pumps),
                          const Text("Pumps", style: TextStyle(fontSize: 12),)
                        ],
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mainValves),
                          const Text("Main Valves", style: TextStyle(fontSize: 12),)
                        ],
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(valves.split('+').join(', ').toString()),
                          const Text("Valves", style: TextStyle(fontSize: 12),)
                        ],
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scheduleItem[index]["ScaleFactor"].toString()),
                          const Text("Scale Factor", style: TextStyle(fontSize: 12),)
                        ],
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: TextButton(
                            onPressed: (){
                              setState(() {
                                scheduleItem[index]["SkipFlag"] = scheduleItem[index]["SkipFlag"] == 0 ? 1 : 0;
                              });
                            },
                            child: Text(scheduleItem[index]["SkipFlag"] == 0 ? "Skip" : "Un skip",
                              // style: TextStyle(color: skipFlag[index]["SkipFlag"] == 0 ? Colors.red : null),
                            )),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: IconButton(
                            tooltip: "Edit",
                            onPressed: () {
                              sideSheet(scheduleItem, constraints, index);
                            },
                            icon: const Icon(Icons.edit)),
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void sideSheet(scheduleItem, constraints, index) {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      barrierColor: const Color(0xff66000000),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  // margin: EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.zero,
                  ),
                  height: double.infinity,
                  width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.2,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Scale Factor",),
                            SizedBox(
                              width: 30,
                              child: TextFormField(
                                style: TextStyle(color: Theme.of(context).primaryColor),
                                initialValue: scheduleItem[index]["ScaleFactor"].toString(),
                                onChanged: (newValue){
                                  setState(() {
                                    scheduleItem[index]["ScaleFactor"] = newValue != '' ? newValue : scheduleItem[index]["ScaleFactor"];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                        buildSwitch(scheduleItem[index], "Central fertilizer site", "CentralFertOnOff", stateSetter, "CentralFertilizerSite"),
                        const SizedBox(height: 10,),
                        buildCheckBoxList(scheduleItem[index], "CentralFertChannelSelection", "CentralFertChannelSelectionName", stateSetter, "CentralFertOnOff"),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                        buildSwitch(scheduleItem[index], "Local fertilizer site", "LocalFertOnOff", stateSetter, "LocalFertilizerSite"),
                        const SizedBox(height: 10,),
                        buildCheckBoxList(scheduleItem[index], "LocalFertChannelSelection", "LocalFertChannelSelectionName", stateSetter, "LocalFertOnOff"),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                        buildSwitch(scheduleItem[index], "Central filter site", "CentralFilterLimit", stateSetter, "CentralFilterSite"),
                        const SizedBox(height: 10,),
                        buildCheckBoxList(scheduleItem[index], "CentralFilterSelection", "CentralFilterSelectionName", stateSetter, "CentralFilterLimit"),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                        buildSwitch(scheduleItem[index], "Local filter site", "LocalFilterLimit", stateSetter, "LocalFilterSite"),
                        const SizedBox(height: 10,),
                        buildCheckBoxList(scheduleItem[index], "LocalFilterSelection", "LocalFilterSelectionName", stateSetter, "LocalFilterLimit"),
                        Divider(thickness: 0.3, color: Theme.of(context).primaryColor,),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }

  Widget buildSwitch(scheduleItem, title, itemValue, stateSetter, itemName) {
    return CustomAnimatedSwitcher(
      condition: scheduleItem[itemName] != "",
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Switch(
              value: scheduleItem[itemValue] == 1 ? true : false,
              onChanged: (newValue) {
                stateSetter(() {
                  scheduleItem[itemValue] == 1
                      ? scheduleItem[itemValue] = 0
                      : scheduleItem[itemValue] = 1;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildCheckBoxList(scheduleItem, item, name, stateSetter, condition) {
    ScrollController localScrollController = ScrollController();
    return CustomAnimatedSwitcher(
      condition: scheduleItem[condition] == 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: localScrollController,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            localScrollController
                .jumpTo(localScrollController.offset - details.primaryDelta! / 2);
          },
          child: Row(
            children: List.generate(
              scheduleItem[item].split("_").length,
                  (int itemIndex) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${scheduleItem[name].split("_")[itemIndex]}"),
                        Checkbox(
                          value: scheduleItem[item].split("_")[itemIndex] == "1" ? true : false,
                          onChanged: (newValue) {
                            stateSetter(() {
                              List<String> channelSelectionList = scheduleItem[item].split("_");
                              channelSelectionList[itemIndex] = channelSelectionList[itemIndex] == "1" ? "0" : "1";
                              scheduleItem[item] = channelSelectionList.join("_");
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}



class StatusInfo {
  final Color color;
  final String statusString;

  StatusInfo(this.color, this.statusString);
}

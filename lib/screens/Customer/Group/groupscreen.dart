import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/GroupsModel.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/SelectedGroupProvider.dart';
import '../../../state_management/group_provider.dart';
import 'groupdetailsscreen.dart';

class MyGroupScreen extends StatefulWidget {
  const MyGroupScreen(
      {super.key, required this.userId, required this.controllerId});
  final userId, controllerId;
  @override
  MyGroupScreenState createState() => MyGroupScreenState();
}

class MyGroupScreenState extends State<MyGroupScreen> with ChangeNotifier {
  NameListProvider nameListProvider = NameListProvider();

  Map<dynamic, dynamic> jsondata = {};
  Groupedname _groupedname = Groupedname();
  Timer? _timer;

  String selectedGroupnew = '';
  List<Group>? groupNamesnew = [];
  ScrollController _controller = ScrollController();
  ScrollController _controller2 = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        fetchData();
      });
    }
  }

  // datainit() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     print('mounted.staret');
  //     if (mounted) {
  //       setState(() {
  //         fetchData();
  //         _timer = Timer(Duration(milliseconds: 500), () {
  //           // valueAssign();
  //           // selectvalvelistvalue();
  //
  //           groupNamesnew = _groupedname.data?.group;
  //           var groupselect =
  //               Provider.of<SelectedGroupProvider>(context, listen: false);
  //
  //           if (_groupedname.data!.group!.isNotEmpty) {
  //             selectedGroupnew = groupNamesnew!.first.id!;
  //             groupselect.updateSelectedGroup(groupNamesnew!.first.name!);
  //           }
  //         });
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response =
    await HttpService().postRequest("getUserPlanningNamedGroup", body);
    if (response.statusCode == 200) {

      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _groupedname = Groupedname.fromJson(jsondata1);

        _timer = Timer(Duration(milliseconds: 500), () {
          groupNamesnew = _groupedname.data?.group;
          var groupselect =
          Provider.of<SelectedGroupProvider>(context, listen: false);
          groupselect.clearvalues();

          if (_groupedname.data!.group!.isNotEmpty) {
            selectedGroupnew = groupNamesnew!.first.id!;
            groupselect.updateSelectedGroup(groupNamesnew!.first.name!);

            List<String> valveID = [];
            for (var i = 0; i < _groupedname.data!.group![0].valve!.length; i++) {
              String vid = _groupedname.data!.group![0].valve![i].id ?? '';
              valveID.add(vid.split("VL").last);
            }

            groupselect.updateselectedvalve(valveID);

          }
        });
      });

    } else {
      // _showSnackBar(response.body);
    }

  }

  void _showDetailsScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DetailsSection(
          data: jsondata['group']!,
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showAlertDialog(
      BuildContext context,
      String title,
      String msg,
      bool btncount,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            btncount
                ? TextButton(
              child: const Text("cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
                : Container(),
          ],
        );
      },
    );
  }

  bool colorChange(List<dynamic> selectlist, String srno) {
    if (selectlist.isNotEmpty) {
      for (var i = 0; i < selectlist.length; i++) {
        if (selectlist[i]['sNo'].toString() == srno) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var groupselect = Provider.of<SelectedGroupProvider>(context, listen: true);
    if (_groupedname.data == null) {
      return Container(
        child: const Center(
            child: Text(
              'Currently no group available add first Product Limit',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
      );
    } else if (_groupedname.data!.group!.length <= 0) {
      return Container(
        child: const Center(
            child: Text(
              'Currently no group available add first Product Limit',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            )),
      );
    } else {
      return Builder(builder: (context) {
        return Scaffold(
          body: Padding(
            padding: MediaQuery.of(context).size.width > 600
                ? const EdgeInsets.only(
                left: 40.0, right: 40.0, top: 10.0, bottom: 20.0)
                : const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //TODO:- SelectvalveNAme
                selectvalveName(context),
                //TODO:- icon Group Details Icon
                Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      title: const Text('List of Groups'),
                      trailing: IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () {
                          jsondata['group']!.isNotEmpty
                              ? _showDetailsScreen(context)
                              : _showAlertDialog(context, 'Warnning',
                              'Currently no group available', false);
                        },
                      ),
                    )),
                //TODO:- Group
                groupnamenew(context),
                //TODO:- Line
                lineValvesshow(context),
                const SizedBox(
                  height: 5,
                ),
                //Show Lines and selection valve
              ],
            ),
          ),
          floatingActionButton: Row(
            children: [
              const Spacer(),
              //ToDo: Delete Button
              FloatingActionButton(
                onPressed: () async {
                  _groupedname.data!.group![groupselect.selectedGroupsrno]
                      .valve = List.empty();
                  var group = _groupedname.data!.toJson();
                  Map<String, Object> body = {
                    "userId": widget.userId,
                    "controllerId": widget.controllerId,
                    "group": group['group'],
                    "createUser": widget.userId
                  };

                  setState(() async {
                    final response = await HttpService()
                        .postRequest("createUserPlanningNamedGroup", body);
                    final jsonDataresponse = json.decode(response.body);
                    GlobalSnackBar.show(context, jsonDataresponse['message'],
                        response.statusCode);
                  });
                },
                child: const Icon(Icons.delete),
              ),
              const SizedBox(
                width: 5,
              ),
              //ToDo: Send button
              FloatingActionButton(
                onPressed: () async {
                  var group = _groupedname.data!.toJson();

                  Map<String, Object> body = {
                    "userId": widget.userId,
                    "controllerId": widget.controllerId,
                    "group": group['group'],
                    "createUser": widget.userId
                  };
                  final response = await HttpService()
                      .postRequest("createUserPlanningNamedGroup", body);
                  final jsonDataresponse = json.decode(response.body);
                  GlobalSnackBar.show(context, jsonDataresponse['message'],
                      response.statusCode);
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
          // ),
        );
      });
    }
  }

  @override
  Widget selectvalveName(BuildContext context) {
    var groupselect = Provider.of<SelectedGroupProvider>(context, listen: true);

    return Container(
      // height: 50,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${groupselect.selectedGroup} :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(
                '${groupselect.selectedvalve.join(' & ')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
    //Group Details Icon
  }

  @override
  Widget groupnamenew(BuildContext context) {
    var groupselect = Provider.of<SelectedGroupProvider>(context, listen: true);
    return Column(
      children: [
        Wrap(
          children: groupNamesnew?.map((group) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: FilterChip(
                label: Text(group.name ?? ''),
                backgroundColor: groupselect.selectedGroup == group.id
                    ? Colors.amber
                    : Colors.blueGrey,
                selectedColor: Colors.amber,
                selected: selectedGroupnew == group.id,
                showCheckmark: false,
                onSelected: (isSelected) {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    setState(() {
                      selectedGroupnew = group.id!;
                      groupselect.updateSelectedGroup(group.name!);
                      groupselect.updateSelectedGroupsrno(group.sNo!);
                      groupselect.updateSelectedGroupid(group.id ?? '');
                      groupselectvalveupdate(group, context);
                    });
                  });
                },
              ),
            );
          }).toList() ??
              [],
        ),
      ],
    );
  }

  @override
  Widget lineValvesshow(BuildContext context) {
    var groupselect = Provider.of<SelectedGroupProvider>(context, listen: true);

    return Expanded(
      child: ListView.builder(
        controller: _controller,
        itemCount: _groupedname.data!.line!.length, // Outer list item count
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    //Line name
                    width: double.infinity,
                    child: Text(
                      _groupedname.data!.line![index].name!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 70,
                    child: Scrollbar(
                      trackVisibility: true,
                      child: ListView.builder(
                        controller: _controller2,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        _groupedname.data!.line![index].valve!.length ?? 0,
                        itemBuilder: (context, innerIndex) {

                          String vid =
                              '${_groupedname.data!.line![index].valve![innerIndex].id}'
                                  .split("VL")
                                  .last;

                          //Edit Valve selection
                          return InkWell(
                            onTap: () {
                              Valveselect selectvalve = _groupedname
                                  .data!.line![index].valve![innerIndex];

                              Group group = _groupedname
                                  .data!.group![groupselect.selectedGroupsrno];

                              String valveid = _groupedname.data!.line![index]
                                  .valve![innerIndex].id ??
                                  '';
                              String Lineid =
                                  _groupedname.data!.line![index].id ?? '';
                              setState(() {
                                groupselection(
                                    group, selectvalve, Lineid, context);
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.all(4),
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: groupselectioncolor(
                                      _groupedname.data!.group![
                                      groupselect.selectedGroupsrno],
                                      _groupedname.data!.line![index]
                                          .valve![innerIndex],
                                      context)
                                      ? Colors.amber
                                      : Colors.blueGrey,
                                  child: Text('$vid'),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void groupselection(
      Group group, Valveselect selectValve, String id, BuildContext context) {

    if (group.location == id) {
      bool idExists = false;
      for (var i = 0; i < group.valve!.length; i++) {
        if (group.valve![i].id == selectValve.id) {
          group.valve!.removeAt(i);
          idExists = true;
        }
      }
      if (!idExists) {
        group.valve!.add(selectValve);
      }
    } else {
      group.location = id;
      group.valve = [];
      group.valve!.add(selectValve);
    }

    groupselectvalveupdate(group, context);
  }

  bool groupselectioncolor(
      Group group, Valveselect selectValve, BuildContext context) {
    bool isValveMatch = group.valve!.any((valve) => valve.id == selectValve.id);

    // groupselectvalveupdate(group, context);

    return isValveMatch;
  }

  void groupselectvalveupdate(Group group, BuildContext context) {
    var groupselect =
    Provider.of<SelectedGroupProvider>(context, listen: false);
    List<String> valveID = [];
    for (var i = 0; i < group.valve!.length; i++) {
      String vid = group.valve![i].id ?? '';
      valveID.add(vid.split("VL").last);
    }
    groupselect.updateselectedvalve(valveID);
  }

  void updateGroupWithMissingValves(List<Group> line, List<Group> group) {
    for (var groupItem in group) {
      var lineItem = line.firstWhere(
              (lineItem) => lineItem.id == groupItem.location,
          orElse: () => Group());

      if (lineItem.valve != null) {
        groupItem.valve ??= [];

        groupItem.valve!.removeWhere((groupValve) =>
        !lineItem.valve!.any((lineValve) => lineValve.id == groupValve.id));

        var missingValves = lineItem.valve!.where((lineValve) => !groupItem
            .valve!
            .any((groupValve) => groupValve.id == lineValve.id));

        groupItem.valve!.addAll(missingValves);
      }
    }
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../constants/http_service.dart';
import '../../../state_management/group_provider.dart';
import 'groupdetailsscreen.dart';


class MyGroupScreen extends StatefulWidget {
  const MyGroupScreen({super.key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  MyGroupScreenState createState() => MyGroupScreenState();
}

class MyGroupScreenState extends State<MyGroupScreen> with ChangeNotifier {
  List<dynamic> selectedValuesList = [];
  List<String> orderedSelectedValues = [];
  List<String> groupValues = [];
  int selectedgroupIndex = -1;
  String selectgroup = '';
  int selectline = -1;
  String groupedvalvestr = '';
  List<String> grouplist = [];
  List<String> emptygrouplist = [];
  int oldgroupIndex = -1;
  int oldlineindex = -1;
  NameListProvider nameListProvider = NameListProvider();
 
  var jsondata;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    Timer(Duration(milliseconds: 500), () {
      valueAssign();
      selectvalvelistvalue();
      print('jsondataselectvalvelistvalue');
    });
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    final response =
        await HttpService().postRequest("getUserPlanningNamedGroup", body);
    if (response.statusCode == 200) {
      setState(() {
        final jsondata1 = jsonDecode(response.body);
        jsondata = jsondata1['data'];
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  void valueAssign() {
    print('valueAssign function ');
    setState(() {
      selectedgroupIndex = jsondata['group']!.isNotEmpty ? 0 : -1;
      emptygrouplist.clear();
      grouplist.clear();
      for (var i = 0; i < jsondata['group']!.length; i++) {
        if (jsondata['group']![i]['valve'].length > 0) {
          grouplist.add('${jsondata['group']![i]['name']}');
        } else {
          emptygrouplist.add('${jsondata['group']![i]['name']}');
        }
      }
    });
  }

  void selectvalvelistvalue() {
    print('selectvalvelistvalue');
    setState(() {
      if (selectedgroupIndex != -1) {
        selectedValuesList = [];
        nameListProvider.removeAll();
        jsondata['group']![selectedgroupIndex]['location'] == ''
            ? selectline = -1
            : selectline = int.parse(jsondata['group']![selectedgroupIndex]
                    ['location']
                .split(' ')[1]);
        ;

         for (var i = 0;
            i < jsondata['group']![selectedgroupIndex]['valve'].length;
            i++) {
          groupedvalvestr =
              '${jsondata['group']![selectedgroupIndex]['name']}:';
          selectedValuesList
              .add(jsondata['group']![selectedgroupIndex]['valve'][i]);
          groupedvalvestr = jsondata['group']![selectedgroupIndex]['name'];
          nameListProvider.addName('${i + 1},');
          nameListProvider.updateSelectedValues(selectedValuesList);
        }
      }
    });
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
    print('emptygrouplist');
    if (emptygrouplist.isEmpty) {
      print(emptygrouplist);
      _showAlertDialog(context, 'Warnning',
          'Currently no group available add first Product Limit', false);
      return Container();
    } else {
      return Builder(builder: (context) {
        return Scaffold(
          // backgroundColor: Colors.white70,
          appBar: AppBar(
              title: const Text(
            'Groups',
            textAlign: TextAlign.center,
          )),
          body: Padding(
            padding: MediaQuery.of(context).size.width > 600
                ? const EdgeInsets.only(
                    left: 80.0, right: 80.0, top: 10.0, bottom: 20.0)
                : const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    // height: 50,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: nameListProvider.names.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$groupedvalvestr :',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                label: Text(
                                  '${nameListProvider.names.join('')}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : null),
                //Group Details Icon
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
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          height: 80,
                          child: Scrollbar(
                            trackVisibility: true,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: ScrollController(),
                              itemCount: grouplist.length,
                              itemBuilder: (context, groupIndex) {
                                String gname = jsondata['group']![groupIndex]
                                        ['name']
                                    .toString();
                                //ClicK Group
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      groupedvalvestr = '';
                                      groupedvalvestr = '$gname';
                                      nameListProvider.removeAll();
                                      selectedgroupIndex = groupIndex;
                                      selectvalvelistvalue();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    child: Center(
                                        child: Chip(
                                      label: Text(gname),
                                      backgroundColor:
                                          selectedgroupIndex == groupIndex
                                              ? Colors.amber
                                              : Colors.blueGrey,
                                    )),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Container(width: 50,height: 100,child: ,),

                      Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(2),
                        child: FloatingActionButton(
                          elevation: 4,
                          onPressed: () {
                            setState(() {
                              //Add group list
                              if (emptygrouplist.isNotEmpty) {
                                grouplist.add(emptygrouplist[0].toString());
                                emptygrouplist.removeAt(0);
                                groupedvalvestr = grouplist[0].toString();
                                nameListProvider.removeAll();
                              } else {
                                _showAlertDialog(context, 'Warning',
                                    'Group Limit is Reached', false);
                              }
                            });

                            print('click add button');
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                //Show Lines and selection valve
                Expanded(
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemCount:
                        jsondata['line']?.length, // Outer list item count
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
                                  jsondata['line']![index]['name'].toString(),
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
                                height: 70, // Set the height of the inner list
                                child: Scrollbar(
                                  trackVisibility: true,
                                  child: ListView.builder(
                                    controller: ScrollController(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (jsondata['line']![index]
                                                ['valve']
                                            ?.length) ??
                                        0,
                                    itemBuilder: (context, innerIndex) {
                   
                                      int vnamesrno = jsondata['line']![index]
                                          ['valve'][innerIndex]['sNo'];
//Edit
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (groupedvalvestr != '') {
                                              if (selectline != (index + 1)) {
                                                orderedSelectedValues.clear();
                                                selectedValuesList.clear();
                                                selectline = index + 1;
                                                oldlineindex = index + 1;
                                                nameListProvider.removeAll();
                                              }
                                            
                                              int? checksrno;
                                              if (jsondata['group'].length >
                                                  0) {
                                                for (var i = 0;
                                                    i <
                                                        jsondata['group']
                                                            .length;
                                                    i++) {
                                                  for (var j = 0;
                                                      j <
                                                          jsondata['group'][i]
                                                                  ['valve']
                                                              .length;
                                                      j++) {
                                                    if (jsondata['group'][i]
                                                                ['valve'][j]
                                                            ['sNo'] ==
                                                        vnamesrno) {
                                                      checksrno = j;
                                                    }
                                                  }
                                                }
                                              }
                                              print('checksrno: $checksrno ');

//Mycode
                                              if (jsondata['group'].length >
                                                  0) {
                                                if (checksrno == null) {
                                                  print('checksrno == null');
                                                  jsondata['group']![
                                                              selectedgroupIndex]
                                                          ['valve']
                                                      .add(jsondata['line']![
                                                              index]['valve']
                                                          [innerIndex]);
                                                } else {
                                                  jsondata['group']![
                                                              selectedgroupIndex]
                                                          ['valve']
                                                      .removeAt(checksrno);
                                                }
                                              }

                                              selectline = index + 1;
                                              oldlineindex = index + 1;

                                              nameListProvider.names.contains(
                                                      '${innerIndex + 1},')
                                                  ? nameListProvider.removeName(
                                                      '${innerIndex + 1},')
                                                  : nameListProvider.addName(
                                                      '${innerIndex + 1},');
                                            } else {
                                              _showAlertDialog(
                                                  context,
                                                  'Warnning',
                                                  'Add group First then select valves in group',
                                                  false);
                                            }
                                            print('end');
                                          });
                                        },
                                        child: Container(
                                          width: 70,
                                          margin: const EdgeInsets.all(4),
                                          child: Center(
                                            child: CircleAvatar(
                                              // backgroundColor: Colors.blueGrey,
                                              backgroundColor: selectline ==
                                                          index + 1 &&
                                                      colorChange(
                                                          jsondata['group'][
                                                                  selectedgroupIndex]
                                                              ['valve'],
                                                          vnamesrno.toString())
                                                  ? Colors.amber
                                                  : Colors.blueGrey,
                                              child: Text('${innerIndex + 1}'),
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
                ),
              ],
            ),
          ),
          floatingActionButton: Row(
            children: [
              const Spacer(),
              //Delete Button
              FloatingActionButton(
                onPressed: () async {
                  jsondata['group']?[selectedgroupIndex]['valve'] = [];
                  jsondata['group']?[selectedgroupIndex]['location'] = '';

                  Map<String, Object> body = {
                    "userId": '15',
                    "controllerId": "1",
                    "group": jsondata['group'],
                    "createUser": "1"
                  };
                  final response = await HttpService()
                      .postRequest("createUserPlanningNamedGroup", body);
                  final jsonDataresponse = json.decode(response.body);
                },
                child: const Icon(Icons.delete),
              ),
              const SizedBox(
                width: 5,
              ),
              //Send button
              FloatingActionButton(
                onPressed: () async {
            
                  jsondata['group']?[selectedgroupIndex]['location'] =
                      'Line $selectline';
                  Map<String, Object> body = {
                    "userId": '15',
                    "controllerId": "1",
                    "group": jsondata['group'],
                    "createUser": "1"
                  };
                  // print(body);
                  final response = await HttpService()
                      .postRequest("createUserPlanningNamedGroup", body);
                  final jsonDataresponse = json.decode(response.body);
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
}

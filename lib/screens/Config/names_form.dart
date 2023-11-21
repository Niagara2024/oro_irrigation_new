import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import '../../Models/names_model.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';

class Names extends StatefulWidget {
  const Names({Key? key, required this.userID, required this.customerID, required this.groupID,});
  final int userID, customerID, groupID;

  @override
  State<Names> createState() => _NamesState();
}

class _NamesState extends State<Names>  with TickerProviderStateMixin
{
  List<NamesModel> _namesList = <NamesModel>[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MyContainerWithTabs(names: _namesList, userID: widget.userID, groupID: widget.groupID, customerID: widget.customerID,);
  }

  Future<void> fetchData() async {
    final response = await HttpService().postRequest("getUserName", {"userId": widget.customerID, "controllerId": widget.groupID});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _namesList = List.from(data["data"]).map((item) => NamesModel.fromJson(item)).toList();
      setState(() {});
    } else {
      _showSnackBar(response.body);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class MyContainerWithTabs extends StatefulWidget
{
  const MyContainerWithTabs({super.key, required this.names, required this.userID, required this.customerID, required this.groupID});
  final List<NamesModel> names;
  final int userID, customerID, groupID;

  @override
  State<MyContainerWithTabs> createState() => _MyContainerWithTabsState();
}

class _MyContainerWithTabsState extends State<MyContainerWithTabs>
{
  @override
  Widget build(BuildContext context)
  {
    return Container(
      color:  Colors.white,
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: widget.names.length, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                    isScrollable: true,
                    tabs: [
                      for (var i = 0; i < widget.names.length; i++)
                        Tab(text: widget.names[i].nameDescription,),
                    ],
                    onTap: (value) {
                    },
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height-440,
                    child: TabBarView(
                      children: [
                        for (int i = 0; i < widget.names.length; i++)
                          widget.names[i].userName!.isEmpty ? Container()
                              : buildTab(widget.names[i].userName!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    List<Map<String, dynamic>> nameListJson =  widget.names.map((name) => name.toJson()).toList();
                    Map<String, dynamic> body = {
                      "userId": widget.customerID,
                      "controllerId": widget.groupID,
                      "userNameList": nameListJson,
                      "createUser": widget.userID
                    };
                    final response = await HttpService().postRequest("createUserName", body);
                    if(response.statusCode == 200)
                    {
                      var data = jsonDecode(response.body);
                      if(data["code"]==200)
                      {
                        _showSnackBar(data["message"]);
                      }
                      else{
                        _showSnackBar(data["message"]);
                      }
                    }
                  },
                  label: const Text('Save'),
                  icon: const Icon(
                    Icons.save_as_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTab(List<dynamic> nameList)
  {
    if(nameList[0]['location'] == '')
    {
      return DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 580,
          columns: const [
            DataColumn2(
                label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.M
            ),
            DataColumn2(
                label: Text('Id', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.M
            ),
            DataColumn2(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),),
                size: ColumnSize.L
            ),
          ],
          rows: List<DataRow>.generate(nameList.length, (index) => DataRow(cells: [
            DataCell(Text('${index+1}')),
            DataCell(Text(nameList[index]['id'])),
            DataCell(
              TextFormField(
                initialValue: nameList[index]['name'],
                onChanged: (val){
                  setState(() {
                    nameList[index]['name'] = val;
                  });
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: myTheme.primaryColor,
                    ),
                  ),
                ),
            ),
            ),
          ])));
    }
    return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 580,
        columns: const [
          DataColumn2(
              label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.M
          ),
          DataColumn2(
            label: Text('Id', style: TextStyle(fontWeight: FontWeight.bold),),
            size: ColumnSize.M
          ),
          DataColumn2(
              label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.L
          ),
          DataColumn2(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.L
          ),

        ],
        rows: List<DataRow>.generate(nameList.length, (index) => DataRow(cells: [
          DataCell(Text('${index+1}')),
          DataCell(Text(nameList[index]['id'])),
          DataCell(Text(nameList[index]['location'])),
          DataCell(TextFormField(
            initialValue: nameList[index]['name'],
            onChanged: (val){
              setState(() {
                nameList[index]['name'] = val;
              });
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: myTheme.primaryColor,
                ),
              ),
            ),
          ),),
        ])));

  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

}

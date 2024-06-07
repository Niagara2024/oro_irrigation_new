import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubUsers extends StatefulWidget {
  const SubUsers({Key? key, required this.customerID, required this.controllerId}) : super(key: key);
  final int customerID, controllerId;

  @override
  State<SubUsers> createState() => _SubUsersState();
}

class _SubUsersState extends State<SubUsers> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.count(
        crossAxisCount: 3, // Number of columns
        padding: const EdgeInsets.all(8.0),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        children: List.generate(7, (index) {
          return Card(
            elevation: 3.0,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                    ),
                    const Text('Subuser Name'),
                    const Text('+91 9595945744'),
                    Container(
                      width: double.infinity,
                      height: 25,
                      color: Colors.green.shade300,
                      child: Center(
                        child: Text('Shared controller or site', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Site 1'),
                      value: true,
                      onChanged: (bool? newValue) {
                        print('Checkbox value changed to: $newValue');
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Site 2'),
                      value: true,
                      onChanged: (bool? newValue) {
                        print('Checkbox value changed to: $newValue');
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Site 3'),
                      value: true,
                      onChanged: (bool? newValue) {
                        print('Checkbox value changed to: $newValue');
                      },
                    ),
                    Container(
                      width: double.infinity,
                      height: 25,
                      color: Colors.green.shade300,
                      child: const Center(
                        child: Text('Permission', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text('View only'),
                            value: true,
                            onChanged: (bool? newValue) {
                              print('Checkbox value changed to: $newValue');
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text('ON/OFF'),
                            value: true,
                            onChanged: (bool? newValue) {
                              print('Checkbox value changed to: $newValue');
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text('New program'),
                            value: true,
                            onChanged: (bool? newValue) {
                              print('Checkbox value changed to: $newValue');
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text('Stand alone'),
                            value: true,
                            onChanged: (bool? newValue) {
                              print('Checkbox value changed to: $newValue');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

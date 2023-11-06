import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final configuration = Provider.of<PreferencesMainProvider>(context).configuration;
    String tempControllerName = '';
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.background,
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/product 1.png',
                  width: 44,
                  height: 44,
                ),
                const SizedBox(width: 20,),
                Text(
                  configuration != null ? configuration.general.controllerName : '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.background,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8,),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(
                      Icons.type_specimen_rounded,
                      color: Colors.black,
                    ),
                  ),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                  ),
                  tileColor: Colors.white,
                  title: const Text('TYPE'),
                  subtitle: Text(
                    configuration != null ? configuration.general.categoryName : '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 8,),

                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(
                      Icons.format_list_numbered_rounded,
                      color: Colors.black,
                    ),
                  ),
                  tileColor: Colors.white,
                  title: const Text('SERIAL NUMBER'),
                  subtitle: Text(
                    configuration != null ? configuration.general.deviceId.toString() : '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(
                      Icons.perm_device_info,
                      color: Colors.black,
                    ),
                  ),
                  tileColor: Colors.white,
                  title: const Text('CONTROLLER NAME'),
                  subtitle: Text(
                    configuration != null ? configuration.general.controllerName : '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: InkWell(
                    child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                    onTap: () {
                      _textEditingController.text = Provider.of<PreferencesMainProvider>(context, listen: false).configuration!.general.controllerName;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Edit Controller name"),
                          content: TextFormField(
                            controller: _textEditingController,
                            onChanged: (newValue) => tempControllerName = newValue,
                            onTap: () {
                              _textEditingController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _textEditingController.text.length,
                              );
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("CANCEL", style: TextStyle(color: Colors.red),),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Provider.of<PreferencesMainProvider>(context, listen: false).updateControllerName(tempControllerName);
                              },
                              child: const Text("OKAY", style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(
                      Icons.account_box_rounded,
                      color: Colors.black,
                    ),
                  ),
                  tileColor: Colors.white,
                  title: const Text('AFFILIATE'),
                  subtitle: Text(
                    configuration != null ? configuration.general.userName : '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 8,),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

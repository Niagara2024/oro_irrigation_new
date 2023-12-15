import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';

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
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
          surfaceTintColor: Colors.white,
          child: Column(
            children: [
              CustomTile(
                title: 'TYPE',
                content: Icons.type_specimen_rounded,
                showSubTitle: true,
                subtitle: configuration != null ? configuration.general.categoryName : '',
              ),
              CustomTile(
                title: 'SERIAL NUMBER',
                content: Icons.format_list_numbered_rounded,
                showSubTitle: true,
                subtitle: configuration != null ? configuration.general.deviceId.toString() : '',
              ),
              CustomTile(
                title: 'CONTROLLER NAME',
                content: Icons.perm_device_info,
                showSubTitle: true,
                subtitle: configuration != null ? configuration.general.controllerName : '',
                trailing: InkWell(
                  child: Icon(Icons.drive_file_rename_outline_rounded, color: Theme.of(context).primaryColor,),
                  onTap: () {
                    _textEditingController.text = Provider.of<PreferencesMainProvider>(context, listen: false).configuration!.general.controllerName;
                    _textEditingController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _textEditingController.text.length,
                    );
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Edit Controller name"),
                        content: TextFormField(
                          controller: _textEditingController,
                          autofocus: true,
                          onChanged: (newValue) => tempControllerName = newValue,
                          inputFormatters: [LengthLimitingTextInputFormatter(20)],
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
              CustomTile(
                title: 'AFFILIATE',
                content: Icons.account_box_rounded,
                showSubTitle: true,
                subtitle: configuration != null ? configuration.general.userName : '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

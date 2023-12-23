import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/irrigation_program_main_provider.dart';

class ConditionsScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const ConditionsScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    final conditionsProvider = Provider.of<IrrigationProgramMainProvider>(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView(
          padding: constraints.maxWidth > 550 ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.025) : EdgeInsets.zero,
          children: [
            const SizedBox(height: 10,),
            const Center(child: Text('SELECT CONDITION FOR PROGRAM')),
            const SizedBox(height: 10),
            ...conditionsProvider.sampleConditions!.condition.asMap().entries.map((entry) {
              final conditionTypeIndex = entry.key;
              final condition = entry.value;
              final title = condition.title;
              final iconCode = condition.iconCodePoint;
              final iconFontFamily = condition.iconFontFamily;
              final value = condition.value != '' ? condition.value : false;
              final selected = condition.selected;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: ListTile(
                      title: Text(title, style: Theme.of(context).textTheme.bodyLarge,),
                      subtitle: Text('${(conditionsProvider.sampleConditions!.condition[conditionTypeIndex].value['name'] != null)
                          ? conditionsProvider.sampleConditions!.condition[conditionTypeIndex].value['name'] : 'Tap to select condition'}',),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Icon(IconData(int.parse(iconCode), fontFamily: iconFontFamily), color: Colors.black,),
                      ),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (newValue){
                          conditionsProvider.updateConditionType(newValue, conditionTypeIndex);
                        },
                      ),
                      onTap: () {
                        showAdaptiveDialog(
                            context: context,
                            builder: (BuildContext dialogContext) => Consumer<IrrigationProgramMainProvider>(
                              builder: (context, conditionsProvider, child) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: conditionsProvider.sampleConditions!.defaultData.conditionLibrary.asMap().entries.map((conditions) {
                                      final conditionName = conditions.value.name;
                                      final conditionSno = conditions.value.sNo;
                                      var conditionNameIndex = conditions.key;
                                      return RadioListTile(
                                          title: Text(conditionName),
                                          value: conditionName,
                                          groupValue: conditionsProvider.sampleConditions!.condition[conditionTypeIndex].value['name'],
                                          onChanged: (newValue) {
                                            conditionsProvider.updateConditions(title, conditionSno, newValue, conditionTypeIndex);
                                            Navigator.of(context).pop();
                                          }
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            )
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5,)
                ],
              );
            })
          ],
        );
      },
    );
  }
}

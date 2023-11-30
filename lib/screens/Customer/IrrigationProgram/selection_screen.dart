import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/IrrigationModel/selection_model.dart';
import '../../../state_management/irrigation_program_main_provider.dart';


class SelectionScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  const SelectionScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber});
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final Map<int, GlobalKey> itemKeys = {};
  String filterSelection = "Central filter";
  String fertSelection = "Central fert";
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final selectionPvd = Provider.of<IrrigationProgramMainProvider>(context,listen: true);


    Widget buildCard(List<NameData> itemList, List<NameData> itemList2,
        String title, String subtitle, String subtitle2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (itemList.isNotEmpty)
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                (itemList.isNotEmpty) ? Text(subtitle,) : Container(),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          ChoiceChip(
                            label: Text('${itemList[index].name}', style: const TextStyle(fontSize: 15)),
                            selected: itemList[index].selected ?? false,
                            selectedColor: Theme.of(context).colorScheme.secondary,
                            onSelected: (bool selected) {
                              selectionPvd.selectItem(index, subtitle2.isEmpty ? title : subtitle );
                            },
                          ),
                          const SizedBox(width: 5,)
                        ],
                      );
                    }
                  ),
                ),
                if (subtitle2 != '') const Divider(),
                if (subtitle2 != '' && itemList2.isNotEmpty)
                  Text(subtitle2),
                if (subtitle2 != '')
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: itemList2.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            ChoiceChip(
                              label: Text('${itemList2[index].name}', style: const TextStyle(fontSize: 15)),
                              selected: itemList2[index].selected ?? false,
                              selectedColor: Theme.of(context).colorScheme.secondary,
                              onSelected: (bool selected) {
                                selectionPvd.selectItem(index, subtitle2);
                              },
                            ),
                            const SizedBox(width: 5,)
                          ],
                        );
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (selectionPvd.selectionModel.data == null) {
      return const Center(
          child: CircularProgressIndicator());
    } else {
      return ListView(
        shrinkWrap: true,
        children: [
          selectionPvd.selectionModel.data!.mainValve!.isNotEmpty ? buildCard(
              selectionPvd.selectionModel.data!.mainValve!, [], 'MAIN VALVE',
              'List of Valves', '') : Container(),
          const SizedBox(height: 10),
          selectionPvd.selectionModel.data!.irrigationPump!.isNotEmpty ? buildCard(
              selectionPvd.selectionModel.data!.irrigationPump!, [], 'PUMP SELECTION',
              'List of Pump', '') : Container(),
          const SizedBox(height: 10),
          (selectionPvd.selectionModel.data!.centralFertilizerSite!.isNotEmpty ||
              selectionPvd.selectionModel.data!.localFertilizer!.isNotEmpty) ? buildCard(
              selectionPvd.selectionModel.data!.centralFertilizerSite!,
              selectionPvd.selectionModel.data!.localFertilizer!, 'Fertilizer Selection',
              'Central Fertilizer', 'Local Fertilizer') : Container(),
          const SizedBox(height: 10),
          (selectionPvd.selectionModel.data!.centralFilterSite!.isNotEmpty ||
              selectionPvd.selectionModel.data!.localFilter!.isNotEmpty) ? buildCard(
              selectionPvd.selectionModel.data!.centralFilterSite!,
              selectionPvd.selectionModel.data!.localFilter!, 'Filter Selection',
              'Central Filter', 'Local Filter') : Container(),
          const SizedBox(height: 10),
        ],
      );
    }
  }
}
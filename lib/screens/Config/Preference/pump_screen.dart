import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';
import '../../../widgets/SCustomWidgets/custom_tab.dart';
import '../../../widgets/SCustomWidgets/custom_text_container.dart';
import '../../../widgets/SCustomWidgets/custom_train_widget.dart';


class PumpScreen extends StatefulWidget {
  const PumpScreen({Key? key}) : super(key: key);

  @override
  State<PumpScreen> createState() => _PumpScreenState();
}

class _PumpScreenState extends State<PumpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    final pumpScreenProvider = Provider.of<PreferencesMainProvider>(context, listen: false);

    // Initialize the provider
    pumpScreenProvider.updatePumpIndex(0);
    pumpScreenProvider.extractTotalPumpsInfo();
    pumpScreenProvider.extractPumpInfo();

    // Initialize the TabController
    _tabController = TabController(
      length: pumpScreenProvider.totalPumps.length,
      vsync: this,
    )..addListener(() {
      pumpScreenProvider.updatePumpIndex(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pumpScreenProvider = Provider.of<PreferencesMainProvider>(context);
    final selectedPumpIndex = pumpScreenProvider.selectedPumpIndex;
    final isScreenSizeLarge = MediaQuery.of(context).size.width >= 600;

    return DefaultTabController(
      length: pumpScreenProvider.totalPumps.length,
      initialIndex: selectedPumpIndex,
      child: Column(
        children: [
          if (!isScreenSizeLarge)
            ...[
              // const CustomCard(imageAssetPath: 'assets/images/scroll (2) 1.png', title: 'View all',),
              const SizedBox(height: 10,),
              CustomTrainWidget(
                title: 'Pumps',
                child: TabBar(
                  controller: _tabController,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  indicatorColor: Colors.transparent,
                  isScrollable: true,
                  tabs: pumpScreenProvider.totalPumps.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String pump = entry.value;
                    return CustomTab(
                      height: 65,
                      radius: 25,
                      content: pump,
                      tabIndex: index,
                      selectedTabIndex: pumpScreenProvider.selectedPumpIndex,
                    );
                  }).toList(),
                ),
              ),
            ],
          const SizedBox(height: 10),
          Expanded(
            child: isScreenSizeLarge
                ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Table(
                    columnWidths: {
                      0: const FlexColumnWidth(1.5),
                      for (int i = 1; i < pumpScreenProvider.configuration!.pumps![0].value.length + 1; i++)
                        i: const FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        children: [
                          const TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Pump', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                          ...pumpScreenProvider.configuration!.pumps![0].value.map((e){
                            return TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(e.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  Table(
                    columnWidths: {
                      0: const FlexColumnWidth(1.5),
                      for (int i = 1; i < pumpScreenProvider.configuration!.pumps![0].value.length + 1; i++)
                        i: const FlexColumnWidth(1),
                    },
                    children: _buildRows(pumpScreenProvider),
                  )
                ],
              ),
            )
                : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: pumpScreenProvider.totalPumps.asMap().entries.map((entry) {
                final int pumpIndex = entry.key;
                final String pump = entry.value;
                return Column(
                  children: [
                    CustomTextContainer(
                      text: pumpScreenProvider.totalPumpsName[pumpIndex]!,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemCount: pumpScreenProvider.configuration!.pumps!.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: CustomTile(
                                  subtitle: pumpScreenProvider.configuration!.pumps!.firstWhere((element) => element.id == pump).value[index].type,
                                  //content: IconData(int.parse(pumpScreenProvider.configuration!.selectedContact.selectedContact[index].iconCodePoint ?? ''), fontFamily: pumpScreenProvider.configuration!.selectedContact.selectedContact[index].iconFontFamily),
                                  trailing: DropdownButton<String>(
                                    value: pumpScreenProvider.configuration!.pumps!.firstWhere((element) => element.id == pump).value[index].selectedContact,
                                    underline: Container(),
                                    onChanged: (newContact) {
                                      pumpScreenProvider.updateContactsForPumps(newContact, pump, pumpScreenProvider.configuration!.selectedContact.selectedContact[index].type, index);
                                    },
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'None',
                                        child: Text('None'),
                                      ),
                                      ...pumpScreenProvider.configuration!.contactName
                                          .map((e) => e.name)
                                          .where((name) => name != null)
                                          .cast<String>()
                                          .map((contact) {
                                        return DropdownMenuItem<String>(
                                          value: contact,
                                          child: Text(contact),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (index == pumpScreenProvider.configuration!.pumps!.firstWhere((element) => element.id == pump).value.length - 1)
                                const SizedBox(height: 60),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildRows(PreferencesMainProvider pumpScreenProvider) {
    final List<TableRow> rows = [];

    for (int index = 0; index < pumpScreenProvider.totalPumps.length; index++) {
      final String pump = pumpScreenProvider.totalPumps[index];

      final List<Widget> rowChildren = [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Text(
                pumpScreenProvider.totalPumpsName[index]!,
              ),
            ),
          ),
        ),
      ];

      final pumpItem = pumpScreenProvider.configuration!.pumps![index];
      for (final selectedContact in pumpItem.value) {
        final dropdown = SizedBox(
          width: 100,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedContact.selectedContact,
            underline: Container(),
            onChanged: (newContact) {
              pumpScreenProvider.updateContactsForPumps(newContact, pump, pumpScreenProvider.configuration!.selectedContact.selectedContact[index].type, index);
            },
            items: [
              const DropdownMenuItem<String>(
                value: 'None',
                child: Text('None'),
              ),
              ...pumpScreenProvider.configuration!.contactName
                  .map((e) => e.name)
                  .where((name) => name != null)
                  .cast<String>()
                  .map((contact) {
                return DropdownMenuItem<String>(
                  value: contact,
                  child: Text(contact),
                );
              }).toList(),
            ],
          ),
        );

        rowChildren.add(TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Center(child: dropdown)));
      }

      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? null : Theme.of(context).primaryColor.withOpacity(0.2),
          ),
          children: rowChildren,
        ),
      );
    }

    return rows;
  }
}

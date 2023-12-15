import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/preferences_screen_main_provider.dart';
import '../../../widgets/SCustomWidgets/custom_card.dart';
import '../../../widgets/SCustomWidgets/custom_list_tile.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  @override
  void initState() {
    super.initState();
    final contactsProvider = Provider.of<PreferencesMainProvider>(context, listen: false);
    if(contactsProvider.configuration?.contactName != null) {
      contactsProvider.initContactList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final configuration = Provider.of<PreferencesMainProvider>(context).configuration;
    final dataProvider = Provider.of<PreferencesMainProvider>(context);

    return configuration?.contactName != null
        ? Column(
      children: [
        const CustomCard(imageAssetPath: 'assets/images/lan (1) 1.png', title: 'SELECT TYPE FOR EACH CONTACT',),
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: configuration!.contactName.length,
              itemBuilder: (context, index) {
                final contactNames = configuration.contactName;
                final contactId = configuration.contacts?.where((name) => name.id.isNotEmpty).map((name) => name.id.isNotEmpty).toList() ?? [];
                final contactTypes = configuration.contactType.map((type) => type.contactType).toList();

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white
                      ),
                      child: CustomTile(
                        title: contactNames[index].name != '' ? contactNames[index].name ?? 'No name' : contactNames[index].id,
                        content: (index+1).toString(),
                        trailing: DropdownButton<String>(
                          underline: Container(),
                          value: configuration.contacts![index].value,
                          items: contactTypes.map((option) {
                            return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option,)
                            );
                          }).toList(),
                          onChanged: (selectedOption) {
                            dataProvider.changeTypeForContact(index,selectedOption!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    if (index == contactNames.length - 1)
                      const SizedBox(height: 60),
                  ],
                );
              }
          ),
        ),
      ],
    )
        : Center(child: Text('Contacts not selected'),
    );
  }
}
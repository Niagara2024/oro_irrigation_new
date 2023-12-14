import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Forms/contacts.dart';
import 'Forms/add_device_type.dart';
import 'Forms/add_global_settings.dart';
import 'Forms/add_interface_type.dart';
import 'Forms/add_language.dart';
import 'Forms/add_name_type.dart';
import 'Forms/add_object_type.dart';
import 'Forms/add_product_type.dart';
import 'Forms/add_setting_category.dart';
import 'Forms/add_unit_type.dart';
import 'Forms/add_widget_type.dart';
import 'Forms/dd_category.dart';
import 'Forms/dealer_definitions.dart';
import 'Forms/product_category.dart';
import 'Forms/product_model_form.dart';

class AllEntry extends StatefulWidget {
  const AllEntry({Key? key}) : super(key: key);

  @override
  State<AllEntry> createState() => _AllEntryState();
}

class _AllEntryState extends State<AllEntry> with SingleTickerProviderStateMixin {
  static const List<Object> myObjectList = [
    'Product category',
    'Product model',
    'Device Type',
    'Product Type',
    'Contact Type',
    'DD Category',
    'Dealer Definition',
    'Setting menu',
    'Settings category',
    'Interface type',
    'Languages',
    'Name type',
    'Object Type',
    'Widget Type',
    'Unit type',
  ];

  final Map<String, Widget> tabWidgets = {
    'Contact Type': const Contacts(),
    'DD Category': const DDCategory(),
    'Dealer Definition': const DealerDefinitions(),
    'Product category': const ProductCategory(),
    'Product model': const ProductModelForm(),
    'Device Type': const AddDeviceType(),
    'Product Type': const AddProductType(),
    'Name type': const AddNameType(),
    'Object Type': const AddObjectType(),
    'Interface type': const AddInterfaceType(),
    'Setting menu': const AddGlobalSettings(),
    'Settings category': const AddSettingCategory(),
    'Languages': const AddLanguage(),
    'Unit type': const AddUnitType(),
    'Widget Type': const AddWidgetType(),
  };

  late final TabController _tabCont;

  @override
  void initState() {
    _tabCont = TabController(length: myObjectList.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabCont.length, // Number of tabs
      child: Column(
        children: [
          TabBar(
            controller: _tabCont,
            isScrollable: true,
            indicatorColor: myTheme.primaryColor,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              ...myObjectList.map(
                    (label) => Tab(
                  child: Text(label.toString()),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height-110,
            child: TabBarView(
              controller: _tabCont,
              children: [
                ...myObjectList.map(
                      (label) => tabWidgets[label] ?? Center(child: Text('Page of $label')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Entry'),
        bottom: TabBar(
          controller: _tabCont,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          tabs: [
            ...myObjectList.map(
                  (label) => Tab(
                child: Text(label.toString()),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCont,
        children: [
          ...myObjectList.map(
                (label) => tabWidgets[label] ?? Center(child: Text('Page of $label')),
          ),
        ],
      ),
    );
  }
}
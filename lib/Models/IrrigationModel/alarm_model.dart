class Item {
  final String title;
  final String delayTime;
  final String irrigation;
  final String dosing;

  Item({
    required this.title,
    required this.delayTime,
    required this.irrigation,
    required this.dosing,
  });
}

class ItemCategory {
  final List<Item> items;

  ItemCategory({
    required this.items,
  });
}

class ItemsData {
  final List<ItemCategory> categories;

  ItemsData({
    required this.categories,
  });
}

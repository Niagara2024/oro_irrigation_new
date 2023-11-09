import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/product_inventrory_model.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';
import 'Forms/add_product.dart';

enum SampleItem { itemOne, itemTwo, itemThree}

class ProductInventory extends StatefulWidget {
  const ProductInventory({Key? key, required this.userName}) : super(key: key);
  final String userName;

  @override
  State<ProductInventory> createState() => ProductInventoryState();
}

class ProductInventoryState extends State<ProductInventory> {
  String userID = '0';
  int userType = 0;
  List<ProductListModel> productInventoryList = [];
  SampleItem? selectedMenu;

  List<dynamic> jsonDataByCategory = [];
  List<dynamic> jsonDataByModel = [];
  int totalProduct = 0;
  int totalCategory = 0;
  int totalModel = 0;
  int outOfStockModel = 0;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    fetchFilterData();
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userId') ?? "";
      userType = int.parse(prefs.getString('userType') ?? "");
    });
    getProductList(1, 30);

  }

  Future<void> getProductList(int set, int limit) async {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null, "set":set, "limit":limit} : {"fromUserId": null, "toUserId": userID, "set":set, "limit":limit};
    print(body);
    final response = await HttpService().postRequest("getProduct", body);
    if (response.statusCode == 200) {
      setState(() {
        totalProduct = jsonDecode(response.body)["data"]["totalProduct"];
        totalCategory = jsonDecode(response.body)["data"]["totalCategory"];
        totalModel = jsonDecode(response.body)["data"]["totalModel"];
        outOfStockModel = jsonDecode(response.body)["data"]["outOfStockModel"];
        productInventoryList = (jsonDecode(response.body)["data"]["product"] as List).map((data) => ProductListModel.fromJson(data)).toList();
      });
    }else {
      //_showSnackBar(response.body);
    }
  }

  Future<void> fetchFilterData() async {
    final response = await HttpService().postRequest("getFilterCategoryAndModel", {});

    if (response.statusCode == 200) {
      final jsonDCode =json.decode(response.body)["data"];

      setState(() {
        jsonDataByCategory = jsonDCode['category'];
        jsonDataByModel = jsonDCode['model'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade50,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  userType == 1 ? buildAdminHeader() : buildUserHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                      child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 600,
                          dataRowHeight: 40.0,
                          headingRowHeight: 40,
                          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                          border: TableBorder.all(color: Colors.grey),
                          columns: const [
                            DataColumn2(
                                label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                fixedWidth: 70
                            ),
                            DataColumn2(
                                label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                                label: Text('Model Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                              label: Text('IMEI Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                              fixedWidth: 170,
                            ),
                            DataColumn2(
                              label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 95,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 80,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 90,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Sales Person', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 150,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 100,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                              fixedWidth: 50,
                            ),
                          ],
                          rows: List<DataRow>.generate(productInventoryList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${index+1}'))),
                            DataCell(Text(productInventoryList[index].categoryName)),
                            DataCell(Text(productInventoryList[index].modelName)),
                            DataCell(Text('${productInventoryList[index].deviceId}')),
                            DataCell(Center(child: Text(productInventoryList[index].dateOfManufacturing))),
                            DataCell(Center(child: Text('${productInventoryList[index].warrentyMonths}'))),
                            DataCell(Center(child: userType==productInventoryList[index].productStatus? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('In Stock')],):
                            const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active')],))),
                            DataCell(Center(child: widget.userName==productInventoryList[index].latestBuyer? Text('-'):Text(productInventoryList[index].latestBuyer))),
                            DataCell(Center(child: Text('25-09-2023'))),
                            DataCell(Center(child: PopupMenuButton<SampleItem>(
                              initialValue: selectedMenu,
                              // Callback that sets the selected popup menu item.
                              onSelected: (SampleItem item) {
                                setState(() {
                                  selectedMenu = item;
                                });
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                                const PopupMenuItem<SampleItem>(
                                  value: SampleItem.itemOne,
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<SampleItem>(
                                  value: SampleItem.itemTwo,
                                  child: Text('Delete'),
                                ),
                                const PopupMenuItem<SampleItem>(
                                  value: SampleItem.itemThree,
                                  child: Text('Replace'),
                                ),
                              ],
                            )))
                          ])),
                      ),
                    ),
                  ),
                  buildSummaryRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAdminHeader()
  {
    return Column(
      children: [
        // ... (rest of the admin header code)
        Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )
          ),
          height: 50,
          child: ListTile(
            title: RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'Product ', style: TextStyle(fontSize: 20, color: Colors.black)),
                  TextSpan(text: 'Inventory', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 21)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width-650,
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                ActionChip(
                  avatar: Icon(Icons.filter_alt_outlined, color: myTheme.primaryColor),
                  label: const Text('Filter'),
                  tooltip: 'By\nCategory\nModel\nManufacture date\nSales person\nSearch',
                  backgroundColor: Colors.white,
                  elevation: 6.0,
                  shadowColor: Colors.grey[60],
                  padding: const EdgeInsets.all(5.0),
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 600,
                          width: 500,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), // Adjust the value for corner radius
                          ),
                          child: Column(
                            children: [
                              Container(height: 35,
                                decoration: BoxDecoration(
                                  color: myTheme.primaryColor,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), // Adjust the value for corner radius
                                ),
                                child: const Center(
                                  child: Text('Filter By',style: TextStyle(color: Colors.white),),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SearchAnchor(
                                  viewHintText: 'Search by IMEi Number',
                                    builder: (BuildContext context, SearchController controller) {
                                      return SearchBar(
                                        hintText: 'Search by IMEi Number',
                                        controller: controller,
                                        padding: const MaterialStatePropertyAll<EdgeInsets>(
                                            EdgeInsets.symmetric(horizontal: 10.0)),
                                        onTap: () {
                                          controller.openView();
                                        },
                                        onChanged: (_) {
                                          controller.openView();
                                        },
                                        leading: const Icon(Icons.search),
                                      );
                                    }, suggestionsBuilder:
                                    (BuildContext context, SearchController controller)
                                    {
                                    return List<ListTile>.generate(10, (int index) {
                                    final String item = '55488855256697$index';
                                    return ListTile(
                                      title: Text(item),
                                      onTap: () {
                                        setState(() {
                                          controller.closeView(item);
                                        });
                                      },
                                    );
                                  });
                                }),
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Category',
                                          ),
                                          const Divider(),
                                          Wrap(
                                            spacing: 10.0,
                                            runSpacing: 5.0,
                                            children: List.generate(jsonDataByCategory.length, (index) {
                                              return ChoiceChip(
                                                label: Text('${jsonDataByCategory[index]['categoryName']}'),
                                                selected: true,
                                                selectedColor: Colors.amber,
                                                onSelected: (bool selected) {
                                                  //selectItem(index, subtitle.isEmpty ? title : subtitle,selectionModelProvider);
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 10,),
                                          const Text('Model',),
                                          const Divider(),
                                          Wrap(
                                            spacing: 10.0,
                                            runSpacing: 7.0,
                                            children: List.generate(jsonDataByModel.length, (index) {
                                              return ChoiceChip(
                                                label: Text('${jsonDataByModel[index]['categoryName']}- ${jsonDataByModel[index]['modelName']}'),
                                                selected: false,
                                                selectedColor: Colors.amber,
                                                onSelected: (bool selected) {
                                                  //selectItem(index, subtitle.isEmpty ? title : subtitle,selectionModelProvider);
                                                },
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ),
                              Container(height: 45,
                                color: myTheme.primaryColor,
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(onPressed: () {Navigator.pop(context);}, child: const Text('Done',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),),
                                      const SizedBox(width: 10,)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 10,),
                ActionChip(
                  tooltip: 'Add new stock\nto Inventory panel',
                  avatar: Icon(Icons.add, color: myTheme.primaryColor),
                  label: const Text('Product Stock'),
                  backgroundColor: Colors.white,
                  elevation: 6.0,
                  shadowColor: Colors.grey[60],
                  padding: const EdgeInsets.all(5.0),
                  onPressed: () async {
                    await showDialog<void>(
                    context: context,
                    builder: (context) => const AlertDialog(
                    content: AddProduct(),
                    )).then((value) => getProductList(1, 30));
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2, child: Container(color: Colors.grey.shade200,)),
        /*Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )
          ),
          height: 44,
          child: ListTile(
            trailing:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              ],
            ),
          ),
        ),*/
      ],
    );
  }

  Widget buildUserHeader() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )
          ),
          height: 50,
          child: ListTile(
            title: RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'Product ', style: TextStyle(fontSize: 20, color: Colors.black)),
                  TextSpan(text: 'Inventory', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 21)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionChip(
                  tooltip: 'Category\nModel\nManufacture date\nSales person',
                  avatar: Icon(Icons.sort, color: myTheme.primaryColor),
                  label: const Text('Sort By'),
                  backgroundColor: Colors.white,
                  elevation: 6.0,
                  shadowColor: Colors.grey[60],
                  padding: const EdgeInsets.all(5.0),
                  onPressed: (){},
                ),
                const SizedBox(width: 10,),
                ActionChip(
                  tooltip: 'By Search',
                  avatar: Icon(Icons.filter_alt_outlined, color: myTheme.primaryColor),
                  label: const Text('Filter'),
                  backgroundColor: Colors.white,
                  elevation: 6.0,
                  shadowColor: Colors.grey[60],
                  padding: const EdgeInsets.all(5.0),
                  onPressed: (){},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSummaryRow() {
    //const List<String> list = <String>['10', '20', '30', '40', '50'];
    //String dropdownValue = list.first;
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20, top: 5),
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(children: [
            Text('Total Category', style: TextStyle(fontSize: 13)),
            Text('$totalCategory',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            Text("Total Products", style: TextStyle(fontSize: 13)),
            Text('$totalModel', style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            Text("Out of stock", style: TextStyle(fontSize: 13)),
            Text('$outOfStockModel',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            Text("Total Items", style: TextStyle(fontSize: 13)),
            Text('$totalProduct', style: TextStyle(fontSize: 17)),
          ],),
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               /* const Text('Per page  ='),
                const SizedBox(width: 5,),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down_outlined),
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: myTheme.primaryColor,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20,),*/
                const Text('1-10 of 2000'),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Previous page', onPressed:() {}, icon: const Icon(Icons.arrow_left)),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Next page',onPressed:() {}, icon: const Icon(Icons.arrow_right)),
                const SizedBox(width: 10,),
                IconButton(tooltip:'Settings',onPressed:() {}, icon: const Icon(Icons.settings_outlined))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
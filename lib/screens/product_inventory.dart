import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/product_inventrory_model.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';

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
  List<ProductListModel> filterProductInventoryList = [];
  SampleItem? selectedMenu;

  List<String> jsonDataByImeiNo = [];
  String searchedChipName = '';
  bool searchActive = false;
  bool filterActive = false;
  bool searched = false;

  int totalProduct = 0;
  int totalCategory = 0;
  int totalModel = 0;
  int outOfStockModel = 0;

  int batchSize = 30;
  int currentSet = 1;

  bool isNextButtonEnabled = true;
  bool isPreviousButtonEnabled = false;

  String jsonOptions = '';
  late Map<String, dynamic> jsonDataMap;

  bool visibleLoading = false;


  @override
  void initState() {
    super.initState();
    getUserInfo();
  }


  Future<void> getUserInfo() async {
    indicatorViewShow();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userId') ?? "";
      userType = int.parse(prefs.getString('userType') ?? "");
    });
    getProductList(currentSet, batchSize);
    fetchCatModAndImeiData();
  }

  Future<void> getProductList(int set, int limit) async {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null, "set":set, "limit":limit} : {"fromUserId": null, "toUserId": userID, "set":set, "limit":limit};
    final response = await HttpService().postRequest("getProduct", body);
    if (response.statusCode == 200)
    {
      if(jsonDecode(response.body)["code"]==200)
      {
        setState(() {
          totalProduct = jsonDecode(response.body)["data"]["totalProduct"];
          totalCategory = jsonDecode(response.body)["data"]["totalCategory"];
          totalModel = jsonDecode(response.body)["data"]["totalModel"];
          outOfStockModel = jsonDecode(response.body)["data"]["outOfStockModel"];
          productInventoryList = (jsonDecode(response.body)["data"]["product"] as List).map((data) => ProductListModel.fromJson(data)).toList();

          isNextButtonEnabled = productInventoryList.length >= limit;
          isPreviousButtonEnabled = currentSet > 1;
          indicatorViewHide();
        });

      }

      indicatorViewHide();

    }else {
      //_showSnackBar(response.body);
      indicatorViewHide();
    }
  }

  Future<void> fetchCatModAndImeiData() async
  {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null} : {"fromUserId": null, "toUserId": userID};
    final response = await HttpService().postRequest("getFilterCategoryModelAndImei", body);
    if (response.statusCode == 200) {
      final jsonDCode = json.decode(response.body)["data"];

      setState(() {
        jsonDataMap = json.decode(response.body);

        List<dynamic> dynamicImeiList = jsonDCode['imei'];
        jsonDataByImeiNo = List<String>.from(dynamicImeiList);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchFilterData(dynamic categoryId, dynamic modelId, dynamic deviceId) async
  {
    final body = userType == 1 ? {"fromUserId": null, "toUserId": null, "categoryId": categoryId, "modelId": modelId, "deviceId": deviceId} : {"fromUserId": null, "toUserId": userID, "categoryId": categoryId, "modelId": modelId, "deviceId": deviceId};
    print(body);
    final response = await HttpService().postRequest("getFilteredProduct", body);
    if (response.statusCode == 200)
    {
      if(jsonDecode(response.body)["code"]==200)
      {
        setState(() {
          searched = true;
          filterProductInventoryList = (jsonDecode(response.body)["data"] as List).map((data) => ProductListModel.fromJson(data)).toList();
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return visibleLoading? Visibility(
      visible: visibleLoading,
      child: Container(
        padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 100, 0, mediaQuery.size.width/2 - 100, 0),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    ) : Container(
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
                          rows: searched ? List<DataRow>.generate(filterProductInventoryList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}'))),
                            DataCell(Text(filterProductInventoryList[index].categoryName)),
                            DataCell(Text(filterProductInventoryList[index].modelName)),
                            DataCell(Text('${filterProductInventoryList[index].deviceId}')),
                            DataCell(Center(child: Text(filterProductInventoryList[index].dateOfManufacturing))),
                            DataCell(Center(child: Text('${filterProductInventoryList[index].warrantyMonths}'))),
                            DataCell(Center(child: userType==filterProductInventoryList[index].productStatus? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('In Stock')],):
                            const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active')],))),
                            DataCell(Center(child: widget.userName==filterProductInventoryList[index].latestBuyer? Text('-'):Text(filterProductInventoryList[index].latestBuyer))),
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
                          ])):
                          List<DataRow>.generate(productInventoryList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${(currentSet - 1) * batchSize + index + 1}'))),
                            DataCell(Text(productInventoryList[index].categoryName)),
                            DataCell(Text(productInventoryList[index].modelName)),
                            DataCell(Text(productInventoryList[index].deviceId)),
                            DataCell(Center(child: Text(productInventoryList[index].dateOfManufacturing))),
                            DataCell(Center(child: Text('${productInventoryList[index].warrantyMonths}'))),
                            DataCell(Center(child: userType==productInventoryList[index].productStatus? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('In Stock')],):
                            const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active')],))),
                            DataCell(Center(child: widget.userName==productInventoryList[index].latestBuyer? Text('-'):Text(productInventoryList[index].latestBuyer))),
                            const DataCell(Center(child: Text('25-09-2023'))),
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
                PopupMenuButton<dynamic>(
                  icon: const Icon(Icons.filter_alt_outlined),
                  tooltip: 'filter by category or model',
                  itemBuilder: (BuildContext context) {

                    setState(() {
                      searchActive = false;
                    });

                    List<PopupMenuEntry<dynamic>> menuItems = [];
                    menuItems.add(
                      const PopupMenuItem<dynamic>(
                        enabled: false,
                        child: Text("Category"),
                      ),
                    );

                    List<dynamic> categoryItems = jsonDataMap['data']['category'];
                    menuItems.addAll(
                      categoryItems.map((dynamic item) {
                        return PopupMenuItem<dynamic>(
                          value: item,
                          child: Text(item['categoryName']),
                        );
                      }),
                    );

                    menuItems.add(
                      const PopupMenuItem<dynamic>(
                        enabled: false,
                        child: Text("Model"),
                      ),
                    );

                    List<dynamic> modelItems = jsonDataMap['data']['model'];
                    menuItems.addAll(
                      modelItems.map((dynamic item) {
                        return PopupMenuItem<dynamic>(
                          value: item,
                          child: Text('${item['categoryName']} - ${item['modelName']}'),
                        );
                      }),
                    );

                    return menuItems;
                  },
                  onSelected: (dynamic selectedItem) {
                    if (selectedItem is Map<String, dynamic>) {
                      filterActive = true;
                      if (selectedItem.containsKey('categoryName') && selectedItem.containsKey('modelName')) {
                        setState(() {
                          searchedChipName = '${selectedItem['categoryName']} - ${selectedItem['modelName']}';
                          fetchFilterData(null, selectedItem['modelId'], null);
                        });
                      } else {
                        setState(() {
                          searchedChipName = '${selectedItem['categoryName']}';
                          fetchFilterData(selectedItem['categoryId'], null, null);
                        });
                      }
                    }
                  },
                ),
                const SizedBox(width: 10,),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'search by imei number',
                  onPressed: () {
                    setState(() {
                      searchActive = true;
                      searchedChipName = '';
                    });
                  },
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 2, child: Container(color: Colors.grey.shade200,)),
        searchActive ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
            viewHintText: 'Search by IMEi Number',
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                hintText: 'Search by IMEi Number',
                controller: controller,
                onTap: () {
                  filterActive = true;
                  controller.openView();
                },
                onChanged: (val) {
                  print(val);
                },
                onSubmitted: (val) {
                  print(val);
                },
                leading: const Icon(Icons.search),
                trailing: <Widget>[
                  Tooltip(
                    message: 'Close',
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          filterActive = false;
                          searchActive = false;
                          searched = false;
                          filterProductInventoryList.clear();
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(jsonDataByImeiNo.length, (int index) {
                final String item = jsonDataByImeiNo[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                      searched = true;
                      fetchFilterData(null, null, item);
                    });
                  },
                );
              });
            },
          ),
        ) : searchedChipName == ''? const SizedBox() : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Chip(
                  backgroundColor: Colors.yellow,
                  label: Text('filtered By $searchedChipName'),
                  onDeleted: (){
                    setState(() {
                      searchedChipName = '';
                      filterActive = false;
                      searched = false;
                      filterProductInventoryList.clear();
                    });
                  }),
            ),
          ],
        ),
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
    return filterActive ? Container() : Container(
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
            const Text('Total Category', style: TextStyle(fontSize: 13)),
            Text('$totalCategory',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const Text("Total Products", style: TextStyle(fontSize: 13)),
            Text('$totalModel', style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const Text("Out of stock", style: TextStyle(fontSize: 13)),
            Text('$outOfStockModel',style: TextStyle(fontSize: 17)),
          ],),
          Column(children: [
            const Text("Total Items", style: TextStyle(fontSize: 13)),
            Text('$totalProduct', style: const TextStyle(fontSize: 17)),
          ],),
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${(currentSet - 1) * batchSize + 1} to ${currentSet * batchSize > totalProduct ? totalProduct : currentSet * batchSize}  of  $totalProduct'),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Previous page', onPressed: isPreviousButtonEnabled ? () => _onPreviousButtonPressed() : null , icon: const Icon(Icons.arrow_left)),
                const SizedBox(width: 5,),
                IconButton(tooltip:'Next page', onPressed: isNextButtonEnabled ? () => _onNextButtonPressed() : null , icon: const Icon(Icons.arrow_right)),
                const SizedBox(width: 10,),
                IconButton(tooltip:'Settings',onPressed:() {}, icon: const Icon(Icons.settings_outlined))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNextButtonPressed() {
    getProductList(currentSet = currentSet+1, batchSize);

  }

  void _onPreviousButtonPressed() {
    getProductList(currentSet = currentSet-1, batchSize);
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}
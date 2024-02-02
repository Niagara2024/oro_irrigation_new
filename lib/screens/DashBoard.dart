import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Forms/create_account.dart';
import 'package:oro_irrigation_new/screens/product_inventory.dart';
import 'package:oro_irrigation_new/screens/web_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Customer/Dashboard/DashboardNode.dart';
import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'Customer/Dashboard/SentAndReceived.dart';
import 'Customer/Dashboard/FarmSettings.dart';
import 'Customer/customer_home.dart';
import 'my_preference.dart';
import 'product_entry.dart';
import 'AdminDealerHomePage.dart';
import 'login_form.dart';


String appBarTitle = 'Home';
get formKey => null;
TextEditingController dateCtl = TextEditingController();
String selectedCategory = '';

enum Calendar { day, week, month, year }

class MainDashBoard extends StatelessWidget
{
  const MainDashBoard({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      routes: {
        '/': (context) => const DashBoardMain(),
        '/login': (context) => const LoginForm(),
      },
    );
  }
}


class DashBoardMain extends StatefulWidget
{
  const DashBoardMain({super.key});

  @override
  DashBoardMainState createState() => DashBoardMainState();
}

class DashBoardMainState extends State<DashBoardMain> with TickerProviderStateMixin
{
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  get formKey => null;
  String selectedCategory = '';
  String appBarTitle = 'Home';
  int userID = 0;
  String userName = '', userType = '', userCountryCode = '', userMobileNo = '';
  final List<Map> myProducts =  List.generate(5, (index) => {"id": index, "name": "Product $index"}).toList();

  late MqttPayloadProvider payloadProvider;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
    manager = MQTTManager();
    _executeSharedPreferences();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      mqttConfigureAndConnect();
    });
  }


  Future _executeSharedPreferences() async
  {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = (prefs.getString('userName') ?? "");
      userType = (prefs.getString('userType') ?? "");
      userCountryCode = (prefs.getString('countryCode') ?? "");
      userMobileNo = (prefs.getString('mobileNumber') ?? "");
      userID = int.parse(prefs.getString('userId') ?? "");
    });
  }

  void mqttConfigureAndConnect() {
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  @override
  Widget build(BuildContext context)
  {
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints)
        {
          if (constraints.maxWidth < 600) {
            return const DashboardNarrow();//mobile
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const DashboardMiddle();//pad or tap
          } else {
            return DashboardWide(userName: userName, userType: userType, countryCode: userCountryCode, mobileNo: userMobileNo, userID: userID, screenWidth: MediaQuery.sizeOf(context).width,);//desktop or web
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}



//Narrow-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardNarrow extends StatefulWidget {
  const DashboardNarrow({Key? key}) : super(key: key);
  @override
  State<DashboardNarrow> createState() => _DashboardNarrowState();
}

class _DashboardNarrowState extends State<DashboardNarrow> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Middle-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardMiddle extends StatefulWidget {
  const DashboardMiddle({Key? key}) : super(key: key);
  @override
  State<DashboardMiddle> createState() => _DashboardMiddleState();
}

class _DashboardMiddleState extends State<DashboardMiddle> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Wide-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardWide extends StatefulWidget
{
  const DashboardWide({Key? key, required this.userName, required this.userType, required this.countryCode,  required this.mobileNo, required this.userID, required this.screenWidth}) : super(key: key);
  final String userType, userName, countryCode, mobileNo;
  final int userID;
  final double screenWidth;

  @override
  State<DashboardWide> createState() => _DashboardWideState();
}

class _DashboardWideState extends State<DashboardWide> {

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;
  Calendar calendarView = Calendar.day;
  late Widget _centerWidget;
  String currentTap = 'Dashboard';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomerSite();
  }

  Future<void> getCustomerSite() async
  {
    _centerWidget = Center(child: Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth/2 - 150),
      child: const LoadingIndicator(
        indicatorType: Indicator.ballPulse,
      ),
    ));
    callCustomerDashboard();
  }

  Future<void> callCustomerDashboard()  async {
    await Future.delayed(const Duration(seconds: 3));
    if(widget.userType =='3'){
      onOptionSelected('Dashboard');
    }
  }

  void onOptionSelected(String option) {
    currentTap = option;
    setState(() {
      if (option == 'Dashboard') {
        _centerWidget = CustomerHome(customerID: widget.userID, type: 0, customerName: widget.userName, userID: widget.userID, mobileNo: '+${widget.countryCode}-${widget.mobileNo}',);
      } else if (option == 'My Product') {
        _centerWidget = ProductInventory(userName: widget.userName);
      } else if (option == 'Device Settings') {
        _centerWidget = FarmSettings(customerID: widget.userID, siteList: [],);
      }
      else if (option == 'Sent And Received') {
        _centerWidget = SentAndReceived(customerID: widget.userID, siteList: [],);
      }
    });
  }

  @override
  Widget build(BuildContext context)  {
    //var appState = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.1),
      appBar: widget.userType =='3'? AppBar(
        leading: const Image(image: AssetImage("assets/images/niagara_logo.png")),
        leadingWidth: 200,
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('+${widget.countryCode} ${widget.mobileNo}', style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.white)),
                ],
              ),
              const SizedBox(width: 05),
              const CircleAvatar(
                radius: 23,
                backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
              ),
            ],),
          const SizedBox(width: 10)
        ],
      ) : null,
      body: widget.userType =='3'? Stack(
        children: [
          MyDrawer(
            userName: widget.userName, countryCode: widget.countryCode, phoneNo: widget.mobileNo, onOptionSelected: onOptionSelected, currentTap: currentTap,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 241.0),
            child: Container(
                color: Colors.white,
                child: _centerWidget
            ),
          ),
        ],
      ):
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.white,
            labelType: NavigationRailLabelType.all,
            indicatorColor: myTheme.primaryColor,
            indicatorShape: const CircleBorder(eccentricity: 0.3),
            //unselectedIconTheme: const IconThemeData(color: Colors.grey),
            elevation: 5,
            leading: const Column(
              children: [
                Image(image: AssetImage("assets/images/company_logo.png"), height: 60,),
                SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout, color: Colors.redAccent,),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      await prefs.remove('userName');
                      await prefs.remove('countryCode');
                      await prefs.remove('mobileNumber');
                      await prefs.remove('subscribeTopic');
                      if (mounted){
                        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                      }
                    },
                  ),
                ),
              ),
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                if(_selectedIndex==0){
                  appBarTitle = 'Home';
                }else if(_selectedIndex==1){
                  appBarTitle = 'Product';
                }else{
                  appBarTitle = 'My Preference';
                }
              });
            },
            destinations: widget.userType == '1'? <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.topic_outlined),
                selectedIcon: Icon(Icons.topic_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Colors.white,),
                label: Text(''),
              ),
            ]:
            <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list, color: Colors.white),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Colors.white,),
                label: Text(''),
              ),
            ],
          ),
          Expanded(
            child: widget.userType == '1'?
            _selectedIndex == 0 ? AdminDealerHomePage(userName: widget.userName, countryCode: widget.countryCode, mobileNo: widget.mobileNo, fromLogin: true, userId: 0, userType: 0,) :
            _selectedIndex == 1 ? ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? const AllEntry():
            _selectedIndex == 2 ? const MyPreference(userID: 1,) : const MyWebView() :

            _selectedIndex == 0 ? AdminDealerHomePage(userName: widget.userName, countryCode: widget.countryCode, mobileNo: widget.mobileNo, fromLogin: true, userId: 0, userType: 0,) :
            _selectedIndex == 1 ? ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? const MyPreference(userID: 1,) : const MyWebView(),
          ),
        ],
      )
    );
  }
}

class MyDrawer extends StatelessWidget {
  final Function(String) onOptionSelected;
  const MyDrawer({super.key, required this.onOptionSelected, required this.userName, required this.countryCode, required this.phoneNo, required this.currentTap});
  final String userName, countryCode, phoneNo, currentTap;

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.sizeOf(context).height);
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(
                  color: Colors.black.withOpacity(0.2), // Adjust color as needed
                  width: 0.5, // Adjust thickness as needed
                ),
              ),
            ),
            child: SizedBox(
              width: 240.0,
              height: MediaQuery.sizeOf(context).height > 660 ? MediaQuery.sizeOf(context).height - 60 : 660,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                      child: Text('HOME', style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                    buildCustomListTile('Dashboard', Icons.dashboard_outlined, 'Dashboard'),
                    buildCustomListTile('My Product', Icons.topic_outlined, 'My Product'),
                    buildCustomListTile('Report Overview', Icons.my_library_books_outlined, 'Report Overview'),
                    buildCustomListTile('Sent And Received', Icons.question_answer_outlined, 'Sent And Received'),
                    buildCustomListTile('Controller Logs', Icons.message_outlined, 'Controller Logs'),
                    buildCustomListTile('Device Settings', Icons.settings_outlined, 'Device Settings'),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
                      child: Text('ORGANIZATION', style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                    buildCustomListTile('App Info', Icons.info_outline, 'App Info'),
                    buildCustomListTile('Help & Support', Icons.help_outline, 'Help & Support'),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
                      child: Text('ACCOUNT', style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                    buildCustomListTile('My Preference', Icons.settings_outlined, 'My Preference'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red,),
                        title: const Text('Logout', style: TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('userId');
                          await prefs.remove('userName');
                          await prefs.remove('countryCode');
                          await prefs.remove('mobileNumber');
                          await prefs.remove('subscribeTopic');
                          if (context.mounted){
                            Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomListTile(String title, IconData icon, String tapOption) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: currentTap == tapOption ? myTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(5)), // Adjust the radius as needed
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: currentTap == tapOption ? myTheme.primaryColor : Colors.black.withOpacity(0.6),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: currentTap == tapOption ? myTheme.primaryColor : Colors.black.withOpacity(0.8),
            ),
          ),
          onTap: () {
            onOptionSelected(tapOption);
          },
        ),
      ),
    );
  }
}

class CustomShapeBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,// Adjust bottom-right corner radius as needed
      ));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }
}
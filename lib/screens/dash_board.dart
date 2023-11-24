import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Forms/create_account.dart';
import 'package:oro_irrigation_new/screens/product_inventory.dart';
import 'package:oro_irrigation_new/screens/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/mqtt_web_client.dart';
import 'Customer/customer_home.dart';
import 'my_preference.dart';
import 'product_entry.dart';
import 'home_page.dart';
import 'login_form.dart';


String appBarTitle = 'Home';
get formKey => null;
TextEditingController dateCtl = TextEditingController();
String selectedCategory = '';

enum Calendar { day, week, month, year }

class DashBoard extends StatelessWidget
{
  const DashBoard({super.key});

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


  @override
  void initState() {
    super.initState();
    MqttWebClient().init();
    _executeSharedPreferences();
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

    Future.delayed(const Duration(milliseconds: 500), () async {
      MqttWebClient().onSubscribed('tweet/$userMobileNo');
    });

  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints)
        {
          if (constraints.maxWidth < 600) {
            return const DashboardNarrow();//mobile
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const DashboardMiddle();//pad or tap
          } else {
            return DashboardWide(userName: userName, userType: userType, countryCode: userCountryCode, mobileNo: userMobileNo, userID: userID,);//desktop or web
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
  const DashboardWide({Key? key, required this.userName, required this.userType, required this.countryCode,  required this.mobileNo, required this.userID}) : super(key: key);
  final String userType, userName, countryCode, mobileNo;
  final int userID;

  @override
  State<DashboardWide> createState() => _DashboardWideState();
}

class _DashboardWideState extends State<DashboardWide> {

  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;
  Calendar calendarView = Calendar.day;



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar:
      widget.userType =='1'?
      AppBar(
        title: Text (appBarTitle),
        actions: _selectedIndex==0?[
          IconButton(tooltip: 'Create customer account', icon: const Icon(Icons.person_add_outlined), color: Colors.white, onPressed: () async
          {
              await showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  content: CreateAccount(),
                ));

          }),
          const SizedBox(width: 20,),
          const Icon(Icons.notifications_none, color: Colors.white,),
          const SizedBox(width: 30,),
        ] :
        _selectedIndex==1? [
          ActionChip(
            tooltip: 'Create new Product',
            shape: const StadiumBorder(side: BorderSide()),
            avatar: const Icon(Icons.add_card, color: Colors.white),
            label: const Text('New Product', style: TextStyle(color: Colors.white),),
            backgroundColor: myTheme.primaryColor,
            elevation: 6.0,
            shadowColor: Colors.grey[60],
            padding: const EdgeInsets.all(5.0),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  const AllEntry()),);
            },
          ),
          const SizedBox(width: 20,),
        ] :
        [],
      ) :
      widget.userType =='2'?
      AppBar(
        title: Text (appBarTitle),
        actions: _selectedIndex==0?[
          IconButton(tooltip: 'Create customer account', icon: const Icon(Icons.person_add_outlined), color: Colors.white, onPressed: () async
          {
            await showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  content: CreateAccount(),
                ));

          }),
          const SizedBox(width: 20,),
          const Icon(Icons.notifications_none, color: Colors.white,),
          const SizedBox(width: 30,),
        ] : [
          const SizedBox(width: 20,),
        ],
      ) :
      AppBar(
        title: Text (appBarTitle),
        actions: _selectedIndex==0?[
          const Badge(
            label: Text('32'),
            child: Icon(Icons.notifications_none, color: Colors.white,),
          ),
          const SizedBox(width: 30,),
        ] : [
          const SizedBox(width: 20,),
        ],
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            indicatorColor: myTheme.primaryColor.withOpacity(0.1),
            minWidth: 125.0,
            selectedIndex: _selectedIndex,
            groupAlignment: groupAlignment,
            labelType: NavigationRailLabelType.all,
            leading: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 35,
                    //backgroundImage: AssetImage("assets/images/login_amico.png"),
                    backgroundColor: myTheme.primaryColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 3,),
                  Text(widget.userName, style: myTheme.textTheme.titleSmall,),
                  const SizedBox(height: 3,),
                  Text('+${widget.countryCode} ${widget.mobileNo}', style: myTheme.textTheme.titleSmall,),
                ],
              ),
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
            destinations: <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 10),
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF0D5D9A),),
                label: Text('Home'),
              ),
              widget.userType =='3'? const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group_outlined, color: Color(0xFF0D5D9A),),
                label: Text('Manage User'),
              ) :
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.add_chart),
                selectedIcon: Icon(Icons.add_chart, color: Color(0xFF0D5D9A),),
                label: Text('Product'),
              ),
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Color(0xFF0D5D9A),),
                label: Text('My Preference'),
              ),
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Color(0xFF0D5D9A),),
                label: Text('App Info'),
              ),
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5, bottom: 70),
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Color(0xFF0D5D9A),),
                label: Text('Help & Support'),
              ),
            ],
          ),
          Expanded(
            child: _selectedIndex == 0 ?
            widget.userType =='3'? CustomerHome(customerID: widget.userID,): const HomePage() :
            _selectedIndex == 1 ?
            ProductInventory(userName: widget.userName) :
            _selectedIndex == 2 ? const MyPreference(userID: 1,) : const MyWebView(),
          ),
        ],
      ),
    );
  }
}


/*class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDestination = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('widget.title'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Header',
                style: textTheme.headline6,
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Item 1'),
              selected: _selectedDestination == 0,
              onTap: () => selectDestination(0),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Item 2'),
              selected: _selectedDestination == 1,
              onTap: () => selectDestination(1),
            ),
            ListTile(
              leading: Icon(Icons.label),
              title: Text('Item 3'),
              selected: _selectedDestination == 2,
              onTap: () => selectDestination(2),
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Label',
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Item A'),
              selected: _selectedDestination == 3,
              onTap: () => selectDestination(3),
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        padding: EdgeInsets.all(20),
        childAspectRatio: 3 / 2,
        children: [
          Image.asset('assets/nav-drawer-1.jpg'),
          Image.asset('assets/nav-drawer-2.jpg'),
          Image.asset('assets/nav-drawer-3.jpg'),
          Image.asset('assets/nav-drawer-4.jpg'),
        ],
      ),
    );
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }
}*/

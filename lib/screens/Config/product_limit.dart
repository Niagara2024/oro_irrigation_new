import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../Models/product_limit.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/config_maker_provider.dart';
import 'config_maker/config_maker.dart';
import 'config_screen.dart';
import 'dealer_definition_config.dart';

class ProductLimits extends StatefulWidget {
  const ProductLimits({Key? key, required this.userID,  required this.customerID, required this.userType, required this.siteID, required this.nodeCount, required this.siteName, required this.userDeviceListId, required this.deviceId}) : super(key: key);
  final int userID, customerID, userType, siteID, nodeCount, userDeviceListId;
  final String siteName, deviceId;


  @override
  State<ProductLimits> createState() => _ProductLimitsState();
}

class _ProductLimitsState extends State<ProductLimits> {

  String userID = '0';
  String userType = '0';
  int filledRelayCount = 0;
  int currentTxtFldVal = 0;
  List<MdlProductLimit> productLimits = <MdlProductLimit>[];

  var myControllers = [];
  bool visibleLoading = false;

  int _currentStep = 0;
  late List<Step> _steps;

  @override
  void initState() {
    super.initState();
    getProductLimits();
  }

  @override
  void dispose() {
    print('dispose');

    for (var c in myControllers) {
      c.dispose();
    }

    /*if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
        configPvd.clearConfig();
      });
    }*/

    super.dispose();
  }

  Widget buildStepContent(BuildContext context, int stepNumber)
  {
    final mediaQuery = MediaQuery.of(context);

    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    configPvd.clearConfig();

    switch (stepNumber) {
      case 1:
        return visibleLoading? Center(
          child: Visibility(
            visible: visibleLoading,
            child: Container(
              padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 30, 0, mediaQuery.size.width/2 - 30, 0),
              child: const LoadingIndicator(
                indicatorType: Indicator.ballPulse,
              ),
            ),
          ),
        ) : Container(
          color:  Colors.blueGrey.shade50,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                          child: GridView.builder(
                            itemCount: productLimits.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsetsDirectional.all(5.0),
                                decoration:  BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: myTheme.primaryColor.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: const Offset(2, 2), // Shadow position
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded (
                                      flex:1,
                                      child : Container(
                                        constraints: const BoxConstraints.expand(),
                                        decoration: BoxDecoration(
                                          color: myTheme.primaryColor.withOpacity(0.2),
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircleAvatar(
                                            backgroundColor: myTheme.primaryColor.withOpacity(0.5),
                                            child: Icon(Icons.reset_tv, color: Colors.white,),
                                          ),
                                        ),
                                      ),),
                                    Expanded(
                                      flex :2,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: TextField(
                                              controller: myControllers[index],
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                labelText: productLimits[index].product,
                                              ),
                                              onTap: () {
                                                currentTxtFldVal = int.parse(myControllers[index].text);
                                                print(currentTxtFldVal);
                                              },
                                              onChanged: (input) async {
                                                await Future.delayed(const Duration(milliseconds: 50));
                                                setState(() {
                                                  String crTvVal = myControllers[index].text;
                                                  if (widget.nodeCount < filledRelayCount + int.parse(myControllers[index].text.isEmpty ? '0' : myControllers[index].text) - currentTxtFldVal) {
                                                    if (crTvVal.isNotEmpty) {
                                                      myControllers[index].text = crTvVal.substring(0, crTvVal.length - 1);
                                                    }
                                                    _showSnackBar('Limit reached');
                                                  } else {
                                                    filledRelayCount = myControllers.fold<int>(0,(sum, controller) => sum + (int.tryParse(controller.text) ?? 0),);
                                                  }

                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),)
                                  ],
                                ),
                              );
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                              childAspectRatio: mediaQuery.size.width / 460,
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Relay Total :'),
                    const SizedBox(width: 10,),
                    Text('${widget.nodeCount}', style: const TextStyle(fontSize: 17),),
                    const SizedBox(width: 20,),
                    const Text('Remaining :'),
                    const SizedBox(width: 10,),
                    Text('${widget.nodeCount - filledRelayCount}', style: const TextStyle(fontSize: 17),),
                    const SizedBox(width: 20,),
                    IconButton(
                        tooltip : 'Save changes',
                        onPressed: () async {
                          updateProductLimit();
                        },
                        icon: const Icon(Icons.save_as_outlined)),
                    const SizedBox(width: 10,),
                    IconButton(
                        tooltip : 'Config',
                        onPressed: () async {
                          if(filledRelayCount==0){
                            _showSnackBar('Product Limit empty');
                          }else{
                            configPvd.clearConfig();
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.siteName, siteID: widget.siteID, controllerId: widget.userDeviceListId, imeiNumber: widget.deviceId,)),);
                          }
                        },
                        icon: const Icon(Icons.account_tree_rounded)),
                    const SizedBox(width: 20,)
                  ],
                ),
              ),
            ],
          ),
        );
      case 2:
        return Column(
          children: [
            Text('This is the content of Step 2'),
            SizedBox(height: 10),
            FlutterLogo(size: 100),
          ],
        );
      case 3:
        return Text('This is the content of Step 3');
      default:
        return SizedBox.shrink();
    }
  }

  Future<void> getProductLimits() async
  {
    indicatorViewShow();
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic> body = {"userId" : widget.customerID, "controllerId" : widget.siteID};
    print(body);
    final response = await HttpService().postRequest("getUserProductLimit", body);
    if (response.statusCode == 200)
    {
      productLimits.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        myControllers = [];
        for (int i=0; i < cntList.length; i++) {
          productLimits.add(MdlProductLimit.fromJson(cntList[i]));
          myControllers.add(TextEditingController());
          myControllers[i].text = '${productLimits[i].quantity}';
          filledRelayCount = filledRelayCount + productLimits[i].quantity;

        }
      }
      setState(() {
        print('${filledRelayCount}');
        productLimits;
        indicatorViewHide();
      });

    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> updateProductLimit() async
  {
    for (int i=0; i < productLimits.length; i++) {
      productLimits[i].quantity = int.parse(myControllers[i].text);
    }

    Map<String, dynamic> body = {
      "userId": widget.customerID,
      "controllerId": widget.userDeviceListId,
      "productLimit": productLimits,
      "createUser": widget.userID,
    };
    final response = await HttpService().postRequest("createUserProductLimit", body);
    if(response.statusCode == 200)
    {
      var data = jsonDecode(response.body);
      if(data["code"]==200) {
        _showSnackBar(data["message"]);
      }
      else{
        _showSnackBar(data["message"]);
      }
    }
  }

  Future<void> getConfigData()  async {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserConfigMaker', {'userId' : widget.customerID, 'controllerId' : widget.siteID});
      var jsonData = jsonDecode(response.body);
      print('jsonData : ${jsonData['data']}');
      configPvd.fetchAll(jsonData['data']);
    }catch(e){
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context)
  {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteName),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        physics: const ScrollPhysics(),
        currentStep: _currentStep,
        connectorThickness: 2,
        connectorColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.white70;
          },
        ),
        elevation: 5.0,
        onStepTapped: (step) {
          setState(() => _currentStep = step);
        },
        onStepContinue: () {
          if(_currentStep==0){
            updateProductLimit();
            getConfigData();
          }else if(_currentStep == 2){
            //updateProductLimit();
          }
          _currentStep < 2 ? setState(() => _currentStep += 1) : null;
        },
        onStepCancel: () {
          _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
        },
        stepIconBuilder: (context, stepState) {
          if (stepState == StepState.editing) {
            return Icon(Icons.edit_outlined, color: myTheme.primaryColor); // Custom icon for completed step
          } else if (stepState == StepState.complete) {
            return const Icon(Icons.check, color: Colors.green); // Custom icon for disabled step
          } else {
            return const Icon(Icons.block, color: Colors.grey); // Custom icon for other steps
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
          return _currentStep==2 ? Container(height: 0) :
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 50,
                color: Colors.white,
                child: _currentStep==0? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Relay Total :'),
                    const SizedBox(width: 10,),
                    Text('${widget.nodeCount}', style: const TextStyle(fontSize: 17),),
                    const SizedBox(width: 20,),
                    const Text('Remaining :'),
                    const SizedBox(width: 10,),
                    Text('${widget.nodeCount - filledRelayCount}', style: const TextStyle(fontSize: 17),),
                    const SizedBox(width: 20,)
                  ],
                ) : null,
              ),
              _currentStep > 0 ? TextButton(
                onPressed: controlsDetails.onStepCancel,
                child: const Text('Cancel'),
              ) : const Text(''),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: controlsDetails.onStepContinue,
                label: _currentStep==2 ? const Text('Save') : const Text('Save & Continue'),
                icon: const Icon(
                  Icons.save_as_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Product Limit'),
            content: visibleLoading? Container(
              margin: const EdgeInsets.only(top: 0),
              height: mediaQuery.size.height-230,
              color:  Colors.white,
              child: Center(
                child: Visibility(
                  visible: visibleLoading,
                  child: Container(
                    height: mediaQuery.size.height,
                    padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 50, 0, mediaQuery.size.width/2 - 50, 0),
                    child: const LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                    ),
                  ),
                ),
              ),
            ) : Container(
              height: mediaQuery.size.height-230,
              color:  Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: GridView.builder(
                              itemCount: productLimits.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsetsDirectional.all(5.0),
                                  decoration:  BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black38, // Border color
                                      width: 1.0,          // Border width
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded (
                                        flex:1,
                                        child : Container(
                                          constraints: const BoxConstraints.expand(),
                                          decoration: BoxDecoration(
                                            color: myTheme.primaryColor.withOpacity(0.2),
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundColor: myTheme.primaryColor.withOpacity(0.5),
                                              child: const Icon(Icons.reset_tv, color: Colors.white,),
                                            ),
                                          ),
                                        ),),
                                      Expanded(
                                        flex :2,
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: TextField(
                                                controller: myControllers[index],
                                                keyboardType: TextInputType.number,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                  labelText: productLimits[index].product,
                                                ),
                                                onTap: () {
                                                  currentTxtFldVal = int.parse(myControllers[index].text);
                                                  print(currentTxtFldVal);
                                                },
                                                onChanged: (input) async {
                                                  await Future.delayed(const Duration(milliseconds: 50));
                                                  setState(() {
                                                    String crTvVal = myControllers[index].text;
                                                    if (widget.nodeCount < filledRelayCount + int.parse(myControllers[index].text.isEmpty ? '0' : myControllers[index].text) - currentTxtFldVal) {
                                                      if (crTvVal.isNotEmpty) {
                                                        myControllers[index].text = crTvVal.substring(0, crTvVal.length - 1);
                                                      }
                                                      _showSnackBar('Limit reached');
                                                    } else {
                                                      filledRelayCount = myControllers.fold<int>(0,(sum, controller) => sum + (int.tryParse(controller.text) ?? 0),);
                                                    }

                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),)
                                    ],
                                  ),
                                );
                              },
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                                childAspectRatio: mediaQuery.size.width / 460,
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep == 0 ? StepState.editing : _currentStep >= 1 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: const Text('Config maker'),
            content: Container(
              height: mediaQuery.size.height-230,
              color:  Colors.white,
              child: ConfigMakerScreen(userID: widget.userID, customerID: widget.customerID, siteID: widget.userDeviceListId, imeiNumber: widget.deviceId,),
            ),
            isActive: _currentStep >= 0,
            state:  _currentStep == 1 ? StepState.editing : _currentStep >= 2 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: const Text('Others'),
            content: Container(
              height: mediaQuery.size.height-176,
              color:  Colors.white,
              child: ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.siteName, siteID: widget.siteID, controllerId: widget.userDeviceListId, imeiNumber: widget.deviceId,),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 2? StepState.editing : StepState.disabled,
          ),
        ],
      ),
    );
  }

 /* @override
  Widget build(BuildContext context)
  {
    final mediaQuery = MediaQuery.of(context);
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteName),
      ),
      body : LayoutBuilder(
        builder: (context, constraints) {
          return Stepper(
            type: StepperType.horizontal,
            physics: const ScrollPhysics(),
            currentStep: _currentStep,
            connectorThickness: 3,
            steps: [
              Step(
                title: const Text('Product Limit'),
                content: visibleLoading? Center(
                  child: Visibility(
                    visible: visibleLoading,
                    child: Container(
                      height: mediaQuery.size.height,
                      padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 50, 0, mediaQuery.size.width/2 - 50, 0),
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                      ),
                    ),
                  ),
                ) : Container(
                  height: mediaQuery.size.height-240,
                  color:  Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                                child: GridView.builder(
                                  itemCount: productLimits.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsetsDirectional.all(5.0),
                                      decoration:  BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: myTheme.primaryColor.withOpacity(0.5),
                                            blurRadius: 2,
                                            offset: const Offset(2, 2), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded (
                                            flex:1,
                                            child : Container(
                                              constraints: const BoxConstraints.expand(),
                                              decoration: BoxDecoration(
                                                color: myTheme.primaryColor.withOpacity(0.2),
                                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: CircleAvatar(
                                                  backgroundColor: myTheme.primaryColor.withOpacity(0.5),
                                                  child: Icon(Icons.reset_tv, color: Colors.white,),
                                                ),
                                              ),
                                            ),),
                                          Expanded(
                                            flex :2,
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                  child: TextField(
                                                    controller: myControllers[index],
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.digitsOnly
                                                    ],
                                                    decoration: InputDecoration(
                                                      labelText: productLimits[index].product,
                                                    ),
                                                    onTap: () {
                                                      currentTxtFldVal = int.parse(myControllers[index].text);
                                                      print(currentTxtFldVal);
                                                    },
                                                    onChanged: (input) async {
                                                      await Future.delayed(const Duration(milliseconds: 50));
                                                      setState(() {
                                                        String crTvVal = myControllers[index].text;
                                                        if (widget.nodeCount < filledRelayCount + int.parse(myControllers[index].text.isEmpty ? '0' : myControllers[index].text) - currentTxtFldVal) {
                                                          if (crTvVal.isNotEmpty) {
                                                            myControllers[index].text = crTvVal.substring(0, crTvVal.length - 1);
                                                          }
                                                          _showSnackBar('Limit reached');
                                                        } else {
                                                          filledRelayCount = myControllers.fold<int>(0,(sum, controller) => sum + (int.tryParse(controller.text) ?? 0),);
                                                        }

                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),)
                                        ],
                                      ),
                                    );
                                  },
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                                    childAspectRatio: mediaQuery.size.width / 460,
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 60,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Relay Total :'),
                            const SizedBox(width: 10,),
                            Text('${widget.nodeCount}', style: const TextStyle(fontSize: 17),),
                            const SizedBox(width: 20,),
                            const Text('Remaining :'),
                            const SizedBox(width: 10,),
                            Text('${widget.nodeCount - filledRelayCount}', style: const TextStyle(fontSize: 17),),
                            const SizedBox(width: 20,),
                            IconButton(
                                tooltip : 'Save changes',
                                onPressed: () async {
                                  updateProductLimit();
                                },
                                icon: const Icon(Icons.save_as_outlined)),
                            const SizedBox(width: 10,),
                            IconButton(
                                tooltip : 'Config',
                                onPressed: () async {
                                  if(filledRelayCount==0){
                                    _showSnackBar('Product Limit empty');
                                  }else{
                                    configPvd.clearConfig();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.siteName, siteID: widget.siteID, controllerId: widget.userDeviceListId, imeiNumber: widget.deviceId,)),);
                                  }
                                },
                                icon: const Icon(Icons.account_tree_rounded)),
                            const SizedBox(width: 20,)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
                state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Config maker'),
                content: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'You mobile number'),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
              ),
              Step(
                title: const Text('Others'),
                content: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Verification code'),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep >= 2? StepState.complete : StepState.disabled,
              ),
            ],
            onStepTapped: (step) {
              setState(() => _currentStep = step);
            },
            onStepContinue: () {
              _currentStep < 2 ? setState(() => _currentStep += 1) : null;
            },
            onStepCancel: () {
              _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
            },

          );
        },
      )

    );
  }*/


/*
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.siteName} - Product Limit'),
      ),
      body: visibleLoading? Center(
        child: Visibility(
          visible: visibleLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 30, 0, mediaQuery.size.width/2 - 30, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      ) : Container(
        color:  Colors.blueGrey.shade50,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                        child: GridView.builder(
                          itemCount: productLimits.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsetsDirectional.all(5.0),
                              decoration:  BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: myTheme.primaryColor.withOpacity(0.5),
                                    blurRadius: 2,
                                    offset: const Offset(2, 2), // Shadow position
                                  ),
                                ],
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded (
                                    flex:1,
                                    child : Container(
                                      constraints: const BoxConstraints.expand(),
                                      decoration: BoxDecoration(
                                        color: myTheme.primaryColor.withOpacity(0.2),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          backgroundColor: myTheme.primaryColor.withOpacity(0.5),
                                          child: Icon(Icons.reset_tv, color: Colors.white,),
                                        ),
                                      ),
                                    ),),
                                  Expanded(
                                    flex :2,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: TextField(
                                            controller: myControllers[index],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              labelText: productLimits[index].product,
                                            ),
                                            onTap: () {
                                              currentTxtFldVal = int.parse(myControllers[index].text);
                                              print(currentTxtFldVal);
                                            },
                                            onChanged: (input) async {
                                              await Future.delayed(const Duration(milliseconds: 50));
                                              setState(() {
                                                String crTvVal = myControllers[index].text;
                                                if (widget.nodeCount < filledRelayCount + int.parse(myControllers[index].text.isEmpty ? '0' : myControllers[index].text) - currentTxtFldVal) {
                                                  if (crTvVal.isNotEmpty) {
                                                    myControllers[index].text = crTvVal.substring(0, crTvVal.length - 1);
                                                  }
                                                  _showSnackBar('Limit reached');
                                                } else {
                                                  filledRelayCount = myControllers.fold<int>(0,(sum, controller) => sum + (int.tryParse(controller.text) ?? 0),);
                                                }

                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),)
                                ],
                              ),
                            );
                          },
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                            childAspectRatio: mediaQuery.size.width / 460,
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Relay Total :'),
                  const SizedBox(width: 10,),
                  Text('${widget.nodeCount}', style: const TextStyle(fontSize: 17),),
                  const SizedBox(width: 20,),
                  const Text('Remaining :'),
                  const SizedBox(width: 10,),
                  Text('${widget.nodeCount - filledRelayCount}', style: const TextStyle(fontSize: 17),),
                  const SizedBox(width: 20,),
                  IconButton(
                      tooltip : 'Save changes',
                      onPressed: () async {
                        updateProductLimit();
                      },
                      icon: const Icon(Icons.save_as_outlined)),
                  const SizedBox(width: 10,),
                  IconButton(
                      tooltip : 'Config',
                      onPressed: () async {
                        if(filledRelayCount==0){
                          _showSnackBar('Product Limit empty');
                        }else{
                          configPvd.clearConfig();
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.siteName, siteID: widget.siteID, controllerId: widget.userDeviceListId, imeiNumber: widget.deviceId,)),);
                        }
                      },
                      icon: const Icon(Icons.account_tree_rounded)),
                  const SizedBox(width: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }*/

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
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

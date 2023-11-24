import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/http_service.dart';
import 'dash_board.dart';

TextEditingController _mobileNoController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
bool _isObscure = true;
bool _isLoginWithPassword = true;
bool isValid = false;
bool visibleLoading = false;
bool _validate = false;

String strTitle = 'ORO DRIP IRRIGATION';
String strSubTitle = 'Drip irrigation is a type of watering system used in agriculture, gardening, and landscaping to efficiently deliver water directly to the roots of plants.';
String strOtpText = 'We will send you an OPT(One Time password) to the entered customer mobile number';

class LoginForm extends StatelessWidget
{
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      routes: {
        '/': (context) => const Scaffold(body: MyStatefulWidget(),),
        '/dashboard': (context) => const DashBoard(),
      },
    );
  }
}

class MyStatefulWidget extends StatefulWidget
{
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints)
          {
            if (constraints.maxWidth < 600) {
              return const NarrowLayout();//mobile
            } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
              return const MiddleLayout();//pad or tap
            } else {
              return const WideLayout();//desktop or web
            }
          },
        ),
    );
  }
}

class NarrowLayout extends StatelessWidget {
  const NarrowLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NarrowOtpView();
  }
}

class MiddleLayout extends StatelessWidget {
  const MiddleLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OTPViewWide();
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OTPViewWide();
  }
}

class NarrowOtpView extends StatefulWidget {
  const NarrowOtpView({Key? key}) : super(key: key);
  @override
  State<NarrowOtpView> createState() => _NarrowOtpViewState();
}

class _NarrowOtpViewState extends State<NarrowOtpView> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: width-20,
                height: 500,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 170, child: Image.asset('assets/images/login_illustrator.png', height: 170, width: 170,),),
                            Text(strTitle, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 5,),
                            Text(strSubTitle, style: Theme.of(context).textTheme.bodySmall,),
                            const SizedBox(height: 20,),
                            SizedBox(height: 50,
                              child: InternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber number) {
                                  print(number.phoneNumber);
                                },
                                selectorConfig: const SelectorConfig(
                                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                  setSelectorButtonAsPrefixIcon: true,
                                  leadingPadding: 10,
                                  useEmoji: false,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle: const TextStyle(color: Colors.black),
                                initialValue: PhoneNumber(isoCode: 'IN'),

                                textFieldController: _mobileNoController,
                                formatInput: false,
                                keyboardType:
                                const TextInputType.numberWithOptions(signed: true, decimal: true),
                                onSaved: (PhoneNumber number) {
                                  //print('On Saved: $number');
                                },
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Text(strOtpText, style: Theme.of(context).textTheme.bodySmall,),
                            const SizedBox(height: 30,),
                            SizedBox(
                              width: 150.0,
                              height: 40.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: myTheme.primaryColor,
                                    onPrimary: Colors.white
                                ),
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (mounted){
                                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
                                  }

                                  /* Map<String, String> body = {
                                                    'mobileCountryCode': '91',
                                                    'mobileNumber': '9698852733',
                                                    'password': '123456',
                                                    'language': '1',
                                                    'deviceToken': 'e1d7a1c3fd19061c554frtrtr44',
                                                    'macAddress': 'e1d7a1c3fd19061c'
                                                  };

                                                  final response = await HttpService().postRequest("getUser", body);
                                                  print(response);

                                                  final response2 = await HttpService().putRequest("updateUser", body);
                                                  print(response2);*/

                                },
                                child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ), //Padding
              ), //Card
            ),
          ),
        ],
      ),
    );
  }
}


class OTPViewWide extends StatefulWidget {
  const OTPViewWide({Key? key}) : super(key: key);
  @override
  State<OTPViewWide> createState() => _OTPViewWideState();
}

class _OTPViewWideState extends State<OTPViewWide>
{
  @override
  Widget build(BuildContext context)
  {
    double width = MediaQuery.of(context).size.width;
    if(_isLoginWithPassword){
      return loginWithPassword(width);
    }
    return loginWithOTP(width);
  }

  Widget loginWithOTP(double width)
  {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: width,
              child: Center(
                child: Card(
                  elevation: 50,
                  shadowColor: Color(0xFF0D5D9A),
                  color: Color(0xFF0D5D9A),
                  child: SizedBox(
                    width: 400,
                    height: 450,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              padding: const EdgeInsets.only(top: 5, right: 10, left: 10, bottom: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 170, child: Image.asset('assets/images/login_illustrator.png', height: 170, width: 170,),),
                                  Text(strTitle, style: myTheme.textTheme.titleLarge),
                                  const SizedBox(height: 5,),
                                  Text(strSubTitle, style: myTheme.textTheme.titleSmall),
                                  const SizedBox(height: 10,),
                                  SizedBox(height: 50,
                                    child: InternationalPhoneNumberInput(
                                      onInputChanged: (PhoneNumber number) {
                                        //print(number.phoneNumber);
                                      },
                                      selectorConfig: const SelectorConfig(
                                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                        setSelectorButtonAsPrefixIcon: true,
                                        leadingPadding: 10,
                                        useEmoji: true,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode: AutovalidateMode.disabled,
                                      selectorTextStyle: myTheme.textTheme.titleMedium,
                                      initialValue: PhoneNumber(isoCode: 'IN'),

                                      textFieldController: _mobileNoController,
                                      formatInput: false,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      onSaved: (PhoneNumber number) {
                                        //print('On Saved: $number');
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(strOtpText, style: myTheme.textTheme.titleSmall),
                                  const SizedBox(height: 20,),
                                  SizedBox(
                                    width: 150.0,
                                    height: 40.0,
                                    child: TextButton(
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        if (mounted){
                                          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
                                        }
                                      },
                                      child: Text('CONTINUE'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox
                ), //Card
              ),
            ),
          ),
          SizedBox(
              height: 40,
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ⓒ Powerd by Niagara Automation", style: myTheme.textTheme.titleSmall),
                    Text("Version : 1.0.1", style: myTheme.textTheme.titleSmall),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget loginWithPassword(double width)
  {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: width,
              child: Center(
                child: Card(
                  elevation: 50,
                  shadowColor: Color(0xFF0D5D9A),
                  color: Color(0xFF0D5D9A),
                  child: SizedBox(
                    width: 400,
                    height: 550,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              padding: const EdgeInsets.only(top: 5, right: 10, left: 10, bottom: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 170, child: Image.asset('assets/images/login_illustrator.png', height: 170, width: 170,),),
                                  Text(strTitle, style: myTheme.textTheme.titleLarge),
                                  const SizedBox(height: 2,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                    child: Text(strSubTitle, style: myTheme.textTheme.titleSmall,),
                                  ),
                                  const SizedBox(height: 15,),
                                  SizedBox(height: 50,
                                    child: InternationalPhoneNumberInput(
                                      inputDecoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        icon: const Icon(Icons.phone_outlined),
                                        labelText: 'Phone Number',
                                        suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.red,),
                                            onPressed: () {
                                              _mobileNoController.clear();
                                            }),
                                      ),
                                      onInputChanged: (PhoneNumber number) {
                                        print(number);
                                      },
                                      selectorConfig: const SelectorConfig(
                                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                        setSelectorButtonAsPrefixIcon: true,
                                        leadingPadding: 10,
                                        useEmoji: true,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode: AutovalidateMode.disabled,
                                      selectorTextStyle: myTheme.textTheme.titleMedium,
                                      initialValue: PhoneNumber(isoCode: 'IN'),
                                      textFieldController: _mobileNoController,
                                      formatInput: false,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      onSaved: (PhoneNumber number) {
                                        print('On Saved: $number');
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _isObscure,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      border: const OutlineInputBorder(),
                                      icon: const Icon(Icons.lock_outline),
                                      labelText: 'Password',
                                      suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          }),

                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                      height: 30,
                                      width: width,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 2, left: 40),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text("Forgot Password ?", style: myTheme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      )
                                  ),
                                  const SizedBox(height: 15,),
                                  SizedBox(
                                    width: 150.0,
                                    height: 40.0,
                                    child: TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          _mobileNoController.text.isEmpty ||_passwordController.text.isEmpty ? _showSnackBar('Value Can\'t Be Empty') :
                                          _mobileNoController.text.length < 6 || _passwordController.text.length < 5 ? _showSnackBar('Invalid Mobile number or Password') : _validate = true;
                                        });

                                        if(_validate)
                                        {
                                          Map<String, Object> body = {
                                            'mobileNumber': _mobileNoController.text,
                                            'password': _passwordController.text,
                                          };
                                          final response = await HttpService().postRequest("userSignIn", body);
                                          print(response.body);
                                          if(response.statusCode == 200)
                                          {
                                            var data = jsonDecode(response.body);
                                            if(data["code"]==200)
                                            {
                                              _mobileNoController.clear();
                                              _passwordController.clear();

                                              final userDetails = data["data"];
                                              final regDetails = userDetails["user"];

                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('userType', regDetails["userType"].toString());
                                              await prefs.setString('userName', regDetails["userName"].toString());
                                              await prefs.setString('userId', regDetails["userId"].toString());
                                              await prefs.setString('countryCode', regDetails["countryCode"].toString());
                                              await prefs.setString('mobileNumber', regDetails["mobileNumber"].toString());
                                              await prefs.setString('password', regDetails["password"].toString());
                                              await prefs.setString('email', regDetails["email"].toString());

                                             if (mounted){
                                                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
                                              }
                                            }
                                            else{
                                              _showSnackBar(data["message"]);
                                            }
                                          }
                                        }
                                      },
                                      child: const Text('CONTINUE'),
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: 'or Login with ', style: myTheme.textTheme.titleSmall),
                                        TextSpan(text: 'OTP', style: myTheme.textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ), //Column
                    ), //Padding
                  ), //SizedBox
                ), //Card
              ),
            ),
          ),
          SizedBox(
              height: 40,
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("  ⓒ Powerd by Niagara Automation", style: myTheme.textTheme.titleSmall),
                    Text("Version : 1.0.1  ", style: myTheme.textTheme.titleSmall),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relaxretail/Comoon/Loader.dart';
import 'package:relaxretail/Screens/HomePage.dart';
import 'package:relaxretail/Screens/Report.dart';
import 'package:relaxretail/Services/Authentication.dart';
import 'package:relaxretail/Theme.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController userName = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscureText = true;
  bool showError = false;

  @override
  void initState() {
    mobileNumber.text = "1234567890";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Image.asset(
                    "assets/images/Earthgenix Logo R.PNG",
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 26),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      controller: userName,
                      decoration: InputDecoration(
                          labelText: "User Name",
                          labelStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: showError && userName.text.isEmpty
                                      ? Colors.red
                                      : Colors.black))),
                    ),
                  ),
                  showError && userName.text.isEmpty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: const Text(
                              "Please enter username",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: mobileNumber,
                      decoration: InputDecoration(
                          labelText: "Mobile Number",
                          labelStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: showError && mobileNumber.text.isEmpty
                                      ? Colors.red
                                      : Colors.black))),
                    ),
                  ),
                  showError && mobileNumber.text.isEmpty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: const Text(
                              "Please enter mobile number.",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      controller: password,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: showError && userName.text.isEmpty
                                      ? Colors.red
                                      : Colors.black)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          )),
                    ),
                  ),
                  showError && password.text.isEmpty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: const Text(
                              "Please enter password.",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: const Text("FORGOT PASSWORD?"),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor)),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        setState(() {
                          showError = false;
                        });
                        if (userName.text.isNotEmpty &&
                            mobileNumber.text.isNotEmpty &&
                            password.text.isNotEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const Loader();
                              });
                          authenticate(userName.text, mobileNumber.text,
                                  password.text)
                              .then((value) {
                            Navigator.pop(context);
                            if (value != null && value['response'] == true) {
                              if(value['data']['roleCode'] == "ADM" || value['data']['roleCode'] == "MIS"){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Report(
                                            userId: value['data']['id'],
                                            role: value['data']['roleCode'],
                                          )));
                              }else{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage(
                                            userId: value['data']['id'],
                                            role: value['data']['roleCode'],
                                          )));
                              }
                            }
                          });
                        } else {
                          setState(() {
                            showError = true;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              // Positioned(
              //   bottom: 5,
              //   child: Container(
              //     width: MediaQuery.of(context).size.width * 1,
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: <Widget>[
              //         const Text(
              //           "Developed By",
              //           style: TextStyle(
              //             fontSize: 12,
              //               color: Colors.black, fontWeight: FontWeight.w600),
              //         ),
              //         const SizedBox(
              //           height: 10,
              //         ),
              //         Image.asset(
              //           "assets/images/company logo.png",
              //           width: MediaQuery.of(context).size.width * 0.3,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

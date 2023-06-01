import "package:chat_app/pages/auth/register_page.dart";
import "package:chat_app/service/auth_service.dart";
import "package:chat_app/service/database_service.dart";
import "package:chat_app/widgets/widgets.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "../../helper/helper_functions.dart";
import "../home_page.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Chat App",
                          style: TextStyle(
                              color: Color(0xFFEEEEEE),
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Login now and join the conversation!",
                          style: TextStyle(
                            color: Color(0xFFEEEEEE),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Image.asset("assets/login.png"),
                        TextFormField(
                          style: const TextStyle(color: Color(0xFFEEEEEE)),
                          decoration: textInputDecoration.copyWith(
                            labelText: "Email",
                            labelStyle:
                                const TextStyle(color: Color(0xFFEEEEEE)),
                            prefixIcon: const Icon(Icons.email,
                                color: Color(0xFFEEEEEE)),
                          ),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter a valid email";
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          style: const TextStyle(color: Color(0xFFEEEEEE)),
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                            labelText: "Password",
                            labelStyle:
                                const TextStyle(color: Color(0xFFEEEEEE)),
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFFEEEEEE)),
                          ),
                          validator: (val) {
                            return RegExp(
                                        r"^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-zA-Z]).{8,}$")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter a valid password (1 upercase, 1 number, 8 characters)";
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                  color: Color(0xFF393E46),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                            text: "Don't have an account? ",
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Register here",
                                  style: const TextStyle(
                                      color: Color(0xFFEEEEEE),
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreenReplace(
                                          context, const RegisterPage());
                                    }),
                            ],
                            style: const TextStyle(
                                color: Color(0xFFEEEEEE), fontSize: 14)))
                      ],
                    )),
              ),
            ),
      backgroundColor: const Color(0xFF393E46),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.loginUser(email, password).then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(email);
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(
            snapshot.docs[0].get("fullName"),
          );

          nextScreenReplace(context, HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}

import "package:chat_app/pages/auth/login_page.dart";
import "package:chat_app/pages/home_page.dart";
import "package:chat_app/service/auth_service.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "../../helper/helper_functions.dart";
import "../../widgets/widgets.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
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
                          "ChatApp",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEEEEEE)),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Create your account now and start chatting!",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFEEEEEE)),
                        ),
                        Image.asset("assets/register.png"),
                        TextFormField(
                          style: const TextStyle(color: Color(0xFFEEEEEE)),
                          decoration: textInputDecoration.copyWith(
                            labelText: "Full Name",
                            labelStyle:
                                const TextStyle(color: Color(0xFFEEEEEE)),
                            prefixIcon: const Icon(Icons.person,
                                color: Color(0xFFEEEEEE)),
                          ),
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Name cannot be empty";
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              fullName = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
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
                              "Register",
                              style: TextStyle(
                                  color: Color(0xFF393E46),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                            text: "Already have an account? ",
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Login here",
                                  style: const TextStyle(
                                      color: Color(0xFFEEEEEE),
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreenReplace(
                                          context, const LoginPage());
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

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUser(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../material/custom.dart';
import '../../model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;
  bool rememberMe = false;

  @override
  void initState() {
    loadRememberMe();
    super.initState();
  }

  void loadRememberMe() async {
    final nav = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('username')!.isNotEmpty) {
      User.username = prefs.getString('username')!;
      User.role = prefs.getString('role')!;
      User.linkImage = prefs.getString('linkImage')!;
      if (User.role == "Manager") {
        nav.pushNamed('/');
      } else if (User.role == "Karyawan Produksi") {
        nav.pushNamed('/');
      } else if (User.role == "Karyawan Gudang") {
        nav.pushNamed('/inventory');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.12,
                vertical: MediaQuery.of(context).size.height * 0.08,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hi, Welcome Back!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Username',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomWidget.customTextField(
                      'Enter Your Username', userController, false),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  CustomWidget.customTextField(
                      'Enter Your Password', passwordController, true),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                rememberMe = !rememberMe;
                              }),
                              child: rememberMe
                                  ? const Icon(
                                      Icons.check_box,
                                      color: Colors.black,
                                    )
                                  : const Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    errorMessage ?? '',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      if (userController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Please Fill The Input';
                        });
                      } else {
                        var navigator = Navigator.of(context);
                        final response = await User.loginCheck(
                            userController.text, passwordController.text);
                        if (response['status'] == true) {
                          if (rememberMe) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('username', response['username']);
                            prefs.setString('role', response['role']);
                            prefs.setString('linkImage', response['linkImage']);
                          }
                          User.username = response['username'];
                          User.role = response['role'];
                          User.linkImage = response['linkImage'];
                          if (response['role'] == "Manager") {
                            navigator.pushNamed('/export');
                          } else if (response['role'] == "Karyawan Produksi") {
                            navigator.pushNamed('/');
                          } else if (response['role'] == "Karyawan Gudang") {
                            navigator.pushNamed('/inventory');
                          }
                        } else {
                          setState(() {
                            errorMessage = 'Wrong Username Or Password';
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF161A30),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'By',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('images/scentco.jpg')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

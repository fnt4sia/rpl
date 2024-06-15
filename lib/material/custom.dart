import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

class CustomWidget {
  static Widget customTextField(
      String label, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }

  static Widget customText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static Widget hamburgerMenu(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161A30),
        ),
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.network(
                    User.linkImage,
                    height: 65,
                    width: 65,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        User.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        User.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    User.role == "Manager"
                        ? ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/export');
                            },
                            title: const Text(
                              'Export Data',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            leading: const Icon(
                              Icons.file_download,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : const SizedBox(),
                    User.role == "Manager" || User.role == "Karyawan Produksi"
                        ? ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/');
                            },
                            title: const Text(
                              'Retail Sales',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            leading: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : const SizedBox(),
                    User.role == "Manager" || User.role == "Karyawan Gudang"
                        ? ListTile(
                            title: const Text(
                              'Stock Recap',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/stock');
                            },
                            leading: const Icon(
                              Icons.inventory_outlined,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : const SizedBox(),
                    User.role == "Manager" || User.role == "Karyawan Gudang"
                        ? ListTile(
                            title: const Text(
                              'Inventory',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/inventory');
                            },
                            leading: const Icon(
                              Icons.inventory,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              child: ListTile(
                onTap: () async {
                  final nav = Navigator.of(context);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('username');
                  prefs.remove('role');
                  prefs.remove('linkImage');
                  User.username = '';
                  User.role = '';
                  User.linkImage = '';
                  nav.pushReplacementNamed('/login');
                },
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                leading: const Icon(
                  Icons.logout_sharp,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  static String username = '';
  static String role = '';
  static String linkImage = '';

  static Future<Map> loginCheck(
      String usernameTemp, String passwordTemp) async {
    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/scentco-fe75a/databases/(default)/documents/user/$usernameTemp');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = (jsonDecode(response.body))['fields'];
      if (data['username']['stringValue'] == usernameTemp &&
          data['password']['stringValue'] == passwordTemp) {
        return {
          'status': true,
          'username': data['username']['stringValue'],
          'role': data['role']['stringValue'],
          'linkImage': data['linkImage']['stringValue'],
        };
      } else {
        return {
          'status': false,
        };
      }
    } else {
      return {
        'status': false,
      };
    }
  }
}

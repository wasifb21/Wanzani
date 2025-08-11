import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth {
  Future<Map<String, dynamic>> signUpUser({
    required String username,
    required String password,
    required String email,
    required String confirmPassword,
  }) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var body = {
        "username": username,
        "password": password,
        "email": email,
        "confirm_password": confirmPassword,
        "server_key":
            "4e64dd15c58ad26dbf0368fe30497f6103660b12-7051cefa69738f6c908f284780f8363f-63888596",
      };

      var response = await http.post(
        Uri.parse('https://www.wanzani.com/api/create-account'),
        headers: headers,
        body: body,
      );

      // Debug logs
      print('📡 API Status Code: ${response.statusCode}');
      print('📦 API Raw Response: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
        print('✅ Parsed JSON: $data');
      } catch (e) {
        print('⚠️ JSON Decode Failed: $e');
        data = {
          "api_status": response.statusCode,
          "raw_response": response.body,
        };
      }

      return {
        'success': (data['api_status'] == 200),
        'body': data,
      };
    } catch (e) {
      print('🔥 Error during signup: $e');
      return {
        'success': false,
        'body': {'error': e.toString()},
      };
    }
  }
}

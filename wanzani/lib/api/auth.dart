import 'dart:convert';
import 'package:http/http.dart' as http;

class auth {
  Future<Map<String, dynamic>> signUpUser({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var body = {
        "username": username, // API requires username separately
        "password": password,
        "email": email,
        "confirm_password": password,
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
          "success": false,
          "raw_response": response.body,
        };
      }

      return {
        'success': (data['success'] == true),
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

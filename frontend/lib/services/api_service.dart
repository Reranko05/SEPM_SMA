import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_host_stub.dart' if (dart.library.io) 'backend_host_io.dart';

class ApiService {
  final String baseUrl;
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBackendHost();

  Future<dynamic> postJson(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final headers = await _headers(auth);
    final uri = Uri.parse('$baseUrl$path');
    try {
      // debug log to help diagnose CORS/network issues
      // ignore: avoid_print
      print("REQUEST URL: $uri");
      print("REQUEST BODY: ${jsonEncode(body)}");
      final res = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 15));
      return _process(res);
    } catch (e) {
      throw ApiException(-1, 'Network error: ${e.toString()}');
    }
  }

  Future<dynamic> getJson(String path, {bool auth = false}) async {
    final headers = await _headers(auth);
    final uri = Uri.parse('$baseUrl$path');
    try {
      // ignore: avoid_print
      print('GET $uri headers=$headers');
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _process(res);
    } catch (e, stack) {
        print("NETWORK ERROR: $e");
        print(stack);
        throw ApiException(-1, 'Network error: ${e.toString()}');
      }
  }

  Future<dynamic> deleteJson(String path, {bool auth = false}) async {
    final headers = await _headers(auth);
    final uri = Uri.parse('$baseUrl$path');
    try {
      // ignore: avoid_print
      print('DELETE $uri headers=$headers');
      final res = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _process(res);
    } catch (e) {
      throw ApiException(-1, 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, String>> _headers(bool auth) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  dynamic _process(http.Response res) {
    final code = res.statusCode;

    print("STATUS CODE: $code");
    print("RAW RESPONSE: ${res.body}");

    if (code >= 200 && code < 300) {
      if (res.body.isEmpty) return {};

      try {
        final decoded = jsonDecode(res.body);
        return decoded; // can be Map or List
      } catch (e) {
        throw ApiException(code, "JSON parse error: ${res.body}");
      }
    }

    throw ApiException(code, res.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}


import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'api_response.dart';

class BaseApiService {
  static const int _maxResponseBodyLogChars = 4096;

  void _debugLogResponse(http.Response response) {
    if (!kDebugMode) return;
    debugPrint('Response Status Code: ${response.statusCode}');
    final b = response.body;
    if (b.length <= _maxResponseBodyLogChars) {
      debugPrint('Response Body: $b');
    } else {
      debugPrint(
        'Response Body: <${_maxResponseBodyLogChars} of ${b.length} chars>',
      );
      debugPrint('${b.substring(0, _maxResponseBodyLogChars)}…');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      if (kDebugMode) debugPrint('GET Request URL: $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  Future<dynamic> getWithQueryParams(String endpoint, Map<String, String> queryParams, String token) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: queryParams);
      if (kDebugMode) debugPrint('GET Request URL with Params: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  Future<dynamic> getWithBody(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      if (kDebugMode) {
        debugPrint('GET(body) Request URL: $url');
        debugPrint('GET(body) Request Body: ${jsonEncode(data)}');
      }
      
      final request = http.Request('GET', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      } else {
        request.headers['Content-Type'] = 'application/json';
      }
      request.body = jsonEncode(data);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  /// Multipart POST (e.g. expense proof upload). Do not json-encode [fields].
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
    String token,
  ) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (kDebugMode) {
        debugPrint('POST Multipart URL: $uri');
        debugPrint('POST Multipart fields: $fields');
      }
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(fields);
      request.files.addAll(files);
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      if (kDebugMode) {
        debugPrint('POST Request URL: $url');
        debugPrint('POST Request Body: ${jsonEncode(data)}');
      }
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  Future<dynamic> patch(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      if (kDebugMode) {
        debugPrint('PATCH Request URL: $url');
        debugPrint('PATCH Request Body: ${jsonEncode(data)}');
      }
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      if (kDebugMode) debugPrint('DELETE Request URL: $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      return _returnResponse(response);
    } catch (e) {
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw FetchDataException('No Internet connection');
      }
      rethrow;
    }
  }

  dynamic _returnResponse(http.Response response) {
    _debugLogResponse(response);

    String errorMessage = response.body;
    try {
      final json = jsonDecode(response.body);
      if (json['message'] != null) {
        errorMessage = json['message'];
      }
    } catch (_) {

    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
      case 403:
        throw UnauthorisedException(errorMessage);
      case 500:
      default:
        throw FetchDataException(errorMessage);
    }
  }
}

class AppException implements Exception {
  final String? _message;
  final String? _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

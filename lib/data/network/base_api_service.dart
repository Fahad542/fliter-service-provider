import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'api_response.dart';

class BaseApiService {
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      print('GET Request URL: $url');
      final response = await http.get(Uri.parse(url), headers: headers);
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> getWithQueryParams(String endpoint, Map<String, String> queryParams, String token) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: queryParams);
      print('GET Request URL with Params: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';
      print('POST Request URL: $url');
      print('POST Request Body: ${jsonEncode(data)}');
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  dynamic _returnResponse(http.Response response) {
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
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

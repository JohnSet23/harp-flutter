import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http/http.dart';

class MyServerRequest {
  static String serverClientApi =
      "https://harp-main.vercel.app/api/v1/";

   static Future<Response>  httpPostRequest(String route, var body) async {
    try {
      return await http.post(Uri.parse(serverClientApi + route),
          body: json.encode(body),
          headers: {
            "Accept": "application/json",
            "Content-type": "application/json",
          }).timeout(const Duration(seconds: 20));
    } on SocketException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on TimeoutException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on Exception catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    }
  }

 static Future<Response> httpGetRequest(String route) async {
    try {
      return await http.get(Uri.parse(serverClientApi + route), headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
      }).timeout(const Duration(seconds: 20));
    } on SocketException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on TimeoutException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on Exception catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    }
  }

 static Future<Response> httpGetQueryRequest(
      String queryName, String queryValue, String route) async {
    try {
      return await http.get(
          Uri.parse(
              "$serverClientApi$route?$queryName=$queryValue"),
          headers: {
            "Accept": "application/json",
            "Content-type": "application/json",
          }).timeout(const Duration(seconds: 20));
    } on SocketException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on TimeoutException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on Exception catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    }
  }

 static Future<Response> httpGetComplexQueryRequest(
      String complexQuery, String route) async {

  
    try {
      return await http.get(
          Uri.parse("$serverClientApi$route?$complexQuery"),
          headers: {
            "Accept": "application/json",
            "Content-type": "application/json",
          }).timeout(const Duration(seconds: 20));
    } on SocketException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on TimeoutException catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    } on Exception catch (err) {
      // print("Exception : " + err.toString());
      return Future.error(err);
    }
  }
}

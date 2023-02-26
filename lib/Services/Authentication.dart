import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:relaxretail/const.dart';

Future<dynamic> authenticate(
    dynamic userName, dynamic phoneNumber, dynamic password) async {
  var response = await http.post(
    Uri.parse(
        "${apiUrl}Tpr/Authenticate?userName=$userName&password=$password&phoneNumber=$phoneNumber"),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

Future<dynamic> getAttend(dynamic userId) async {
  var response = await http.get(
    Uri.parse(
        "${apiUrl}Tpr/GetAttend?userId=$userId&fromDate=1900-01-01&toDate=1900-01-01"),
  );
  print("${apiUrl}Tpr/GetAttend?userId=$userId&fromDate=1900-01-01&toDate=1900-01-01");
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

Future<dynamic> getOrders(dynamic dayWorkId) async {
  var response = await http.get(
    Uri.parse("${apiUrl}Tpr/GetOrder?dayWorkId=$dayWorkId"),
  );
  print('${apiUrl}Tpr/GetOrder?dayWorkId=$dayWorkId');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}


Future<dynamic> getOrdersByDate(dynamic userId,dynamic selectedDate) async {
  var response = await http.get(
    Uri.parse("${apiUrl}Tpr/GetDayworkID?userId=$userId&fromDate=$selectedDate"),
  );
  print('${apiUrl}Tpr/GetDayworkID?userId=$userId&fromDate=$selectedDate');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}


Future<dynamic> getDayworkProductivity(dynamic dayWorkId) async {
  var response = await http.get(
    Uri.parse("${apiUrl}Tpr/GetDayworkProductivity?dwId=$dayWorkId"),
  );
  print('${apiUrl}Tpr/GetDayworkProductivity?dwId=$dayWorkId');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

Future<dynamic> getReportByDate(dynamic selectedDate) async {
  var response = await http.get(
    Uri.parse("${apiUrl}Tpr/GetAttendListByDate?reportDate=$selectedDate"),
  );
  print('${apiUrl}Tpr/GetAttendListByDate?reportDate=$selectedDate');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

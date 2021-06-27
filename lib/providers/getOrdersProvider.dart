import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotmies/apiCalls/apiCalling.dart';
import 'package:spotmies/apiCalls/apiUrl.dart';
import 'package:spotmies/apiCalls/testController.dart';

class GetOrdersProvider extends ChangeNotifier {
  final controller = TestController();
  var orders;
  var local;

  getOrders() async {
    var response = await Server().getMethod(API.getOrders);
    orders = jsonDecode(response);
    controller.getData();
    notifyListeners();
  }

  localStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('orders', jsonEncode(orders));
  }

  localData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderData = prefs.getString('orders');
    Map<String, dynamic> details =
        jsonDecode(orderData) as Map<String, dynamic>;
    local = details;
  }
}

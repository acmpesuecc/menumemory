import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menumemory/models/order.dart';

import 'restaurant.dart';

class Visit {
  DateTime datetime;
  List<VisitOrder> order;
  String restaurantId;
  Restaurant restaurant_info;

  Visit(
      {required this.datetime,
      required this.order,
      required this.restaurantId,
      required this.restaurant_info});

  String displayText() {
    Map<String, dynamic> res = {};
    res["datetime"] = this.datetime;
    res["restaurantId"] = this.restaurantId;

    String text = "{";
    text += "   datetime: " + datetime.toString() + "\n";
    text += "   restaurantId: " + restaurantId + "\n";
    text += "   restaurantInfo: " + restaurant_info.displayText() + "\n";
    text += "   order: [";
    this.order.forEach((o) {
      text += "      ${o.displayText()}";
    });
    text += "]}";
    return text;
  }

  static Visit fromJson(Map<String, dynamic> snapshotData) {
    Timestamp dateTimeTimestamp = snapshotData["datetime"];
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(
        dateTimeTimestamp.microsecondsSinceEpoch);
    String restaurantId = snapshotData["restaurant_id"];

    Map<String, dynamic> restaurantInfo =
        snapshotData["restaurant_info"] as Map<String, dynamic>;
    Restaurant restaurant = Restaurant(
        id: restaurantId,
        name: restaurantInfo["name"],
        area: restaurantInfo["area"],
        address: restaurantInfo["address"],
        mapsLink: restaurantInfo["maps_link"],
        mapsRatingOutOf5: restaurantInfo["maps_rating_out_of_5"]);

    List orderSnapshotList = snapshotData["order"];
    List<VisitOrder> orderList = [];
    orderSnapshotList.forEach((orderSnapshot) {
      orderList.add(VisitOrder.fromJson(orderSnapshot));
    });

    return Visit(
        datetime: dateTime,
        order: orderList,
        restaurantId: restaurantId,
        restaurant_info: restaurant);
  }
}

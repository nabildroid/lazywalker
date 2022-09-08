import 'dart:convert';
import 'dart:math';

import '../models/djezzy_walk_offer.dart';
import 'djezzy_auth.dart';

class Djezzy {
  final DjezzyAuth _auth;

  Djezzy(this._auth);

  Future<bool> walkAndWin(DjezzyWalkOffer offer) async {
    final response = await _auth.post(
      "djezzy-api/api/v1/subscribers/213${offer.phoneNumber}/subscription-product?include=",
      body: jsonEncode(offer.toJson()),
    );

    if (response.statusCode == 200 && !response.data.contains("Rejected")) {
      return true;
    }

    throw Exception("not accepted");
  }
}

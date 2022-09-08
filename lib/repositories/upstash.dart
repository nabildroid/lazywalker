import 'package:http/http.dart';

class UpStash {
  static const String keyPrefix = 'lazywalker';
  final Client _client;

  final String authToken;

  UpStash(this._client, {required this.authToken});

  Future<bool> isAllowed(String phoneNumber) async {
    return true;
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';

class DjezzyAuth {
  static final client = Dio(BaseOptions(
    baseUrl: "https://apim.djezzy.dz/",
  ));

  static void closeClient() {
    client.close();
  }

  static const String clientId = "6E6CwTkp8H1CyQxraPmcEJPQ7xka";
  static const String clientSecret = "MVpXHW_ImuMsxKIwrJpoVVMHjRsa";

  final DjezzyToken token;

  DjezzyAuth(this.token);

  Future<Response<dynamic>> post(String url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return Dio().post(
      "https://copy.laknabil.me/log/now/lazy/" + url,
      data: body,
      options: Options(
        headers: {
          ...headers ?? {},
          "accept-encoding": "deflate",
          "Authorization": "Bearer ${token.accessToken}",
        },
      ),
    );
  }

  static Future<void> sign(String phoneNumber) async {
    final a = await client.post(
      "oauth2/registration",
      data: DjezzyAuthRequest(phoneNumber).toJson(),
      options: Options(headers: {
        "content-type": "application/x-www-form-urlencoded",
        "User-Agent":
            "ZDZDZD/2.1.0 (Linux; U; Android 8.1.0; FEFEFF Build/HDEDEFE-AAAAA)",
      }),
    );

    if (a.statusCode != 200) {
      throw Exception("sign failed");
    }
  }

  static Future<DjezzyAuth?> validateOtp(DjezzyOtpRequest otp) async {
    final response = await client.post(
      "oauth2/token",
      data: otp.toJson(),
      options: Options(headers: {
        "content-type": "application/x-www-form-urlencoded",
        "User-Agent":
            "ZDZDZD/2.1.0 (Linux; U; Android 8.1.0; FEFEFF Build/HDEDEFE-AAAAA)",
      }),
    );

    // todo check DjezzyOtpRequest.scop and DjezzyToken.scop
    if (response.statusCode == 200) {
      return DjezzyAuth(DjezzyToken.fromJson(response.data));
    } else {
      throw Exception("validate otp failed");
    }
  }

  static Future<DjezzyAuth?> _refrechToken(DjezzyToken expiredToken) async {
    // BUG implement the refrech token functionality
  }

  Future<DjezzyToken?> ping() async {
    // throw an excpetion if is unable to ping or refrech
  }
}

class DjezzyOtpRequest {
  static const String grantType = "mobile";

  static const String scope = "openid";

  final String mobileNumber;
  final String otp;

  DjezzyOtpRequest(this.mobileNumber, this.otp);

  Map<String, dynamic> toJson() => {
        "grant_type": grantType,
        "mobileNumber": "213$mobileNumber",
        "scope": scope,
        "otp": otp,
        "client_secret": DjezzyAuth.clientSecret,
        "client_id": DjezzyAuth.clientId,
      };
}

class DjezzyAuthRequest {
  static const String scope = "smsotp";
  final String msisdn;

  DjezzyAuthRequest(this.msisdn);

  //to  json
  Map<String, dynamic> toJson() => {
        "scope": "smsotp",
        "msisdn": "213$msisdn",
        "client_id": DjezzyAuth.clientId,
      };
}

class DjezzyToken {
  final String accessToken;
  final String expiresIn; // todo make it a date
  final String idToken;
  final String refreshToken;
  final String scope;
  final String tokenType;

  DjezzyToken({
    required this.accessToken,
    required this.expiresIn,
    required this.idToken,
    required this.refreshToken,
    required this.scope,
    required this.tokenType,
  });

  factory DjezzyToken.fromJson(Map json) {
    return DjezzyToken(
      accessToken: json["access_token"],
      expiresIn: json["expires_in"].toString(),
      idToken: json["id_token"],
      refreshToken: json["refresh_token"],
      scope: json["scope"],
      tokenType: json["token_type"],
    );
  }

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "expires_in": expiresIn,
        "id_token": idToken,
        "refresh_token": refreshToken,
        "scope": scope,
        "token_type": tokenType,
      };
}

class DjezzAuthenticatedPhoneNumber {
  final String phoneNumber;
  final DjezzyToken token;
  final DateTime created;

  DjezzAuthenticatedPhoneNumber(
    this.phoneNumber, {
    required this.token,
    required this.created,
  });

  Map<String, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "token": token.toJson(),
        "created": created.toIso8601String(),
      };

  factory DjezzAuthenticatedPhoneNumber.fromJson(Map json) {
    return DjezzAuthenticatedPhoneNumber(
      json["phoneNumber"],
      token: DjezzyToken.fromJson(json["token"]),
      created: DateTime.parse(json["created"]),
    );
  }
}

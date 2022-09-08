import 'dart:convert';

import 'package:lazywalker/models/app_settings.dart';
import 'package:lazywalker/models/check_phone.dart';
import 'package:lazywalker/models/walk.dart';
import 'package:lazywalker/repositories/djezzy_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB {
  final SharedPreferences _db;

  LocalDB(this._db);

  Future<bool> isFirstInstall() async {
    return _db.getBool('isFirstInstall') ?? true;
  }

  Future<AppSetting> loadAppSettings() async {
    final data = _db.getString("appSettings");
    if (data != null) {
      return AppSetting.fromJson(jsonDecode(data));
    } else {
      return AppSetting.defaultSetting();
    }
  }

  Future<void> saveAppSettings(AppSetting appSetting) async {
    await _db.setString("appSettings", jsonEncode(appSetting.toJson()));
  }

  Future<DateTime> lastSycnDate() async {
    final data = _db.getString("lastSyncDate");
    if (data != null) {
      return DateTime.parse(data);
    } else {
      return DateTime.now().subtract(const Duration(days: 365));
    }
  }

  Future<void> addPhoneNumber(DjezzAuthenticatedPhoneNumber phoneNumber) async {
    final data = _db.getString("phoneNumbers");
    if (data != null) {
      final phoneNumbers = jsonDecode(data) as List;
      phoneNumbers.add(phoneNumber.toJson());
      await _db.setString("phoneNumbers", jsonEncode(phoneNumbers));
    } else {
      await _db.setString("phoneNumbers", jsonEncode([phoneNumber.toJson()]));
    }
  }

  Future<List<DjezzAuthenticatedPhoneNumber>> getPhoneNumbers() async {
    final data = _db.getString("phoneNumbers");
    if (data != null) {
      final phoneNumbers = jsonDecode(data) as List;
      return phoneNumbers
          .map((e) => DjezzAuthenticatedPhoneNumber.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  // add walk to saved list of walks
  Future<void> saveWalk(Walk offer) async {
    final savedWalks = await getWalks();
    savedWalks.add(offer);

    await _db.setStringList(
      "savedWalks",
      savedWalks.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> reset() async {
    await _db.clear();
  }

  // get saved walks
  Future<List<Walk>> getWalks() async {
    final data = _db.getStringList("savedWalks");
    if (data != null) {
      return data.map((e) => Walk.fromJson(jsonDecode(e))).toList();
    } else {
      return [];
    }
  }

  Future<CheckPhone?> getLastCheckedPhoneNumber() async {
    final data = _db.getString("lastCheckedPhoneNumber");
    if (data != null) {
      return CheckPhone.fromJson(jsonDecode(data));
    } else {
      return null;
    }
  }

  Future<void> setLastCheckedPhoneNumber(CheckPhone checked) async {
    await _db.setString(
      "lastCheckedPhoneNumber",
      jsonEncode(checked.toJson()),
    );
  }
}

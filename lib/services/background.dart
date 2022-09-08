import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:lazywalker/constants/keys.dart';
import 'package:lazywalker/main.dart';
import 'package:lazywalker/models/check_phone.dart';
import 'package:lazywalker/models/djezzy_walk_offer.dart';
import 'package:lazywalker/models/walk.dart';
import 'package:lazywalker/repositories/djezzy.dart';
import 'package:lazywalker/repositories/djezzy_auth.dart';
import 'package:lazywalker/repositories/local_db.dart';
import 'package:lazywalker/repositories/upstash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const djezzyTask = 'djezzyTasker';
const syncDb = 'syncDb';

Future<bool> djezzyBackgroundTask({
  bool ignoreDelay = false,
  FlutterLocalNotificationsPlugin? localNotification,
}) async {
  final now = DateTime.now();

  final db = LocalDB(await SharedPreferences.getInstance());

  final settings = await db.loadAppSettings();
  final authorized = await db.getPhoneNumbers();

  if (authorized.isEmpty) return Future.value(true);

  // create not_finished checkPhone Instance
  late final CheckPhone checkPhone;
  final lastChecked = await db.getLastCheckedPhoneNumber();
  if (lastChecked != null && !lastChecked.isFinished) {
    checkPhone = lastChecked;
  } else {
    if (authorized.length > 1) {
      authorized.removeWhere(
        (element) => element.phoneNumber == lastChecked?.phone,
      );
    }
    authorized.shuffle();
    checkPhone = CheckPhone.fromPhone(authorized.first.phoneNumber);
  }

  final next = authorized.firstWhere(
    (element) => checkPhone.phone == element.phoneNumber,
  );
  final djezzy = Djezzy(DjezzyAuth(next.token));

  final List<Walk> walkes = [];

  // create offers to be applied (or previously not failed _ retry)
  final List<DjezzyWalkOffer> offers = [];
  for (var type in settings.offers) {
    final offer = type.create(next.phoneNumber);
    if (checkPhone.failedWalks.isEmpty ||
        checkPhone.failedWalks.containsKey(offer.code)) {
      offers.add(offer);
    }
  }

  for (var i = 0; i < settings.repetition; i++) {
    // CHECK probably the OS will kill this process before saving the previous walkes

    if (offers.isEmpty) break;

    if (!ignoreDelay) {
      await Future.delayed(Duration(seconds: i * 10));
    }

    for (var offer in offers) {
      bool isSuccess = true;

      final start = DateTime.now();

      try {
        await djezzy.walkAndWin(offer);
      } catch (e) {
        // todo save the error to Log;
        isSuccess = true;
      }

      walkes.add(Walk(
        offer: offer,
        time: now,
        isSuccessful: isSuccess,
        duration: start.difference(DateTime.now()),
        isBackground: true,
      ));

      if (isSuccess) {
        if (localNotification != null) {
          showDjezzyBackgroundNotification(
            localNotification,
            id: Random().nextInt(1000),
            phone: offer.phoneNumber,
            code: offer.code,
            isSuccess: true,
          );
        }
      }
    }

    // remove successful walks from offers
    for (var walk in walkes) {
      if (walk.isSuccessful) {
        offers.removeWhere((element) => element.code == walk.offer.code);
      }
    }
  }

  // make success on the top &  remove duplication from walks by code
  walkes.sort((a, b) => (b.isSuccessful ? 1 : 0) - (a.isSuccessful ? 1 : 0));
  final uniqueWalks = walkes
      .fold<Map<String, Walk>>({}, (p, c) {
        p.putIfAbsent(c.offer.code, () => c);
        return p;
      })
      .values
      .toList();

  for (var walk in uniqueWalks) {
    await db.saveWalk(walk);

    if (localNotification != null && !walk.isSuccessful) {
      showDjezzyBackgroundNotification(
        localNotification,
        id: Random().nextInt(1000),
        phone: walk.offer.phoneNumber,
        code: walk.offer.code,
        isSuccess: walk.isSuccessful,
      );
    }
  }

  final failedWalkes = uniqueWalks.where((e) => !e.isSuccessful).toList();
  db.setLastCheckedPhoneNumber(
    checkPhone.setFailedWalkes(failedWalkes),
  );

  final isTaskDoneForGood = walkes.every(
        (element) => element.isSuccessful,
      ) ||
      checkPhone.isAboutToFinish;

  return Future.value(isTaskDoneForGood);
}

Future<void> syncBagroundTask() async {
  final now = DateTime.now();
  final db = LocalDB(await SharedPreferences.getInstance());

  final redis = UpStash(Client(), authToken: KeysConstants.upStash);
  // todo delete unwanted phone number, upload the Walks success rate,
}

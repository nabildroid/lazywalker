import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lazywalker/cubes/setting_cubit.dart';
import 'package:lazywalker/cubes/sim_cubit.dart';
import 'package:lazywalker/cubes/walks_cubit.dart';
import 'package:lazywalker/repositories/djezzy.dart';
import 'package:lazywalker/repositories/djezzy_auth.dart';
import 'package:lazywalker/repositories/local_db.dart';
import 'package:lazywalker/screens/home1.dart';
import 'package:lazywalker/services/background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'models/check_phone.dart';
import 'models/djezzy_walk_offer.dart';
import 'models/walk.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

@pragma('vm:entry-point')
void backgroundHandlerV2() {
  Workmanager().executeTask((task, inputData) async {
    final flutterLocalNotificationsPlugin = await initNotification();

    print("TTTTTTTTTTTTTTTTTTTTTASSSSSSSSSK $task");
    if (task == djezzyTask) {
      return await djezzyBackgroundTask(
        localNotification: flutterLocalNotificationsPlugin,
      );
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  flutterLocalNotificationsPlugin = await initNotification();

  runApp(MyApp(
    sharedPreferences: await SharedPreferences.getInstance(),
  ));
}

initWorkManager() async {
  if (Platform.isAndroid) {
    await Workmanager().initialize(
      backgroundHandlerV2,
      isInDebugMode: true,
    );
  }
}

initNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  return flutterLocalNotificationsPlugin;
}

showDjezzyBackgroundNotification(
    FlutterLocalNotificationsPlugin localNotifications,
    {required int id,
    required String phone,
    required String code,
    required bool isSuccess}) async {
  final title = isSuccess ? "we get you $code" : 'djezzy blocked us';
  final body = isSuccess
      ? "Congratulations you have $code in your $phone number"
      : "we tried to get you $code in your $phone number but djezzy blocked us, we will try again!";

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'djezzyBackgroundApply',
    'djezzy background apply',
    importance: Importance.high,
    priority: Priority.low,
    ticker: 'djezzy',
    autoCancel: true,
    colorized: true,
    subText: phone,
    styleInformation: BigTextStyleInformation(body),
    color: isSuccess
        ? Color.fromARGB(255, 18, 93, 190)
        : Color.fromARGB(255, 95, 68, 66),
    icon: isSuccess ? 'skull' : 'dead_fish',
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await localNotifications.show(
    id,
    title,
    body,
    platformChannelSpecifics,
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = LocalDB(sharedPreferences);
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingCubit>(
          create: (BuildContext context) => SettingCubit(db)..init(),
        ),
        BlocProvider<SimCubit>(
          create: (BuildContext context) => SimCubit(db)..init(),
        ),
        BlocProvider<WalksCubit>(
          create: (BuildContext context) => WalksCubit(db)..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Lazy Walker',
        debugShowCheckedModeBanner: false,
        home: Home1(),
      ),
    );
  }
}

const djezzyTask = 'AAAA';
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

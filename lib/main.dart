import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lazywalker/cubes/setting_cubit.dart';
import 'package:lazywalker/cubes/sim_cubit.dart';
import 'package:lazywalker/cubes/walks_cubit.dart';
import 'package:lazywalker/repositories/local_db.dart';
import 'package:lazywalker/screens/home1.dart';
import 'package:lazywalker/services/background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void callbackDispatcheraaa() {
  Workmanager().executeTask((task, inputData) async {
    final flutterLocalNotificationsPlugin = await initNotification();

    print("TTTTTTTTTTTTTTTTTTTTTASSSSSSSSSK $task");
    if (task == djezzyTask) {
      return djezzyBackgroundTask(
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
      callbackDispatcheraaa,
      isInDebugMode: true,
    );
  }
}

initNotification() async {
  if (Platform.isAndroid) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    return flutterLocalNotificationsPlugin;
  }
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

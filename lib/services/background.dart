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
import 'package:lazywalker/repositories/station.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

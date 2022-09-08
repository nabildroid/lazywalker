// create the appSetting state and cubit classes

import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lazywalker/models/app_settings.dart';
import 'package:lazywalker/models/djezzy_walk_offer.dart';
import 'package:lazywalker/services/background.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';
import '../repositories/local_db.dart';

class SettingState extends Equatable {
  final AppSetting appSetting;

  const SettingState(this.appSetting);

  SettingState copyWith({
    AppSetting? appSetting,
  }) {
    return SettingState(
      appSetting ?? this.appSetting,
    );
  }

  // init
  factory SettingState.init() {
    return SettingState(AppSetting.defaultSetting());
  }

  @override
  List<Object?> get props => [appSetting];
}

class SettingCubit extends Cubit<SettingState> {
  final LocalDB _db;
  SettingCubit(this._db) : super(SettingState.init());

  // init
  init() async {
    final appSetting = await _db.loadAppSettings();
    emit(state.copyWith(
      appSetting: appSetting,
    ));
  }

  @override
  onChange(change) async {
    await _db.saveAppSettings(
      change.nextState.appSetting,
    );

    final setting = change.nextState.appSetting;

    super.onChange(change);
  }

  void setInterval(int interval) {
    final newState = state.copyWith(
      appSetting: state.appSetting.copyWith(
        interval: interval,
      ),
    );
    emit(newState);
    _reschedulerWork(newState.appSetting);
  }

  void setTime(TimeOfDay time) {
    final newState = state.copyWith(
      appSetting: state.appSetting.copyWith(
        time: time,
      ),
    );
    emit(newState);
    _reschedulerWork(newState.appSetting);
  }

  void setRepetition(int repetition) {
    final newState = state.copyWith(
      appSetting: state.appSetting.copyWith(
        repetition: repetition,
      ),
    );
    emit(newState);
    _reschedulerWork(newState.appSetting);
  }

  void toggleOffer(DjezzyWalkOfferOptions offer) {
    final offers = state.appSetting.offers;

    if (offers.contains(offer)) {
      offers.remove(offer);
    } else {
      offers.add(offer);
    }

    final newState = state.copyWith(
      appSetting: state.appSetting.copyWith(
        offers: offers,
      ),
    );
    emit(newState);
    _reschedulerWork(newState.appSetting);
  }

  void enable() async {
    final newState = state.copyWith(
      appSetting: state.appSetting.copyWith(
        enabled: true,
      ),
    );
    emit(newState);
    await initWorkManager();
    _reschedulerWork(newState.appSetting);
  }

  void disable() async {
    final newState = state.copyWith(
        appSetting: state.appSetting.copyWith(
      enabled: false,
    ));

    emit(newState);
    await Workmanager().cancelAll();
  }

  void _reschedulerWork(AppSetting newSettings) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();

    var nextTime = now.add(Duration(days: newSettings.interval));
    nextTime = DateTime(
      nextTime.year,
      nextTime.month,
      nextTime.day,
      newSettings.time.hour,
      newSettings.time.minute,
    );

    final frequency = nextTime.difference(now);
    // use dependency injection to get the workmanager instance

    if (newSettings.enabled) {
      await Workmanager().registerPeriodicTask(
        djezzyTask,
        djezzyTask,
        // frequency: Duration(hours: 5),
        initialDelay: const Duration(seconds: 5),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    }
  }

  void reset() async {
    await _db.reset();
    emit(SettingState.init());
  }
}

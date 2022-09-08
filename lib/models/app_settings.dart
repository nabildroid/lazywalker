// CHECK i think Settings or Config is a better name

import 'package:flutter/material.dart';
import 'package:lazywalker/main.dart';
import 'package:lazywalker/models/djezzy_walk_offer.dart';

class AppSetting {
  final int interval;
  final TimeOfDay time;
  final int repetition;

  final List<DjezzyWalkOfferOptions> offers;

  final bool enabled;

  final bool isPro;

  AppSetting({
    required this.interval,
    required this.time,
    required this.repetition,
    required this.offers,
    required this.enabled,
    required this.isPro,
  });

// create factory default settings
  factory AppSetting.defaultSetting() {
    return AppSetting(
      interval: 3,
      time: const TimeOfDay(hour: 9, minute: 0),
      repetition: 3,
      offers: [],
      enabled: false,
      isPro: false,
    );
  }

  isValide() {
    if (isPro) {
      return true;
    } else {
      if (interval > 2 && repetition > 0 && repetition < 100) {
        return true;
      } else {
        throw Exception('invalid setting');
      }
    }
  }

  // copyWith
  AppSetting copyWith({
    int? interval,
    TimeOfDay? time,
    int? repetition,
    List<DjezzyWalkOfferOptions>? offers,
    bool? enabled,
    bool? isPro,
  }) {
    return AppSetting(
      interval: interval ?? this.interval,
      time: time ?? this.time,
      repetition: repetition ?? this.repetition,
      offers: offers ?? this.offers,
      enabled: enabled ?? this.enabled,
      isPro: isPro ?? this.isPro,
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'interval': interval,
      'time': {
        "hour": time.hour,
        "minute": time.minute,
      },
      'repetition': repetition,
      'offers': offers.map((e) => e.index).toList(),
      'enabled': enabled,
      'isPro': isPro,
    };
  }

  // from json
  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      interval: json['interval'],
      time:
          TimeOfDay(hour: json['time']['hour'], minute: json['time']['minute']),
      repetition: json['repetition'],
      offers: DjezzyWalkOfferOptions.values.where((e) {
        return json['offers'].contains(e.index);
      }).toList(),
      enabled: json['enabled'],
      isPro: json['isPro'],
    );
  }
}

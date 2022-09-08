import 'package:lazywalker/models/djezzy_walk_offer.dart';

class Walk {
  final DjezzyWalkOffer offer;
  final DateTime time;
  final bool isSuccessful;

  final Duration duration;

  final bool isBackground;

  Walk({
    required this.offer,
    required this.time,
    required this.isSuccessful,
    required this.duration,
    required this.isBackground,
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'offer': {
        'code': offer.code,
        'id': offer.id,
        'steps': offer.steps,
        'phoneNumber': offer.phoneNumber,
      },
      'time': time.toIso8601String(),
      'isSuccessful': isSuccessful,
      'duration': duration.inMilliseconds,
      'isBackground': isBackground,
    };
  }

  // from json
  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      offer: DjezzyWalkOffer(
        phoneNumber: json['offer']['phoneNumber'],
        code: json['offer']['code'],
        id: json['offer']['id'],
        steps: json['offer']['steps'],
      ),
      time: DateTime.parse(json['time']),
      isSuccessful: json['isSuccessful'],
      duration: Duration(milliseconds: json['duration']),
      isBackground: json['isBackground'],
    );
  }
}

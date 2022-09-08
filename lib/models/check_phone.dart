import 'package:lazywalker/models/walk.dart';

class CheckPhone {
  final String phone;
  final Map<String, Walk> failedWalks;

  final int failedTries;

  static const totalTries = 10;
  CheckPhone(this.phone, this.failedWalks, this.failedTries);

  bool get isFinished {
    return failedWalks.isEmpty && failedTries != -1 ||
        failedTries >= totalTries;
  }

  bool get isAboutToFinish {
    return failedWalks.isEmpty && failedTries != -1 ||
        failedTries >= totalTries - 1;
  }

  setFailedWalkes(List<Walk> walks) {
    final uniqueWalks =
        walks.fold<Map<String, Walk>>({}, (previousValue, element) {
      previousValue.putIfAbsent(element.offer.code, () => element);
      return previousValue;
    });

    return CheckPhone(
      phone,
      uniqueWalks,
      failedTries + 1,
    );
  }

  factory CheckPhone.fromPhone(String phone) {
    return CheckPhone(phone, {}, -1);
  }

  // to json
  Map<String, dynamic> toJson() => {
        "phone": phone,
        "failedWalks": failedWalks.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        "failedTries": failedTries,
      };

  factory CheckPhone.fromJson(Map<String, dynamic> json) {
    final failedWalks = json["failedWalks"] as Map<String, dynamic>;
    return CheckPhone(
      json["phone"] as String,
      failedWalks.map(
        (key, value) => MapEntry(key, Walk.fromJson(value)),
      ),
      json["failedTries"] as int,
    );
  }
}

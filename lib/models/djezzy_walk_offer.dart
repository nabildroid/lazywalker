import 'package:equatable/equatable.dart';

enum DjezzyWalkOfferOptions {
  g1,
  g2,
  g4,
  g6,
}

extension DjezzyWalkOfferTypes on DjezzyWalkOfferOptions {
  DjezzyWalkOffer create(String phoneNumber) {
    switch (this) {
      case DjezzyWalkOfferOptions.g1:
        return DjezzyWalkOffer(
          phoneNumber: phoneNumber,
          code: "GIFTWALKWIN1GO",
          id: "WALKWIN",
          steps: 5000,
        );

      case DjezzyWalkOfferOptions.g2:
        return DjezzyWalkOffer(
          phoneNumber: phoneNumber,
          code: "GIFTWALKWIN2GO",
          id: "WALKWIN",
          steps: 10000,
        );
      case DjezzyWalkOfferOptions.g4:
        return DjezzyWalkOffer(
          phoneNumber: phoneNumber,
          code: "GIFTWALKWIN4GO",
          id: "WALKWIN",
          steps: 15000,
        );
      case DjezzyWalkOfferOptions.g6:
        return DjezzyWalkOffer(
          phoneNumber: phoneNumber,
          code: "GIFTWALKWIN6GOWEEK",
          id: "WALKWIN",
          steps: 20000,
        );
    }
  }
}

class DjezzyWalkOffer extends Equatable {
  final String code;
  final String id;
  final int steps;

  final String phoneNumber;

  const DjezzyWalkOffer({
    required this.code,
    required this.id,
    required this.steps,
    required this.phoneNumber,
  });

  // to json
  Map<String, dynamic> toJson() => {
        "data": {
          "id": "GIFTWALKWIN",
          "meta": {
            "services": {"code": code, "id": "id", "steps": steps}
          },
          "type": "products"
        }
      };

  @override
  List<Object?> get props => [code, id, steps, phoneNumber];
}

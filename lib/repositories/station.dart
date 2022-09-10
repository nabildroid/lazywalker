import 'package:dio/dio.dart';

class StationMetadata {
  final String version;
  final String public;
  final String name;
  final String description;
  final String url;

  StationMetadata({
    required this.version,
    required this.public,
    required this.name,
    required this.description,
    required this.url,
  });

  // from json
  factory StationMetadata.fromJson(Map json) {
    return StationMetadata(
      version: json["version"],
      public: json["public"],
      name: json["name"],
      description: json["description"],
      url: json["url"],
    );
  }

  // to json
  Map<String, dynamic> toJson() => {
        "version": version,
        "public": public,
        "name": name,
        "description": description,
        "url": url,
      };
}

class Station {
  static bool isPublic = false;
  static final client = Dio(
    BaseOptions(
      baseUrl: "https://apim.djezzy.dz/api/",
    ),
  );

  static Future<StationMetadata?> getMetadata() async {
    try {
      final response = await client.get("metadata");
      if (response.statusCode == 200) {
        return StationMetadata.fromJson(response.data);
      }
    } catch (e) {}
  }

  static Future<bool> isAllowed(phone) async {
    if (isPublic) return true;
    try {
      final response = await client.get("check/$phone");

      if (response.data.type != "not_allowed") {
        return true;
      }
    } catch (e) {}
    return false;
  }
}

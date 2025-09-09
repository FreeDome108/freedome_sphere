
class BorankoProject {
  final String id;
  final String name;
  final String version;
  final List<BorankoPage> pages;

  BorankoProject({
    required this.id,
    required this.name,
    this.version = '1.0.0',
    this.pages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }

  factory BorankoProject.fromJson(Map<String, dynamic> json) {
    return BorankoProject(
      id: json['id'],
      name: json['name'],
      version: json['version'] ?? '1.0.0',
      pages: (json['pages'] as List?)
          ?.map((p) => BorankoPage.fromJson(p))
          .toList() ??
          [],
    );
  }
}

class BorankoPage {
  final String id;
  final int pageNumber;
  final String imagePath;
  final String? text;
  final List<BorankoSound> sounds;

  BorankoPage({
    required this.id,
    required this.pageNumber,
    required this.imagePath,
    this.text,
    this.sounds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageNumber': pageNumber,
      'imagePath': imagePath,
      'text': text,
      'sounds': sounds.map((s) => s.toJson()).toList(),
    };
  }

  factory BorankoPage.fromJson(Map<String, dynamic> json) {
    return BorankoPage(
      id: json['id'],
      pageNumber: json['pageNumber'],
      imagePath: json['imagePath'],
      text: json['text'],
      sounds: (json['sounds'] as List?)
          ?.map((s) => BorankoSound.fromJson(s))
          .toList() ??
          [],
    );
  }
}

class BorankoSound {
  final String id;
  final String soundPath;
  final double startTime;
  final double volume;

  BorankoSound({
    required this.id,
    required this.soundPath,
    this.startTime = 0.0,
    this.volume = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soundPath': soundPath,
      'startTime': startTime,
      'volume': volume,
    };
  }

  factory BorankoSound.fromJson(Map<String, dynamic> json) {
    return BorankoSound(
      id: json['id'],
      soundPath: json['soundPath'],
      startTime: json['startTime']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 1.0,
    );
  }
}

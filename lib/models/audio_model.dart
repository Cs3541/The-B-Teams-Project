enum AudioSourceType { asset, stream, file }

enum AudioLibrarySection { catalog, favorites, imports, history }

class Audio {
  final String name;
  final String? description;
  final String? source;
  final AudioSourceType? sourceType;

  const Audio({
    required this.name,
    this.description,
    this.source,
    this.sourceType,
  });

  bool get hasSource =>
      source != null && source!.trim().isNotEmpty && sourceType != null;

  String get id => '${sourceType?.name ?? 'entry'}:${source ?? name}';

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'source': source,
    'sourceType': sourceType?.name,
  };

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
    name: json['name'] as String,
    description: json['description'] as String?,
    source: json['source'] as String,
    sourceType: AudioSourceType.values.byName(json['sourceType'] as String),
  );
}

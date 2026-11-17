enum AudioSourceType { asset, stream, file }

class Audio {
  final String name;
  final String? description;
  final String? source;
  final AudioSourceType? sourceType;

  Audio({
    required this.name,
    this.description,
    this.source,
    this.sourceType,
  });

  bool get hasSource =>
      source != null && source!.trim().isNotEmpty && sourceType != null;
}

class Album {
  final String id;
  final String name;
  final String coverUrl;

  Album({required this.id, required this.name, required this.coverUrl});

  factory Album.fromJson(Map<String, dynamic> json) {

    return Album(
      id: json['_id'] as String,
      name: json['name'] as String,
      coverUrl: json['cover_source'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'cover_source': coverUrl
    };
  }
}

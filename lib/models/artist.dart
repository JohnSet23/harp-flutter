class Artist {
  final String id;
  final String name;
  final String imageSource;

  Artist({required this.id, required this.name, required this.imageSource});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['_id'] as String,
      name: json['name'] as String,
      imageSource: json['image_source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'image_source': imageSource};
  }
}

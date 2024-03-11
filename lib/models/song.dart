import 'artist.dart'; // Importing the Artist model class
import 'album.dart'; // Importing the Album model class

class Song {
  final String id;
  final String title;
  final String? translationTitle;
  final Artist artist;
  final Album? album;
  final String? featuredArtists;
  final List<dynamic> genre;
  final String? coverUrl;
  final String? lyric;
  final int? track;
  final String language;
  final DateTime? releaseDate;
  final String createdAt;
  final int? viewCount;
  final String source;

  Song(
      {required this.id,
      required this.title,
      this.translationTitle,
      required this.artist,
      this.album,
      this.featuredArtists,
      required this.genre,
      this.coverUrl,
      this.lyric,
      this.track,
      required this.language,
      this.releaseDate,
      required this.createdAt,
      this.viewCount,
      required this.source});

  factory Song.fromJson(Map<String, dynamic> json) {
  
  
    return Song(
  
      id: json['_id'] as String,
      title: json['title'] as String,
      translationTitle: json['translation_title'] as String?,
      album: json['album_id'] != null ? Album.fromJson(json['album_id']) : null,
      featuredArtists: json['featured_artist'] as String?,
      genre: json['genre'] as List<dynamic>,
      coverUrl: json['cover_source'] as String?,
      lyric: json['lyric'] as String?,
      track: json['track'] as int?,
      language: json['language'] as String,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
          artist: Artist.fromJson(json['artist_id']), 
      createdAt: json["createdAt"]!=null ? json["createdAt"] as String : "",   
      viewCount:  json["view_count"] as int?,
      source: json["source"] as String,
  
    );

   
  }

  Map<String, dynamic> toJson() {
  
    return {
      '_id': id,
      'title': title,
      'translation_title': translationTitle,
      'artist_id': artist.toJson(),
      'album_id': album?.toJson(),
      'featured_artist': featuredArtists,
      'genre': genre,
      'coverUrl': coverUrl,
      'lyric': lyric,
      'track': track,
      'language': language,
      'release_date': releaseDate?.toIso8601String(),
      'createdAt': createdAt,
      'view_count': viewCount,
      'source': source
    };
  }
}




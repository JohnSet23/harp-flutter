import 'dart:convert';
import 'package:harp/models/album.dart';
import 'package:harp/models/artist.dart';
import 'package:harp/services/utilites.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class MySharePreferences {
  static void saveSongSearchHistoyList(Song song) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? songlistString = preferences.getString("search_song_history_list");

    List<Song> historySongList = [];

    if (songlistString != null) {
      historySongList = (jsonDecode(songlistString) as List<dynamic>)
          .map((e) => Song.fromJson(e))
          .toList();

      historySongList.add(song);
    } else {
      historySongList.add(song);
    }

    await preferences.setString(
        "search_song_history_list", jsonEncode(historySongList));
  }

  static void saveArtistSearchHistoyList(Artist artist) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? artistListString =
        preferences.getString("search_artist_history_list");

    List<Artist> historyArtistList = [];

    if (artistListString != null) {
      historyArtistList = (jsonDecode(artistListString) as List<dynamic>)
          .map((e) => Artist.fromJson(e))
          .toList();

      historyArtistList.add(artist);
    } else {
      historyArtistList.add(artist);
    }

    await preferences.setString(
        "search_artist_history_list", jsonEncode(historyArtistList));
  }

  static void saveAlbumSearchHistoyList(Album album) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? albumListString =
        preferences.getString("search_album_history_list");

    List<Album> historyAlbumList = [];

    if (albumListString != null) {
      historyAlbumList = (jsonDecode(albumListString) as List<dynamic>)
          .map((e) => Album.fromJson(e))
          .toList();

      historyAlbumList.add(album);
    } else {
      historyAlbumList.add(album);
    }

    await preferences.setString(
        "search_album_history_list", jsonEncode(historyAlbumList));
  }

  static Future<bool> createSongPlaylist(String playlistName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songPlaylistString = preferences.getString("my_playlist");
    List<dynamic> newSongPlaylist = [];
    if (songPlaylistString != null) {
      newSongPlaylist = jsonDecode(songPlaylistString);
    }
    if (newSongPlaylist.any((element) => element["name"] == playlistName)) {
      return false;
    }

    newSongPlaylist.add({"name": playlistName, "playlist": []});

    await preferences.setString("my_playlist", jsonEncode(newSongPlaylist));
    return true;
  }

  static Future deleteSongPlaylist(String playlistName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songPlaylistString = preferences.getString("my_playlist");
    List<dynamic> newSongPlaylist = [];
    if (songPlaylistString != null) {
      newSongPlaylist = jsonDecode(songPlaylistString);
    }

    newSongPlaylist.removeWhere((element) => element["name"] == playlistName);

    await preferences.setString("my_playlist", jsonEncode(newSongPlaylist));
  }

  static Future<List<dynamic>> getFavorteSongPlaylist() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songPlaylistString = preferences.getString("my_playlist");

    if (songPlaylistString != null) {
      return jsonDecode(songPlaylistString);
    } else {
      return [];
    }
  }

  static Future<bool> addSongToPlaylist(String playlistName, Song song) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songPlaylistString = preferences.getString("my_playlist");
    List<dynamic> newSongPlaylists = [];
    if (songPlaylistString != null) {
      newSongPlaylists = jsonDecode(songPlaylistString);
    }

    //get single playlist by playlist name
    List<dynamic> newSinglePlayList = Map<String, dynamic>.from(newSongPlaylists
        .singleWhere((element) => element["name"] == playlistName))["playlist"];

    //in this single playlist, check if the song already exists
    if (newSinglePlayList.any((element) => element["_id"] == song.id)) {
      return false;
    }
    //add song to single playlist as json
    newSinglePlayList.add(song.toJson());

//get value from song playlists with playlistname and replace new single playlist
    for (var map in newSongPlaylists) {
      if (map["name"] == playlistName) {
        map['playlist'] = newSinglePlayList;
      }
    }

    await preferences.setString("my_playlist", jsonEncode(newSongPlaylists));
    return true;
  }

  static void removeSongFromPlaylist(String playlistName, String songId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songPlaylistString = preferences.getString("my_playlist");
    List<dynamic> newSongPlaylist = [];
    if (songPlaylistString != null) {
      newSongPlaylist = jsonDecode(songPlaylistString);
    }

    List<dynamic> newSinglePlayList = Map<dynamic, dynamic>.from(newSongPlaylist
        .singleWhere((element) => element["name"] == playlistName))["playlist"];
    newSinglePlayList.removeWhere((element) => element["_id"] == songId);

    newSongPlaylist.removeWhere((element) => element["name"] == playlistName);

    newSongPlaylist.add({"name": playlistName, "playlist": newSinglePlayList});

    preferences.setString("my_playlist", jsonEncode(newSongPlaylist));
  }

  static void removeItemSearchHistoryList(
      Map<dynamic, dynamic> item, SearchType searchType) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songListString =
        preferences.getString("search_${searchType.name}_history_list");
    List<dynamic> recentSearchHistoryList = [];
    if (songListString != null) {
      recentSearchHistoryList = jsonDecode(songListString);
    }

    recentSearchHistoryList
        .removeWhere((element) => element["_id"] == item["_id"]);
    preferences.setString("search_${searchType.name}_history_list",
        jsonEncode(recentSearchHistoryList));
  }

  static void removeSongSearchHistoryList(Song song) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songListString = preferences.getString("search_song_history_list");
    List<dynamic> recentSearchHistoryList = [];
    if (songListString != null) {
      recentSearchHistoryList = jsonDecode(songListString);
    }

    recentSearchHistoryList.removeWhere((element) => element["_id"] == song.id);
    await preferences.setString(
        "search_song_history_list", jsonEncode(recentSearchHistoryList));
  }

  static void removeArtistSearchHistoryList(Artist artist) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? artistListString =
        preferences.getString("search_artist_history_list");
    List<dynamic> recentSearchHistoryList = [];
    if (artistListString != null) {
      recentSearchHistoryList = jsonDecode(artistListString);
    }

    recentSearchHistoryList
        .removeWhere((element) => element["_id"] == artist.id);
    await preferences.setString(
        "search_artist_history_list", jsonEncode(recentSearchHistoryList));
  }

  static void removeAlbumSearchHistoryList(Album album) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? albumListString =
        preferences.getString("search_album_history_list");
    List<dynamic> recentSearchHistoryList = [];
    if (albumListString != null) {
      recentSearchHistoryList = jsonDecode(albumListString);
    }

    recentSearchHistoryList
        .removeWhere((element) => element["_id"] == album.id);
    await preferences.setString(
        "search_album_history_list", jsonEncode(recentSearchHistoryList));
  }

  static Future<List<Album>> getFavoriteAlbumList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteAlbumString = preferences.getString("fav_album");

    if (favoriteAlbumString != null) {
      return List<Album>.from((jsonDecode(favoriteAlbumString) as List<dynamic>)
          .map((e) => Album.fromJson(e))
          .toList());
    } else {
      return [];
    }
  }

  static Future<bool> isFavoriteAlbum(Map<dynamic, dynamic> album) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteAlbumString = preferences.getString("fav_album");

    if (favoriteAlbumString == null) {
      return false;
    }
    List<dynamic> favoriteAlbumList = jsonDecode(favoriteAlbumString);

    if (favoriteAlbumList.any((element) => element["_id"] == album["_id"])) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> isFavoriteArtist(Map<dynamic, dynamic> artist) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteArtistString = preferences.getString("fav_artist");

    if (favoriteArtistString == null) {
      return false;
    }
    List<dynamic> favoriteArtistList = jsonDecode(favoriteArtistString);

    if (favoriteArtistList.any((element) => element["_id"] == artist["_id"])) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Artist>> getFavoriteArtistList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteArtistString = preferences.getString("fav_artist");

    if (favoriteArtistString != null) {
      return List<Artist>.from(
          (jsonDecode(favoriteArtistString) as List<dynamic>)
              .map((e) => Artist.fromJson(e))
              .toList());
    } else {
      return [];
    }
  }

  static Future<bool> addFavoriteArtist(Artist artist) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteArtistString = preferences.getString("fav_artist");

    List<dynamic> newfavoriteArtistList = [];

    if (favoriteArtistString != null) {
      newfavoriteArtistList = jsonDecode(favoriteArtistString);
    }

    if (newfavoriteArtistList.any((element) => element["_id"] == artist.id)) {
      return false;
    }

    newfavoriteArtistList.add(artist);

    await preferences.setString(
        "fav_artist", jsonEncode(newfavoriteArtistList));
    return true;
  }

  static Future deleteFavoriteArtist(Artist artist) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteArtistString = preferences.getString("fav_artist");

    List<dynamic> newfavoriteArtistList = [];

    if (favoriteArtistString != null) {
      newfavoriteArtistList = jsonDecode(favoriteArtistString);
    }

    newfavoriteArtistList.removeWhere((element) => element["_id"] == artist.id);
    await preferences.setString(
        "fav_artist", jsonEncode(newfavoriteArtistList));
  }

  static Future<bool> addFavoriteAlbum(Album album) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteAlbumString = preferences.getString("fav_album");

    List<dynamic> newfavoriteAlbumList = [];

    if (favoriteAlbumString != null) {
      newfavoriteAlbumList = jsonDecode(favoriteAlbumString);
    }

    if (newfavoriteAlbumList.any((element) => element["_id"] == album.id)) {
      return false;
    }

    newfavoriteAlbumList.add(album);
    await preferences.setString("fav_album", jsonEncode(newfavoriteAlbumList));
    return true;
  }

  static Future deleteFavoriteAlbum(Album album) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? favoriteAlbumString = preferences.getString("fav_album");

    List<dynamic> newfavoriteAlbumList = [];

    if (favoriteAlbumString != null) {
      newfavoriteAlbumList = jsonDecode(favoriteAlbumString);
    }

    newfavoriteAlbumList.removeWhere((element) => element["_id"] == album.id);
    await preferences.setString("fav_album", jsonEncode(newfavoriteAlbumList));
  }

  static Future<List<dynamic>> getSearchHistoryList(
      SearchType searchType) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? songListString =
        preferences.getString("search_${searchType.name}_history_list");

    if (songListString != null) {
      return List<dynamic>.from(jsonDecode(songListString)).reversed.toList();
    } else {
      return [];
    }
  }

  static void removePlayingSongList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove("playing_songlist");
  }

  static Future<List<dynamic>?> getPlayingSongList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? songListString = preferences.getString("playing_songlist");
    if (songListString != null) {
      return jsonDecode(songListString);
    } else {
      return null;
    }
  }
}

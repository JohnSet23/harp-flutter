import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harp/models/album.dart';
import 'package:harp/models/artist.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/album_screen.dart';
import 'package:harp/pages/artist_screen.dart';
import 'package:harp/pages/music_player.dart';
import 'package:harp/services/server_request.dart';
import 'package:harp/services/utilites.dart';

import '../models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver {
  final _searchTextController = TextEditingController();
  SearchType _searchType = SearchType.song;
  String _tempSearchString = "";
  List<dynamic> _tempSearchList = [];
  List<dynamic> _searchList = [];
  List<dynamic> _searchHistory = [];

  @override
  void initState() {
    super.initState();

    _getSearchHistory();
  }

  Future<List<dynamic>> _getSearchRoute(
      String value, String route, bool directSearch) async {
    if (value.trim().isNotEmpty) {
      if (value.length > 1 || value.length == 1) {
        if (directSearch) {
          if (_tempSearchString.trim() != value) {
            try {
              var res = await MyServerRequest.httpGetQueryRequest(
                "keyword",
                value,
                route,
              );

              Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

              setState(() {
                _tempSearchString = value.trim();
                _tempSearchList = mapRes["data"];
              });

              if (mapRes["status"] == 1) {
                return mapRes["data"];
              } else {
                return [];
              }
            } catch (err) {
              return [];
            }
          } else {
            return _tempSearchList;
          }
        } else {
          if (value.substring(value.length - 1) == " ") {
            if (value.length > 2) {
              if (value.substring(value.length - 2, value.length - 1) != " ") {
                if (_tempSearchString != value.trim()) {
                  try {
                    var res = await MyServerRequest.httpGetQueryRequest(
                      "keyword",
                      value.substring(0, value.length - 1).toLowerCase(),
                      route,
                    );

                    Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

                    setState(() {
                      _tempSearchString = value.trim();
                      _tempSearchList = mapRes["data"];
                    });

                    if (mapRes["status"] == 1) {
                      return mapRes["data"];
                    } else {
                      return [];
                    }
                  } catch (err) {
                    return [];
                  }
                } else {
                  return _tempSearchList;
                }
              } else {
                return _tempSearchList;
              }
            } else {
              return _tempSearchList;
            }
          } else {
            return _tempSearchList;
          }
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future _getSearchHistory() async {
    List<dynamic> newSearchHistoryList =
        await MySharePreferences.getSearchHistoryList(_searchType);

    setState(() {
      _searchHistory = newSearchHistoryList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: TextField(
            style: const TextStyle(color: Colors.white),
            controller: _searchTextController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async {
              List<dynamic> newSearchList = [];

              switch (_searchType) {
                case SearchType.song:
                  newSearchList =
                      await _getSearchRoute(value, "song/search", true);
                  break;
                case SearchType.artist:
                  newSearchList =
                      await _getSearchRoute(value, "artist/search", true);
                  break;
                case SearchType.album:
                  newSearchList =
                      await _getSearchRoute(value, "album/search", true);
                  break;
              }

              setState(() {
                _searchList = newSearchList;
              });
            },
            onChanged: (value) async {
              List<dynamic> newSearchList = [];
              switch (_searchType) {
                case SearchType.song:
                  newSearchList =
                      await _getSearchRoute(value, "song/search", false);
                  break;
                case SearchType.artist:
                  newSearchList =
                      await _getSearchRoute(value, "artist/search", false);
                  break;
                case SearchType.album:
                  newSearchList =
                      await _getSearchRoute(value, "album/search", false);
                  break;
              }

              setState(() {
                _searchList = newSearchList;
              });
            },
            autocorrect: false,
            cursorColor: Colors.white,
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Search ${_searchType.name}",
                hintStyle: const TextStyle(color: Colors.white))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Wrap(
                                spacing: 15.0,
                                children: [
                   ChoiceChip(
                      label: const Text('Song'),
                      selected: _searchType== SearchType.song ? true : false,
                      onSelected: (bool selected)  {
                  
                        if(selected){
                         
                            setState(() {
                              _searchHistory = [];
                              _searchType = SearchType.song;
                              _searchList = [];
                              _searchTextController.text = "";
                              _tempSearchList = [];
                              _tempSearchString = "";
                            });
                  
                             _getSearchHistory();
                          
                        }
                       
                      },
                  
                      
                    ),
                  
                       ChoiceChip(
                      label: const Text('Artist'),
                      selected: _searchType== SearchType.artist ? true : false,
                      onSelected: (bool selected)  {
                        if(selected){
                           
                            setState(() {
                              _searchHistory = [];
                              _searchType = SearchType.artist;
                              _searchList = [];
                              _searchTextController.text = "";
                              _tempSearchString = "";
                              _tempSearchList = [];
                            });
                  
                             _getSearchHistory();
                        
                       
                      }},),
                  
                  
                       ChoiceChip(
                      label: const Text('Album'),
                      selected: _searchType== SearchType.album ? true : false,
                      onSelected: (bool selected)  {
                        if(selected){
                  
                              setState(() {
                              _searchHistory = [];
                              _searchType = SearchType.album;
                              _searchList = [];
                              _searchTextController.text = "";
                              _tempSearchList = [];
                              _tempSearchString = "";
                            });
                             _getSearchHistory();
                        }
                       
                      },)
                                ]
                              ),
                ),
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: Row(
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.only(right: 10),
          //         child: ChoiceChip(
          //           padding: const EdgeInsets.all(12.0),
          //           avatar: _searchType == SearchType.song
          //               ? const Icon(
          //                 Icons.check,
          //               )
          //               : null,
          //           label: const Text(
          //             "Song",
          //             style: TextStyle(fontSize: 15),
          //           ),
          //           selected: _searchType == SearchType.song ? true : false,
          //           onSelected: (value) async {
          //             if (value) {

          //                 if (_searchType != SearchType.artist) {
          //                 setState(() {
          //                   _searchHistory = [];
          //                   _searchType = SearchType.artist;
          //                   _searchList = [];
          //                   _searchTextController.text = "";
          //                   _tempSearchString = "";
          //                   _tempSearchList = [];
          //                 });

          //                 await _getSearchHistory();
                          
          //                  }
                    
          //             }
          //           },
          //         ),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.only(right: 10),
          //         child: ChoiceChip(
          //           padding: const EdgeInsets.all(12.0),
          //           avatar: _searchType == SearchType.artist
          //               ? const Icon(
          //                 Icons.check,
          //                 color: Colors.white,
          //               )
          //               : null,
          //           label: const Text(
          //             "Artist",
          //             style: TextStyle(fontSize: 15),
          //           ),
          //           selected: _searchType == SearchType.artist ? true : false,
          //           onSelected: (value) async {
          //             if (value) {
          //               if (_searchType != SearchType.artist) {
          //                 setState(() {
          //                   _searchHistory = [];
          //                   _searchType = SearchType.artist;
          //                   _searchList = [];
          //                   _searchTextController.text = "";
          //                   _tempSearchString = "";
          //                   _tempSearchList = [];
          //                 });

          //                 await _getSearchHistory();
          //               }
          //             }
          //           },
          //         ),
          //       ),

             
          //       Container(
          //         padding: const EdgeInsets.only(right: 10),
          //         child: ChoiceChip(
          //           padding: const EdgeInsets.all(12.0),
          //           avatar: _searchType == SearchType.album
          //               ? const Icon(
          //                 Icons.check,
          //               )
          //               : null,
          //           label: const Text(
          //             "Album",
          //             style: TextStyle(fontSize: 15),
          //           ),
          //           selected: _searchType == SearchType.album ? true : false,
          //           onSelected: (value) async {
          //             if (value) {
          //               if (_searchType != SearchType.album) {
          //                 setState(() {
          //                   _searchHistory = [];
          //                   _searchType = SearchType.album;
          //                   _searchList = [];
          //                   _searchTextController.text = "";
          //                   _tempSearchList = [];
          //                   _tempSearchString = "";
          //                 });
          //                 await _getSearchHistory();
          //               }
          //             }
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          _searchList.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: _searchList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        switch (_searchType) {
                          case SearchType.song:
                            List<Song> songList = _searchList
                                .map(((e) => Song.fromJson(e)))
                                .toList();
                            return GestureDetector(
                              onTap: () {
                                MySharePreferences.saveSongSearchHistoyList(
                                    songList[index]);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MusicPlayerPage(
                                        songList: [songList[index]],
                                        index: 0,
                                        isSameSong: false)));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    songList[index].album != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: songList[index]
                                                  .album!
                                                  .coverUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : songList[index].coverUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      songList[index].coverUrl!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.asset(
                                                  "assets/song_cover_placeholder.jpg",
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              songList[index].title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Container(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              songList[index].artist.name,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );

                          case SearchType.artist:
                            List<Artist> artistList = _searchList
                                .map(((e) => Artist.fromJson(e)))
                                .toList();

                            return GestureDetector(
                              onTap: () {
                                MySharePreferences.saveArtistSearchHistoyList(
                                    artistList[index]);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ArtistScreen(
                                        artist: artistList[index])));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              artistList[index].imageSource,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        artistList[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );

                          case SearchType.album:
                            List<Album> albumList = _searchList
                                .map(((e) => Album.fromJson(e)))
                                .toList();
                            return GestureDetector(
                              onTap: () {
                                MySharePreferences.saveAlbumSearchHistoyList(
                                    albumList[index]);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AlbumScreen(album: albumList[index])));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: albumList[index].coverUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              albumList[index].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Container(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              albumList[index].name,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                        }
                      }))
              :

              // Search History

              Expanded(
                  child: ListView.builder(
                      itemCount: _searchHistory.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        switch (_searchType) {
                          case SearchType.song:
                            List<Song> songList = _searchHistory
                                .map(((e) => Song.fromJson(e)))
                                .toList();
                            return GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MusicPlayerPage(
                                        songList: [songList[index]],
                                        index: 0,
                                        isSameSong: false)));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    songList[index].album != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: songList[index]
                                                  .album!
                                                  .coverUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : songList[index].coverUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      songList[index].coverUrl!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.asset(
                                                  "assets/song_cover_placeholder.jpg",
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              songList[index].title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Container(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              songList[index].artist.name,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          MySharePreferences
                                              .removeSongSearchHistoryList(
                                                  songList[index]);

                                          setState(() {
                                            _searchHistory.removeAt(index);
                                          });
                                        },
                                        icon: Icon(Icons.remove_circle_outline,
                                            color:
                                                Theme.of(context).primaryColor))
                                  ],
                                ),
                              ),
                            );

                          case SearchType.artist:
                            List<Artist> artistList = _searchHistory
                                .map(((e) => Artist.fromJson(e)))
                                .toList();
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ArtistScreen(
                                        artist: artistList[index])));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              artistList[index].imageSource,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        artistList[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          MySharePreferences
                                              .removeArtistSearchHistoryList(
                                                  artistList[index]);

                                          setState(() {
                                            _searchHistory.removeAt(index);
                                          });
                                        },
                                        icon: Icon(Icons.remove_circle_outline,
                                            color:
                                                Theme.of(context).primaryColor))
                                  ],
                                ),
                              ),
                            );

                          case SearchType.album:
                            List<Album> albumList = _searchHistory
                                .map(((e) => Album.fromJson(e)))
                                .toList();
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AlbumScreen(album: albumList[index])));
                              },
                              child: Container(
                                color: Colors.transparent,
                                margin: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: albumList[index].coverUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              albumList[index].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Container(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              albumList[index].name,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          MySharePreferences
                                              .removeAlbumSearchHistoryList(
                                                  albumList[index]);

                                          setState(() {
                                            _searchHistory.removeAt(index);
                                          });
                                        },
                                        icon: Icon(Icons.remove_circle_outline,
                                            color:
                                                Theme.of(context).primaryColor))
                                  ],
                                ),
                              ),
                            );
                        }
                      }))
        ],
      ),
    );
  }
}

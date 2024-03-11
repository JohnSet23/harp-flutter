import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/models/album.dart';
import 'package:harp/models/song.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/music_player.dart';
import 'package:harp/services/server_request.dart';
import 'package:intl/intl.dart';

class AlbumScreen extends StatefulWidget {
  final Album album;
  const AlbumScreen({Key? key, required this.album}) : super(key: key);

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> with WidgetsBindingObserver {
  String _albumReleasedDate = "";
  String _artistName = "";
  String _genre = "";
  bool _isFavorite = false;
  List<Song> _albumSongList = [];


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _getAlbumSongs();
    _getIsFavoriteAlbum();
  
    super.initState();
  }



  _getIsFavoriteAlbum() async {
    bool isFav = await MySharePreferences.isFavoriteAlbum(widget.album.toJson());
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future _getAlbumSongs() async {
    MyServerRequest
        .httpGetComplexQueryRequest(
            "${"filter[album_id]=${widget.album.id}"}&sort=recent", "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        List<Song> sortedList = (mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList();
        sortedList.sort((a, b) {
          return a.track!.compareTo(b.track!);
        });

        setState(() {
          _albumReleasedDate = DateFormat.yMMMMd('en_US')
              .format(DateTime.parse(mapRes["data"][0]["release_date"]))
              .toString();
          _artistName = mapRes["data"][0]["artist_id"]["name"];
          _genre = mapRes["data"][0]["genre"].join(", ");
          _albumSongList = sortedList;
        });
      } else {
        // print("status failure");
      }
    }).catchError((err) {
      debugPrint(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: 230,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.album.coverUrl,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      "assets/noise.jpg",
                      fit: BoxFit.cover,
                    )),
                Positioned.fill(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 30.0,
                        sigmaY: 30.0,
                      ),
                      child: Container()),
                ),
                Positioned(
                    bottom: 0,
                    child: CachedNetworkImage(
                      imageUrl: widget.album.coverUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ))
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(15),
            height: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                    child: Text(
                  widget.album.name,
                  softWrap: true,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500),
                )),
                Flexible(
                    child: Text(
                  _artistName,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300),
                )),
                Flexible(
                    child: Text(
                  "Release Date - $_albumReleasedDate",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                )),
                Flexible(
                    child: Text(
                  "Genre - $_genre",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                )),
                Container(
                    child: _isFavorite
                        ? ButtonTheme(
                            child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () async {
                                  await MySharePreferences.deleteFavoriteAlbum(
                                      widget.album);
                                  Fluttertoast.showToast(
                                      msg: "${widget.album.name} removed from Favorite",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,                              
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  setState(() {
                                    _isFavorite = !_isFavorite;
                                  });
                                },
                                icon: const Icon(
                                  Icons.favorite_border,
                                
                                ),
                                label: const Text(
                                  "Remove Favorite",
                                
                                )))
                        : ButtonTheme(
                            child: OutlinedButton.icon(
                               
                                  
                                onPressed: () async {
                                  await MySharePreferences.addFavoriteAlbum(
                                      widget.album);
                                  Fluttertoast.showToast(
                                      msg: "${widget.album.name} added to Favorite",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  setState(() {
                                    _isFavorite = !_isFavorite;
                                  });
                                },
                                icon: Icon(Icons.favorite_border,
                                    color: Theme.of(context).primaryColor),
                                label: Text(
                                  "Add Favorite",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ))))
              ],
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return GestureDetector(
            onTap: () {
                   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                          builder: (context) => MusicPlayerPage(
                              songList: _albumSongList,
                              index: index,
                              isSameSong: false)), (route) => route.isFirst);
            },
            child: Container(
              color: Colors.transparent,
              margin: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.0,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: _albumSongList[index].album != null
                                ? CachedNetworkImage(
                                    imageUrl: _albumSongList[index].album!.coverUrl
                                       ,
                                    width: 65,
                                    height: 65,
                                    fit: BoxFit.cover,
                                  )
                                : _albumSongList[index].coverUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: _albumSongList[index].coverUrl!
                                            ,
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/song_cover_placeholder.jpg",
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                _albumSongList[index].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Container(
                                height: 5,
                              ),
                              Text(
                                _albumSongList[index].artist.name,
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: _albumSongList.length))
      ],
    ));
  }
}

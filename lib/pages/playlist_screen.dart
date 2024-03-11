import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/models/song.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/music_player.dart';
import 'package:harp/services/server_request.dart';
import 'package:harp/widgets/dialog.dart';
import 'package:harp/widgets/item/playlist_song_item.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistName;
  final List<Song> playlist;
  final String paginationQuery;
  final String sort;
  final int paginationLimit;
  final bool isMyPlaylist;
  const PlaylistScreen(
      {Key? key,
      required this.playlistName,
      required this.playlist,
      required this.isMyPlaylist,
      required this.paginationQuery,
      required this.sort,
      required this.paginationLimit})
      : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen>
    with WidgetsBindingObserver {
  String _songCover = "";

  final _scrollController = ScrollController();
  bool _songlistScrollLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (widget.paginationQuery.isNotEmpty) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            !_songlistScrollLoading) {
          if (widget.playlist.length < widget.paginationLimit) {
            setState(() {
              _songlistScrollLoading = true;
            });
            _getSongPagination();
          }
        }
      });
    }

    if (widget.playlist.isNotEmpty) {
      int random = Random().nextInt(widget.playlist.length);

      String albumString = widget.playlist[random].coverUrl ?? "";
      if (widget.playlist[random].album != null) {
        albumString = widget.playlist[random].album!.coverUrl;
      }

      setState(() {
        _songCover = albumString;
      });
    }

    super.initState();
  }

  Future _getSongPagination() async {
    String url;

    if (widget.sort == "view") {
      url = widget.paginationQuery + widget.playlist.last.viewCount.toString();
    } else {
      url = widget.paginationQuery + widget.playlist.last.createdAt;
    }

    MyServerRequest.httpGetComplexQueryRequest(url, "song").then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (widget.paginationLimit == 50) {
          if (widget.playlist.length > 35) {
            setState(() {
              _songlistScrollLoading = false;
              widget.playlist.addAll(
                 (mapRes["data"] as List<dynamic>)
                .map((json) => Song.fromJson(json))
                .toList()
                .getRange(0, 10));
            });
          } else {
            setState(() {
              _songlistScrollLoading = false;
              widget.playlist.addAll((mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList());
            });
          }
        }

        if (widget.paginationLimit == 100) {
          setState(() {
            _songlistScrollLoading = false;
            widget.playlist.addAll((mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList());
          });
        }
      } else {}
    }).catchError((err) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Text(
                    widget.playlistName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.playlist_play, color: Colors.white),
                  )
                ],
              ),
              collapseMode: CollapseMode.none,
              centerTitle: true,
              background: Container(
                color: Colors.black,
                child: Opacity(
                    opacity: 0.7,
                    child: _songCover.isEmpty
                        ? Image.asset(
                            "assets/song_cover_placeholder.jpg",
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: _songCover, fit: BoxFit.cover)),
              )),
          expandedHeight: 180,
        ),
        SliverToBoxAdapter(
          child: Container(height: 20),
        ),
        if (widget.playlist.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {

                return PlaylistSongItem( song: widget.playlist[index], isMyPlaylist: widget.isMyPlaylist , index: index, playlistName: widget.playlistName, onLongPress: () async{
                       if (widget.isMyPlaylist) {
                      bool? isYes = await showDeleteDialog(
                          widget.playlist[index].title, context);
                      if (isYes == true) {
                        MySharePreferences.removeSongFromPlaylist(
                            widget.playlistName, widget.playlist[index].id);

                        Fluttertoast.showToast(
                            msg: "${widget.playlistName} Playlist removed from Favorite",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0);

                        setState(() {
                          widget.playlist.removeAt(index);
                        });
                      }
                    }

                }, onTap: (){

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                            songList: widget.playlist,
                            index: index,
                            isSameSong: false)));

                },);
            
              },
              childCount: widget.playlist.length,
            ),
          ),
      ],
    ));
  }
}

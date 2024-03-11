import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/models/album.dart';
import 'package:harp/models/artist.dart';
import 'package:harp/models/song.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/album_screen.dart';
import 'package:harp/pages/music_player.dart';
import 'package:harp/services/server_request.dart';


class ArtistScreen extends StatefulWidget {
  final Artist artist;
  const ArtistScreen({Key? key, required this.artist}) : super(key: key);

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedTab = 0;
  final _scrollController = ScrollController();
  late TabController _tabController;
  bool _isFavorite = false;
  List<Album> _albumList = [];
  List<Song> _songList = [];
  bool _songlistScrollLoading = false;


  Future _getAlbums() async {
    MyServerRequest
        .httpGetQueryRequest("artist_id", widget.artist.id, "album")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        setState(() {
          _albumList = (mapRes["data"] as List<dynamic>)
              .map((json) => Album.fromJson(json))
              .toList();
        });
      } else {}
    }).catchError((err) {});
  }

  Future _getSongs() async {
    MyServerRequest
        .httpGetComplexQueryRequest(
            "${"filter[artist_id]=${widget.artist.id}"}&sort=recent",
            "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        setState(() {
          _songList = (mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList();
        });
      } else {}
    }).catchError((err) {});
  }

  _tabListener() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTab = _tabController.index;
      });
      switch (_tabController.index) {
        case 0:
          break;

        case 1:
          _getAlbums();

          break;
      }
    }
  }



  Future _getSongsPagination(String recent) async {
    MyServerRequest
        .httpGetComplexQueryRequest(
            "filter[artist_id]=${widget.artist.id}&sort=recent&prev_latest=$recent",
            "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        setState(() {
          _songlistScrollLoading = false;
          _songList.addAll((mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList());
        });
      } else {}
    }).catchError((err) {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getSongs();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabListener);
    _getIsFavoriteArtist();
 
    _scrollController.addListener(() {
      if (_selectedTab == 0) {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            !_songlistScrollLoading) {
          setState(() {
            _songlistScrollLoading = true;
          });
          _getSongsPagination(_songList.last.createdAt);
        }
      }
    });
  }

  _getIsFavoriteArtist() async {
    bool isFav = await MySharePreferences.isFavoriteArtist(widget.artist.toJson());
    setState(() {
      _isFavorite = isFav;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
        
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
        
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.black,
   
                child: TabBar(
                  controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Songs"),
                    Tab(text: "Albums"),
                  ],
                ),
              ),
            ),
            pinned: true,
            expandedHeight: 280.0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.none,
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget.artist.imageSource,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  Opacity(
                      opacity: 0.75,
                      child: Image.asset(
                        "assets/noise.jpg",
                        fit: BoxFit.cover,
                      )),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 40.0,
                        sigmaY: 40.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: CachedNetworkImage(
                                imageUrl: widget.artist.imageSource,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.artist.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: _isFavorite
                                        ? ButtonTheme(
                                            child: FilledButton.icon(
                                                style: FilledButton.styleFrom(
                                                 
                                                  shape: const StadiumBorder(),
                                                ),
                                                onPressed: () async {
                                                  await MySharePreferences
                                                      .deleteFavoriteArtist(
                                                          widget.artist);

                                                  Fluttertoast.showToast(
                                                      msg: "${widget
                                                              .artist.name} removed from Favorite",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      
                                                    
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
                                                  style: TextStyle(
                                                      ),
                                                )))
                                        : ButtonTheme(
                                            child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                   ),
                                                onPressed: () async {
                                                  await MySharePreferences
                                                      .addFavoriteArtist(
                                                          widget.artist);

                                                  Fluttertoast.showToast(
                                                      msg: "${widget
                                                              .artist.name} added to Favorite",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
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
                                                label: Text(
                                                  "Add Favorite",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ))))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedTab == 0 && _songList.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return GestureDetector(
                    onTap: () {
                         Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => MusicPlayerPage(
                                          songList: _songList,
                                          index: index,
                                          isSameSong: false)),
                                  (route) => route.isFirst);
                     
                    },
                    child: Container(
                      margin: const EdgeInsets.all(15.0),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _songList[index].album != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: _songList[index].album!.coverUrl
                                        ,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _songList[index].coverUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: _songList[index].coverUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    _songList[index].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                Container(
                                  height: 8,
                                ),
                                _songList[index].album != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          _songList[index].album!.name,
                                          softWrap: true,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                childCount: _songList.length,
              ),
            ),
          if (_selectedTab == 1 && _albumList.isNotEmpty)
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.8),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              AlbumScreen(album: _albumList[index])));
                    },
                    child: Card(
                      margin: index.isEven
                          ? const EdgeInsets.fromLTRB(15.0, 10.0, 7.5, 10.0)
                          : const EdgeInsets.fromLTRB(7.5, 10.0, 15.0, 10.0),
                      color: Colors.black,
                      elevation: 5,
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 5.0),
                              child: CachedNetworkImage(
                                imageUrl: _albumList[index].coverUrl,
                                height: MediaQuery.of(context).size.width / 2 -
                                    40.0,
                                width: MediaQuery.of(context).size.width / 2 -
                                    40.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Flexible(
                                child: Text(
                              _albumList[index].name,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorLight),
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: _albumList.length,
              ),
            ),
        ],
      ),
    );
  }
}

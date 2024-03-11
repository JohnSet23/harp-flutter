import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:harp/models/song.dart';
import 'package:harp/pages/playlist_screen.dart';
import 'package:harp/services/server_request.dart';
import 'package:harp/widgets/item/home_feautured_song_item.dart';
import 'package:harp/widgets/item/home_song_item.dart';
import '../music_player.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  List<Song> _popularInternationalSongs = [];
  List<Song> _popularKpopSongs = [];
  List<Song> _featuredSongs = [];
  List<Song> _gaonChartSongs = [];
  List<Song> _billboardChartSongs = [];

  final _kpopSonglistScrollController = ScrollController();
  final _internationalSonglistScrollController = ScrollController();
  bool _isKpopSonglistScrollLoading = false;
  bool _isInternationalSongsScrollLoading = false;

  Future _getInternationalSongs() async {
    MyServerRequest.httpGetComplexQueryRequest(
            "filter[language]=english&sort=view", "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        setState(() {
          _popularInternationalSongs = (mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList();
        });
      }
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getPopularKpopSongs() async {
    MyServerRequest.httpGetComplexQueryRequest(
            "filter[language]=korean&sort=view", "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        setState(() {
          _popularKpopSongs = (mapRes["data"] as List<dynamic>)
              .map((json) => Song.fromJson(json))
              .toList();
        });
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getFeaturedSongs() async {
    MyServerRequest.httpGetComplexQueryRequest(
            "group=${Uri.encodeComponent("Featured Songs")}", "editor")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (List<dynamic>.from(mapRes["data"]).isNotEmpty) {
          setState(() {
            _featuredSongs = (mapRes["data"][0]["song_list"] as List<dynamic>)
                .map((json) => Song.fromJson(json))
                .toList();
          });
        }
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getBillBoardSongs() async {
    MyServerRequest.httpGetComplexQueryRequest(
            "group=${Uri.encodeComponent("Top 100 Billboard Chart")}", "editor")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (List<dynamic>.from(mapRes["data"]).isNotEmpty) {
          setState(() {
            _billboardChartSongs =
                (mapRes["data"][0]["song_list"] as List<dynamic>)
                    .map((json) => Song.fromJson(json))
                    .toList();
          });
        }
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getGaonChartSongs() async {
    MyServerRequest.httpGetComplexQueryRequest(
            "group=${Uri.encodeComponent("Top 100 Gaon Chart")}", "editor")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (List<dynamic>.from(mapRes["data"]).isNotEmpty) {
          setState(() {
            _gaonChartSongs = (mapRes["data"][0]["song_list"] as List<dynamic>)
                .map((json) => Song.fromJson(json))
                .toList();
          });
        }
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getPopularKpopSongsPagination(String value) async {
    MyServerRequest.httpGetComplexQueryRequest(
            "filter[language]=korean&sort=view&prev_latest=$value", "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (_popularKpopSongs.length > 35) {
          setState(() {
            _isKpopSonglistScrollLoading = false;
            _popularKpopSongs.addAll(List<dynamic>.from(mapRes["data"])
                .map((json) => Song.fromJson(json))
                .toList()
                .getRange(0, 10));
          });
        } else {
          setState(() {
            _isKpopSonglistScrollLoading = false;
            _popularKpopSongs.addAll(List<dynamic>.from(mapRes["data"])
                .map((json) => Song.fromJson(json))
                .toList());
          });
        }
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  Future _getPopularInternationalSongsPagination(String value) async {
    MyServerRequest.httpGetComplexQueryRequest(
            "filter[language]=english&sort=view&prev_latest=$value", "song")
        .then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
        if (_popularInternationalSongs.length > 35) {
          setState(() {
            _isInternationalSongsScrollLoading = false;
            _popularInternationalSongs.addAll(List<dynamic>.from(mapRes["data"])
                .map((json) => Song.fromJson(json))
                .toList()
                .getRange(0, 10));
          });
        } else {
          setState(() {
            _isInternationalSongsScrollLoading = false;
            _popularInternationalSongs.addAll(List<dynamic>.from(mapRes["data"])
                .map((json) => Song.fromJson(json))
                .toList());
          });
        }
      } else {}
    }).catchError((err) {
      debugPrint(err);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getInternationalSongs();
    _getPopularKpopSongs();
    _getFeaturedSongs();
    _getBillBoardSongs();
    _getGaonChartSongs();

    _kpopSonglistScrollController.addListener(() {
      if (_kpopSonglistScrollController.position.pixels ==
              _kpopSonglistScrollController.position.maxScrollExtent &&
          !_isKpopSonglistScrollLoading) {
        if (_popularKpopSongs.length < 50) {
          setState(() {
            _isKpopSonglistScrollLoading = true;
          });
          _getPopularKpopSongsPagination(
              _popularKpopSongs.last.viewCount.toString());
        }
      }
    });

    _internationalSonglistScrollController.addListener(() {
      if (_internationalSonglistScrollController.position.pixels ==
              _internationalSonglistScrollController.position.maxScrollExtent &&
          !_isInternationalSongsScrollLoading) {
        if (_popularInternationalSongs.length < 50) {
          setState(() {
            _isInternationalSongsScrollLoading = true;
          });
          _getPopularInternationalSongsPagination(
              _popularInternationalSongs.last.viewCount.toString());
        }
      }
    });
  }

  @override
  void dispose() {
    _kpopSonglistScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_featuredSongs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  aspectRatio: 1,
                  viewportFraction: 0.5,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
                items: _featuredSongs.map((song) {
                  return HomeFeaturedSongItem(
                    song: song,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PlaylistScreen(
                                playlistName: "Featured Songs",
                                playlist: _featuredSongs,
                                isMyPlaylist: false,
                                paginationLimit: 0,
                                paginationQuery: '',
                                sort: '',
                              )));
                    },
                  );
                }).toList(),
              ),
            ),

          //Billboard Chart
          if (_billboardChartSongs.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlaylistScreen(
                          playlistName: "Top 100 Billboard Chart",
                          playlist: _billboardChartSongs,
                          isMyPlaylist: false,
                          paginationLimit: 0,
                          paginationQuery: '',
                          sort: '',
                        )));
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                child: Row(
                  children: [
                    const Flexible(
                        child: Text("Top 100",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        "assets/billboard_icon.png",
                        width: 75,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Flexible(
                        child: Text("Chart",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          if (_billboardChartSongs.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 230,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _billboardChartSongs.length,
                  itemBuilder: (BuildContext context, int index) =>
                      HomeSongItem(
                        song: _billboardChartSongs[index],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                  songList: _billboardChartSongs,
                                  index: index,
                                  isSameSong: false)));
                        },
                      )),
            ),

          //Gaon Chart
          if (_gaonChartSongs.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlaylistScreen(
                          playlistName: "Top 100 Gaon Chart",
                          playlist: _gaonChartSongs,
                          isMyPlaylist: false,
                          paginationLimit: 0,
                          paginationQuery: '',
                          sort: '',
                        )));
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                child: const Row(
                  children: [
                    Flexible(
                        child: Text("Top 100 Gaon Chart",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),

          if (_gaonChartSongs.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 230,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _gaonChartSongs.length,
                  itemBuilder: (BuildContext context, int index) =>
                      HomeSongItem(
                        song: _gaonChartSongs[index],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                  songList: _gaonChartSongs,
                                  index: index,
                                  isSameSong: false)));
                        },
                      )),
            ),

          //Popular International Songs
          if (_popularInternationalSongs.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlaylistScreen(
                          playlistName: "Top 50 Popular Songs",
                          playlist: _popularInternationalSongs,
                          isMyPlaylist: false,
                          paginationLimit: 50,
                          paginationQuery:
                              "filter[language]=english&sort=view&prev_latest=",
                          sort: 'view',
                        )));
              },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                child: const Text("Top 50 Popular Songs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          if (_popularInternationalSongs.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 230,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  controller: _internationalSonglistScrollController,
                  itemCount: _popularInternationalSongs.length,
                  itemBuilder: (BuildContext context, int index) =>
                      HomeSongItem(
                        song: _popularInternationalSongs[index],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                  songList: _popularInternationalSongs,
                                  index: index,
                                  isSameSong: false)));
                        },
                      )),
            ),

          if (_popularKpopSongs.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlaylistScreen(
                          playlistName: "Top 50 Kpop Songs",
                          playlist: _popularKpopSongs,
                          isMyPlaylist: false,
                          paginationLimit: 50,
                          sort: 'view',
                          paginationQuery:
                              "filter[language]=korean&sort=view&prev_latest=",
                        )));
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                child: const Text("Top 50 Kpop Songs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          if (_popularKpopSongs.isNotEmpty)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularKpopSongs.length,
                  controller: _kpopSonglistScrollController,
                  itemBuilder: (BuildContext context, int index) =>
                      HomeSongItem(
                        song: _popularKpopSongs[index],
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                  songList: _popularKpopSongs,
                                  index: index,
                                  isSameSong: false)));
                        },
                      )),
            ),
          Container(
            height: 10,
          ),
        ],
      ),
    );
  }
}

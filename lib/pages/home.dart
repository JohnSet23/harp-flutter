import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harp/global.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/music_player.dart';
import 'package:harp/pages/search_screen.dart';
import 'package:harp/widgets/play_animation_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'bottom_navigation_bar/favorite_tab.dart';
import 'bottom_navigation_bar/home_tab.dart';
import 'bottom_navigation_bar/settings_tab.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware, WidgetsBindingObserver {
  late HomeTab _homeTab;
  late FavoriteTab _favoriteTab;
  late SettingsTab _settingsTab;
  late List<Widget> _pageList;

  int _currentTab = 0;
  bool isPlayerReady = false;
  String _playerSongTitle = "";
  StreamSubscription<SequenceState?>? _playerSequenceStream;
  StreamSubscription<bool>? _playerPlayingStream;
  final ValueNotifier<bool> _playerPlayingNotifier = ValueNotifier<bool>(false);


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeTab = const HomeTab();
  
    _favoriteTab = const FavoriteTab();
    _settingsTab = const SettingsTab();
    _pageList = [_homeTab, _favoriteTab, _settingsTab];
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    if (_playerSequenceStream != null) {
      _playerSequenceStream!.cancel();
    }
    if (_playerPlayingStream != null) {
      _playerPlayingStream!.cancel();
    }

  
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context)!);
  
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.

    if (player != null) {
      if (player!.processingState != ProcessingState.idle) {
        setState(() {
          isPlayerReady = true;
        });
        _playerPlayingStream = player!.playingStream.listen((event) {
          setState(() {
            _playerPlayingNotifier.value = event;
          });
        });

        _playerSequenceStream = player!.sequenceStateStream.listen((event) {
          setState(() {
            _playerSongTitle = (event!.currentSource!.tag as MediaItem).title;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("HARP", style: TextStyle(color: Colors.white),),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Image.asset(
                "assets/harp_tranparent_white.png",
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SearchScreen()));
            },
            icon: const Icon(Icons.search),
            color: Colors.white,
          )
        ],
      ),
  
      body: IndexedStack(
        index: _currentTab,
        children: _pageList,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        
          !isPlayerReady
              ? Container()
              : (player!.sequenceState != null &&
                      player!.processingState != ProcessingState.idle)
                  ? GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MusicPlayerPage(
                                songList: const [],
                                index: player!.currentIndex!,
                                isSameSong: true)));
                      },
                      child: Container(
                        height: 65.0,
                        width: MediaQuery.of(context).size.width,
                        color: const Color(0xCC000000),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.0),
                                ),
                                child: (player!.sequenceState!.currentSource!
                                                .tag as MediaItem)
                                            .artUri !=
                                        null
                                    ? CachedNetworkImage(
                                        imageUrl: (player!
                                                .sequenceState!
                                                .currentSource!
                                                .tag as MediaItem)
                                            .artUri
                                            .toString(),
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/song_cover_placeholder.jpg",
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      )),
                            Flexible(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _playerSongTitle.isEmpty
                                      ? (player!.sequenceState!.currentSource!
                                              .tag as MediaItem)
                                          .title
                                      : _playerSongTitle,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ValueListenableBuilder<bool>(
                                      builder: (context, value, child) {
                                        return SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: value
                                                ? PlayButton(
                                                    pauseIcon: Icon(
                                                      Icons.pause,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 30,
                                                    ),
                                                    onPressed: () {
                                                      if (player!.playing) {
                                                        player!.pause();
                                                      } else {
                                                        player!.play();
                                                      }
                                                    },
                                                  )
                                                : IconButton(
                                                    onPressed: () {
                                                      if (player!.playing) {
                                                        player!.pause();
                                                      } else {
                                                        player!.play();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.play_arrow,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 30,
                                                    )));
                                      },
                                      valueListenable: _playerPlayingNotifier,
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(right: 25),
                                    child: IconButton(
                                        onPressed: () async {
                                          MySharePreferences
                                              .removePlayingSongList();

                                          player!.stop();
                                          setState(() {
                                            isPlayerReady = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.stop,
                                          color: Theme.of(context).primaryColor,
                                          size: 30,
                                        )))
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.white,
            selectedFontSize: 14,
            selectedIconTheme: const IconThemeData(size: 35),
            elevation: 0,
            backgroundColor: const Color(0xCC000000),
            iconSize: 28,
            currentIndex: _currentTab,
            onTap: (int index) {
              setState(() {
                _currentTab = index;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: "Home",
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home)
              ),
              BottomNavigationBarItem(
                  label: "Favorites", 
                  activeIcon: Icon(Icons.favorite),
                  icon: Icon(Icons.favorite_border_outlined)
                  
                  ),
       
              BottomNavigationBarItem(
                label: "Settings",
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings)
                
              
              ),
            ],
          )
        ],
      ),
    );
  }
}

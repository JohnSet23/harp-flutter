import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/models/album.dart';
import 'package:harp/models/artist.dart';
import 'package:harp/models/song.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/album_screen.dart';
import 'package:harp/pages/artist_screen.dart';
import 'package:harp/widgets/play_animation_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:harp/widgets/player_common.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:harp/global.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<Song> songList;
  final int index;
  final bool isSameSong;

  const MusicPlayerPage(
      {Key? key,
      required this.songList,
      required this.index,
      required this.isSameSong})
      : super(key: key);

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with WidgetsBindingObserver, RouteAware {
  String _songTitle = "";
  String _songCoverSorce = "";
  String _songArtist = "";
  String _albumName = "";
  String _songLyrics = "";
  String _featuredArtist = "";
  String _translationTitle = "";
  final ValueNotifier<bool> _playerPlayingNotifier = ValueNotifier<bool>(false);

  int _index = 0;
  StreamSubscription<SequenceState?>? _playerSequenceStream;
  StreamSubscription<PlayerState?>? _playerStateStream;
  final ValueNotifier<int> _playlistIndexNotifier = ValueNotifier<int>(0);
  List<dynamic> _favouritePlaylist = [];
  List<Song> _songList = [];

  Future<void> _initSongList() async {
    
     _songList = widget.songList;

       setState(() {
        //Song Info
        _songTitle = _songList[widget.index].title;
       if(_songList[widget.index].album !=null)  _songCoverSorce = _songList[widget.index].album!.coverUrl;

       _songArtist = _songList[widget.index].artist.name ;
     if(_songList[widget.index].album !=null)    _albumName = _songList[widget.index].album!.name;
        _songLyrics = _songList[widget.index].lyric ?? "";
        _featuredArtist = _songList[widget.index].featuredArtists ?? "";
        _translationTitle = _songList[widget.index].translationTitle ?? "";
      });

   
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    try {
      await _setAudioSourceForPlayer();

      // Activate the audio session before playing audio.
      if (await session.setActive(true)) {
        _playerStateStream = player!.playerStateStream.listen((event) {
          setState(() {
            _playerPlayingNotifier.value = event.playing;
          });
        });
        _playerSequenceStream = player!.sequenceStateStream.listen((event) {
          _playerSequenceStateListerner(event);
        });
        player!.setVolume(0.5);
        player!.play();
      } else {
        // The request was denied and the app should not play audio
      }
    } catch (e) {
      // print("Error loading audio source: $e");
    }
  }

  _getFavoritePlaylist() async {
    List<dynamic> newPlaylist =
        await MySharePreferences.getFavorteSongPlaylist();
    setState(() {
      _favouritePlaylist = newPlaylist;
    });
  }

  _playerSequenceStateListerner(SequenceState? event) {
    if (mounted) {
      MediaItem tag = event!.currentSource!.tag as MediaItem;
      setState(() {
        //Song Info
        _songTitle = tag.title;
        _songCoverSorce = tag.artUri != null ? tag.artUri.toString() : "";
        _songArtist = tag.artist ?? "";
        _albumName = tag.album ?? "";
        _songLyrics = tag.displaySubtitle ?? "";
        _featuredArtist = tag.extras!["featured_artist"];
        _translationTitle = tag.extras!["translation_title"];

        _index = event.currentIndex;
        _playlistIndexNotifier.value = event.currentIndex;
      });
  
    }
  }

  _setAudioSourceForPlayer() async {
    await player!.setAudioSource(
      ConcatenatingAudioSource(
        // Start loading next item just before reaching it.
        useLazyPreparation: true, // default
        // Customise the shuffle algorithm.
        shuffleOrder: DefaultShuffleOrder(), // default
        // Specify the items in the playlist.
        children: _songList.map((song) {
          return AudioSource.uri(
            Uri.parse(song.source),
            tag: MediaItem(
                // Specify a unique ID for each media item:
                id: song.id,
                // Metadata to display in the notification:
                album: song.album?.name,
                artist: song.artist.name,
                extras: {
                  "featured_artist": song.featuredArtists ?? "",
                  "translation_title": song.translationTitle ?? "",
                  "track": song.track ?? "",
                  "release_date": song.releaseDate?.toIso8601String(),
                  "language": song.language,
                  if (song.album != null) "album": song.album?.toJson(),
                  "artist": song.artist.toJson(),
                  "song": song.toJson()
                },
                title: song.title,
                genre: song.genre.join(', '),
                artUri: song.album != null
                    ? Uri.parse(song.album!.coverUrl)
                    : song.coverUrl != null
                        ? Uri.parse(song.coverUrl!)
                        : null,
                displaySubtitle: song.lyric),
          );
        }).toList(),
      ),
      // Playback will be prepared to start from track1.mp3
      initialIndex: widget.index, // default
      // Playback will be prepared to start from position zero.
      initialPosition: Duration.zero, // default
    );
  }

  _showAddPlayListNameDialog(StateSetter setState) {
    String playlistName = "";

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Color(0xFF212121),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: const Text(
                                      "Add New Playlist",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                iconSize: 25,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                playlistName = value;
                              });
                            },
                            autocorrect: false,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                labelStyle: TextStyle(color: Colors.white),
                                label: Text("Playlist Name")),
                          ),
                        ),
                      ],
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1.0, color: Colors.white),
                              shape: const StadiumBorder()),
                          onPressed: () async {
                            if (playlistName.trim().isNotEmpty) {
                              bool status =
                                  await MySharePreferences.createSongPlaylist(
                                      playlistName);
                              if (!status) {
                                Fluttertoast.showToast(
                                    msg: "Playlist Name Already Exists",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                      
                                setState(() {

                                     _favouritePlaylist.add(
                                    {"name": playlistName, "playlist": []});
                                  
                                });

                                if(!mounted)return;
                                Navigator.of(context).pop();
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Playlist Name Empty",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                          child: const Text(
                            "Save Playlist",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                )),
          );
        });
  }

  _showAddPlayListDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF212121),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                    child: Text(
                                      "Choose Playlist to Add",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                  
                                          fontSize: 19),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAddPlayListNameDialog(setState);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 15.0, 20, 15),
                                child: Icon(
                                  Icons.playlist_add,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(0, 15.0, 10, 15),
                                child: const Text(
                                  "Add New Playlist",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: _favouritePlaylist.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    bool status = await MySharePreferences
                                        .addSongToPlaylist(
                                            _favouritePlaylist[index]["name"],
                                            Song.fromJson((player!
                                                    .sequenceState!
                                                    .currentSource!
                                                    .tag as MediaItem)
                                                .extras!["song"])
                                            );

                                    if (!status) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Song already exists in Playlist",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    } else {
                                    
                                      Fluttertoast.showToast(
                                          msg: "Added to Selected Playlist",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
           if(!mounted)return;
                                            Navigator.of(context).pop();
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 5.0),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 15.0, 20, 15),
                                          child: Icon(
                                            Icons.playlist_play,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            _favouritePlaylist[index]["name"],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ));
              },
            ),
          );
        });
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player!.positionStream,
          player!.bufferedPositionStream,
          player!.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  void showLyricsModalBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Opacity(
          opacity: 0.8,
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25))),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                _songTitle,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            if (_translationTitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _translationTitle,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                _songArtist,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            _songLyrics.isNotEmpty
                                ? _songLyrics
                                : "No Lyrics to show!",
                            style: const TextStyle(
                              height: 2,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
                ],
              )),
        );
      },
    );
  }

  void showPlaylistModalBottomSheet() {
  
    final ValueNotifier<int> songLength = ValueNotifier(0);

   setState(() {
      _songList = player!.sequence!.map((e) {
      return Song.fromJson((e.tag as MediaItem).extras!["song"]);
    }).toList();

    songLength.value = _songList.length;
   });

   

    

    showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Opacity(
            opacity: 0.8,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: Text(
                                      "Current Playlist",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Icon(
                                    Icons.playlist_play_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 35,
                                  ),
                                ],
                              ),
                              IconButton(
                                iconSize: 25,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                        if (player!.sequence != null && _songList.isNotEmpty)
                          Expanded(
                              child: ValueListenableBuilder<int>(
                                  valueListenable: songLength,
                                  builder: (context, length, child) {
                                    return ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _songList.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            if (index != _index) {
                                           
                                                player!.seek(Duration.zero,
                                                    index: index);
                                                if (!player!.playing) {
                                                  player!.play();
                                                }
                                              
                                            }
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            margin: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      player!.sequence!.length >
                                                              1
                                                          ? Container(
                                                              width: 40.0,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                              child: Text(
                                                                "${index + 1}",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            )
                                                          : Container(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          child: _songList[
                                                                          index]
                                                                      .album !=
                                                                  null
                                                              ? CachedNetworkImage(
                                                                  imageUrl: _songList[
                                                                          index]
                                                                      .album!
                                                                      .coverUrl,
                                                                  width: 50,
                                                                  height: 50,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.asset(
                                                                  "assets/song_cover_placeholder.jpg",
                                                                  width: 50,
                                                                  height: 50,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Text(
                                                              _songList[index]
                                                                  .title,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                            ),
                                                            Container(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              _songList[index]
                                                                  .artist
                                                                  .name,
                                                              softWrap: true,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ValueListenableBuilder<int>(
                                                    valueListenable:
                                                        _playlistIndexNotifier,
                                                    builder: (context, value,
                                                        child) {
                                                      return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                          child: value != index
                                                              ? Container()
                                                              : ValueListenableBuilder<
                                                                      bool>(
                                                                  valueListenable:
                                                                      _playerPlayingNotifier,
                                                                  builder:
                                                                      (context,
                                                                          value,
                                                                          child) {
                                                                    return Container(
                                                                      child: value
                                                                          ? SizedBox(
                                                                              width: 43,
                                                                              height: 43,
                                                                              child: PlayButton(
                                                                                pauseIcon: Icon(
                                                                                  Icons.pause,
                                                                                  color: Theme.of(context).primaryColor,
                                                                                  size: 30,
                                                                                ),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    player!.pause();
                                                                                  });
                                                                                },
                                                                              ),
                                                                            )
                                                                          : IconButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  player!.play();
                                                                                });
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.play_arrow,
                                                                                color: Theme.of(context).primaryColor,
                                                                                size: 30,
                                                                              ),
                                                                            ),
                                                                    );
                                                                  }));
                                                    })
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          height: 0.5,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.fromLTRB(
                                              40, 0, 20, 0.0),
                                        );
                                      },
                                    );
                                  }))
                      ],
                    ));
              },
            ));
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    _playerStateStream?.cancel();
    _playerSequenceStream?.cancel();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _prepareInitPlayer();
    _getFavoritePlaylist();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.

    if (player != null) {
      if (player!.processingState != ProcessingState.idle) {
        _playerStateStream = player!.playerStateStream.listen((event) {
          setState(() {
            _playerPlayingNotifier.value = event.playing;
          });
        });

        _playerSequenceStream = player!.sequenceStateStream.listen((event) {
          _playerSequenceStateListerner(event);
        });
      }
    }
  }

  void _prepareInitPlayer() async {
    if (player != null) {
      //player is playing something
      if (widget.isSameSong) {

        
        _playerStateStream = player!.playerStateStream.listen((event) {
          setState(() {
            _playerPlayingNotifier.value = event.playing;
          });
        });

        _playerSequenceStream = player!.sequenceStateStream.listen((event) {
          _playerSequenceStateListerner(event);
        });
      } else {
        //play new song list while player is playing
        player!.stop();
        setState(() {
          _index = widget.index;
        });

        player = AudioPlayer();
        _initSongList();
      }
    } else {
      player = AudioPlayer();
      setState(() {
        _index = widget.index;
      });
      // setSongInfo();

      _initSongList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("HARP"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _songCoverSorce.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: _songCoverSorce,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                )
              : Image.asset(
                  "assets/song_cover_placeholder.jpg",
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
                sigmaX: 35.0,
                sigmaY: 35.0,
              ),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 80.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _songCoverSorce.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _songCoverSorce,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/song_cover_placeholder.jpg",
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              )),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                              child: player != null
                                  ? Text(
                                      player!.sequenceState != null
                                          ? (player!
                                                  .sequenceState!
                                                  .currentSource!
                                                  .tag as MediaItem)
                                              .title
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 24),
                                    )
                                  : Container()),
                          GestureDetector(
                            onTap: () {
                              _playerSequenceStream?.cancel();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ArtistScreen(
                                      artist: Artist.fromJson((player!
                                                  .sequenceState!
                                                  .currentSource!
                                                  .tag as MediaItem)
                                              .extras!["artist"]))
                                              
                                              
                                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                              child: Text(
                                _featuredArtist.isNotEmpty
                                    ? "$_songArtist ft. $_featuredArtist"
                                    : _songArtist,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AlbumScreen(
                                      album: Album.fromJson((player!.sequenceState!
                                              .currentSource!.tag as MediaItem)
                                          .extras!["album"]) )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                              child: Text(
                                _albumName,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite_border_outlined,
                                size: 33,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                _showAddPlayListDialog();
                              },
                            ),
                          ),
                        ],
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Display play/pause button and volume/speed sliders.
                          ControlButtons(player!,
                              widget.songList.length == 1 ? true : false),
                          // Display seek bar. Using StreamBuilder, this widget rebuilds
                          // each time the position, buffered position or duration changes.
                          StreamBuilder<PositionData>(
                            stream: _positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return SeekBar(
                                duration:
                                    positionData?.duration ?? Duration.zero,
                                position:
                                    positionData?.position ?? Duration.zero,
                                bufferedPosition:
                                    positionData?.bufferedPosition ??
                                        Duration.zero,
                                onChangeEnd: player!.seek,
                              );
                            },
                          ),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: IconButton(
                                      iconSize: 28,
                                      onPressed: () {
                                        showLyricsModalBottomSheet();
                                      },
                                      icon: Icon(
                                        Icons.subtitles,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: IconButton(
                                      onPressed: () {
                                        if (player!.loopMode == LoopMode.off) {
                                          setState(() {
                                            player!.setLoopMode(LoopMode.one);
                                          });
                                        } else {
                                          setState(() {
                                            player!.setLoopMode(LoopMode.off);
                                          });
                                        }
                                      },
                                      icon: player!.loopMode == LoopMode.off
                                          ? Icon(
                                              Icons.loop_outlined,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              child: const Icon(
                                                Icons.loop,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: IconButton(
                                      iconSize: 28,
                                      onPressed: () {
                                        showPlaylistModalBottomSheet();
                                      },
                                      icon: Icon(
                                        Icons.playlist_play,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )),
                              ]),
                        ],
                      ),

                      //Banner
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final bool isOneSong;

  const ControlButtons(this.player, this.isOneSong, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Opens volume slider dialog
        IconButton(
          iconSize: 30,
          icon: Icon(
            Icons.volume_up,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        isOneSong
            ? Container()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  iconSize: 55.0,
                  icon: Icon(
                    Icons.skip_previous,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    player.seekToPrevious();
                  },
                ),
              ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return SizedBox(
                width: 55,
                height: 55,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (playing != true) {
              return IconButton(
                iconSize: 55.0,
                icon: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                iconSize: 55.0,
                icon: Icon(
                  Icons.pause,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                iconSize: 55.0,
                icon: Icon(
                  Icons.replay,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),

        isOneSong
            ? Container()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  iconSize: 55.0,
                  icon: Icon(
                    Icons.skip_next,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    player.seekToNext();
                  },
                ),
              ),

        IconButton(
          iconSize: 30,
          icon: player.shuffleModeEnabled
              ? Icon(
                  Icons.shuffle_on_outlined,
                  color: Theme.of(context).primaryColor,
                )
              : Icon(
                  Icons.shuffle_outlined,
                  color: Theme.of(context).primaryColor,
                ),
          onPressed: () {
            player.setShuffleModeEnabled(!player.shuffleModeEnabled);
          },
        ),
      ],
    );
  }
}

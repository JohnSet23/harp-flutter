import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/global.dart';
import 'package:harp/models/album.dart';
import 'package:harp/models/artist.dart';
import 'package:harp/models/song.dart';
import 'package:harp/services/my_share_preferences.dart';
import 'package:harp/pages/album_screen.dart';
import 'package:harp/pages/artist_screen.dart';
import 'package:harp/pages/playlist_screen.dart';
import 'package:harp/widgets/dialog.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({Key? key}) : super(key: key);

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  int _selectedTab = 0;
  List<dynamic> _favoriteSongPlaylist = [];
  List<Artist> _favoriteArtistList = [];
  List<Album> _favoriteAlbumList = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_tabListener);
    _getFavoriteSongPlaylist();
    super.initState();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator
    _getFavoriteSongPlaylist();
    _getFavoriteArtistList();
    _getFavoriteAlbumList();
  }

  _showAddPlayListNameDialog() {
    String playlistName = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
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
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                                _favoriteSongPlaylist.add({"name": playlistName, "playlist": []});
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
              ),
            ),
          );
        });
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
          _getFavoriteAlbumList();

          break;

        case 2:
          _getFavoriteArtistList();

          break;
      }
    }
  }

  _getFavoriteSongPlaylist() async {
    List<dynamic> newSongPlaylist =
        await MySharePreferences.getFavorteSongPlaylist();
    setState(() {
      _favoriteSongPlaylist = newSongPlaylist;
    });
  }

  _getFavoriteArtistList() async {
    List<Artist> newArtistPlaylist =
        await MySharePreferences.getFavoriteArtistList();

    setState(() {
      _favoriteArtistList = newArtistPlaylist;
    });
  }

  _getFavoriteAlbumList() async {
    List<Album> newAlbumPlaylist =
        await MySharePreferences.getFavoriteAlbumList();

    setState(() {
      _favoriteAlbumList = newAlbumPlaylist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "Songs"),
            Tab(text: "Albums"),
            Tab(text: "Artist"),
          ],
        ),
        if (_selectedTab == 0)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showAddPlayListNameDialog();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 15.0, 20, 15),
                        child: Icon(
                          Icons.playlist_add,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 15.0, 10, 15),
                        child: const Text(
                          "Add New Playlist",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.8,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        if (_selectedTab == 0)
          Flexible(
            child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _favoriteSongPlaylist.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () async {
                      bool? isYes = await showDeleteDialog(
                          _favoriteSongPlaylist[index]["name"] + " Playlist",
                          context);
                      if (isYes == true) {
                        await MySharePreferences.deleteSongPlaylist(
                            _favoriteSongPlaylist[index]["name"]);

                        Fluttertoast.showToast(
                            msg: _favoriteSongPlaylist[index]["name"] +
                                " Playlist removed from Favorite",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            textColor: Colors.white,
                            fontSize: 16.0);

                                        
                      

                        setState(() {
                            _favoriteSongPlaylist.removeWhere((element) =>
                            element["name"] ==
                            _favoriteSongPlaylist[index]["name"]);
                        
                        });
                      }
                    },
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PlaylistScreen(
                                playlistName: _favoriteSongPlaylist[index]
                                    ["name"],
                                playlist: (_favoriteSongPlaylist[index]
                                    ["playlist"] as List<dynamic>).map((e) => Song.fromJson(e)).toList(),
                                isMyPlaylist: true,
                                paginationLimit: 0,
                                paginationQuery: '',
                                sort: '',
                              )));
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 18.0, 20, 18),
                            child: Icon(
                              Icons.playlist_play,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _favoriteSongPlaylist[index]["name"],
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 19),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        if (_selectedTab == 1 && _favoriteAlbumList.isNotEmpty)
          Flexible(
              child: ListView.builder(
                  itemCount: _favoriteAlbumList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () async {
                        bool? isYes = await showDeleteDialog(
                            _favoriteAlbumList[index].name, context);
                        if (isYes == true) {
                          await MySharePreferences.deleteFavoriteAlbum(
                              _favoriteAlbumList[index]);

                          Fluttertoast.showToast(
                              msg: "${_favoriteAlbumList[index].name} removed from Favorite",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              fontSize: 16.0);

                          setState(() {
                           _favoriteAlbumList.removeWhere((element) =>
                              element.id ==
                              _favoriteAlbumList[index].id);
                          });
                        }
                      },
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AlbumScreen(album: _favoriteAlbumList[index])));
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
                                      imageUrl: _favoriteAlbumList[index].coverUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                               
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      _favoriteAlbumList[index].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      _favoriteAlbumList[index].name
                                          .toString(),
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })),
        if (_selectedTab == 2 && _favoriteArtistList.isNotEmpty)
          Flexible(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _favoriteArtistList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () async {
                        bool? isYes = await showDeleteDialog(
                            _favoriteArtistList[index].name, context);
                        if (isYes == true) {
                          await MySharePreferences.deleteFavoriteArtist(
                              _favoriteArtistList[index]);

                          Fluttertoast.showToast(
                              msg: "${_favoriteArtistList[index].name} removed from Favorite",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              fontSize: 16.0);    

                          setState(() {
                            _favoriteArtistList.removeWhere((element) =>
                              element.id ==
                              _favoriteArtistList[index].id);
                          });
                        }
                      },
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ArtistScreen(
                                artist: 
                                    _favoriteArtistList[index])));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: _favoriteArtistList[index].imageSource
                                      ,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _favoriteArtistList[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })),
      ],
    );
  }
}

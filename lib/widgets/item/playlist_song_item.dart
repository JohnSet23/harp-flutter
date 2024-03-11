import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harp/models/song.dart';


class PlaylistSongItem extends StatelessWidget {
  final Song song;
  final bool isMyPlaylist;
  final String playlistName;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final int index;
  const PlaylistSongItem({super.key,  required this.isMyPlaylist, required this.index, required this.playlistName, required this.onLongPress, required this.onTap, required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
                  onLongPress: onLongPress,
                  onTap: onTap,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 5),
                          width: 36,
                          child: Text(
                            "${index + 1}.",
                            textAlign: TextAlign.justify,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        song.album != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: song.album!.coverUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : song.coverUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl: song.coverUrl!
                                         ,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              Container(
                                height: 8,
                              ),
                              song.album != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                      song.album!.name,
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
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
  }
}
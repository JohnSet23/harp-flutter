import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';


class HomeSongItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  const HomeSongItem({super.key,required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
                  onTap: onTap,
                  child: Container(
                      width: 130,
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: song.album !=
                                      null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          song
                                              .album!
                                              .coverUrl,
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110,
                                    )
                                  : Container(
                                      child: song
                                                  .coverUrl !=
                                              null
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                 song
                                                      .coverUrl!,
                                              fit: BoxFit.cover,
                                              width: 110,
                                              height: 110,
                                            )
                                          : Image.asset(
                                              "assets/song_cover_placeholder.jpg",
                                              fit: BoxFit.cover,
                                              width: 110,
                                              height: 110,
                                            ))),
                          Container(
                            width: 120,
                            padding: const EdgeInsets.fromLTRB(0.0, 5, 5, 5),
                            child: Text(song.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                               song.artist.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          )
                        ],
                      )),
                );
  }
}
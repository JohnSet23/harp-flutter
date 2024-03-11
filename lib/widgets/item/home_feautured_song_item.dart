import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harp/models/song.dart';


class HomeFeaturedSongItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const HomeFeaturedSongItem({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
                        onTap: onTap,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                song.album != null
                                    ? CachedNetworkImage(
                                        imageUrl: song.album!.coverUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        child: song.coverUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: song.coverUrl!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                "assets/song_cover_placeholder.jpg",
                                                fit: BoxFit.cover),
                                      ),
                                Positioned(
                                    bottom: 0,
                                    child: Container(
                                        alignment: Alignment.center,
                                        width: 200,
                                        height: 90,
                                        color: const Color(0x66000000),
                                        child: Padding(
                                          padding: const EdgeInsets.all(7.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Flexible(
                                                child: Text(song.title,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Flexible(
                                                child: Text(song.artist.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11)),
                                              )
                                            ],
                                          ),
                                        )))
                              ],
                            )),
                      );
  }
}
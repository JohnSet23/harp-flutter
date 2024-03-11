import 'package:flutter/material.dart';
import 'package:harp/pages/request_song.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
 

  _showAboutHarpDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xFF212121),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/harp_tranparent.png",
                          width: 150,
                          height: 150,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                            "@2022 Harp By Kagyii",
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline),
                          ),
                      )
                    ],
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          )))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RequestSong()));
              },
              leading: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              title: const Text(
                "Request a Song",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            color: Theme.of(context).primaryColorLight,
            thickness: 0.3,
          ),
        ),
        ListTile(
            onTap: () {
              _showAboutHarpDialog();
            },
            leading: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(Icons.info_outline,
                  color: Theme.of(context).primaryColorLight),
            ),
            title: const Text(
              "About Harp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            )),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harp/services/server_request.dart';

class RequestSong extends StatefulWidget {
  const RequestSong({Key? key}) : super(key: key);

  @override
  State<RequestSong> createState() => _RequestSongState();
}

class _RequestSongState extends State<RequestSong> {
  String _songName = "";
  String _albumName = "";
  String _artistName = "";
  final _formKey = GlobalKey<FormState>();
  

  @override
  void initState() {
    super.initState();

  }

  Future _requestSong() async {
    MyServerRequest.httpPostRequest("request-song", {
      "song_name": _songName,
      if (_albumName.trim().isNotEmpty) "album_name": _albumName,
      if (_artistName.trim().isNotEmpty) "artist_name": _artistName
    }).then((res) {
      Map<dynamic, dynamic> mapRes = jsonDecode(res.body);

      if (mapRes["status"] == 1) {
       
        Fluttertoast.showToast(
            msg: "$_songName is requested successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Error Requesting Song!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    }).catchError((err) {
      debugPrint(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Song"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      _songName = value;
                    });
                  },
                  validator: (value) {
                    if (value != null) {
                      if (value.trim().isEmpty) {
                        return "Song name is required";
                      } else {
                        return null;
                      }
                    } else {
                      return "Song name is required";
                    }
                  },
                  decoration: const InputDecoration(
                    
                      contentPadding: EdgeInsets.all(8),
                      label: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "* ", style: TextStyle(color: Colors.red)),
                        TextSpan(
                            text: "Song Name",
                            )
                      ],
                      style: TextStyle(color: Colors.white),
                      
                      ))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
             
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      _albumName = value;
                    });
                  },
                  decoration: const InputDecoration(
             
                      contentPadding: EdgeInsets.all(8),
                      label: Text(
                        "Album Name",
                         style: TextStyle(color: Colors.white),
                   
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                
                  autocorrect: false,
                  onChanged: (value) {
                    setState(() {
                      _artistName = value;
                    });
                  },
                  decoration: const InputDecoration(
                   
                      contentPadding: EdgeInsets.all(8),
                      label: Text(
                        "Artist Name",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
       
              Padding(
                padding: const EdgeInsets.all(15),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      shape: const StadiumBorder()),
                  onPressed: () {
                    _requestSong();
                
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    child: const Text(
                      "Request Now",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

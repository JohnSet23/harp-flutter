import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// in this project, audio player is used as global variable.
// can also use audio player with state management library such as provider instead of using it as the global variable

AudioPlayer? player;
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();


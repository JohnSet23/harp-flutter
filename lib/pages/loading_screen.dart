import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harp/constants/color.dart';
import 'package:harp/pages/home.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
 
  void showLoading() async {
    const sec = Duration(milliseconds: 1500);
    Timer(sec, () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    showLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: Image.asset(
              "assets/harp_tranparent.png",
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50.0),
            child: JumpingDotsProgressIndicator(
              color: AppColor.secondaryColor,
              fontSize: 60.0,
              dotSpacing: 5,
            ),
          )
        ],
      ),
    );
  }
}

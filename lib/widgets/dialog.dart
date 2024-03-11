import 'package:flutter/material.dart';
import 'dart:async';


Future<bool?> showDeleteDialog(String value, BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        backgroundColor: const Color(0xFF212121),
        buttonPadding: const EdgeInsets.all(20),
        title: const Row(
          children: [
            Flexible(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
        content: Text.rich(TextSpan(children: [
          const TextSpan(
              text: "Do you want to delete ",
              style: TextStyle(color: Colors.white)),
          TextSpan(
            text: value,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: "?", style: TextStyle(color: Colors.white)),
        ])),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog

          ElevatedButton(
            child: const Text(
              "Yes",
           
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          OutlinedButton(
  
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              )),
        ],
      );
    },
  );
}

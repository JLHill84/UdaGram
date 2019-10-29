import 'package:flutter/material.dart';

class ComposeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.deepOrange.withOpacity(0.1),
        padding: const EdgeInsets.only(right: 16, top: 6, bottom: 12),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16, top: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(width: 1, color: Colors.deepOrange)),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Say your piece...')),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.send,
                  color: Colors.deepOrange,
                ),
              ),
            )
          ],
        ));
  }
}

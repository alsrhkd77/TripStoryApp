import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Center(
        child: LoadingBouncingGrid.square(
          backgroundColor: Colors.blue,
          size: deviceSize.width / 2,
        ),
      ),
    );
  }
}

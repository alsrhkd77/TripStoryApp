import 'package:flutter/material.dart';

class NetworkImageView extends StatefulWidget {
  final String url;
  
  NetworkImageView({this.url});
  
  @override
  _NetworkImageViewState createState() => _NetworkImageViewState();
}

class _NetworkImageViewState extends State<NetworkImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.network(this.widget.url, fit: BoxFit.contain,),
        ),
      ),
    );
  }
}

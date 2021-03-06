import 'package:flutter/material.dart';

class NetworkImageViewPage extends StatefulWidget {
  final String url;

  NetworkImageViewPage({this.url});

  @override
  _NetworkImageViewPageState createState() => _NetworkImageViewPageState();
}

class _NetworkImageViewPageState extends State<NetworkImageViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5.0,
          child: Image.network(
            this.widget.url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

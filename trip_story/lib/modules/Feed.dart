import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:tripstory/modules/UtilityModule.dart';

class Feed extends StatefulWidget {
  final FeedValue FeedContents;

  Feed({Key key, @required this.FeedContents}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Image testimg = new Image.network(
    "https://images.pexels.com/photos/672657/pexels-photo-672657.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
    fit: BoxFit.cover,
  );

  Future<void> getimage() async {
    UtilityModule f_ctr = new UtilityModule();
    //await f_ctr.loadImageList();
    var f = await f_ctr.getImage();
    await f_ctr.UploadFile(f);
    String s = f_ctr.resData['file'];
    testimg = Image.memory(base64Decode(s));
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  /*new Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                              "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
                    ),
                  ),*/
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Text(
                    widget.FeedContents.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              new IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: null,
              )
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Image(
            image: new NetworkImage(widget.FeedContents.img_path[0]),
            height: deviceSize.height / 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: <Widget>[
                  new Icon(
                    Icons.favorite_border,
                  ),
                  new SizedBox(
                    width: 16.0,
                  ),
                  new Icon(
                    Icons.chat_bubble_outline,
                  ),
                  /*new SizedBox(
                      width: 16.0,
                    ),
                    new Icon(Icons.send),*/
                ],
              ),
              new Icon(Icons.bookmark_border)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Container(
                child: Image.network(
                    'https://purepng.com/public/uploads/medium/heart-icon-s4k.png'),
                width: 15,
                height: 15,
                margin: EdgeInsets.symmetric(horizontal: 6.0),
              ),
              Text(
                widget.FeedContents.likes.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(widget.FeedContents.upload_date,
              style: TextStyle(color: Colors.grey), textAlign: TextAlign.right,),
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Divider(
          color: Colors.black,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}

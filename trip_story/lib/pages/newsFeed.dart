import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tripstory/modules/Feed.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:tripstory/modules/UtilityModule.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  UtilityModule connector = new UtilityModule();
  List<FeedValue> feeds = new List<FeedValue>();

  _NewsFeedState() {
    loadFeeds();
  }

  Future<void> loadFeeds() async {
    List<dynamic> result = await connector.getTimeline();
    List<FeedValue> temp = [];
    int count = 0;
    for (var i in result) {
      FeedValue feedValue = new FeedValue(i['img_path'], i['id'], i['name'], i['feed_id'],
          i['content'], i['tag_name'], i['upload_date'], i['likes']);
      temp.add(feedValue);
    }
    setState(() {
      feeds = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Expanded(flex: 1, child: new InstaStories()),
        Flexible(
            child: ListView.builder(
              itemBuilder: (context, index) => Feed(FeedContents: feeds[index]),
              itemCount: feeds.length,
        ))
      ],
    );
  }
}

/*
class NewsFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Expanded(flex: 1, child: new InstaStories()),
        Flexible(child: Feed())
      ],
    );
  }
}
 */

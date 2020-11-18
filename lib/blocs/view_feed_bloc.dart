import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trip_story/handler/feed_handler.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';

class ViewFeedBloc {
  var _feed;
  Map mapInfo = new Map();

  final FeedHandler _handler = new FeedHandler();

  final BehaviorSubject _feedBehavior = new BehaviorSubject();
  final BehaviorSubject _mapInfoBehavior = new BehaviorSubject<Map>();

  Stream get feedStream => _feedBehavior.stream;

  fetchPost(int id, String type) async {
    _feed = await _handler.fetchFeedView(id, type);
    Friend friend = await _handler.fetchAuthorProfile(_feed.author);
    _feed.profile = friend.profile;
    _feedBehavior.sink.add(_feed);
  }

  Set<Marker> makeMarker({var context, var function}) {
    if (_feed == null) {
      return new Set();
    }
    return function(context, _feed.points);
  }

  tapLike() {
    if (_feed.liked) {
      _feed.likes--;
      _feed.liked = false;
    } else {
      _feed.likes++;
      _feed.liked = true;
    }
    _handler.sendLike(_feed.id);
    _feedBehavior.sink.add(_feed);
  }

  dispose() {
    _feedBehavior.close();
    _mapInfoBehavior.close();
  }
}

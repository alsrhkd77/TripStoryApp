import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trip_story/handler/feed_handler.dart';
import 'package:trip_story/handler/friend_handler.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';

class ViewFeedBloc {
  var _feed;
  String _type = '';
  Map mapInfo = new Map();

  final FeedHandler _feedHandler = new FeedHandler();
  final FriendHandler _friendHandler = new FriendHandler();

  final BehaviorSubject _feedBehavior = new BehaviorSubject();
  final BehaviorSubject _mapInfoBehavior = new BehaviorSubject<Map>();

  Stream get feedStream => _feedBehavior.stream;

  fetchPost(int id, String type) async {
    _type = type;
    _feed = await _feedHandler.fetchFeedView(id, type);
    Friend friend = await _friendHandler.fetchProfile(_feed.author);
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
    _feedHandler.sendLike(_feed.id);
    _feedBehavior.sink.add(_feed);
  }

  addComment(){
    _feed.comments++;
    _feedBehavior.sink.add(_feed);
  }

  removeComment(){
    _feed.comments--;
    _feedBehavior.sink.add(_feed);
  }

  Future<String> removeFeed() async {
    if(_type == ''){
      return '올바르지 않은 게시물 입니다.';
    }
    return await _feedHandler.removeFeed(_feed.id, _type);
  }

  dispose() {
    _feedBehavior.close();
    _mapInfoBehavior.close();
  }
}

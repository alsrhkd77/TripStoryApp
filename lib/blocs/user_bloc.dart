import 'package:rxdart/rxdart.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/handler/feed_handler.dart';
import 'package:trip_story/handler/friend_handler.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';

class UserBloc {
  Friend _friend = new Friend();
  List<Post> _postList;
  List<Trip> _tripList;

  final FriendHandler _friendHandler = new FriendHandler();
  final FeedHandler _feedHandler = new FeedHandler();

  final BehaviorSubject _profileBehavior = new BehaviorSubject<Friend>();
  final BehaviorSubject _postBehavior = new BehaviorSubject<List<Post>>();
  final BehaviorSubject _tripBehavior = new BehaviorSubject<List<Trip>>();
  final BehaviorSubject _feedCountBehavior = new BehaviorSubject<int>();

  Stream get profileStream => _profileBehavior.stream;
  Stream get postStream => _postBehavior.stream;
  Stream get tripStream => _tripBehavior.stream;
  Stream get feedCountStream => _feedCountBehavior.stream;

  UserBloc(){
    _feedCountBehavior.sink.add(0);
    _profileBehavior.sink.add(_friend);
  }

  Future<void> fetchAll(String nickName) async {
    await _fetchProfile(nickName);
    await _fetchFeed(nickName);
  }

  _fetchProfile(String nickName) async {
    _friend = await _friendHandler.fetchProfile(nickName);
    _profileBehavior.sink.add(_friend);
  }

  _fetchFeed(String nickName) async {
    if(nickName == Owner().nickName){
      _postList = await _feedHandler.fetchPostList();
      _tripList = await _feedHandler.fetchTripList();
    }else{
      _postList = await _feedHandler.fetchPostList(nickName);
      _tripList = await _feedHandler.fetchTripList(nickName);
    }
    _feedCountBehavior.sink.add(_postList.length + _tripList.length);
    _postBehavior.sink.add(_postList.reversed.toList());
    _tripBehavior.sink.add(_tripList.reversed.toList());
  }

  follow(String nickName){
    _friendHandler.follow(nickName);
    _friend.followed = true;
    _friend.follower = _friend.follower + 1;
    _profileBehavior.sink.add(_friend);
  }

  unfollow(String nickName){
    _friendHandler.unfollow(nickName);
    _friend.followed = false;
    _friend.follower = _friend.follower - 1;
    _profileBehavior.sink.add(_friend);
  }

  dispose(){
    _profileBehavior.close();
    _postBehavior.close();
    _tripBehavior.close();
    _feedCountBehavior.close();
  }

}

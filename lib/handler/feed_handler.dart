import 'dart:convert';

import 'package:trip_story/models/trip.dart';
import 'package:trip_story/provider/post_provider.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/friend.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/provider/friend_provider.dart';
import 'package:trip_story/provider/trip_provider.dart';
import 'package:http/http.dart' as http;

class FeedHandler {
  final PostProvider _postProvider = PostProvider();
  final TripProvider _tripProvider = TripProvider();
  final FriendProvider _friendProvider = FriendProvider();

  Future<List<Post>> fetchPostList([nickName]) async {
    if (nickName != null) {
      return await _postProvider.fetchOtherPostList(nickName);
    } else {
      return await _postProvider.fetchMyPostList();
    }
  }

  Future<List<Trip>> fetchTripList([nickName]) async {
    if (nickName != null) {
      return await _tripProvider.fetchOtherTripList(nickName);
    } else {
      return await _tripProvider.fetchMyTripList();
    }
  }

  Future<Post> fetchFeedView(feedId, type) async {
    switch (type) {
      case 'post':
        return await _postProvider.fetchPostView(feedId);
        break;
      case 'trip':
        return await _tripProvider.fetchTripView(feedId);
        break;
      default:
        throw Exception('Need request data type');
        break;
    }
  }

  Future<List> fetchTimeline(int offset, int limit) async {
    List _list = await _postProvider.fetchTimeline(offset, limit);
    for (int i = 0; i < _list.length; i++) {
      Friend _author =
          await _friendProvider.fetchProfile(_list[i]['item'].author);
      _list[i]['item'].profile = _author.profile;
    }
    return _list;
  }

  Future<void> sendLike(feedId) async {
    http.Response response = await http.post(AddressBook.setLike,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'postId': feedId, 'memberId': Owner().id}));
    var resData = jsonDecode(response.body);
  }
  
  Future<String> removeFeed(feedId, type) async {
    switch (type) {
      case 'post':
        return await _postProvider.removePost(feedId);
        break;
      case 'trip':
        return await _tripProvider.removeTrip(feedId);
        break;
      default:
        throw Exception('Need request data type');
        break;
    }
  }

}

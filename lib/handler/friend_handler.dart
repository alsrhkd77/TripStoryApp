import 'package:trip_story/models/friend.dart';
import 'package:trip_story/provider/friend_provider.dart';

class FriendHandler {
  final FriendProvider _friendProvider = FriendProvider();

  Future<List<Friend>> fetchAll(String nickName, String type) async {
    switch (type) {
      case 'following':
        return await _friendProvider.fetchAllFollowing(nickName);
        break;
      case 'follower':
        return await _friendProvider.fetchAllFollower(nickName);
        break;
      default:
        throw Exception('Need request data type');
        break;
    }
  }

  Future<Friend> fetchProfile(String nickName) async =>
      await _friendProvider.fetchProfile(nickName);

  Future<void> follow(String nickName) async =>
      await _friendProvider.follow(nickName);

  Future<void> unfollow(String nickName) async =>
      await _friendProvider.unfollow(nickName);
}

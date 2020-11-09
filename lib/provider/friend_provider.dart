import 'dart:convert';

import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/models/friend.dart';
import 'package:http/http.dart' as http;

class FriendProvider{
  Future<List<Friend>> fetchAllFollower(String nickName) async {
    List result = new List<Friend>();
    http.Response _response = await http.get(AddressBook.getFollowers + nickName);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for(var data in resData['followerInfos']){
        Friend temp = new Friend();
        temp.fromJson(data);
        result.add(temp);
      }
      return result;
    }
    else if(resData['errors'] != null){
      throw Exception('Failed to load post view value\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to load post view value');
    }
  }

  Future<List<Friend>> fetchAllFollowing(String nickName) async {
    List result = new List<Friend>();
    http.Response _response = await http.get(AddressBook.getFollowing + nickName);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for(var data in resData['followerInfos']){
        Friend temp = new Friend();
        temp.fromJson(data);
        result.add(temp);
      }
      return result;
    }
    else if(resData['errors'] != null){
      throw Exception('Failed to load post view value\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to load post view value');
    }
  }
}
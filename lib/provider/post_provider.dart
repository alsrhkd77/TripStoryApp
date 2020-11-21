import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/post.dart';

class PostProvider {
  Future<List> fetchMyPostList() async {
    List _result = new List<Post>();
    http.Response _response =
        await http.get(AddressBook.getPostList + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        Post _temp = new Post.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
      return _result;
    } else if (resData['errors'] != null) {
      throw Exception('Failed to load post list value\n${resData['errors']}');
    } else {
      throw Exception('Failed to load post list value\nerrors=null');
    }
  }

  Future<List> fetchOtherPostList(String nickName) async {
    List _result = new List<Post>();
    http.Response _response = await http
        .get(AddressBook.getOtherPostList + nickName + '/' + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        Post _temp = new Post.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
      return _result;
    } else if (resData['errors'] != null) {
      throw Exception('Failed to load post list value\n${resData['errors']}');
    } else {
      throw Exception('Failed to load post list value\nerrors=null');
    }
  }

  Future<Post> fetchPostView(feedId) async {
    http.Response _response = await http.get(
        AddressBook.postView + feedId.toString() + '/' + Owner().id.toString());
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      return new Post().fromJson(resData);
    } else if (resData['errors'] != null) {
      throw Exception('Failed to load post view value\n${resData['errors']}');
    } else {
      throw Exception('Failed to load post view value\nerrors=null');
    }
  }

  Future<List<Map>> fetchTimeline(int offset, int limit) async {
    http.Response _response = await http.get(AddressBook.getTimeline +
        Owner().id.toString() +
        '/' +
        offset.toString() +
        '/' +
        limit.toString());
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      List _list = new List<Map>();
      for (var data in resData['items']) {
        Map temp = new Map();
        Post _post = new Post();
        _post.fromJson(data);
        temp['item'] = _post;
        temp['type'] = data['type'];
        _list.add(temp);
      }
      return _list;
    } else if (resData['errors'] != null) {
      throw Exception(
          'Failed to load timeline value at offset=$offset, limit=$limit\n${resData['errors']}');
    } else {
      throw Exception(
          'Failed to timeline value at offset=$offset, limit=$limit\nerrors=null');
    }
  }

  Future<String> removePost(feedId) async {
    http.Response _response = await http
        .delete(AddressBook.postView + feedId.toString() + '/' + Owner().id);
    var resData = jsonDecode(_response.body);
    if (resData['result'] == 'success') {
      return 'success';
    } else if (resData['errors'] != null) {
      print('Failed to remove post\n${resData['errors']}');
      return resData['errors'].toString();
    } else {
      print('Failed to remove post\nerrors=null');
      return 'failed';
    }
  }
}

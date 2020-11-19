import 'dart:convert';

import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/comment.dart';
import 'package:http/http.dart' as http;

class CommentProvider{
  Future<List<Comment>> fetchAllComment(int feedId) async {
    http.Response _response = await http.get(AddressBook.comment + feedId.toString());
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      List _list = new List<Comment>();
      for(var item in resData['commentDetails']){
        Comment _comment = new Comment();
        _comment.fromJson(item);
        _list.add(_comment);
      }
      return _list;
    }
    else if(resData['errors'] != null){
      throw Exception('Failed to load comment list value\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to load comment list value');
    }
  }

  Future<void> addComment(int feedId, String content) async {
    http.Response response = await http.post(AddressBook.addComment,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'memberId': Owner().id, 'postId': feedId.toString(), 'content': content}));
    var resData = jsonDecode(response.body);
    if(resData['result'] == 'success'){
      return 'success';
    }else if(resData['errors'] != null){
      throw Exception('Failed to upload comment\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to upload comment');
    }
  }

  Future<void> removeComment(int commentId) async {
    http.Response _response = await http.delete(AddressBook.comment + commentId.toString());
    var resData = jsonDecode(_response.body);
    if(resData['result'] == 'success'){
      return 'success';
    }else if(resData['errors'] != null){
      throw Exception('Failed to remove comment\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to remove comment');
    }
  }
}
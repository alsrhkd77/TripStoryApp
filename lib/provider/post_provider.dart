import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/post.dart';

class PostProvider {

  Future<Post> fetchPostView(postId) async {
    http.Response _response = await http.get(AddressBook.getPostView +
        postId.toString() +
        '/' +
        Owner().id.toString());
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      return new Post().fromJSON(resData['']);
    }
    else if(resData['errors'] != null){
      throw Exception('Failed to load post view value\n${resData['errors']}');
    }
    else {
      throw Exception('Failed to load post view value');
    }
  }

}

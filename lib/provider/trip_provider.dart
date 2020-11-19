import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/trip.dart';

class TripProvider {
  Future<Trip> fetchTripView(feedId) async {
    http.Response _response = await http.get(AddressBook.tripView +
        feedId.toString() +
        '/' +
        Owner().id.toString());
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      return new Trip().fromJson(resData);
    } else if (resData['errors'] != null) {
      throw Exception('Failed to load post view value\n${resData['errors']}');
    } else {
      throw Exception('Failed to load post view value');
    }
  }

  Future<List<Trip>> fetchMyTripList() async {
    List _result = new List<Trip>();
    http.Response _response =
        await http.get(AddressBook.getTripList + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        Trip _temp = new Trip.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
    }
    return _result;
  }

  Future<List<Trip>> fetchOtherTripList(String nickName) async {
    List _result = new List<Trip>();
    http.Response _response = await http
        .get(AddressBook.getOtherTripList + nickName + '/' + Owner().id);
    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if (state == 'success') {
      for (var value in resData['postThumbnails']) {
        Trip _temp = new Trip.init(
            id: value['postId'],
            content: value['content'],
            writeDate: DateTime.parse(value['createTime']),
            imageList: [value['thumbnailPath'] as String]);
        _result.add(_temp);
      }
    }
    return _result;
  }

  Future<String> removeTrip(feedId) async {
    http.Response _response = await http.delete(AddressBook.tripView + feedId + '/' + Owner().id);
    var resData = jsonDecode(_response.body);
    if (resData['result'] == 'success') {
      return 'success';
    } else if (resData['errors'] != null) {
      print('Failed to remove trip\n${resData['errors']}');
      return resData['errors'].toString();
    } else {
      print('Failed to remove trip\nerrors=null');
      return 'failed';
    }
  }
}

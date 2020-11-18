import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/blocs/edit_post_bloc.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';

class EditTripBloc extends EditPostBloc {
  var feed;
  var feedBehavior;
  final _polylineBehavior = BehaviorSubject<Set>();

  Stream<Set> get polylineStream => _polylineBehavior.stream;

  EditTripBloc(){
    feed = new Trip();
    feedBehavior = BehaviorSubject<Trip>();
    feedBehavior.sink.add(feed);
  }

  switchingUseMaps(){
    feed.useMaps = !feed.useMaps;
    feedBehavior.sink.add(feed);
  }

  setUseMaps(bool value){
    feed.useMaps = value;
    feedBehavior.sink.add(feed);
  }

  bool addPoint(LatLng point, DateTime visit){
    bool result = true;
    if(feed.points.containsKey(point)){
      result = false;
    }else{
      feed.points[point] = new List<DateTime>();
      result = true;
    }
    feed.points[point].add(visit);
    feedBehavior.sink.add(feed);
    updatePolyline();
    return result;
  }

  updatePointVisit(LatLng point, int index, DateTime visit){
    feed.points[point][index] = visit;
    feedBehavior.sink.add(feed);
    updatePolyline();
  }

  removePointVisit(LatLng point, int index){
    feedBehavior.sink.add(feed);
    updatePolyline();
  }

  removePoint(LatLng point) {
    feed.points.remove(point);
    feedBehavior.sink.add(feed);
    updatePolyline();
  }

  ///경로
  updatePolyline() {
    if(feed.points.length < 2){
      return;
    }
    Set<Polyline> _polylines = Set();
    List<DateTime> date = [];
    List<LatLng> list = [];
    for (List<DateTime> d in feed.points.values) {
      date = date + d;
    }
    date.sort();
    for (DateTime t in date) {
      for (LatLng key in feed.points.keys) {
        if (feed.points[key].contains(t)) {
          list.add(key);
        }
      }
    }
    Polyline polyline = new Polyline(
        polylineId: PolylineId("route"),
        visible: true,
        color: Colors.blue,
        width: 4,
        points: list);
    _polylines.add(polyline);
    _polylineBehavior.sink.add(_polylines);
  }

  addPost(Post post){
    feed.postList.add(post);
    feedBehavior.sink.add(feed);
  }

  removePost(index){
    feed.postList.removeAt(index);
    feedBehavior.sink.add(feed);
  }

  @override
  autoDate() {

  }

  @override
  uploadNewFeed() async {
    var request = new http.MultipartRequest("POST", Uri.parse(AddressBook.uploadTrip));
    request.fields['author'] = Owner().id;
    request.fields['content'] = feed.content;
    if (feed.useVisit) {
      request.fields['travelStart'] = DateFormat('yyyy-MM-dd').format(feed.startDate);
      request.fields['travelEnd'] = DateFormat('yyyy-MM-dd').format(feed.endDate);
    }
    if(feed.useMaps){
      for (LatLng k in feed.points.keys){
        for(DateTime d in feed.points[k]){
          var temp = jsonEncode({
            'lat' : k.latitude,
            'lng' : k.longitude,
            'passDate' : DateFormat('yyyy-MM-ddTHH:mm').format(d),
          });
          request.files.add(http.MultipartFile.fromString('courses', temp.toString()));
        }
      }
    }
    for (String i in feed.imageList) {
      request.files.add(await http.MultipartFile.fromPath('images', i));
    }
    for (String t in feed.tagList) {
      request.files.add(http.MultipartFile.fromString('tags', t));
    }
    for (Post p in feed.postList) {
      request.files.add(
          http.MultipartFile.fromString('posts', p.id.toString()));
    }
    //request.fields['postTags'] = formData['memberEmail'];
    /*
    request.files.add(http.MultipartFile.fromString('postTags', 'value1'));
    request.files.add(http.MultipartFile.fromString('postTags', 'value2'));
    request.files.add(http.MultipartFile.fromString('postTags', 'value3'));
     */

    var response = await (await request.send()).stream.bytesToString();
    var resData = jsonDecode(response);
    uploadState = resData['result'];
  }

  @override
  uploadEditFeed() {

  }

  @override
  dispose() {
    super.dispose();
    _polylineBehavior.close();
  }
}
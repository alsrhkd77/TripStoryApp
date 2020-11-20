import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/models/post.dart';

class EditPostBloc {
  var feed;
  List<DateTime> _imgDate = [];
  String uploadState = '-';
  BehaviorSubject feedBehavior;

  Stream get feedStream => feedBehavior.stream;

  EditPostBloc() {
    feed = new Post();
    feedBehavior = BehaviorSubject<Post>();
    feedBehavior.sink.add(feed);
  }

  ///공개 범위
  setScopePrivate(){
    feed.scope = 'private';
    feedBehavior.sink.add(feed);
  }
  setScopePublic(){
    feed.scope = 'public';
    feedBehavior.sink.add(feed);
  }
  setScopeFriend(){
    feed.scope = 'friend';
    feedBehavior.sink.add(feed);
  }

  ///방문 날짜 설정
  switchingUseVisit(){
    feed.useVisit = !feed.useVisit;
    feedBehavior.sink.add(feed);
  }

  setUseVisit(bool value){
    feed.useVisit = value;
    feedBehavior.sink.add(feed);
  }

  setStartDate(DateTime value){
    feed.startDate = value;
    feedBehavior.sink.add(feed);
  }
  
  setEndDate(DateTime value){
    feed.endDate = value;
    feedBehavior.sink.add(feed);
  }

  //방문 날짜 자동 업데이트
  autoDate(){
    if (_imgDate.isEmpty) {
      return;
    } else {
      _imgDate.sort();
      if (_imgDate[0].compareTo(DateTime.now()) < 0) {
        setStartDate(_imgDate[0]);
        for (DateTime d in _imgDate.reversed) {
          if (d.compareTo(DateTime.now()) < 0) {
            setEndDate(d);
            break;
          }
        }
      }
    }
  }

  ///태그 리스트
  addTag(String tagName){
    feed.tagList.add(tagName);
    feedBehavior.sink.add(feed);
  }

  removeTag(int index){
    feed.tagList.removeAt(index);
    feedBehavior.sink.add(feed);
  }

  ///본문
  changeContent(String value){
    feed.content = value;
    feedBehavior.sink.add(feed);
  }

  ///이미지
  addImage(String path, DateTime imgDate){
    feed.imageList.add(path);
    _imgDate.add(imgDate);
    feedBehavior.sink.add(feed);
  }

  removeImage(int _index){
    feed.imageList.removeAt(_index);
    _imgDate.removeAt(_index);
    feedBehavior.sink.add(feed);
  }

  ///업로드
  submit() async {
    await uploadNewFeed();
  }

  bool uploadAble(){
    return feed.imageList.isEmpty;
  }

  uploadNewFeed() async {
    var request = new http.MultipartRequest("POST", Uri.parse(AddressBook.uploadPost));
    request.fields['author'] = Owner().id;
    request.fields['content'] = feed.content;
    request.fields['scope'] = feed.scope.toUpperCase();
    if (feed.useVisit) {
      request.fields['visitStart'] = DateFormat('yyyy-MM-dd').format(feed.startDate);
      request.fields['visitEnd'] = DateFormat('yyyy-MM-dd').format(feed.endDate);
    }
    for (String i in feed.imageList) {
      //var image = await ImagePicker().getImage(source: ImageSource.gallery);
      request.files.add(await http.MultipartFile.fromPath('images', i));
    }
    for (String t in feed.tagList) {
      request.files.add(http.MultipartFile.fromString('tags', t));
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
    print(resData);
  }

  uploadEditFeed(){

  }

  //소멸
  dispose(){
    feedBehavior.close();
  }
}
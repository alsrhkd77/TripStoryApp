import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/common_table.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/handler/friend_handler.dart';
import 'package:trip_story/models/friend.dart';
import 'package:http/http.dart' as http;

class FriendBloc{
  List<Friend> _friendList;
  Set<Friend> _result;
  String _searchWord;
  bool owner = false;
  String _title;
  final _friendHandler = FriendHandler();
  final _listBehavior = BehaviorSubject<Set>();
  final _searchWordBehavior = BehaviorSubject<String>();
  final _titleBehavior = BehaviorSubject<String>();

  Stream<Set> get listStream => _listBehavior.stream;
  Stream<String> get textStream => _searchWordBehavior.stream;
  Stream<String> get titleStream => _titleBehavior.stream;

  FriendBloc(){
    _searchWord = '';
    _title = '';
    _titleBehavior.sink.add(_title);
    _searchWordBehavior.sink.add(_searchWord);
  }

  searchFriend(String value){
    _result.clear();
    _searchWord = value;
    _searchWordBehavior.sink.add(_searchWord);
    _listBehavior.sink.add(_result);
    _friendList.forEach((element) {
      if(element.nickName.contains(value)){
        _result.add(element);
      }
      else if(element.name.contains(value)){
        _result.add(element);
      }
    });
    _listBehavior.sink.add(_result);
  }

  fetchAllData(String nickName, String type) async {
    if(Owner().nickName == nickName){
      owner = true;
    }
    _result = new Set<Friend>();
    _friendList = await _friendHandler.fetchAll(nickName, type);
    _result.addAll(_friendList);
    _title = '${_friendList.length} ${CommonTable.relation[type]}';
    _titleBehavior.sink.add(_title);
    _listBehavior.sink.add(_result);
  }

  unfollow(Friend friend) async {
    _result.remove(friend);
    _friendList.remove(friend);
    _listBehavior.sink.add(_result);
    http.Response response = await http.delete(AddressBook.friends + '/${Owner().id}/${friend.nickName}',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
  }

  dispose(){
    _listBehavior.close();
    _searchWordBehavior.close();
    _titleBehavior.close();
  }
}
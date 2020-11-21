import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/common_table.dart';

class SearchPlacePage extends StatefulWidget {
  @override
  _SearchPlacePageState createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  //sample url = https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=%EA%B2%BD%EB%B3%B5%EA%B6%81&key=AIzaSyC_7UI-khusysXGe22E6MUuphBbepTsZss
  String _status = 'ZERO_RESULTS';
  List _placeList = new List();

  getPlaceList(String value) async {
    http.Response _response = await http.get(
        'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=' +
            AddressBook.googleMapsKey +
            '&input=' +
            value);
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      setState(() {
        _status = resData['status'];
      });
      if (_status == 'OK') {
        setState(() {
          _placeList = resData['predictions'];
        });
      }
      print(resData);
    } else {
      throw Exception('Failed to search place value');
    }
  }

  buildListView() {
    if (_status == 'OK') {
      return ListView.separated(
          separatorBuilder: (context, index) => Divider(
                color: Colors.black26,
              ),
          shrinkWrap: true,
          itemCount: _placeList.length,
          itemBuilder: (context, index) {
            return placeTile(index);
          });
    } else {
      String text = CommonTable.googlePlaceApiStatus[_status];
      if (text == null) {
        text = '검색 결과가 없습니다.';
      }
      return Center(
        child: Text(text),
      );
    }
  }

  Widget placeTile(int index) {
    return ListTile(
      title: Text(_placeList[index]['structured_formatting']['main_text']),
      subtitle: Text(_placeList[index]['description']),
      trailing: OutlineButton(
        child: Text('선택'),
        onPressed: () {
          Map value = new Map();
          value['placeName'] =
              _placeList[index]['structured_formatting']['main_text'];
          value['placeId'] = _placeList[index]['place_id'];
          Navigator.pop(context, value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장소 검색'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///검색 위젯
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15.0),
              child: TextFormField(
                maxLength: 20,
                onChanged: (value) {
                  setState(() {
                    _placeList = new List();
                  });
                  getPlaceList(value);
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search'),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: buildListView(),
            ),
          ],
        ),
      ),
    );
  }
}

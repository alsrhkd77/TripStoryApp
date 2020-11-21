import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/paged_image_view.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/provider/post_provider.dart';

class SelectPostPage extends StatefulWidget {
  final selected;

  const SelectPostPage({Key key, this.selected}) : super(key: key);

  @override
  _SelectPostPageState createState() => _SelectPostPageState();
}

class _SelectPostPageState extends State<SelectPostPage> {
  List<Post> list;
  Map result = new Map();

  @override
  void initState() {
    super.initState();
    result['status'] = 'loading';
    getMyPosts();
  }

  Future<void> getMyPosts() async {
    List<Post> _list = new List();
    PostProvider _postProvider = new PostProvider();
    http.Response _response =
        await http.get(AddressBook.getMyPostList + Owner().id);
    print(_response.body);
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      if (resData['result'] == 'success') {
        for (var id in resData['posts']) {
          Post _post;
          _post = await _postProvider.fetchPostView(id);
          if(this.widget.selected.isEmpty){
            _list.add(_post);
          }else{
            for(int i=0; i<this.widget.selected.length; i++){
              if(this.widget.selected[i].id == _post.id){
                break;
              }
              if(i == this.widget.selected.length - 1){
                _list.add(_post);
              }
            }
          }
        }
        setState(() {
          result['status'] = 'success';
          list = _list;
        });
      } else if (resData['errors'] != null) {
        setState(() {
          result['status'] = resData['errors'];
        });
      } else {
        setState(() {
          result['status'] = '서버 에러\n잠시후 다시 시도해주세요';
        });
      }
    } else {
      setState(() {
        result['status'] = '잘못된 요청입니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 선택'),
      ),
      body: result['status'] == 'success'
          ? Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 4 / 5,
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(12.0),
                        height: MediaQuery.of(context).size.width * 4 / 5,
                        child: InkWell(
                          child: Card(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 2.0,
                            child: Stack(
                              fit: StackFit.passthrough,
                              children: [
                                PagedImageView(
                                  list: list[index].imageList,
                                  fit: BoxFit.cover,
                                  zoomAble: false,
                                ),
                                Positioned(
                                  child: Container(
                                    color: Color.fromRGBO(0, 0, 0, 80),
                                    //width: MediaQuery.of(context).size.width * 4 / 5,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: list[index].liked
                                              ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.white54,
                                                ),
                                          onPressed: (){},
                                        ),
                                        Text(
                                          list[index].likes.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 25.0,
                                        ),
                                        Icon(
                                          Icons.mode_comment_outlined,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          list[index].comments.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  bottom: 0,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Positioned(
                                  child: Text(DateFormat('yyyy. MM. dd')
                                      .format(list[index].writeDate), style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                                  bottom: 15,
                                  right: 12,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context, list[index]);
                            //TODO: connect post
                            /*
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ViewPostPage()));
                       */
                          },
                        ),
                      );
                    }),
              ),
            )
          : Center(
              child: LoadingBouncingGrid.square(
                inverted: true,
                backgroundColor: Colors.blueAccent,
                size: 150.0,
              ),
            ),
    );
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/edit_post_bloc.dart';
import 'package:trip_story/common/common_table.dart';
import 'package:trip_story/common/image_data.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/page/edit_feed_template.dart';

class EditPostPage extends StatefulWidget {
  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  final EditPostBloc _bloc = new EditPostBloc();
  final EditFeedTemplate _template = new EditFeedTemplate();

  ///이미지 리스트
  Widget buildImageView() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              child: PageView.builder(
                controller: _pageController,
                itemCount: snapshot.data.imageList.length + 1,
                itemBuilder: (_, i) {
                  if (i == snapshot.data.imageList.length) {
                    return InkWell(
                      child: Container(
                        margin: EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0, color: Colors.blueAccent),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0))),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: addImage,
                    );
                  } else {
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            image: Image.file(
                              File(snapshot.data.imageList[i]),
                            ).image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      onTap: () => _bloc.removeImage(i),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_bloc.uploadAble()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('이미지가 1개 이상 필요합니다.'),
      ));
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              title: Text('업로드 중입니다'),
              content: Container(
                padding: EdgeInsets.all(15.0),
                child: LoadingBouncingGrid.square(
                  inverted: true,
                  backgroundColor: Colors.blueAccent,
                  size: 90.0,
                ),
              ),
            ),
          );
        });
    await _bloc.submit();
    Navigator.pop(context);
    if (_bloc.uploadState == 'success') {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => MainStatefulWidget()),
          (route) => false);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('업로드에 실패하였습니다.\n다시 시도해주세요.'),
      ));
    }
  }

  Future<void> addImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              title: Text('이미지를 추가하는 중입니다'),
              content: Container(
                padding: EdgeInsets.all(15.0),
                child: LoadingBouncingGrid.square(
                  backgroundColor: Colors.blueAccent,
                  size: 90.0,
                ),
              ),
            ),
          );
        });

    //check image format
    String check = image.path.toString().toUpperCase();
    for (String type in CommonTable.imageFormat) {
      if (check.endsWith(type)) {
        DateTime _imgDate = await ImageData.getImageDateTime(image.path);
        await _bloc.addImage(image.path, _imgDate);
        Navigator.pop(context);
        return;
      }
    }
    Navigator.pop(context);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('지원하지 않는 이미지 형식 입니다.\n다른 이미지를 사용해주세요.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _template.buildScope(_bloc),
            _template.buildDateTime(_bloc),
            buildImageView(),
            SizedBox(height: 15.0),
            _template.buildTagView(
              context: context,
              bloc: _bloc,
            ),
            SizedBox(height: 12.0),
            _template.buildContent(_bloc),
            _template.buildSubmit(
              context: context,
              onPressed: _submit,
            ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}

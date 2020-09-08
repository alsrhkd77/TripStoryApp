import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tripstory/modules/FeedValue.dart';
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/pages/feedInfo.dart';

import 'URLBook.dart';

class UtilityModule {
  //final String _uploadURL = "http://192.168.0.13:8080/upload";
  //final String _uploadURL = "http://113.198.235.225:8080/uploadfile";
  final String _uploadURL = "https://tripstory.ga/test"; //mac server
  final String _postUploadURL = "https://tripstory.ga/feed"; //mac server
  final String _downloadBaseURL = "http://192.168.0.13:8080/get-image";
  final String _requestTimelineURL = "https://tripstory.ga/feeds";
  String _imagePath;
  List<Asset> _imageList;

  Map<String, dynamic> resData;
  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImage = new List();
  List allNameList = new List();

  Future<void> loadImageList() async {
    Map<dynamic, dynamic> allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print(" call $allImageTemp.length");
    this.allImage = allImageTemp['URIList'] as List;
    this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
  }

  Future<String> getImage() async {
    await _findImage();
    return _imagePath;
  }

  List<Asset> getImageList() {
    loadAssets();
    return _imageList;
  }

  Future _findImage() async {
    //pick one image
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _imagePath = image.path;
    printExifOf(_imagePath);
  }

  Future<void> loadAssets() async {
    //pick image list
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: resultList,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Trip Stroy",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    _imageList = resultList;
  }

  Future<void> UploadFiles() async {
    await loadAssets();
    var iter = _imageList.iterator;
    while (iter.moveNext()) {
      await UploadFile("iter.current");
    }
  }

  Future<void> UploadFile(String imagePath) async {
    File f = File(imagePath);
    //var stream = new http.ByteStream(DelegatingStream.typed(f.openRead()));
    String stream = base64Encode(f.readAsBytesSync());
    //var length = await f.length();

    var uri = Uri.parse(_uploadURL);

    //var request = new http.MultipartRequest("POST", uri);

    Map<String, dynamic> value = {
      'id': 'qweqewq'
          '',
      'file': stream
    };

    http.Response response = await http.post(_uploadURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));

    //resData = jsonDecode(response.body);
    print(response.body);
    //print('${resData['id']}');

    /*
    var multipartFile = new http.MultipartFile('file', stream, length,
        //filename: basename(f.path));
        filename: "file.jpg");
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    request.fields['name'] = 'test';
    var response = await request.send();

    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
     */
  }

  Future<void> uploadPost(String tag, String content, List<String> path) async {
    List<String> streams = [];
    List<String> nameList = [];
    for (var item in path) {
      File f = File(item);
      String stream = base64Encode(f.readAsBytesSync());
      streams.add(stream);
      nameList.add(basename(item));
    }

    Map<String, dynamic> value = {
      'id': UserInfo().getUserId(),
      'tag': tag,
      'content': content
      //, 'img_names' : nameList
      ,
      'imgs': streams
    };

    http.Response response = await http.post(_postUploadURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
  }

  Future<String> addComment(String feed_id, String content) async {
    Map<String, dynamic> value = {
      'feed_id': feed_id,
      'comment': content,
      'user_id': UserInfo().getUserId()
    };

    http.Response response = await http.post(URLBook.add_comment,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
    return response.body;
  }

  Future<String> delComment(String feed_id, int numb) async {
    Map<String, dynamic> value = {'feed_id': feed_id, 'number': numb};

    http.Response response = await http.post(URLBook.del_comment,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    print(response.body);
    return response.body;
  }

  Future<List> getTimeline() async {
    Map<String, dynamic> value = {'id': UserInfo().getUserId()};

    http.Response response = await http.post(_requestTimelineURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    var result = jsonDecode(response.body);
    return result;
  }

  Future<List<FeedValue>> getMyPost() async {
    //단일 게시물들 가져오기
    Map<String, dynamic> value = {'id': UserInfo().getUserId()};

    http.Response response = await http.post(_requestTimelineURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    List<FeedValue> result = [];
    for (var i in jsonDecode(response.body)) {
      FeedValue temp = new FeedValue(
          i['img_path'],
          i['id'],
          i['name'],
          i['feed_id'],
          i['contents'],
          i['tag_name'],
          i['upload_date'],
          i['likes']);
      result.add(temp);
    }
    return result;
  }

  printExifOf(String path) async {
    Map<String, IfdTag> data =
        await readExifFromBytes(await new File(path).readAsBytes());

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return;
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    for (String key in data.keys) {
      print("$key (${data[key].tagType}): ${data[key]}");
    }
  }

  getImageLatLang(String path) async {
    Map<String, IfdTag> data =
        await readExifFromBytes(await new File(path).readAsBytes());

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return;
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }
    var lat = data['GPS GPSLatitude'].values;
    var lang = data['GPS GPSLongitude'].values;
    print("lat: " + lat.toString());
    print("lang" + lang.toString());
    double resultLat = int.parse(lat[0].toString()) +
        (int.parse(lat[1].toString()) / 60) +
        ((int.parse(lat[2].toString().split('/')[0]) /
                int.parse(lat[2].toString().split('/')[1])) /
            3600);
    double resultLang = int.parse(lang[0].toString()) +
        (int.parse(lang[1].toString()) / 60) +
        ((int.parse(lang[2].toString().split('/')[0]) /
                int.parse(lang[2].toString().split('/')[1])) /
            3600);
    return {'lat': resultLat, 'lang': resultLang};
  }

  //feedvalue 리스트를 받아 태그 리스트를 만들어 반환
  Map<String, int> getFeedTags(List<FeedValue> value) {
    Map<String, int> result = Map<String, int>();
    for (var i in value) {
      if (result.containsKey(i.tag_name)) {
        result[i.tag_name]++;
      } else {
        result[i.tag_name] = 1;
      }
    }
    return result;
  }
}

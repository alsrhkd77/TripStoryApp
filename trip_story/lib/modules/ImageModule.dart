import 'dart:collection';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:image_picker/image_picker.dart';

class ImageModule {
  Map<dynamic, dynamic> _allImageInfo = new HashMap();
  String _imagePath;

  Future<void> loadImageList() async {
    _allImageInfo = await FlutterGallaryPlugin.getAllImages;
    print(" call $_allImageInfo.length");
    /*
    this.allImage = allImageTemp['URIList'] as List;
    this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
     */
  }

  void sortImageList(){

  }

  Future<String> getImage() async {
    await _findImage();
    return _imagePath;
  }

  Future _findImage() async {
    //pick one image
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _imagePath = image.path;
  }

  //안씀 참고용
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

}
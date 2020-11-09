import 'dart:io';
import 'package:exif/exif.dart';
import 'package:http/http.dart' as http;

class ImageData {
  static getImageData(String path) async {
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

    /// Get Date of Photography
    /*
    var dateTime = DateTime.parse(data['Image DateTime']
        .toString()
        .replaceFirst(":", "-")
        .replaceFirst(":", "-"));
    print(dateTime);
     */

    /// GET Photograph Location
    if (data.containsKey('GPS GPSLatitude') &&
        data.containsKey('GPS GPSLongitude')) {
      var preLat = data['GPS GPSLatitude'].values;
      var preLong = data['GPS GPSLongitude'].values;
      var _lat = _calcLatLong(
          preLat[0].toString(), preLat[1].toString(), preLat[2].toString());
      var _lang = _calcLatLong(
          preLong[0].toString(), preLong[1].toString(), preLong[2].toString());
      print(_lat.toString() + '  ' + _lang.toString());
    }

    //print all exif data
    /*
    for (String key in data.keys) {
      print("$key (${data[key].tagType}): ${data[key]}");
    }
     */
  }

  static Future<DateTime> getImageDateTime(String path) async {
    DateTime result;
    if (path.startsWith('http')) {
      result = await _getNetworkImageDateTime(path);
    } else {
      result = await _getLocalImageDateTime(path);
    }
    return result;
  }

  static Future<Map<String, double>> getImageLocation(String path) async {
    Map<String, double> result;
    if (path.startsWith('http')) {
      result = await _getNetworkImageLocation(path);
    } else {
      result = await _getLocalImageLocation(path);
    }
    return result;
  }

  static Future<DateTime> _getLocalImageDateTime(String path) async {
    Map<String, IfdTag> data =
        await readExifFromBytes(await new File(path).readAsBytes());

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return DateTime.now().add(new Duration(days: 1));
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    if (data.keys.contains('Image DateTime')) {
      /// Get Date of Photography
      DateTime dateTime = DateTime.parse(data['Image DateTime']
          .toString()
          .replaceFirst(":", "-")
          .replaceFirst(":", "-"));
      return dateTime;
    } else {
      print("No DateTime information found\n");
      return DateTime.now().add(new Duration(days: 1));
    }
  }

  static Future<DateTime> _getNetworkImageDateTime(String url) async {
    http.Response response = await http.get(url);
    Map<String, IfdTag> data = await readExifFromBytes(response.bodyBytes);

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return DateTime.now().add(new Duration(days: 1));
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    if (data.keys.contains('Image DateTime')) {
      /// Get Date of Photography
      DateTime dateTime = DateTime.parse(data['Image DateTime']
          .toString()
          .replaceFirst(":", "-")
          .replaceFirst(":", "-"));
      print(dateTime);
      return dateTime;
    } else {
      print("No DateTime information found\n");
      return DateTime.now().add(new Duration(days: 1));
    }
  }

  static double _calcLatLong(String DD, String MM, String SS) {
    double result, dd, mm, ss;
    if (DD.indexOf('/') < 0) {
      dd = double.parse(DD);
    } else {
      dd = double.parse(DD.split('/')[0]) / double.parse(DD.split('/')[1]);
    }
    if (MM.indexOf('/') < 0) {
      mm = double.parse(MM);
    } else {
      mm = double.parse(MM.split('/')[0]) / double.parse(MM.split('/')[1]);
    }
    if (SS.indexOf('/') < 0) {
      ss = double.parse(SS);
    } else {
      ss = double.parse(SS.split('/')[0]) / double.parse(SS.split('/')[1]);
    }
    result = dd + (mm / 60) + (ss / 3600);
    return result;
  }

  static Future<Map<String, double>> _getLocalImageLocation(String path) async {
    Map<String, double> result = Map();
    result['none'] = 1.0;
    Map<String, IfdTag> data =
        await readExifFromBytes(await new File(path).readAsBytes());

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return result;
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    /// GET Photograph Location
    if (data.containsKey('GPS GPSLatitude') &&
        data.containsKey('GPS GPSLongitude')) {
      result['none'] = 0.0;
      var preLat = data['GPS GPSLatitude'].values;
      var preLong = data['GPS GPSLongitude'].values;
      var _lat = _calcLatLong(
          preLat[0].toString(), preLat[1].toString(), preLat[2].toString());
      var _long = _calcLatLong(
          preLong[0].toString(), preLong[1].toString(), preLong[2].toString());
      result['lat'] = _lat;
      result['lng'] = _long;
      print(_lat.toString() + '  ' + _long.toString());
    }
    return result;
  }

  static Future<Map<String, double>> _getNetworkImageLocation(
      String url) async {
    Map<String, double> result = Map();
    result['none'] = 1.0;
    http.Response response = await http.get(url);
    Map<String, IfdTag> data = await readExifFromBytes(response.bodyBytes);

    if (data == null || data.isEmpty) {
      print("No EXIF information found\n");
      return result;
    }

    if (data.containsKey('JPEGThumbnail')) {
      print('File has JPEG thumbnail');
      data.remove('JPEGThumbnail');
    }
    if (data.containsKey('TIFFThumbnail')) {
      print('File has TIFF thumbnail');
      data.remove('TIFFThumbnail');
    }

    /// GET Photograph Location
    if (data.containsKey('GPS GPSLatitude') &&
        data.containsKey('GPS GPSLongitude')) {
      result['none'] = 0.0;
      var preLat = data['GPS GPSLatitude'].values;
      var preLong = data['GPS GPSLongitude'].values;
      var _lat = _calcLatLong(
          preLat[0].toString(), preLat[1].toString(), preLat[2].toString());
      var _long = _calcLatLong(
          preLong[0].toString(), preLong[1].toString(), preLong[2].toString());
      result['lat'] = _lat;
      result['lng'] = _long;
      print(_lat.toString() + '  ' + _long.toString());
    }
    return result;
  }
}

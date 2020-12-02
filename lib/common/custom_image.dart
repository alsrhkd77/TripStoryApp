import 'dart:io';

import 'package:flutter/material.dart';

class CustomImage {
  Widget image;

  CustomImage(String path) {
    if (path.startsWith('http')) {
      this.image = Image.network(
        path,
        fit: BoxFit.contain,
      );
    } else {
      this.image = Image.file(
        File(path),
      );
    }
  }
}

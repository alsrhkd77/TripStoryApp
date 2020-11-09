import 'package:flutter/material.dart';

class CommonTable {
  static final Map scope = {
    'public': ['전체 공개  ', Icons.public],
    'friend': ['친구 공개  ', Icons.group],
    'private': ['비공개  ', Icons.lock]
  };

  static final Map relation = {'follower': '팔로워', 'following': '팔로잉'};
}

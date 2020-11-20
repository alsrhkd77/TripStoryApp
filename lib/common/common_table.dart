import 'package:flutter/material.dart';

class CommonTable {
  static final Map scope = {
    'public': ['전체 공개  ', Icons.public],
    'friend': ['친구 공개  ', Icons.group],
    'private': ['비공개  ', Icons.lock]
  };

  static final Map googlePlaceApiStatus = {
    'ZERO_RESULTS': '검색 결과가 없습니다.',
    'OVER_QUERY_LIMIT': '서비스 이용 불가',
    'UNKNOWN_ERROR': '다시 시도해주세요.',
    'INVALID_REQUEST' : '유효하지 않은 요청입니다.',
  };

  static final Map relation = {'follower': '팔로워', 'following': '팔로잉'};

  static final List<String> imageFormat = [
    '.JPEG',
    '.JPG',
    '.PNG',
    '.GIF',
    '.WEBP',
    '.BMP',
    '.WBMP'
  ];
}

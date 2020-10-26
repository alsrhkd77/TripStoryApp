import 'package:flutter/material.dart';

/*
App Bar 제거용
Scaffold의 appBar에 이거 사용
 */

class BlankAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

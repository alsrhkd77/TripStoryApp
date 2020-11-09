import 'package:flutter/material.dart';
import 'package:trip_story/common/owner.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String uploadingState = '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 프로필'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(25.0),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 4,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    radius: (MediaQuery.of(context).size.width / 4) - 2.5,
                    backgroundImage: NetworkImage(Owner().profile),
                  ),
                ),
              )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 4 / 5,
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.blueAccent),
                child: Text('프로필 사진 변경'),
                onPressed: () {},
              ),
            ),
            SizedBox(height: 15.0,),
            ListTile(
              leading: Icon(Icons.face),
              title: Text(Owner().name),
              subtitle: Text('이름'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(Owner().email),
              subtitle: Text('email'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(Owner().nickName),
              subtitle: Text('닉네임'),
              trailing: IconButton(
                icon: Icon(Icons.create),
                onPressed: (){},
              )
            ),
          ],
        ),
      ),
    );
  }
}

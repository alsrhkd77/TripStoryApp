import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tripstory/modules/blank_appbar.dart';
import 'package:http/http.dart' as http;

class Regist extends StatefulWidget {
  @override
  _RegistState createState() => _RegistState();
}

class _RegistState extends State<Regist> {
  final formKey = new GlobalKey<FormState>();
  final idKey = new GlobalKey<FormState>();
  String _id;
  String _password;
  String _name;
  Size deviceSize;

  void checkID() {
    final idForm = idKey.currentState;
    if (idForm.validate()) {
      idForm.save();
      print('success');
      requestCheckID();
    } else {
      print('ID from failed');
    }
  }

  Future<void> requestCheckID() async {
    //TODO: check id
    http.Response response = await http.post('http://tripstory.ga/id-doubled',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(_id));
    var resData = jsonDecode(response.body);
    if (resData.match("True")) {
      print('ID is doubled');
    } else {
      print('ID is useable');
    }
  }

  void signup() {
    //submit button
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print('success');
      //TODO: request create user(if (true=success, false=fail and retry))
    } else {
      print('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new Scaffold(
        appBar: new BlankAppbar(),
        resizeToAvoidBottomPadding: false,
        body: new Container(
          padding: EdgeInsets.all(32),
          child: new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  'Sign up',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                ),
                new Padding(padding: EdgeInsets.all(20)),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new SizedBox(
                        width: deviceSize.width -
                            (deviceSize.width * 1 / 5) -
                            64 -
                            (deviceSize.width * 1 / 20),
                        child: new Form(
                          key: idKey,
                          child: new TextFormField(
                            //id
                            obscureText: false,
                            decoration: new InputDecoration(
                                border: OutlineInputBorder(), labelText: 'ID'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'ID can\'t be empty';
                              } else if (!RegExp(r"^[A-Za-z0-9+]{4,12}$")
                                  .hasMatch(value)) {
                                return 'Please combination of Alphabet and Numbers';
                              }
                              return null;
                            },
                            onSaved: (value) => _id = value,
                          ),
                        )),
                    new SizedBox(
                      width: deviceSize.width * 1 / 5,
                      child: new RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0)),
                        color: Colors.red,
                        textColor: Colors.white,
                        child: new Text(
                          'CHECK',
                          style: new TextStyle(fontSize: 12.0),
                        ),
                        onPressed: checkID,
                      ),
                    ),
                  ],
                ),
                new Padding(padding: EdgeInsets.all(10)),
                new TextFormField(
                  //password
                  obscureText: true,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Password'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password can\'t be empty';
                    } else if (!RegExp(r"^[A-Za-z0-9+]{6,18}$")
                        .hasMatch(value)) {
                      return 'Please combination of Alphabet and Numbers';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value,
                ),
                new Padding(padding: EdgeInsets.all(10)),
                new TextFormField(
                  //name
                  obscureText: false,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Name'),
                  validator: (value) =>
                      value.isEmpty ? 'name can\'t be empty' : null,
                  onSaved: (value) => _name = value,
                ),
                new Padding(padding: EdgeInsets.all(15)),
                new SizedBox(
                  height: 50,
                  child: new RaisedButton(
                    shape: new RoundedRectangleBorder(
                        //borderRadius: new BorderRadius.circular(18.0)
                        ),
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text(
                      'Submmit',
                      style: new TextStyle(fontSize: 20.0),
                    ),
                    onPressed: signup,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

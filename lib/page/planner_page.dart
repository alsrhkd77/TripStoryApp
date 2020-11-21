import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:trip_story/blocs/planner_bloc.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/page/edit_plan_page.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class PlannerPage extends StatefulWidget {
  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final _bloc = new PlannerBloc();
  List planList = [];
  List taggedPlanList = [];

  Widget buildPlanList() {
    return StreamBuilder(
        stream: _bloc.myPlansStream,
        builder: (context, snapshot) {
          return ReorderableWrap(
            children: List.generate(snapshot.data.length, (index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                elevation: 5.0,
                child: ListTile(
                  onTap: () {
                    print(snapshot.data);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => EditPlanPage(
                                  travelPlan: snapshot.data[index],
                                )));
                  },
                  title: Text(snapshot.data[index].title),
                  subtitle: Text(DateFormat('yyyy. MM. dd')
                          .format(snapshot.data[index].itinerary.first) +
                      ' ~ ' +
                      DateFormat('yyyy. MM. dd')
                          .format(snapshot.data[index].itinerary.last)),
                  trailing: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    onTap: () {},
                  ),
                ),
              );
            }),
            onReorder: _bloc.onReorder,
          );
        });
  }

  List<Widget> buildTaggedPlanList(data) {
    List result = new List<Widget>();
    for (int index = 0; index < data.length; index++) {
      Card temp = new Card(
        key: Key('$index'),
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        elevation: 5.0,
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => EditPlanPage(
                          travelPlan: data[index],
                        )));
          },
          title: Text(data[index].title),
          subtitle: Text(DateFormat('yyyy. MM. dd')
                  .format(data[index].itinerary.first) +
              ' ~ ' +
              DateFormat('yyyy. MM. dd').format(data[index].itinerary.last)),
          trailing: IconButton(
            icon: Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ),
      );
      result.add(temp);
    }
    return result;
  }

  void _taggedOnReorder(int oldIndex, int newIndex) {
    setState(() {
      final String item = taggedPlanList.removeAt(oldIndex);
      taggedPlanList.insert(newIndex, item);
    });
  }

  Future<void> addNewPlan() async {
    final _key = new GlobalKey<FormState>();
    String _title;
    List<DateTime> _picked;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            title: Text('여행 일정'),
            content: Form(
              key: _key,
              child: TextFormField(
                maxLength: 25,
                onSaved: (value) => _title = value,
                validator: (value) => value.isEmpty ? 'Can\'t be empty' : null,
                decoration: InputDecoration(hintText: '여행 일정 이름을 알려주세요!'),
              ),
            ),
            actions: [
              FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('일정 선택'),
                onPressed: () async {
                  if (_key.currentState.validate()) {
                    _key.currentState.save();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });

    if (_title != null) {
      final List<DateTime> picked = await DateRagePicker.showDatePicker(
          context: context,
          initialFirstDate: new DateTime.now(),
          initialLastDate: new DateTime.now(),
          firstDate: new DateTime(1945),
          lastDate: new DateTime.now().add(Duration(days: 1825)));
      if (picked != null && picked.length >= 2) {
        _picked = picked;
        _picked.sort();
        _bloc.addNewPlan(_title, _picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      backgroundColor: Colors.lightBlueAccent,
      body: StreamBuilder(
        stream: _bloc.myPlansStream,
        builder: (context, snapshot) {
          return ReorderableListView(
            header: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/planner.png',
                    width: MediaQuery.of(context).size.width * 2 / 3,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Text(
                    '여행 일정',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  elevation: 5.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1.0, color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    child: IconButton(
                      //padding: EdgeInsets.symmetric(horizontal: 25.0),
                      icon: Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        await addNewPlan();
                      },
                    ),
                  ),
                ),
              ],
            ),
            children: buildTaggedPlanList(snapshot.data),
            onReorder: _bloc.onReorder,
          );
        },
      ),
      /*
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                alignment: Alignment.center,
                child: Image.network(
                  AddressBook.plannerLogo,
                  width: MediaQuery.of(context).size.width * 2 / 3,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text(
                  '내 여행',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic),
                ),
              ),
              buildPlanList(),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                elevation: 5.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  child: IconButton(
                    //padding: EdgeInsets.symmetric(horizontal: 25.0),
                    icon: Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      await addNewPlan();
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text(
                  '태그된 여행',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic),
                ),
              ),
              ReorderableWrap(
                  children: buildTaggedPlanList(), onReorder: _taggedOnReorder),
            ],
          ),
        )*/
    );
  }
}

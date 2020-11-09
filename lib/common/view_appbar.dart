import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/common/owner.dart';

class ViewAppbar extends StatelessWidget {
  final Widget trailer;
  final String profileUrl;
  final String name;
  final int author;
  final bool useDate;
  final DateTime startDate;
  final DateTime endDate;

  String visit = '';

  ViewAppbar(
      {this.trailer,
      this.profileUrl,
      this.name,
      this.author,
      this.useDate,
      this.startDate,
      this.endDate});

  goUserPage() {
    print(author);
  }

  @override
  Widget build(BuildContext context) {
    if (useDate) {
      if (DateFormat('yyyy-MM-dd').format(startDate) ==
          DateFormat('yyyy-MM-dd').format(endDate)) {
        visit = DateFormat('yyyy. MM. dd').format(startDate);
      } else {
        visit = DateFormat('yyyy. MM. dd').format(startDate) +
            " ~ " +
            DateFormat('yyyy. MM. dd').format(endDate);
      }
    }
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 3 / 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              InkWell(
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 20,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    radius: (MediaQuery.of(context).size.width / 20) - 2,
                    backgroundImage: NetworkImage(Owner().profile),
                  ),
                ),
                onTap: goUserPage,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 15 / 20,
                child: ListTile(
                  title: InkWell(
                    child: Text(name),
                    onTap: goUserPage,
                  ),
                  subtitle: Text(visit),
                  trailing: trailer,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

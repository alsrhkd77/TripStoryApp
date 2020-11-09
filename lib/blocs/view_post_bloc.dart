import 'package:rxdart/rxdart.dart';
import 'package:trip_story/handler/view_post_handler.dart';
import 'package:trip_story/models/post.dart';

class ViewPostBloc{
  int id;
  var _handler;
  var feedBehavior;

  Stream get _postView => feedBehavior.stream;

  ViewPostBloc({this.id}){
    _handler = new ViewPostHandler();
    feedBehavior = new BehaviorSubject<Post>();
  }

  fetchPost() async {
    Post _post = await _handler.fetchViewPost(id);
    feedBehavior.sink.add(_post);
  }

  dispose(){
    feedBehavior.close();
  }

}
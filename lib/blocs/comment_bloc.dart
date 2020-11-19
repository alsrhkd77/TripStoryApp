import 'package:rxdart/rxdart.dart';
import 'package:trip_story/models/comment.dart';
import 'package:trip_story/provider/comment_provider.dart';

class CommentBloc{
  List<Comment> _list = new List();
  int _feedId;
  final CommentProvider _commentProvider = new CommentProvider();

  final BehaviorSubject _commentListBehavior = new BehaviorSubject<List>();

  Stream get commentStream => _commentListBehavior.stream;

  CommentBloc(){
    _commentListBehavior.sink.add(_list);
  }

  fetchAllComment(int feedId) async {
    _feedId = feedId;
    _list = await _commentProvider.fetchAllComment(feedId);
    _commentListBehavior.sink.add(_list);
  }

  addComment(String content) async {
    await _commentProvider.addComment(_feedId, content);
    fetchAllComment(_feedId);
  }

  removeComment(int index) async {
    await _commentProvider.removeComment(_list[index].id);
    fetchAllComment(_feedId);
  }

  dispose(){
    _commentListBehavior.close();
  }
}
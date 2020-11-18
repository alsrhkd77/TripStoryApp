import 'package:rxdart/rxdart.dart';
import 'package:trip_story/handler/feed_handler.dart';

class TimelineBloc{
  List<Map> _list;
  int _offset;
  String _loadingState = '-';

  final FeedHandler _viewFeedHandler = new FeedHandler();

  final BehaviorSubject listBehavior = new BehaviorSubject<List>();
  final BehaviorSubject loadingStateBehavior = new BehaviorSubject<String>();

  Stream get timelineStream => listBehavior.stream;
  Stream get loadingStream => loadingStateBehavior.stream;

  TimelineBloc(){
    loadingStateBehavior.sink.add(_loadingState);
  }

  fetchStart() async {
    _offset = 0;
    List<Map> temp = await _viewFeedHandler.fetchTimeline(_offset, _offset + 5);
    _list = temp;
    listBehavior.sink.add(_list);
  }

  fetchNext() async {
    if(_loadingState == '-'){
      _setLoading();
      _offset = _offset + 5;
      List<Map> temp = await _viewFeedHandler.fetchTimeline(_offset, _offset + 5);
      if(temp.isNotEmpty){
        _list.addAll(temp);
      }else{
        _offset = _offset - 5;
      }
      listBehavior.sink.add(_list);
      _endLoading();
    }
  }

  tapLike(int index) {
    if (_list[index]['item'].liked) {
      _list[index]['item'].likes--;
      _list[index]['item'].liked = false;
    } else {
      _list[index]['item'].likes++;
      _list[index]['item'].liked = true;
    }
    _viewFeedHandler.sendLike(_list[index]['item'].id);
    listBehavior.sink.add(_list);
  }

  _setLoading(){
    _loadingState = 'loading';
    loadingStateBehavior.sink.add(_loadingState);
  }

  _endLoading(){
    _loadingState = '-';
    loadingStateBehavior.sink.add(_loadingState);
  }

  dispose(){
    listBehavior.close();
    loadingStateBehavior.close();
  }
}
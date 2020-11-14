import 'package:rxdart/rxdart.dart';
import 'package:trip_story/models/travel_plan.dart';

class PlannerBloc {
  List<TravelPlan> _myPlans = new List();
  List<TravelPlan> _taggedPlans = new List();

  BehaviorSubject myPlanBehavior = new BehaviorSubject<List>();
  BehaviorSubject taggedPlanBehavior = new BehaviorSubject<List>();

  Stream get myPlansStream => myPlanBehavior.stream;
  Stream get taggedPlansStream => taggedPlanBehavior.stream;

  PlannerBloc(){
    myPlanBehavior.sink.add(_myPlans);
    taggedPlanBehavior.sink.add(_taggedPlans);
  }

  Future<void> fetchAllPlans() async {
    //get from server;
    TravelPlan temp = new TravelPlan();
    temp.fromJson({
      'title': '부산 여행',
      'companion': [],
      'start': DateTime(2020, 3, 1),
      'end': DateTime(2020, 3, 2),
      'places': [
        ['광안리'],
        ['해운대']
      ]
    });
  }

  addNewPlan(String title, List<DateTime> itinerary){
    //upload to server
    TravelPlan travelPlan = new TravelPlan();
    travelPlan.title = title;
    travelPlan.itinerary = itinerary;
    _myPlans.add(travelPlan);
    myPlanBehavior.sink.add(_myPlans);
  }

  onReorder(int oldIndex, int newIndex){
    final TravelPlan item = _myPlans.removeAt(oldIndex);
    _myPlans.insert(newIndex, item);
    myPlanBehavior.sink.add(_myPlans);
  }

  removePlan(){
    //upload to server
    myPlanBehavior.sink.add(_myPlans);
  }

  dispose(){
    myPlanBehavior.close();
    taggedPlanBehavior.close();
  }
}

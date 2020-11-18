class TravelPlan {
  int id;
  String title; //여행 이름
  List<DateTime> itinerary; //여행 일정
  List<String> companion; //태그된 사람
  List places;

  void fromJson(value){
    title = value['title'];
    setDate(value['start'], value['end']);
    companion = value['companion'];
    places = value['places'];
  }

  void setDate(DateTime start, DateTime end){
    DateTime temp = start;
    while(temp.compareTo(end) < 0){
      itinerary.add(temp);
      temp.add(Duration(days: 1));
    }
  }
}
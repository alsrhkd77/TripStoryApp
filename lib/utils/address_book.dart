import 'dart:math';

class AddressBook {
  static final String address = 'http://175.200.243.184:8080';  // 세운이형 집
  //static final String address = "https://tripstory-server-rh4nd6uquq-du.a.run.app"; // GCP Cloud Run Server
  static final String login = address + '/auth/login/ts';
  static final String registration = address + '/auth/sign-up';
  static final String idCheck = address + '/auth/check';
  static final String defaultProfileUrl = 'https://i.stack.imgur.com/l60Hf.png';

  static final String googleMapsKey = 'AIzaSyC_7UI-khusysXGe22E6MUuphBbepTsZss';

  static String getSampleImg(){
    Random random = new Random();
    List<String> list = new List();
    list.add('https://cdnimg.melon.co.kr/cm2/album/images/103/46/650/10346650_500.jpg?14a08050b8c6adc879b6e0cf587d456a/melon/quality/80/optimize');
    list.add('https://cdnimg.melon.co.kr/cm2/artistcrop/images/002/61/143/261143_20200508100949_500.jpg?8671d6593fd8038301e96ebcd9a8fd62/melon/quality/80/optimize');
    list.add("https://cdnimg.melon.co.kr/cm/album/images/026/46/282/2646282_500.jpg/melon/resize/282/quality/80/optimize");
    list.add("https://cdnimg.melon.co.kr/cm/album/images/022/22/587/2222587_500.jpg/melon/resize/282/quality/80/optimize");
    list.add('https://cdnimg.melon.co.kr/cm/album/images/101/15/622/10115622_500.jpg?8dce6727064b378b17e74a45c0de7e50/melon/resize/282/quality/80/optimize');
    return list[random.nextInt(5)];
  }
}

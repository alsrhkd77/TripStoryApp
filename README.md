# Trip Story

>APK : [Trip Story.apk](https://github.com/alsrhkd77/TripStoryApp/raw/master/Trip%20Story.apk)



## 프로젝트 개요

 현대인에게 여행은 단순한 휴식 이상의 의미가 있다. 새로운 사람을 만나기 위해 여행을 떠나기도 하며, 지루한 일상을 벗어나 신선한 자극을 주기 위해 여행을 떠나기도 한다. 페이스북, 인스타그램과 같은 SNS에서 여행 관련 게시물의 높은 조회 수는 여행에 대한 현대인의 큰 관심을 보여주는 한 예시이다.

 이러한 상황에 맞추어 다양한 포털이나 SNS 여행 관련 페이지에서 다양한 정보를 제공해주고 있다. 그러나 여행자의 일정 관리, 여행 일지 기록 등의 기능은 다소 미흡한 것이 현실이다. 더불어 여행 관련 정보를 블로그나 개인 웹 사이트에 포스팅된 게시물의 경우 광고성 게시물인 경우가 많아 객관적으로 좋은 정보를 얻기 힘들다.

 이에 착안하여 일지의 기록과 공유를 쉽게 하고 나아가 수집된 일지로부터 객관적인 정보를 수집하여 필요한 여행자에게 제공하는 서비스를 제작 및 배포하는 것을 목표로 한다.



## Preview
### Sign Up

- **TextFormFeild Widget**과 **Regular expression**을 사용한 특수문자 및 공백문자 사용 제한, 이메일 형식 체크



### Login

-  **shared_preferences** 패키지를 사용한 자동로그인 지원

|일반 로그인|자동로그인|로그아웃|
|:--------:|:--------:|:--------:|
|![로그인](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/Login.gif?raw=true)|![자동로그인](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/autoLogin.gif?raw=true)|![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/logout.gif?raw=true)|



### Time line

- 스크롤 끝에 도달 시 **페이징**을 통한 로딩

|                           타임라인                           |                        페이지 라우팅                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/TimeLine.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/TimeLineLink.gif?raw=true) |



### Search

- 검색 프로세스 비동기 처리
- 단일 검색어를 통한 여러 카테고리 검색

|                          검색 결과                           |                        페이지 라우팅                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/search.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/search2.gif?raw=true) |



### Peripheral search

- 지도 중심좌표 기반 검색
- 마커 선택 시 Google Geocoding API를 사용해 **"좌표->주소"** 출력
- 데이터 요청량이 너무 많아 **"지도 이동 시 검색 -> 버튼 눌러서 검색"** 으로 변경

|                          검색 결과                           |                        내 위치로 이동                        |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/map.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/MyLocation.gif?raw=true) |



### User profile

- 조회한 프로필에 따라 필요한 부분만 변경하여 표시

|                         본인 프로필                          |                         타인 프로필                          |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/myinfo.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/yourinfo.gif?raw=true) |



### Edit profile

- 위젯 부분 재배치

|                         프로필 변경                          |
| :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/editProfile.gif?raw=true) |



### Make post

- 사진 메타데이터를 이용한 **자동 날짜 설정**

|                        자동 날짜 설정                        |                        수동 날짜 설정                        |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/makepost1.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/makepost2.gif?raw=true) |



### Make trip

- 사진 메타데이터를 이용해 사진 생성 위치에 **마커 자동 추가**
- 마커 좌표와 방문 일시를 이용해 **경로 자동 생성**
- 일반 게시물 포함 가능
- 특정 위치 수동 마커 추가 가능

|                        자동 마커 생성                        |                        수동 마커 생성                        |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/automarker.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/selfmarker.gif?raw=true) |



### View post

|                      댓글, 좋아요 기능                       |                    태그로 검색, 삭제 기능                    |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/post.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/postRemove.gif?raw=true) |



### View trip

|                       댓글, 마커 기능                        |                      일반 게시물로 연결                      |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/trip1.gif?raw=true) | ![](https://github.com/alsrhkd77/TripStoryApp/blob/master/screenshot/gif/trip2.gif?raw=true) |



## 개발 기능
### 사용자

- [x] 회원가입
- [x] 로그인
- [x] 내 프로필 조회
- [x] 타인 프로필 조회
- [x] 닉네임 변경
- [x] 프로필 사진 변경
- [x] 팔로우 및 팔로우 취소
- [ ] 소셜 로그인(Google, Facebook)



### 게시물

- [x] 게시물 작성
- [x] 게시물 조회
- [x] 게시물 삭제
- [x] 댓글 작성 및 삭제
- [x] 타임라인 표시



### 검색

- [x] 검색어를 통한 검색
- [x] 내 주변 검색



### 플래너

- [x] 계획 목록 작성
- [x] 날짜 범위 선택
- [x] 장소명을 통한 검색
- [x] 검색한 장소 세부계획에 추가
- [ ] 세부계획 장소 마커
- [ ] 세부계획 날짜별 경로
- [ ] 세부계획 저장



### Custom Widget

- [x] Page View + Page Indicator  ([/lib/common/paged_image_view.dart](https://github.com/alsrhkd77/TripStoryApp/blob/master/lib/common/paged_image_view.dart))
- [x] Blank App Bar  ([/lib/common/blank_appbar.dart](https://github.com/alsrhkd77/TripStoryApp/blob/master/lib/common/blank_appbar.dart))



### Technical

- [x] 사진 메타데이터 추출
- [x] 요청 응답 대기 dialog
- [ ] 사용자 인증방식 토근으로 변경
- [ ] 모든 페이지 BLoC 패턴 적용을 통해 UI와 Business logic 분리
- [ ] 모든 요청 결과값 statusCode 확인
- [ ] statusCode 에러 메시지 맵핑할 String 작성

 

## 용어 정리
- Feed = 단일 게시물(Post), 여행 게시물(Trip)
- Post = 단일 게시물
- Trip = 여햏 게시물



## 버전 관리
 00.00.00
 Major ver.Minor ver.Build or Maintenance ver

 - Major: 전체를 뒤엎을 정도의 큰 변화가 발생했을 때(1부터 시작)
 - Minor: 없던 기능의 추가나 기존 기능의 수정 등의 변화가 발생했을 때(0부터 시작)
 - Build or Maintenance: 자잘한 버그나 내부적 코드 보완 등의 변화가 발생했을 때

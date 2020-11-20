import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trip_story/page/network_image_view_page.dart';

class PagedImageView extends StatelessWidget {
  final List list;
  final bool zoomAble;
  final BoxFit fit;
  //final controller = PageController(viewportFraction: 0.8);
  final controller = PageController();

  PagedImageView({this.list, this.zoomAble, this.fit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
            controller: controller,
            itemCount: list.length,
            itemBuilder: (_, i) {
              if (zoomAble) {
                return InkWell(
                  child: Image.network(
                    list[i],
                    fit: fit,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NetworkImageViewPage(
                                  url: list[i],
                                )));
                  },
                );
              } else {
                return Image.network(
                  list[i],
                  fit: fit,
                );
              }
            }),
        list.length > 1 ? Container(
          padding: EdgeInsets.all(8.0),
          child: SmoothPageIndicator(
            controller: controller,
            count: list.length,
            effect: WormEffect(
              dotColor: Colors.white60,
              activeDotColor: Colors.blue,
              dotHeight: 6.0,
              dotWidth: 6.0,
              spacing: 10.0,
            ),
          ),
        ) : SizedBox(height: 0.0,),
      ],
    );
  }
}

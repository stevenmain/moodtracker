import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderShowFullmages extends StatefulWidget {
  // final List listImagesModel;
  // final int current;
  static const routeName = '/propertyImageFull';
  // SliderShowFullmages(this.listImagesModel, this.current, {required int });

  @override
  _SliderShowFullmagesState createState() => _SliderShowFullmagesState();
}

class _SliderShowFullmagesState extends State<SliderShowFullmages> {
  int _current = 0;
  bool _stateChange = false;
  @override
  void initState() {
    super.initState();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    List imageList = [];
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final listImagesModel = routeArgs['listImagesModel'];
    final current1 = routeArgs['current'] as int;
    for (int i = 0; i < listImagesModel.length; i++) {
      imageList.add(listImagesModel[i.toString()]);
      print(listImagesModel[i.toString()]);
    }

    _current = (_stateChange == false) ? current1 : _current;
    return new Container(
        color: Colors.transparent,
        child: new Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              //title: const Text('Transaction Detail'),
            ),
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CarouselSlider(
                    options: CarouselOptions(
                        autoPlay: false,
                        height: MediaQuery.of(context).size.height / 1.3,
                        viewportFraction: 1.0,
                        onPageChanged: (index, data) {
                          setState(() {
                            _stateChange = true;
                            _current = index;
                          });
                        },
                        initialPage: current1),
                    items: map<Widget>(imageList, (index, url) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0)),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.fill,
                                  height: 400.0,
                                ),
                              ),
                            )
                          ]);
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: map<Widget>(imageList, (index, url) {
                      return Container(
                        width: 10.0,
                        height: 9.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 5.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_current == index)
                              ? Colors.redAccent
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            )));
  }
}

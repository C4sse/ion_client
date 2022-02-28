import 'dart:core';

import 'package:flutter/material.dart';

import 'views/echo_test.dart';
import 'views/pub_sub.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class RouteItem {
  RouteItem({
    required this.title,
    required this.subtitle,
    required this.push,
  });

  final String title;
  final String subtitle;
  final Function(BuildContext context) push;
}

typedef PageContentBuilder = Widget Function([String room]);

class _MyAppState extends State<MyApp> {
  List<RouteItem> items = <RouteItem>[
    RouteItem(
        title: 'Dial A Doctor',
        subtitle: 'echo test with simulcast.',
        push: (BuildContext context) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => EchoTest()));
        }),
    RouteItem(
        title: 'Dial A Doctor',
        subtitle: '',
        push: (BuildContext context) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => PubSub()));
        }),
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  TextEditingController namecontroller = TextEditingController();
  TextEditingController roomcontroller = TextEditingController();
  
  bool? isVideoMuted = true;
  bool? isAudioMuted = true;

  Map<String, PageContentBuilder> routes = {
    '/pubsub': ([String? room]) => PubSub()
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String name = "name";
    final PageContentBuilder? pageContentBuilder = routes[name];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
          builder: (context) => pageContentBuilder(
            "hi",
          ),
        );
        return route;
      } else {
        final Route route = MaterialPageRoute<Widget>(
          builder: (context) => pageContentBuilder(),
        );
        return route;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    roomcontroller.text = "roomtest"; //
    return MaterialApp(

        // home: Scaffold(
        // appBar: AppBar(
        //   title: Text('Video conferencing'),
        // ),
        // body: ListView.builder(
        //     shrinkWrap: true,
        //     padding: const EdgeInsets.all(0.0),
        //     itemCount: items.length,
        //     itemBuilder: (context, i) {
        //       return _buildRow(context, items[i]);
        //     })),
        onGenerateRoute: _onGenerateRoute,
        home: Builder(builder: (context) {
          return Scaffold(
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      "Room code",
                      // style: mystyle(20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // PinCodeTextField(
                    //     controller: roomcontroller,
                    //     appContext: context,
                    //     autoDisposeControllers: false,
                    //     animationType: AnimationType.fade,
                    //     pinTheme: PinTheme(shape: PinCodeFieldShape.underline),
                    //     animationDuration: Duration(microseconds: 300),
                    //     length: 6,
                    //     onChanged: (value) {}),
                    TextField(
                      controller: roomcontroller,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: namecontroller,
                      // style: mystyle(20),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Name",
                        // labelStyle: mystyle(15)
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    CheckboxListTile(
                      value: isVideoMuted,
                      onChanged: (value) {
                        setState(() {
                          isVideoMuted = value;
                        });
                      },
                      title: Text(
                        "Video Muted",
                        // style: mystyle(18, Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    CheckboxListTile(
                      value: isAudioMuted,
                      onChanged: (value) {
                        setState(() {
                          isAudioMuted = value;
                        });
                      },
                      title: Text(
                        "Audio Muted",
                        // style: mystyle(18, Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      height: 48,
                      thickness: 2.0,
                    ),
                    // _buildRow(this.context, items[1]),
                    InkWell(
                      // onTap: () => joinmeeting(),
                      // onTap:() => items[1].push(context),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PubSub()),
                        );
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent]),
                        ),
                        child: Center(
                          child: Text(
                            "Join Meeting",
                            // style: mystyle(20, Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }));
  }
}

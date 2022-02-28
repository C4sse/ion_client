import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

class PubSub extends StatefulWidget {
  @override
  _PubSubState createState() => _PubSubState();
}

class _PubSubState extends State<PubSub> {
  final _localRenderer = RTCVideoRenderer();
  final List<RTCVideoRenderer> _remoteRenderers = <RTCVideoRenderer>[];
  // final Connector _connector =
      // Connector('https://3f73-41-221-159-214.ngrok.io'); //http://2705-41-221-144-9.ngrok.io
  final Connector _connector = Connector('http://127.0.0.1:50051');
  final _room = 'ion';
  final _uid = Uuid().v4();
  late RTC _rtc;
  late final LocalStream ls;
  late bool muted = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _rtc.close();
    super.dispose();
  }

  void connect() async {
    print("**************************************");
    _rtc = RTC(_connector);
    _rtc.onspeaker = (Map<String, dynamic> list) {
      print('onspeaker: $list');
    };

    _rtc.ontrack = (track, RemoteStream remoteStream) async {
      print('onTrack: remote stream => ${remoteStream.id}');
      if (track.kind == 'video') {
        var renderer = RTCVideoRenderer();
        await renderer.initialize();
        renderer.srcObject = remoteStream.stream;
        setState(() {
          _remoteRenderers.add(renderer);
        });
      }
      print(track.kind);
    };
    _rtc.ontrackevent = (TrackEvent event) {
      print(
          'ontrackevent state = ${event.state},  uid = ${event.uid},  tracks = ${event.tracks}');
      if (event.state == TrackState.REMOVE) {
        setState(() {
          _remoteRenderers.removeWhere(
              (element) => element.srcObject?.id == event.tracks[0].stream_id);
        });
      }
    };

    await _rtc.connect();
    await _rtc.join(_room, _uid, JoinConfig());

    await _localRenderer.initialize();
    // publish LocalStream
    var localStream =
        await LocalStream.getUserMedia(constraints: Constraints.defaults);
    await _rtc.publish(localStream);
    ls = localStream;

    setState(() {
      _localRenderer.srcObject = localStream.stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ion-sfu',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Dial A Doctor'),
            ),
            body: OrientationBuilder(builder: (context, orientation) {
              return Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('You')],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 700,
                                height: 200,
                                child:
                                    RTCVideoView(_localRenderer, mirror: true))
                          ],
                        ),
                        Row(
                          children: [
                            ..._remoteRenderers.map((remoteRenderer) {
                              return Row(
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                          width: 500,
                                          height: 200,
                                          child: RTCVideoView(remoteRenderer)),
                                      Text('User'),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 100,
                                  )
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints.tightFor(
                                    width: 70, height: 50),
                                child: ElevatedButton(
                                  child: Icon(
                                    Icons.call_end,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ))),
                                  onPressed: () {
                                    _rtc.close();
                                   Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints.tightFor(
                                    width: 70, height: 50),
                                child: ElevatedButton(
                                  child: Icon(
                                    muted == true
                                        ? Icons.mic_off_rounded
                                        : Icons.mic_rounded,
                                  ),
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ))),
                                  onPressed: () {
                                    muted = !muted;
                                    if (muted) {
                                      ls.mute('audio');
                                    } else {
                                      ls.unmute('audio');
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              );
            })));
  }
}

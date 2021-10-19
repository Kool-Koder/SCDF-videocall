import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';

const appId = "a991c309dd9b4466b7affb978e742b87";
String token = "";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _cameraOn = true;
  bool _displaySCDF = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        userEnableLocalVideo: (int uid, bool enableVideo){
          if (enableVideo == false){
            setState(() {
              _displaySCDF = true;
            });
          } else{
            setState(() {
              _displaySCDF = false;
            });
          }
        }
      ),
    );

    String baseUrl = 'https://scdf-videocall.herokuapp.com'; //Add the link to your deployed server here
    int uid = 0;
    //String token;

    Future<void> getToken() async {
      final response = await http.get(
        Uri.parse(baseUrl + '/rtc/' + "ChannelA" + '/publisher/uid/' + uid.toString()
          // To add expiry time uncomment the below given line with the time in seconds
          // + '?expiry=45'
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          token = response.body;
          token = jsonDecode(token)['rtcToken'];
          print("Token" + token);
        });
      } else {
        print('Failed to fetch the token');
      }
    }

    await getToken();

    await _engine.joinChannel(token, "ChannelA", null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('myResponder Video Call'),
        backgroundColor: Colors.red
      ),
      body: Stack(
        children: [
          Center(
            child: _bigVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 150,
              color: Colors.red,
              child: Center(
                child: _smallVideo(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
                child: const Text('Switch camera'),
                onPressed: () {
                  _engine.switchCamera();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => MyApp()),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                )
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: const Text('Toggle camera on/off'),
                onPressed: () {

                  if (_cameraOn == true){
                    _engine.enableLocalVideo(false);
                    setState(() {
                      _cameraOn = false;
                    });
                    print('Disable video');
                  } else{
                    _engine.enableLocalVideo(true);
                    setState(() {
                      _cameraOn = true;
                    });
                    print('Enable video');
                  }
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => MyApp()),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                )
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              child: const Text('End call'),
              onPressed: () {
                _engine.leaveChannel();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => MyApp()),
                // );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              )
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _bigVideo() {
    if (_remoteUid != null) {
      return RtcLocalView.SurfaceView();
      //return RtcRemoteView.SurfaceView(uid: _remoteUid!);
    } else {
      return Text(
        'Please wait while we connect to SCDF',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _smallVideo() {
    if (_localUserJoined = true && _remoteUid == null){
      return RtcLocalView.SurfaceView();
    } else if (_localUserJoined = true && _remoteUid != null){
      if (_displaySCDF == false){
        return RtcRemoteView.SurfaceView(uid: _remoteUid!);
      } else{
        return AvatarGlow(
          glowColor: Colors.blue,
          endRadius: 90.0,
          duration: Duration(milliseconds: 2000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: Duration(milliseconds: 100),
          child: Material(     // Replace this child with your own
            elevation: 8.0,
            shape: CircleBorder(),
            child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Image.asset(
                'assets/SCDF_logo.png',
                height: 60,
              ),
              radius: 40.0,
            ),
          ),
        );
      }
    } else{
      return CircularProgressIndicator();
    }
  }
}

//Testing code for moving across routes
void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('myResponder'),
          backgroundColor: Colors.red
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start call'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
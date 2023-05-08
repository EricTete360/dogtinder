import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dogtinder/controllers/Auth.dart';
import 'package:dogtinder/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  User? _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserInfo();
    _loadCount().then((value) {
      setState(() {
        _count = value;
      });
    });
  }

  void _incrementCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('count') ?? 0;
    setState(() {
      _count = count + 1;
    });
    prefs.setInt('count', _count);
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    print(user);
    setState(() {
      _user = user;
    });
  }

  int _count = 0;
  int _lastCount = 0;
  StreamController<int> _countController = StreamController<int>.broadcast();
  late AnimationController _animatedLeftHeartController;
  late AnimationController _animatedRightHeartController;
  late AnimationController _animatedDownHeartController;

  void _updateCountFromVelocity(Offset velocity) {
    setState(() {
      _count += 1;
      _countController.add(_count);
    });

    if (velocity.dx < 0) {
      _animatedLeftHeartController.forward(from: 0);
    } else if (velocity.dx > 0) {
      _animatedRightHeartController.forward(from: 0);
    } else if (velocity.dy > 0) {
      _animatedDownHeartController.forward(from: 0);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    const double minVelocity = 500.0;
    final Offset delta = details.delta;
    final double primaryDelta = delta.dy.abs();
    final double velocity =
        delta.distance / details.sourceTimeStamp!.inMilliseconds * 1000;

    if (primaryDelta > delta.dx.abs() &&
        primaryDelta > delta.dy.abs() &&
        velocity > minVelocity) {
      _updateCountFromVelocity(delta);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    const double minVelocity = 500.0;
    final Velocity velocity = details.velocity;

    if (velocity.pixelsPerSecond.dy.abs() > velocity.pixelsPerSecond.dx.abs() &&
        velocity.pixelsPerSecond.dy.abs() > minVelocity) {
      _updateCountFromVelocity(velocity.pixelsPerSecond);
    } else if (velocity.pixelsPerSecond.dx.abs() >
            velocity.pixelsPerSecond.dy.abs() &&
        velocity.pixelsPerSecond.dx.abs() > minVelocity) {
      _updateCountFromVelocity(velocity.pixelsPerSecond);
    }
  }

  Future<int> _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('count') ?? 0;
  }

  Future<String> _fetchDogImage() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['message'];
    } else {
      throw Exception('Failed to load dog image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                // print("press");
                AuthenticationHelper().signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                });
              },
              icon: Icon(Icons.logout),
              label: Text("${_user!.email}"),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "❤️ Points : $_count",
                style: TextStyle(fontSize: 24),
              ),
            ),
            Expanded(
                child: FutureBuilder(
              future: _fetchDogImage(),
              builder: ((BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error ${snapshot.error}"),
                  );
                } else {
                  return GestureDetector(
                    child: Card(
                      elevation: 8,
                      margin: EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(snapshot.data, fit: BoxFit.cover),
                      ),
                    ),
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                  );
                }
              }),
            )),
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipeDogCount extends StatefulWidget {
  const SwipeDogCount({super.key});

  @override
  State<SwipeDogCount> createState() => _SwipeDogCountState();
}

class _SwipeDogCountState extends State<SwipeDogCount> {
  int _count = 0;

  void _incrementCount() {
    setState(() {
      _count++;
    });
    SharedPreferences.getInstance().then((value) {
      value.setInt("SwipeCount", _count);
    });
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _count = value.getInt("SwipeInt") ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.fromIterable([1]),
      builder: ((context, snapshot) {
        return Text("$_count", style: TextStyle(fontSize: 20));
      }),
    );
  }
}

class SwipeDogGesture extends StatelessWidget {
  final String direction;
  final VoidCallback onSwipe;
  const SwipeDogGesture(
      {super.key, required this.direction, required this.onSwipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          onSwipe();
        } else {
          onSwipe();
        }
      },
      onVerticalDragEnd: (details) {
        onSwipe();
      },
      child: Container(
        width: 100,
        height: 100,
        color: direction == 'left'
            ? Colors.red
            : direction == 'right'
                ? Colors.blue
                : Colors.black,
        child: Icon(
            direction == 'left'
                ? Icons.favorite
                : direction == 'right'
                    ? Icons.favorite
                    : Icons.favorite_border,
            color: Colors.white),
      ),
    );
  }
}

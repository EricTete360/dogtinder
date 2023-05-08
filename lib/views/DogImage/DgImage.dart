import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

Future<String> getDogImage() async {
  final response =
      await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
  final data = json.decode(response.body);
  return data['message'];
}

class DgImage extends StatelessWidget {
  const DgImage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDogImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final imageUrl = snapshot.data;
          return Image.network(imageUrl!);
        }
      },
    );
  }
}

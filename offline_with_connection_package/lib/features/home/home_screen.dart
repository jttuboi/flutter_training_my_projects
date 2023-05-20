import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokemon')),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(child: const Text('asd'), onPressed: () {}),
        ],
      )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wambsgans/entry.dart';

class ViewEntry extends StatelessWidget {
  // require Entry for constructor
  const ViewEntry({super.key, required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(entry.content),
      ),
    );
  }
}

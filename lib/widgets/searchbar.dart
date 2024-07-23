// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class SearchBarS extends StatefulWidget {
  const SearchBarS({
    super.key,
  });

  @override
  _SearchBarSState createState() => _SearchBarSState();
}

class _SearchBarSState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextField(
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }
}

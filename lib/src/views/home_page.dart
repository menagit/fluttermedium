import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Fire'),
      ),
      body: ListView(
        children: _listElements(context),
      ),
    );
  }

  List<Widget> _listElements(BuildContext context) {
    List<Widget> tiles = List<Widget>();
    tiles
      ..add(ListTile(
        leading: Icon(Icons.add_location),
        trailing: Icon(Icons.keyboard_arrow_right),
        title: Text('Place Marker'),
        onTap: () {
          Navigator.pushNamed(context, 'marker');
        },
      ))
      ..add(Divider());
    return tiles;
  }
}

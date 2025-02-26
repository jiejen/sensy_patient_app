import 'package:flutter/material.dart';
import 'screens/Foot_Selection_Screen.dart';

class FootScreen extends StatefulWidget {
  const FootScreen({Key? key}) : super(key: key);

  @override
  State<FootScreen> createState() => _FootScreenState();
}

class _FootScreenState extends State<FootScreen> {
  /// Keep track of the selected areas.
  List<String> _selectedAreas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foot Selection')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / 2, // For example, 200 wide x 400 high
          child: FootSelectionWidget(
            onSelectionChanged: (selectedList) {
              setState(() {
                _selectedAreas = selectedList;
              });
              debugPrint('Selected foot areas: $_selectedAreas');
            },
          ),
        ),
      ),
    );
  }
}

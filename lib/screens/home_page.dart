import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser!;

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushNamed(context, '/signinpage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                  child: Text('Home Page',
                      style: Theme.of(context).textTheme.titleMedium)),
              ElevatedButton(
                child: const Text("Pairing"),
                onPressed: () {
                  Navigator.pushNamed(context, '/devicepairingpage');
                },
              ),
              // ElevatedButton(
              //   child: const Text("Data"),
              //   onPressed: () {
              //     Navigator.pushNamed(context, '/datapage');
              //   },
              // ),
              ElevatedButton(
                child: const Text("Mapping"),
                onPressed: () {
                  Navigator.pushNamed(context, '/mainpage');
                },
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: const Text("Logout"),
                  onPressed: () {
                    signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

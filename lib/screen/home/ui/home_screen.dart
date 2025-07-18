import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/services/router/router_name.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "-";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final loadedUsername = await SharedPrefService.getValue<String>(
      PrefKey.userId,
      defaultValue: "-",
    );
    setState(() {
      username = loadedUsername!;
    });
    Fluttertoast.showToast(
      msg: "Welcome $loadedUsername",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $username'),
            const SizedBox(height: 20),
            const Text('Home Screen Content'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go(profileScreenPath);
        },
        icon: const Icon(Icons.add),
        label: const Text('Press me'),
      ),
    );
  }
}

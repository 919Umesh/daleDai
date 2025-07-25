import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/ui/index_screen.dart';

import 'package:omspos/screen/login/ui/login_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:omspos/screen/splash/splash_screen.dart';
import 'package:omspos/services/router/router_name.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: splashPath,
  routes: [
    GoRoute(
      path: splashPath,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: loginPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: indexScreenPath,
      builder: (context, state) => const IndexScreen(),
    ),

    GoRoute(
      path: homeScreenPath,
      builder: (context, state) => const HomeScreen(),
    ),
    
    GoRoute(
      path: profileScreenPath,
      builder: (context, state) => const ProfileScreen(),
    ),

    // HomeScreen
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: const Center(child: Text('Page not found')),
  ),
);

// import 'package:flutter/material.dart';
// import 'package:omspos/services/router/app_router.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       routerConfig: appRouter,
//       title: 'OMS POS',
//       theme: ThemeData(primarySwatch: Colors.blue),
//     );
//   }
// }

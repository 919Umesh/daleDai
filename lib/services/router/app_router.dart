import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/home/ui/home_screen.dart';
import 'package:omspos/screen/index/ui/index_screen.dart';

import 'package:omspos/screen/login/ui/login_screen.dart';
import 'package:omspos/screen/profile/ui/profile_screen.dart';
import 'package:omspos/screen/room/ui/room_screen.dart';
import 'package:omspos/screen/splash/splash_screen.dart';
import 'package:omspos/services/router/router_name.dart';

final GoRouter appRouter = GoRouter(
  //Default Routes
  initialLocation: splashPath,
  routes: [
    GoRoute(
      //Splash Path
      path: splashPath,
      builder: (context, state) => const SplashScreen(),
    ),
    //Login Path
    GoRoute(
      path: loginPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: roomScreenPath,
      builder: (context, state) {
        final roomId = state.extra as String;
        return RoomScreen(propertyId: roomId);
      },
    ),

    //Index Screen Path
    GoRoute(
      path: indexScreenPath,
      builder: (context, state) => const IndexScreen(),
    ),
//Home Screen Path
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

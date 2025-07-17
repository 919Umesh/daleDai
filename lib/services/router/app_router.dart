import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omspos/screen/home/home_screen.dart';
import 'package:omspos/screen/login/login_screen.dart';
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
      path: homeScreenPath,
      builder: (context, state) => const HomeScreen(),
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

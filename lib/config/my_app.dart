import 'package:flutter/material.dart';
import 'package:omspos/services/router/app_router.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:provider/provider.dart';
import 'state_list.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: myStateList,
      child: Consumer<ThemeState>(
        builder: (context, themeState, child) {
          return MaterialApp.router(
            title: 'Dale|Dai',
            debugShowCheckedModeBanner: false,
            theme: themeState.currentTheme,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../themes/colors.dart';
// import '../services/router/app_router.dart'; // New GoRouter config
// import 'state_list.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: myStateList,
//       child: MaterialApp.router(
//         title: 'OMS | Retail',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: false,
//           primarySwatch: primarySwatch,
//           primaryColor: primaryColor,
//         ),
//         routerConfig: appRouter, // <- GoRouter config used here
//       ),
//     );
//   }
// }


// // Go to login page
// context.go('/login');

// // Push page on top
// context.push('/customer');


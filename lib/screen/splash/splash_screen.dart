import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_detail.dart';
import '../../constants/text_style.dart';
import '../../themes/fonts_style.dart';
import '../../widgets/gerdient_container.dart';
import '../../widgets/space.dart';
import 'splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashState _splashState; // Store reference here
  @override
  void initState() {
    super.initState();
    _splashState = Provider.of<SplashState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashState.getContext = context;
    });
  }

  @override
  void dispose() {
    _splashState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GredientContainer(
      reverseGredient: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppDetails.organizeBy,
            style: subTitleTextStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              verticalSpace(10),
              Text(
                AppDetails.appName,
                textAlign: TextAlign.center,
                style: cardTextStyleHeader,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

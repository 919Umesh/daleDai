import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_detail.dart';
import '../../constants/text_style.dart';
import '../../themes/fonts_style.dart';
import '../../widgets/gerdient_container.dart';
import '../../widgets/space.dart';
import 'splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashState>(context, listen: false).getContext = context;
    return Consumer<SplashState>(
      builder: (context, state, child) {
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
      },
    );
  }
}

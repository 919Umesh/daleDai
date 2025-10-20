import 'package:flutter/material.dart';
import 'package:omspos/constants/assets_list.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashState _splashState;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _splashState = Provider.of<SplashState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashState.getContext = context;
    });

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _splashState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GredientContainer(
      reverseGredient: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Image.asset(
                        AssetsList.appIcon,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    verticalSpace(20),
                    Text(
                      AppDetails.appName,
                      textAlign: TextAlign.center,
                      style: cardTextStyleHeader.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    verticalSpace(10),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(strokeWidth: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            AppDetails.organizeBy,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ),
    );
  }
}

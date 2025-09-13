import 'package:flutter/material.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/services/language/change_language.dart';
import 'package:omspos/services/language/localization_state.dart';
import 'package:omspos/widgets/change_theme.dart';
import 'package:provider/provider.dart';
import 'package:omspos/utils/translation_extension.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeState>(context, listen: false).getContext = context;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).highlightColor,
          appBar: AppBar(
            title: Text(context.translate('home_title')),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            actions: [
              ChangeLanguage(),
              ThemeToggle(),
            ],
          ),
        );
      },
    );
  }
}

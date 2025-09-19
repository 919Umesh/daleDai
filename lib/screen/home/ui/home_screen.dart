import 'package:flutter/material.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/services/language/change_language.dart';
import 'package:omspos/widgets/modals/profile_modal.dart';
import 'package:omspos/widgets/modals/property_modal.dart';
import 'package:provider/provider.dart';

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
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ProfileModalWidget(),
                      const SizedBox(height: 16.0),
                      InkWell(
                          onTap: () {
                            ChangeLanguage();
                          },
                          child: Text('Properties')),
                      PropertyModalWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

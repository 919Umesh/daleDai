import 'package:flutter/material.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/screen/profile/state/profile_state.dart';
import 'package:omspos/services/language/change_language.dart';
import 'package:omspos/themes/change_theme.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<ProfileState>(context, listen: false).getContext = context;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = Provider.of<ProfileState>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
            onPressed: profileState.refreshProfile,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
    );
  }

}

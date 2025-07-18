import 'package:flutter/material.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/screen/profile/state/profile_state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = Provider.of<ProfileState>(context, listen: false);
      profileState.getContext = context;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = Provider.of<ProfileState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: profileState.refreshProfile,
          ),
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(ProfileState profileState) {
    if (profileState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.errorMessage != null) {
      return Center(
        child: Text(
          profileState.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (profileState.user == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    return _buildProfileContent(profileState.user!);
  }

  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.profileImage != null)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.profileImage!),
            ),
          const SizedBox(height: 16),
          Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Phone: ${user.phone}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('User Type: ${user.userType}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Verified: ${user.isVerified ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
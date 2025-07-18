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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: profileState.refreshProfile,
          ),
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(ProfileState profileState) {
    if (profileState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (profileState.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red[600],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                profileState.errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (profileState.user == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                color: Colors.orange[600],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No user data available',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildProfileContent(profileState.user!);
  }

  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[600]!, Colors.blue[700]!],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: user.profileImage != null
                        ? CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(user.profileImage!),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // User Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // User Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.userType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Profile Details Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Email Card
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user.email,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                // Phone Card
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: user.phone,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                // Verification Status Card
                _buildInfoCard(
                  icon: user.isVerified 
                      ? Icons.verified_user_rounded 
                      : Icons.gpp_maybe_outlined,
                  title: 'Verification Status',
                  value: user.isVerified ? 'Verified' : 'Not Verified',
                  color: user.isVerified ? Colors.green : Colors.orange,
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required MaterialColor color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
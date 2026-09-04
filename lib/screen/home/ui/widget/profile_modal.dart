import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omspos/config/env_config.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/utils/greetings_helper.dart';
import 'package:omspos/themes/theme_state.dart';
import 'package:omspos/screen/search/ui/search_screen.dart';

class ProfileModalWidget extends StatelessWidget {
  final UserModel? userModel;
  const ProfileModalWidget({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [ThemeState.surfaceDark, const Color(0xFF1E2C18)]
              : [Colors.white, const Color(0xFFEAF4E6)],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeState.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: ThemeState.primaryGreen, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      (userModel?.profileImage?.isNotEmpty ?? false)
                          ? userModel!.profileImage!
                          : '${EnvConfig.supabaseUrl}/storage/v1/object/public/profile/Seller.png',
                    ),
                    radius: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate(GreetingHelper.getGreeting()),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${context.translate("hello")}, ',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: userModel?.name ?? 'Guest',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: ThemeState.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ThemeState.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_outlined,
                      color: ThemeState.primaryGreen, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search placeholder — navigates to dedicated search page
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? ThemeState.surfaceDark2 : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ThemeState.primaryGreen.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: ThemeState.primaryGreen, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.translate('search_hint'),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

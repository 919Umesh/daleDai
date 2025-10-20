import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omspos/screen/profile/model/user_model.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/utils/greetings_helper.dart';

class ProfileModalWidget extends StatelessWidget {
  final UserModel? userModel;
  const ProfileModalWidget({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      height: 160,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    (userModel?.profileImage?.isNotEmpty ?? false)
                        ? userModel!.profileImage!
                        : 'https://xuodtwztsrbqtfiisxrq.supabase.co/storage/v1/object/public/profile/Seller.png',
                  ),
                  radius: 30,
                ),

                SizedBox(width: 12), // Add spacing between avatar and text
                Expanded(
                  // This will make the text column take available space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: context.translate('hello'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5), // 8px spacing
                            ),
                            TextSpan(
                              text: userModel?.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        context.translate(GreetingHelper.getGreeting()),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  // search_hint
                  hintText: context.translate('search_hint'),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

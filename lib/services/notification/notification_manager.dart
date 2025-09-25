// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Response;
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../Helper/get_routes.dart';
// import '../Helper/shared_preference_fun.dart';
// import '../Screens/homepage/home_page_repo.dart';
// import '../Screens/reusableGlobal/snackbar_reusable.dart';

// // Global navigator key for navigation from outside the widget tree
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class OneSignalService {
//   static const String _oneSignalAppId = "YOUR_ONESIGNAL_APP_ID"; // Replace with your OneSignal App ID
  
//   // Notification categories for different types
//   static const String promotionCategory = "PROMOTION_CATEGORY";
//   static const String userCategory = "USER_CATEGORY";
//   static const String restaurantCategory = "RESTAURANT_CATEGORY";
//   static const String defaultCategory = "DEFAULT_CATEGORY";

//   Future<void> initialize() async {
//     await _initializeOneSignal();
//     await _requestPermissions();
//     await _setupNotificationHandlers();
//     await _handleUserSubscription();
//     _listenToSubscriptionChanges();
//   }

//   Future<void> _initializeOneSignal() async {
//     // Initialize OneSignal
//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     OneSignal.initialize(_oneSignalAppId);
    
//     // Set app ID
//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    
//     print("OneSignal initialized with App ID: $_oneSignalAppId");
//   }

//   Future<void> _requestPermissions() async {
//     if (Platform.isIOS) {
//       await _requestNotificationPermissionIOS();
//     } else if (Platform.isAndroid) {
//       await _requestNotificationPermissionAndroid();
//     }
    
//     // Request OneSignal permission
//     await OneSignal.Notifications.requestPermission(true);
//   }

//   Future<void> _requestNotificationPermissionIOS() async {
//     PermissionStatus status = await Permission.notification.status;

//     if (status.isGranted) {
//       print("iOS: Notification permission already granted.");
//       return;
//     }

//     if (!status.isGranted) {
//       status = await Permission.notification.request();

//       if (status.isGranted) {
//         print("iOS: Notification permission granted.");
//         return;
//       }
//     }

//     if (status.isDenied || status.isPermanentlyDenied) {
//       _handlePermissionStatus(status, "iOS");
//     }
//   }

//   Future<void> _requestNotificationPermissionAndroid() async {
//     PermissionStatus status = await Permission.notification.status;

//     if (status.isGranted) {
//       print("Android: Notification permission already granted.");
//       return;
//     }

//     status = await Permission.notification.request();
//     _handlePermissionStatus(status, "Android");
//   }

//   void _handlePermissionStatus(PermissionStatus status, String platform) {
//     if (status.isGranted) {
//       print("$platform: Notification permission granted.");
//       return;
//     }

//     if (status.isDenied || status.isPermanentlyDenied) {
//       print(
//           "$platform: Notification permission ${status.isPermanentlyDenied ? 'permanently ' : ''}denied.");
//       _showPermissionSnackbar(status);
//     }
//   }

//   void _showPermissionSnackbar(PermissionStatus status) async {
//     showCustomSnackbar(
//       title: "Enable Notifications for Full App Experience",
//       message:
//           "Stay updated and enjoy more features by allowing notifications.",
//     );

//     if (status.isPermanentlyDenied) {
//       Future.delayed(const Duration(milliseconds: 2000), () async {
//         await openAppSettings();
//       });
//     }
//   }

//   Future<void> _setupNotificationHandlers() async {
//     // Handle notification opened/clicked
//     OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
//       print("Notification clicked: ${event.notification.notificationId}");
//       _handleNotificationTap(event.notification);
//     });

//     // Handle notification received while app is in foreground
//     OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) {
//       print("Notification received in foreground: ${event.notification.notificationId}");
      
//       // You can modify the notification or prevent it from showing
//       // For now, we'll let it display
//       event.notification.display();
      
//       _handleForegroundNotification(event.notification);
//     });

//     // Handle permission changes
//     OneSignal.Notifications.addPermissionObserver((bool permission) {
//       print("Notification permission changed: $permission");
//       _handlePermissionChange(permission);
//     });
//   }

//   void _handleForegroundNotification(OSNotification notification) {
//     // Handle notification received while app is in foreground
//     print("Foreground notification received:");
//     print("Title: ${notification.title}");
//     print("Body: ${notification.body}");
//     print("Additional data: ${notification.additionalData}");
//   }

//   void _handleNotificationTap(OSNotification notification) async {
//     print("Notification tapped:");
//     print("Title: ${notification.title}");
//     print("Body: ${notification.body}");
//     print("Additional data: ${notification.additionalData}");

//     // Extract navigation data from notification
//     String? screen = notification.additionalData?['screen'];
//     String? type = notification.additionalData?['type'];
//     String? id = notification.additionalData?['id'];

//     // Navigate based on notification data
//     await _navigateBasedOnNotification(screen, type, id);
//   }

//   Future<void> _navigateBasedOnNotification(String? screen, String? type, String? id) async {
//     bool loggedInMode = await SharedPreferencesHelper.getBool(
//         key: SharedPreferenceKey.isRestLoggedInMode);

//     // Default navigation
//     if (screen == null) {
//       loggedInMode
//           ? Get.toNamed(Routes.restnotificationPage)
//           : Get.toNamed(Routes.notificationPage);
//       return;
//     }

//     // Navigate based on screen parameter
//     switch (screen.toLowerCase()) {
//       case 'promotions':
//         Get.toNamed(Routes.promotionsPage);
//         break;
//       case 'orders':
//         Get.toNamed(Routes.ordersPage);
//         break;
//       case 'profile':
//         Get.toNamed(Routes.profilePage);
//         break;
//       case 'restaurant':
//         if (id != null) {
//           Get.toNamed(Routes.restaurantDetailsPage, arguments: {'id': id});
//         }
//         break;
//       default:
//         loggedInMode
//             ? Get.toNamed(Routes.restnotificationPage)
//             : Get.toNamed(Routes.notificationPage);
//     }
//   }

//   void _handlePermissionChange(bool hasPermission) {
//     if (hasPermission) {
//       print("Notification permission granted");
//       // Re-subscribe to relevant topics if needed
//       _resubscribeToTopics();
//     } else {
//       print("Notification permission denied");
//     }
//   }

//   Future<void> _handleUserSubscription() async {
//     // Get user subscription ID
//     String? subscriptionId = await _getSubscriptionId();
    
//     if (subscriptionId != null) {
//       print("User subscription ID: $subscriptionId");
//       await _saveSubscriptionId(subscriptionId);
//       await _postSubscriptionToServer(subscriptionId);
//     }

//     // Set external user ID for targeting
//     int userId = await SharedPreferencesHelper.getInt(key: SharedPreferenceKey.userid);
//     if (userId > 0) {
//       OneSignal.login(userId.toString());
//       print("OneSignal external user ID set: $userId");
//     }
//   }

//   void _listenToSubscriptionChanges() {
//     OneSignal.User.addObserver((OSUserChangedState state) {
//       print("OneSignal user state changed");
      
//       // Handle subscription changes
//       if (state.current.pushSubscription != null) {
//         String? newSubscriptionId = state.current.pushSubscription!.id;
//         if (newSubscriptionId != null) {
//           _handleSubscriptionChange(newSubscriptionId);
//         }
//       }
//     });
//   }

//   Future<String?> _getSubscriptionId() async {
//     try {
//       OSPushSubscription? subscription = OneSignal.User.pushSubscription;
//       return subscription?.id;
//     } catch (e) {
//       print("Error getting subscription ID: $e");
//       return null;
//     }
//   }

//   Future<void> _saveSubscriptionId(String subscriptionId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('onesignal_subscription_id', subscriptionId);
//   }

//   Future<String?> getSavedSubscriptionId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('onesignal_subscription_id');
//   }

//   void _handleSubscriptionChange(String newSubscriptionId) async {
//     print('New OneSignal subscription ID: $newSubscriptionId');
    
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedId = prefs.getString('onesignal_subscription_id');

//     if (savedId == null || savedId != newSubscriptionId) {
//       await _postSubscriptionToServer(newSubscriptionId);
//       await prefs.setString('onesignal_subscription_id', newSubscriptionId);
//     }
//   }

//   Future<void> _postSubscriptionToServer(String subscriptionId) async {
//     int userId = await SharedPreferencesHelper.getInt(key: SharedPreferenceKey.userid);
    
//     try {
//       final Response response = await homePageRepository.postOneSignalSubscription(
//         userId: userId,
//         subscriptionId: subscriptionId,
//         deviceType: Platform.operatingSystem,
//       );

//       if (response.statusCode == 200) {
//         print('OneSignal subscription updated successfully.');
//       } else {
//         print('Failed to update OneSignal subscription. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to update OneSignal subscription. Error: ${e.toString()}');
//     }
//   }

//   Future<void> subscribeToTag(String key, String value) async {
//     try {
//       OneSignal.User.addTag(key, value);
//       await _saveTagSubscription(key, value, true);
//       print('Subscribed to tag: $key = $value');
//     } catch (e) {
//       print('Error subscribing to tag: $e');
//     }
//   }

//   Future<void> unsubscribeFromTag(String key) async {
//     try {
//       OneSignal.User.removeTag(key);
//       await _saveTagSubscription(key, "", false);
//       print('Unsubscribed from tag: $key');
//     } catch (e) {
//       print('Error unsubscribing from tag: $e');
//     }
//   }

//   Future<void> subscribeToMultipleTags(Map<String, String> tags) async {
//     try {
//       OneSignal.User.addTags(tags);
      
//       for (var entry in tags.entries) {
//         await _saveTagSubscription(entry.key, entry.value, true);
//       }
      
//       print('Subscribed to multiple tags: $tags');
//     } catch (e) {
//       print('Error subscribing to multiple tags: $e');
//     }
//   }

//   Future<void> _saveTagSubscription(String key, String value, bool isSubscribed) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Map<String, String> subscribedTags = Map<String, String>.from(
//         prefs.getKeys()
//             .where((key) => key.startsWith('onesignal_tag_'))
//             .fold<Map<String, String>>({}, (map, key) {
//           String tagKey = key.replaceFirst('onesignal_tag_', '');
//           String? tagValue = prefs.getString(key);
//           if (tagValue != null) map[tagKey] = tagValue;
//           return map;
//         }));

//     if (isSubscribed) {
//       await prefs.setString('onesignal_tag_$key', value);
//     } else {
//       await prefs.remove('onesignal_tag_$key');
//     }
//   }

//   Future<Map<String, String>> getSubscribedTags() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return Map<String, String>.from(
//         prefs.getKeys()
//             .where((key) => key.startsWith('onesignal_tag_'))
//             .fold<Map<String, String>>({}, (map, key) {
//           String tagKey = key.replaceFirst('onesignal_tag_', '');
//           String? tagValue = prefs.getString(key);
//           if (tagValue != null) map[tagKey] = tagValue;
//           return map;
//         }));
//   }

//   Future<void> _resubscribeToTopics() async {
//     try {
//       Map<String, String> subscribedTags = await getSubscribedTags();
//       if (subscribedTags.isNotEmpty) {
//         OneSignal.User.addTags(subscribedTags);
//         print('Re-subscribed to tags: $subscribedTags');
//       }
//     } catch (e) {
//       print('Error re-subscribing to topics: $e');
//     }
//   }

//   // Send notification to specific user (requires server-side implementation)
//   Future<void> sendNotificationToUser({
//     required String targetUserId,
//     required String title,
//     required String message,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     // This would typically be done from your server
//     // Here's an example of how you might structure the API call
//     try {
//       final Response response = await homePageRepository.sendOneSignalNotification(
//         targetUserId: targetUserId,
//         title: title,
//         message: message,
//         additionalData: additionalData,
//       );

//       if (response.statusCode == 200) {
//         print('Notification sent successfully to user: $targetUserId');
//       } else {
//         print('Failed to send notification. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to send notification. Error: ${e.toString()}');
//     }
//   }

//   // Utility methods
//   Future<bool> isNotificationEnabled() async {
//     OSPushSubscription? subscription = OneSignal.User.pushSubscription;
//     return subscription?.optedIn ?? false;
//   }

//   Future<void> enableNotifications() async {
//     OneSignal.User.pushSubscription.optIn();
//     print("Notifications enabled");
//   }

//   Future<void> disableNotifications() async {
//     OneSignal.User.pushSubscription.optOut();
//     print("Notifications disabled");
//   }

//   Future<void> clearAllTags() async {
//     try {
//       Map<String, String> currentTags = await getSubscribedTags();
//       for (String key in currentTags.keys) {
//         OneSignal.User.removeTag(key);
//         await unsubscribeFromTag(key);
//       }
//       print('All tags cleared');
//     } catch (e) {
//       print('Error clearing tags: $e');
//     }
//   }

//   // Set user properties for targeting
//   Future<void> setUserProperties({
//     String? email,
//     String? name,
//     String? phoneNumber,
//     Map<String, String>? customProperties,
//   }) async {
//     try {
//       if (email != null) {
//         OneSignal.User.addEmail(email);
//       }
      
//       if (phoneNumber != null) {
//         OneSignal.User.addSms(phoneNumber);
//       }

//       if (customProperties != null) {
//         OneSignal.User.addTags(customProperties);
//       }

//       print('User properties set successfully');
//     } catch (e) {
//       print('Error setting user properties: $e');
//     }
//   }

//   // Logout user (clear external user ID)
//   Future<void> logout() async {
//     try {
//       OneSignal.logout();
//       await clearAllTags();
      
//       // Clear saved data
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.remove('onesignal_subscription_id');
      
//       print('OneSignal user logged out');
//     } catch (e) {
//       print('Error logging out OneSignal user: $e');
//     }
//   }
// }

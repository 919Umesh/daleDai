// import 'package:flutter/material.dart';
// import 'package:omspos/screen/room/state/room_state.dart';
// import 'package:omspos/services/sharedPreference/preference_keys.dart';
// import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
// import 'package:provider/provider.dart';

// class ReviewBottomSheet extends StatefulWidget {
//   final String propertyId;

//   const ReviewBottomSheet({super.key, required this.propertyId});

//   @override
//   State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
// }

// class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
//   final _reviewFormKey = GlobalKey<FormState>();
//   final TextEditingController _commentController = TextEditingController();
//   double _rating = 3.0;

//   Future<void> _submitReview() async {
//     if (_reviewFormKey.currentState!.validate()) {
//       final roomState = Provider.of<RoomState>(context, listen: false);
//       //To get the user id from the preference
//       final userId = await SharedPrefService.getValue<String>(
//         PrefKey.userId,
//         defaultValue: "-",
//       );
//       try {
//         final formData = {
//           'property_id': widget.propertyId,
//           "user_id": userId,
//           'rating': _rating.toInt(),
//           'comment': _commentController.text.trim(),
//         };
//         //To post the review data to the server
//         await roomState.createReview(formData);
//         _commentController.clear();
//         //Setting the default value of the rating bar
//         _rating = 3.0;
//         //To close the drawer after posting the data
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Review submitted successfully!'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to submit review: ${e.toString()}'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(24),
//             ),
//           ),
//           child: Form(
//             key: _reviewFormKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Add Your Review',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 24),
//                 Center(
//                   child: Column(
//                     children: [
//                       Text(
//                         _rating.toInt().toString(),
//                         style: const TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Slider(
//                         value: _rating,
//                         min: 1,
//                         max: 5,
//                         divisions: 4,
//                         onChanged: (value) {
//                           setState(() {
//                             _rating = value;
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 4),
//                       const Text('Tap to rate'),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 TextFormField(
//                   controller: _commentController,
//                   decoration: InputDecoration(
//                     labelText: 'Your review',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Theme.of(context).colorScheme.surfaceVariant,
//                   ),
//                   maxLines: 4,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your review';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _submitReview,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                     ),
//                     child: const Text('Submit Review'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

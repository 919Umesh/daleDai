// import 'dart:convert';
//
// import 'package:flutter/material.dart';
//
//
// class MemoryImageViewer extends StatelessWidget {
//   final List<String> imageList;
//   const MemoryImageViewer({super.key, required this.imageList});
//   @override
//   Widget build(BuildContext context) {
//     return PhotoViewGallery.builder(
//       scrollPhysics: const BouncingScrollPhysics(),
//       builder: (BuildContext context, int index) {
//         return PhotoViewGalleryPageOptions(
//           imageProvider: MemoryImage(base64Decode(imageList[index])),
//           initialScale: PhotoViewComputedScale.contained * 0.8,
//           heroAttributes: PhotoViewHeroAttributes(tag: imageList[index]),
//         );
//       },
//       itemCount: imageList.length,
//       loadingBuilder: (context, event) => Center(
//         child: SizedBox(
//           width: 20.0,
//           height: 20.0,
//           child: CircularProgressIndicator(
//             value: event == null
//                 ? 0
//                 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
//           ),
//         ),
//       ),
//       // backgroundDecoration: widget.backgroundDecoration,
//       // pageController: widget.pageController,
//       // onPageChanged: onPageChanged,
//     );
//   }
// }

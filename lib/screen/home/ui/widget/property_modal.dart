import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omspos/config/env_config.dart';
import 'package:omspos/screen/home/model/home_model.dart';
import 'package:omspos/themes/theme_state.dart';

class PropertyModalWidget extends StatelessWidget {
  final AreaModel area;
  const PropertyModalWidget({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: (area.areaImage?.isNotEmpty ?? false)
                  ? area.areaImage!
                  : '${EnvConfig.supabaseUrl}/storage/v1/object/public/profile/Seller.png',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: ThemeState.surfaceDark,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ThemeState.primaryGreen,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: ThemeState.surfaceDark,
                child: const Icon(Icons.landscape, color: Colors.white30, size: 40),
              ),
            ),

            // Rich gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.2, 0.6, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 10,
              right: 10,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    area.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: ThemeState.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

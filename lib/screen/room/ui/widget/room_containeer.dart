import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omspos/config/env_config.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/themes/fonts_style.dart';

class RoomContainer extends StatefulWidget {
  final PropertyModel? property;
  const RoomContainer({super.key, required this.property});

  @override
  State<RoomContainer> createState() => _RoomContainerState();
}

class _RoomContainerState extends State<RoomContainer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.property?.title ?? "No Title",
            style: titleListTextStyle,
          ),
          const SizedBox(height: 8),

          // Paragraph with See More
          Text(
            widget.property?.description ?? "No description available",
            style: subTitleTextStyle,
            maxLines: _isExpanded ? null : 4,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ?  context.translate('see_less') :  context.translate('see_more'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // What we offer
          Text(
             context.translate('what_we_offer'),
            style: titleListTextStyle,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var value in widget.property?.attributes ?? [])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          // Hosted By
          Text(
            context.translate('hosted_by'),
            style: titleListTextStyle,
          ),
          const SizedBox(height: 8),

          // Host info row
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: CachedNetworkImageProvider(
                  '${EnvConfig.supabaseUrl}/storage/v1/object/public/profile/Seller.png',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Umesh Shahi',
                    style: titleListTextStyle,
                  ),
                  Text(
                    'Kathmandu, Nepal',
                    style: subTitleTextStyle,
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.whatshot_sharp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

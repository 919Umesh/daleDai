import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:omspos/config/env_config.dart';
import 'package:omspos/constants/assets_list.dart';
import 'package:omspos/screen/room/ui/room_details.dart';
import 'package:omspos/screen/room/ui/widget/image_carousel.dart';
import 'package:omspos/screen/room/ui/widget/review_containeer.dart';
import 'package:omspos/screen/room/ui/widget/room_card.dart';
import 'package:omspos/screen/room/ui/widget/room_containeer.dart';
import 'package:omspos/screen/room/api/room_api.dart';
import 'package:omspos/services/sharedPreference/sharedPref_service.dart';
import 'package:omspos/services/sharedPreference/preference_keys.dart';
 
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/services/language/translation_extension.dart';
import 'package:omspos/themes/fonts_style.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatefulWidget {
  final String propertyId;

  const RoomScreen({super.key, required this.propertyId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomState = Provider.of<RoomState>(context, listen: false);
      roomState.currentPropertyId = widget.propertyId;
    });
  }

  Future<void> _showAddCommentSheet(BuildContext context, String propertyId) async {
    final TextEditingController _commentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        int _rating = 3;
        return StatefulBuilder(builder: (ctx2, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx2).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Add comment', style: titleListTextStyle),
                const SizedBox(height: 12),
                // Star rating
                Row(
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _rating = starIndex),
                      icon: Icon(
                        starIndex <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write your comment',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final comment = _commentController.text.trim();
                      if (comment.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a comment')),
                        );
                        return;
                      }
                      try {
                        final userId = await SharedPrefService.getValue<String>(PrefKey.userId, defaultValue: '-');
                        final formData = {
                          'property_id': propertyId,
                          'user_id': userId ?? '-',
                          'rating': _rating,
                          'comment': comment,
                        };
                        await RoomApi.createReview(formData);
                        Navigator.of(ctx2).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment added')),
                        );
                        // refresh reviews
                        try {
                          Provider.of<RoomState>(context, listen: false).loadReviews(propertyId);
                        } catch (_) {}
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomState>(
      builder: (context, state, child) {
        if (!state.hanInternet) {
          return Scaffold(
              appBar: AppBar(
                title: Text('No Internet'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetsList.noInternet,
                      fit: BoxFit.contain,
                    ),
                    ElevatedButton(
                      onPressed: state.retry,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ));
        }
        if (state.isLoading) {
          return Center(child: Lottie.asset(AssetsList.davsan));
        }
        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64),
                Text('Error: ${state.errorMessage}'),
                ElevatedButton(
                  onPressed: state.retry,
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }
        return SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                final rs = Provider.of<RoomState>(context, listen: false);
                await rs.loadPropertyDetails(widget.propertyId, refresh: true);
                await rs.loadRooms(widget.propertyId, refresh: true);
                await rs.loadImages(widget.propertyId, refresh: true);
                await rs.loadReviews(widget.propertyId, refresh: true);
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    snap: false,
                    automaticallyImplyLeading: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    expandedHeight: 250,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        context.translate('room_details'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: CachedNetworkImage(
                        imageUrl: state.property?.images[0] ??
                            '${EnvConfig.supabaseUrl}/storage/v1/object/public/profile/Seller.png',
                        fit: BoxFit.cover,
                      ),
                      collapseMode: CollapseMode.parallax,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        RoomContainer(
                          property: state.property,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.translate('rooms'),
                                style: titleListTextStyle,
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.rooms.length,
                          itemBuilder: (context, index) {
                            final room = state.rooms[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => RoomDetailScreen(
                                            roomID: room.roomId,
                                          )));
                                },
                                child: RoomCard(
                                  room: room,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.translate('property_photos'),
                                style: titleListTextStyle,
                              ),
                            ],
                          ),
                        ),
                        ImageCarousel(
                          images: state.property?.images ??
                              [], // Your list of image URLs
                          height: 200, // Optional
                          borderRadius: 12, // Optional
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.translate('comments'),
                                style: titleListTextStyle,
                              ),
                              TextButton(
                                onPressed: () => _showAddCommentSheet(context, widget.propertyId),
                                child: const Text('Add comment'),
                              )
                            ],
                          ),
                        ),
                        ReviewContainer(
                          reviews: state.reviews,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

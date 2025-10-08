import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:omspos/constants/assets_list.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/screen/room/ui/room_details.dart';
import 'package:omspos/screen/room/ui/widget/image_carousel.dart';
import 'package:omspos/screen/room/ui/widget/review_containeer.dart';
import 'package:omspos/screen/room/ui/widget/room_card.dart';
import 'package:omspos/screen/room/ui/widget/room_containeer.dart';
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
            body: CustomScrollView(
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
                          'https://xuodtwztsrbqtfiisxrq.supabase.co/storage/v1/object/public/profile/Seller.png',
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
                        physics: const NeverScrollableScrollPhysics(), // so it scrolls with parent CustomScrollView
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
        );
      },
    );
  }
}

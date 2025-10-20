import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:omspos/constants/assets_list.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/screen/room/ui/widget/image_carousel.dart';
import 'package:omspos/screen/room/ui/widget/room_details_containeer.dart';
import 'package:provider/provider.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomID;

  const RoomDetailScreen({super.key, required this.roomID});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomState>().loadRoomDetails(widget.roomID);
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
                  title: Text(
                    state.room?.roomNumber ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ImageCarousel(
                        images:
                            state.room?.images ?? [], // Your list of image URLs
                        height: 350, // Optional
                        borderRadius: 12, // Optional
                      ),
                      RoomDetailsContainer(
                        room: state.room,
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

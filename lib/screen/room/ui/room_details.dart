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
            appBar: AppBar(title: const Text('Room details')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AssetsList.noInternet,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text('No internet connection'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          state.loadRoomDetails(widget.roomID, refresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Room details')),
            body: Center(child: Lottie.asset(AssetsList.davsan)),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Room details')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        state.loadRoomDetails(widget.roomID, refresh: true),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.room == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: () =>
                  state.loadRoomDetails(widget.roomID, refresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(
                      'Room ${state.room!.roomNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Semantics(
                          label:
                              '${state.room!.images.length} room photos. Swipe to browse.',
                          child: ImageCarousel(
                            images: state.room!.images,
                            height: 300,
                            borderRadius: 18,
                          ),
                        ),
                        const SizedBox(height: 18),
                        RoomDetailsContainer(room: state.room!),
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

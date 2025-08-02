import 'package:flutter/material.dart';
import 'package:omspos/screen/room/model/images_model.dart';
import 'package:omspos/screen/room/model/room_model.dart';
import 'package:omspos/screen/room/model/review_model.dart';
import 'package:omspos/screen/room/state/room_state.dart';
import 'package:omspos/screen/room/ui/room_details.dart';
import 'package:omspos/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatefulWidget {
  final String propertyId;

  const RoomScreen({super.key, required this.propertyId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late final RoomState _roomState;
  final _reviewFormKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 3.0;

  @override
  void initState() {
    super.initState();
    _roomState = Provider.of<RoomState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _roomState.loadRoomsByProperty(widget.propertyId),
      _roomState.getAllImages(widget.propertyId),
      _roomState.getReviewsByProperty(widget.propertyId),
    ]);
  }

  Future<void> _handleRefresh() async {
    await _roomState.refreshData();
  }

  Future<void> _submitReview() async {
    if (_reviewFormKey.currentState!.validate()) {
      try {
        final formData = {
          'propertyId': widget.propertyId,
          'rating': _rating.toInt(),
          'comment': _commentController.text,
        };
        debugPrint(formData.toString());
        // await _roomState.createReview(formData);
        _commentController.clear();
        _rating = 3.0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Room Details'),
      ),
      body: Consumer<RoomState>(
        builder: (context, state, child) {
          if (state.isLoading && !state.isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Images Section
                    _buildPropertyImages(state),
                    const SizedBox(height: 24),

                    // Rooms List Section
                    _buildRoomsList(state),
                    const SizedBox(height: 24),

                    // Reviews Section
                    _buildReviewsSection(state),
                    const SizedBox(height: 24),

                    // Add Review Form
                    _buildReviewForm(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyImages(RoomState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Images',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: state.images.isEmpty
              ? const NoDataWidget()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.imageUrl,
                          width: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 300,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoomsList(RoomState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Rooms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        state.rooms.isEmpty
            ? const NoDataWidget()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('Room ${room.roomNumber}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${room.roomType}'),
                          Text('Rent: \$${room.rentAmount.toStringAsFixed(2)}'),
                          Text(
                            'Status: ${room.isOccupied ? 'Occupied' : 'Available'}',
                            style: TextStyle(
                              color:
                                  room.isOccupied ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => RoomDetailsScreen(room: room),
                        //   ),
                        // );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildReviewsSection(RoomState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        state.reviews.isEmpty
            ? const NoDataWidget()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (starIndex) => Icon(
                                  starIndex < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${review.rating}/5',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on ${review.createdAt.toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _reviewFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Your Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Rating: ${_rating.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: _rating.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Your Review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:omspos/screen/home/api/home_api.dart';
import 'package:omspos/screen/home/model/property_model.dart';
import 'package:omspos/screen/room/room.dart';
import 'package:omspos/services/language/translation_extension.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<PropertyModel> _results = [];
  bool _loading = false;
  List<PropertyModel> _allProperties = [];
  Timer? _debounce;

  Future<void> _performSearch(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }

    // Load all properties once (use cache when available)
    if (_allProperties.isEmpty) {
      setState(() => _loading = true);
      try {
        _allProperties = await HomeApi.getAllProperties(false);
      } catch (e) {
        _allProperties = [];
      } finally {
        setState(() => _loading = false);
      }
    }

    final filtered = _allProperties.where((p) {
      final title = p.title.toLowerCase();
      final address = p.address.toLowerCase();
      final city = p.city.toLowerCase();
      return title.contains(q) || address.contains(q) || city.contains(q);
    }).toList();

    setState(() => _results = filtered);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.translate('search_hint'),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (val) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), () {
              _performSearch(val);
            });
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(child: Text(context.translate('no_results')))
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _results[index];
                    final imageUrl = p.images.isNotEmpty ? p.images[0] : null;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey.shade200,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey.shade200,
                                  child:
                                      const Icon(Icons.home_outlined, size: 20),
                                ),
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade200,
                                child:
                                    const Icon(Icons.home_outlined, size: 20),
                              ),
                      ),
                      title: Text(p.title),
                      subtitle: Text('${p.address}, ${p.city}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RoomScreen(propertyId: p.propertyId),
                        ));
                      },
                    );
                  },
                ),
    );
  }
}

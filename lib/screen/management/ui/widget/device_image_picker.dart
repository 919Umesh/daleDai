import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DeviceImagePicker extends StatelessWidget {
  const DeviceImagePicker({
    super.key,
    required this.selectedFiles,
    required this.existingUrls,
    required this.onFilesChanged,
    required this.onExistingRemoved,
    this.maximumImages = 10,
  });

  final List<XFile> selectedFiles;
  final List<String> existingUrls;
  final ValueChanged<List<XFile>> onFilesChanged;
  final ValueChanged<String> onExistingRemoved;
  final int maximumImages;

  int get _remaining => maximumImages - selectedFiles.length - existingUrls.length;

  Future<void> _chooseSource(BuildContext context) async {
    if (_remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can add up to $maximumImages images.')),
      );
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library_outlined)),
              title: const Text('Choose from gallery'),
              subtitle: const Text('Select one or multiple photos'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_camera_outlined)),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ]),
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final picked = await picker.pickMultiImage(limit: _remaining);
      if (picked.isNotEmpty) {
        onFilesChanged([...selectedFiles, ...picked.take(_remaining)]);
      }
    } else {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) onFilesChanged([...selectedFiles, picked]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = existingUrls.length + selectedFiles.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Listing photos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('$total/$maximumImages photos • converted to WebP', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        FilledButton.tonalIcon(
          onPressed: _remaining > 0 ? () => _chooseSource(context) : null,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Add'),
        ),
      ]),
      const SizedBox(height: 12),
      if (total == 0)
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _chooseSource(context),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_photo_alternate_outlined, size: 42),
              SizedBox(height: 8),
              Text('Add clear photos from your device'),
            ]),
          ),
        )
      else
        SizedBox(
          height: 116,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...existingUrls.map((url) => _preview(
                    context,
                    child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined)),
                    onRemove: () => onExistingRemoved(url),
                  )),
              ...selectedFiles.asMap().entries.map((entry) => _preview(
                    context,
                    child: FutureBuilder<Uint8List>(
                      future: entry.value.readAsBytes(),
                      builder: (_, snapshot) => snapshot.hasData
                          ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    onRemove: () {
                      final updated = [...selectedFiles]..removeAt(entry.key);
                      onFilesChanged(updated);
                    },
                  )),
            ],
          ),
        ),
    ]);
  }

  Widget _preview(BuildContext context, {required Widget child, required VoidCallback onRemove}) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 116, height: 116, child: child)),
          Positioned(
            right: 5,
            top: 5,
            child: Material(
              color: Colors.black.withValues(alpha: .68),
              shape: const CircleBorder(),
              child: InkWell(customBorder: const CircleBorder(), onTap: onRemove, child: const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.close, size: 17, color: Colors.white))),
            ),
          ),
        ]),
      );
}

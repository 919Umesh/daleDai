import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  const ImageUploadService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<String>> uploadAsWebp({
    required String bucket,
    required String entityId,
    required List<XFile> files,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('You must sign in to upload images.');

    final urls = <String>[];
    for (var index = 0; index < files.length; index++) {
      final original = await files[index].readAsBytes();
      final Uint8List webp = await FlutterImageCompress.compressWithList(
        original,
        minWidth: 1600,
        minHeight: 1600,
        quality: 78,
        format: CompressFormat.webp,
        keepExif: false,
      );
      if (webp.isEmpty) {
        throw StateError('Could not optimize ${files[index].name}.');
      }

      final path =
          '$userId/$entityId/${DateTime.now().microsecondsSinceEpoch}_$index.webp';
      await _client.storage.from(bucket).uploadBinary(
            path,
            webp,
            fileOptions: const FileOptions(
              contentType: 'image/webp',
              cacheControl: '31536000',
              upsert: false,
            ),
          );
      urls.add(_client.storage.from(bucket).getPublicUrl(path));
    }
    return urls;
  }

  static Future<void> deleteOwnedUrls({
    required String bucket,
    required Iterable<String> urls,
  }) async {
    final marker = '/storage/v1/object/public/$bucket/';
    final paths = urls
        .where((url) => url.contains(marker))
        .map((url) => Uri.decodeComponent(url.split(marker).last.split('?').first))
        .toList();
    if (paths.isNotEmpty) await _client.storage.from(bucket).remove(paths);
  }
}

import 'package:flutter/services.dart'; // Contains AssetManifest
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RuleItem {
  final String title;
  final String path;

  RuleItem({required this.title, required this.path});
}

final rulesListProvider = FutureProvider<List<RuleItem>>((ref) async {
  // 1. Use the new API to load the manifest
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  
  // 2. Get the list of all assets
  final assets = manifest.listAssets();

  // 3. Filter for your markdown files
  final filePaths = assets
      .where((String key) => 
          key.startsWith('assets/rules_md/') && 
          key.endsWith('.md') &&
          !key.endsWith('cheat_sheet.md'))
      .toList();

  // 4. Map to your model
  return filePaths.map((path) {
    final fileName = path.split('/').last.replaceAll('.md', '');
    final title = fileName
        .split('_')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');

    return RuleItem(title: title, path: path);
  }).toList();
});

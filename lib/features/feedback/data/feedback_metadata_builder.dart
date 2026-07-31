import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_metadata_builder.g.dart';

abstract interface class FeedbackMetadataBuilder {
  Future<Map<String, dynamic>> build({required String screen});
}

class FeedbackMetadataBuilderImpl implements FeedbackMetadataBuilder {
  const FeedbackMetadataBuilderImpl();

  @override
  Future<Map<String, dynamic>> build({required String screen}) async {
    final metadata = <String, dynamic>{
      'platform': _platformName(),
      'screen': screen,
    };

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty) {
        metadata['appVersion'] = packageInfo.version;
      }
    } on Object {
      // Metadata is best-effort and must never block feedback submission.
    }

    return metadata;
  }
}

String _platformName() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}

@Riverpod(keepAlive: true)
FeedbackMetadataBuilder feedbackMetadataBuilder(Ref ref) {
  return const FeedbackMetadataBuilderImpl();
}

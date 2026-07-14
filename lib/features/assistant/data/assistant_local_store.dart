import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/assistant/domain/assistant_conversation.dart';

part 'assistant_local_store.g.dart';

class AssistantLocalStore {
  AssistantLocalStore({
    required this.tokenStore,
    Future<Directory> Function()? getDirectory,
  }) : _getDirectory = getDirectory ?? getApplicationSupportDirectory;

  final SecureTokenStore tokenStore;
  final Future<Directory> Function() _getDirectory;

  Future<AssistantConversation> readConversation() async {
    try {
      final file = await _resolveFile();
      if (file == null || !await file.exists()) {
        return const AssistantConversation();
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const AssistantConversation();
      }

      return AssistantConversation.fromJson(decoded);
    } on FormatException {
      return const AssistantConversation();
    } on FileSystemException {
      return const AssistantConversation();
    }
  }

  Future<void> writeConversation(AssistantConversation conversation) async {
    final file = await _resolveFile();
    if (file == null) {
      return;
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(conversation.toJson()));
  }

  Future<void> clearConversation() async {
    final file = await _resolveFile();
    if (file == null || !await file.exists()) {
      return;
    }

    await file.delete();
  }

  Future<File?> _resolveFile() async {
    final accessToken = await tokenStore.readAccessToken();
    final userId = _readUserId(accessToken);
    if (userId == null) {
      return null;
    }

    final directory = await _getDirectory();
    return File(
      '${directory.path}/assistant/assistant_conversation_$userId.json',
    );
  }

  String? _readUserId(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      final subject = json['sub'];
      return subject is String && subject.isNotEmpty ? subject : null;
    } on FormatException {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
AssistantLocalStore assistantLocalStore(Ref ref) {
  return AssistantLocalStore(tokenStore: ref.watch(secureTokenStoreProvider));
}

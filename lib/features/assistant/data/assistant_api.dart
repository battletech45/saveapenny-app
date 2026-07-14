import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/assistant/data/dto/assistant_chat_request.dart';
import 'package:saveapenny/features/assistant/data/dto/assistant_chat_response.dart';
import 'package:saveapenny/features/assistant/data/dto/assistant_json.dart';

part 'assistant_api.g.dart';

class AssistantApi {
  AssistantApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AssistantChatResponse> chat(AssistantChatRequest request) {
    return _apiClient.send<AssistantChatResponse>(
      call: (dio) =>
          dio.post<dynamic>('/assistant/chat', data: request.toJson()),
      fromData: (data) =>
          AssistantChatResponse.fromJson(assistantReadJsonMap(data)),
    );
  }
}

@Riverpod(keepAlive: true)
AssistantApi assistantApi(Ref ref) {
  return AssistantApi(ref.watch(apiClientProvider));
}

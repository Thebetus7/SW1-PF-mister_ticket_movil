import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class FeedApi {
  final ApiClient _client;

  FeedApi(this._client);

  Future<ApiResponse> getFeed() {
    return _client.get(ApiConstants.feed);
  }
}

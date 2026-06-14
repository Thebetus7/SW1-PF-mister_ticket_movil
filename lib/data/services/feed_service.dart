import '../../core/api/feed_api.dart';
import '../../core/network/api_client.dart';
import '../models/evento_feed.dart';

class FeedService {
  final FeedApi _feedApi;

  FeedService() : _feedApi = FeedApi(ApiClient());

  Future<List<EventoFeedModel>> getFeed() async {
    final response = await _feedApi.getFeed();
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => EventoFeedModel.fromJson(json)).toList();
  }
}

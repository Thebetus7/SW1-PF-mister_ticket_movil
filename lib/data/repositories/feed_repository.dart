import '../models/evento_feed.dart';
import '../services/feed_service.dart';

class FeedRepository {
  final FeedService _feedService = FeedService();

  Future<List<EventoFeedModel>> fetchFeed() async {
    return await _feedService.getFeed();
  }
}

import 'package:flutter/material.dart';
import '../../data/models/evento_feed.dart';
import '../../data/repositories/feed_repository.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository _feedRepository = FeedRepository();
  List<EventoFeedModel> _feed = [];
  bool _isLoading = false;
  String? _error;

  List<EventoFeedModel> get feed => _feed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feed = await _feedRepository.fetchFeed();
    } catch (e) {
      _error = e.toString();
      _feed = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}

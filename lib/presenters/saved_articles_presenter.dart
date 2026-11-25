import 'package:shared_preferences/shared_preferences.dart';

import '../models/articles_model.dart';

class SavedArticlesPresenter {

  // Key used to store saved article IDs.
  static const String _savedArticlesKey =
      'saved_sleep_articles';

  // IDs of bookmarked articles.
  final Set<String> _savedArticleIds = {};

  // Load saved article IDs from local storage.
  Future<void> loadSavedArticles() async {

    final prefs = await SharedPreferences.getInstance();

    final savedIds =
        prefs.getStringList(_savedArticlesKey) ?? [];

    _savedArticleIds
      ..clear()
      ..addAll(savedIds);
  }

  // Check whether an article is bookmarked.
  bool isArticleSaved(String articleId) {
    return _savedArticleIds.contains(articleId);
  }

  // Save or remove an article from bookmarks.
  Future<void> toggleSavedArticle(String articleId) async {

    final prefs = await SharedPreferences.getInstance();

    if (_savedArticleIds.contains(articleId)) {
      _savedArticleIds.remove(articleId);
    } else {
      _savedArticleIds.add(articleId);
    }

    await prefs.setStringList(
      _savedArticlesKey,
      _savedArticleIds.toList(),
    );
  }

  // Return all saved article IDs.
  Set<String> get savedArticleIds =>
      Set.unmodifiable(_savedArticleIds);

  // Return only bookmarked articles.
  List<SleepArticle> getSavedArticles(
    List<SleepArticle> allArticles,
  ) {

    return allArticles.where((article) {
      return _savedArticleIds.contains(article.id);
    }).toList();
  }
}
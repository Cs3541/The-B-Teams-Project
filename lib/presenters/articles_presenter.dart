import '../models/articles_model.dart';

class ArticlesPresenter {
  final List<SleepArticle> _articles = [
    const SleepArticle(
      id: '1',
      title: 'Understanding Sleep Hygiene',
      category: 'Sleep Hygiene',
      summary:
          'Learn how everyday habits can help you get better sleep.',
      readingTime: 2,
      content:
          'Sleep hygiene refers to habits and routines that support '
          'healthy sleep. Try going to bed and waking up at consistent '
          'times, keeping your bedroom comfortable, and reducing '
          'distractions before bedtime. Small, consistent changes can '
          'help you build a healthier sleep routine.',
    ),
    const SleepArticle(
      id: '2',
      title: 'Why Sleep Is Important',
      category: 'Health Benefits',
      summary:
          'Discover how sleep supports your body and mind.',
      readingTime: 2,
      content:
          'Sleep plays an important role in physical and mental health. '
          'It supports learning, memory, concentration, and emotional '
          'well-being. Getting enough sleep regularly can also help '
          'your body recover and maintain normal immune function. '
          'Making sleep a priority is an important part of a healthy '
          'lifestyle.',
    ),
    const SleepArticle(
      id: '3',
      title: 'Build a Relaxing Bedtime Routine',
      category: 'Healthy Habits',
      summary:
          'Explore simple ways to prepare yourself for bedtime.',
      readingTime: 3,
      content:
          'A relaxing bedtime routine can help you wind down at the '
          'end of the day. Consider reading a book, taking a warm bath, '
          'or doing a quiet activity before bed. Try limiting caffeine '
          'later in the day and avoiding stimulating activities close '
          'to bedtime. Keeping a consistent sleep schedule can also '
          'help your body establish a regular rhythm.',
    ),
  ];

  // Return all available articles.
  List<SleepArticle> get articles => List.unmodifiable(_articles);

  // Find an article using its ID.
  SleepArticle? getArticleById(String id) {
    for (final article in _articles) {
      if (article.id == id) {
        return article;
      }
    }

    return null;
  }

  // Search articles by title, category, or summary.
  List<SleepArticle> searchArticles(String query) {
    if (query.trim().isEmpty) {
      return articles;
    }

    final searchQuery = query.toLowerCase().trim();

    return _articles.where((article) {
      return article.title.toLowerCase().contains(searchQuery) ||
          article.category.toLowerCase().contains(searchQuery) ||
          article.summary.toLowerCase().contains(searchQuery);
    }).toList();
  }
}
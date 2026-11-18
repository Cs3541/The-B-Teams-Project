import '../models/articles_model.dart';


class ArticlesPresenter {

  // Sample sleep health articles.
  final List<SleepArticle> _articles = [

    // Article 1
    SleepArticle(
      id: 'article1',
      title: 'Understanding the Science of Sleep',
      category: 'Sleep Basics',
      summary:
          'The science behind why sleep is crucial for your health and well-being.',
      content: '''
Increase your understanding of sleep
Taking this link will lead you to lots of articles relating to sleep science
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/12',
      readingTime: 3,
    ),

    // Article 2
    SleepArticle(
      id: 'article2',
      title: 'Insomnia',
      category: 'Sleep Basics',
      summary:
          'Learn about the causes and treatments of insomnia.',
      content: '''
Broden your knowledge of insomnia
Taking this link will lead you to lots of articles relating to insomnia
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/4',
      readingTime: 4,
    ),

    // Article 3
    SleepArticle(
      id: 'article3',
      title: 'Sleep Across the Lifespan',
      category: 'Sleep',
      summary:
          'Learn about how the different stages of life affect sleep patterns and needs.',
      content: '''
Sleep patterns and need changed in life due to a persons age.
By clicking this link you will be able to learn more about how sleep changed across the lifespan.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/14',
      readingTime: 3,
    ),

    // Article 4
    SleepArticle(
      id: 'article4',
      title: 'Sleep Health and Safety',
      category: 'Sleep',
      summary:
          'Sleep health and safety are much more important then we make them out to be. Learning about them can help you relaize your own.',
      content: '''
Most people don't realize how important sleep health and safety is.
Taking this link will lead you to articles correlated to sleep health and safety.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/15',
      readingTime: 3,
    ),

    // Article 5
    SleepArticle(
      id: 'article5',
      title: 'Cognitive, Affective and Behavioral Neuroscience of Sleep',
      category: 'Sleep',
      summary:
          'The science that is behing cognitve, affective and behavioral aspects of sleep',
      content: '''
Update your knowledge of the these aspects of sleep.
Taking this link provided below will lead you to articles that go more into detail about those aspects.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/13',
      readingTime: 4,
    ),

    SleepArticle(
      id: 'article6',
      title: 'Sleep and Metabolism',
      category: 'Sleep',
      summary:
          'Learn about metabolism and how it is affected by sleep.',
      content: '''
Learn about the correlation between sleep and metabolism.
Taking this link provided below will lead you to articles that go more into detail about those aspects.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/8',
      readingTime: 4,
    ),

    SleepArticle(
      id: 'article7',
      title: 'Neurological Disorders',
      category: 'Sleep Disorders',
      summary:
          'Learn about neurological disorders and their relationship with sleep.',
      content: '''
Broden your knowledge of neurological disorders and how they relate to sleep.
Taking this link provided below will lead you to articles that go more into detail about those aspects.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/11',
      readingTime: 4,
    ),

    SleepArticle(
      id: 'article8',
      title: 'Sleep Disordered Breathing',
      category: 'Sleep Disorders',
      summary:
          'Learn about sleep disordered breathing and its impact on sleep quality.',
      content: '''
Broden your knowledge of sleep disordered breathing and how it affects sleep.
Taking this link provided below will lead you to articles that go more into detail about those aspects.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/10',
      readingTime: 4,
    ),

    SleepArticle(
      id: 'article9',
      title: 'Circadian Disorders',
      category: 'Sleep Disorders',
      summary:
          'Learn about circadian disorders',
      content: '''
Broden your knowledge of circadian disorders and how they affect sleep.
Taking this link provided below will lead you to articles that go more into detail about those aspects.
''',
      link:
        'https://academic.oup.com/sleep/search-results?q=&tax=sleep/2',
      readingTime: 4,
    ),
  ];

  // Return all articles.
  List<SleepArticle> get articles =>
      List.unmodifiable(_articles);

  // Search articles by title, category, or summary.
  List<SleepArticle> searchArticles(String query) {

    if (query.trim().isEmpty) {
      return articles;
    }

    final searchQuery = query.trim().toLowerCase();

    return _articles.where((article) {
      return article.title.toLowerCase().contains(searchQuery) ||
          article.category.toLowerCase().contains(searchQuery) ||
          article.summary.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Find an article by ID.
  SleepArticle? getArticleById(String id) {

    for (final article in _articles) {
      if (article.id == id) {
        return article;
      }
    }

    return null;
  }
}
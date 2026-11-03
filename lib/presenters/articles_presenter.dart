import '../models/articles_model.dart';

class ArticlesPresenter {

  // Sample sleep health articles.
  final List<SleepArticle> _articles = [

    // Article 1
    SleepArticle(
      id: 'article1',
      title: 'Understanding the Importance of Sleep',
      category: 'Sleep Basics',
      summary:
          'Learn why getting enough sleep is important for your health.',
      content: '''
Sleep is an essential part of maintaining good physical and mental health.

During sleep, your body repairs itself, your brain processes information,
and your body prepares for the next day.

Getting enough sleep can help improve concentration, memory, mood, and
overall well-being.

Establishing a consistent sleep schedule and creating a comfortable
sleep environment can help support healthy sleep habits.
''',
      readingTime: 3,
    ),

    // Article 2
    SleepArticle(
      id: 'article2',
      title: 'Tips for Better Sleep',
      category: 'Sleep Habits',
      summary:
          'Discover practical habits that can help you sleep better.',
      content: '''
Developing healthy sleep habits can make it easier to fall asleep and
wake up feeling rested.

Try going to bed and waking up at approximately the same time each day.

Create a relaxing bedtime routine, such as reading a book or listening
to calming music.

Keep your bedroom quiet, dark, and comfortable.

Avoid caffeine late in the day, and give yourself time to relax before
going to bed.
''',
      readingTime: 4,
    ),

    // Article 3
    SleepArticle(
      id: 'article3',
      title: 'How Screen Time Affects Sleep',
      category: 'Technology',
      summary:
          'Understand how electronic devices can affect your bedtime.',
      content: '''
Using electronic devices before bed can make it harder for some people
to relax and fall asleep.

Bright light from screens can affect your body's natural sleep-wake
cycle. Engaging content, games, and notifications can also keep your
mind active when you are trying to wind down.

Consider putting devices away before bedtime and choosing a relaxing
activity instead.

You can also silence notifications at night to reduce interruptions.
''',
      readingTime: 3,
    ),

    // Article 4
    SleepArticle(
      id: 'article4',
      title: 'Understanding Your Sleep Schedule',
      category: 'Sleep Basics',
      summary:
          'Learn how a consistent sleep schedule supports your body clock.',
      content: '''
Your body has an internal clock that helps regulate when you feel
awake and when you feel sleepy.

Keeping a reasonably consistent sleep schedule helps your body maintain
a regular sleep-wake rhythm.

Large changes in your bedtime and wake-up time can make it harder to
feel rested.

Try maintaining a regular schedule throughout the week when possible.
''',
      readingTime: 3,
    ),

    // Article 5
    SleepArticle(
      id: 'article5',
      title: 'Managing Stress Before Bed',
      category: 'Mental Wellness',
      summary:
          'Explore relaxing techniques that may help you unwind at night.',
      content: '''
Stress and worries can sometimes make it difficult to relax at bedtime.

Creating a calming evening routine may help you transition from the
activities of the day to sleep.

You might try slow breathing, gentle stretching, listening to calming
music, or writing down tasks you want to remember for tomorrow.

Try to give yourself some quiet time before bed rather than rushing
straight from a busy activity into trying to sleep.

If sleep difficulties continue to affect your daily life, consider
talking with a healthcare professional.
''',
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
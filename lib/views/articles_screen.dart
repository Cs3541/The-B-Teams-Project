import 'package:flutter/material.dart';

import 'app_top_bar.dart';
import '../models/articles_model.dart';
import '../presenters/articles_presenter.dart';
import '../presenters/saved_articles_presenter.dart';
import '../views/articles_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {

  // Create the presenters.
  final ArticlesPresenter _presenter = ArticlesPresenter();

  final SavedArticlesPresenter _savedPresenter =
      SavedArticlesPresenter();

  // Search query.
  final String _searchQuery = '';

  // Determines whether to display only saved articles.
  final bool _showSavedOnly = false;

  // Loading state.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // Load saved article IDs when the screen starts.
  Future<void> _loadSavedArticles() async {

    await _savedPresenter.loadSavedArticles();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save or remove an article from bookmarks.
  Future<void> _toggleBookmark(SleepArticle article) async {

    await _savedPresenter.toggleSavedArticle(article.id);

    if (mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _savedPresenter.isArticleSaved(article.id)
                ? 'Article saved!'
                : 'Article removed from saved articles.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Get the articles that should currently be displayed.
  List<SleepArticle> get _displayedArticles {

    // Decide whether to display all articles or saved articles.
    final articles = _showSavedOnly
        ? _savedPresenter.getSavedArticles(
            _presenter.articles,
          )
        : _presenter.articles;

    // Filter articles using the search query.
    return articles.where((article) {

      final query = _searchQuery.toLowerCase().trim();

      return article.title.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);

    }).toList();
  }

  // Open the selected article.
  Future<void> _openArticle(SleepArticle article) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          savedPresenter: _savedPresenter,
        ),
      ),
    );

    // Refresh the screen when returning from article details.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const AppTopBar(title: 'Sleep Articles'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Improve Your Sleep',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

      body: _isLoading

          // Loading indicator.
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

            const SizedBox(height: 16),

            // Display article list
            Expanded(
              child: articles.isEmpty
                  ? const Center(child: Text('No articles found.'))
                  : ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),

                            leading: const CircleAvatar(
                              child: Icon(Icons.bedtime),
                            ),

                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Article filter dropdown.
                  DropdownButtonFormField<bool>(
                    value: _showSavedOnly,
                    decoration: InputDecoration(
                      labelText: 'Filter Articles',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('All Articles'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Saved Articles'),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        _showSavedOnly = value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Article list.
                  Expanded(
                    child: _displayedArticles.isEmpty

                        // Empty state.
                        ? Center(
                            child: Text(
                              _showSavedOnly
                                  ? 'You have no saved articles yet.'
                                  : 'No articles found.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )

                        // Display available articles.
                        : ListView.builder(
                            itemCount: _displayedArticles.length,

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(article.category),

                              final article =
                                  _displayedArticles[index];

                              final isSaved =
                                  _savedPresenter.isArticleSaved(
                                article.id,
                              );

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),

                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.all(12),

                                  Text(
                                    '${article.readingTime} min read',
                                    style: const TextStyle(fontSize: 12),
                                  ),

                                  // Article category and reading time.
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        Text(article.category),

                                        const SizedBox(height: 5),

                                        Text(article.summary),

                                        const SizedBox(height: 5),

                                        Text(
                                          '${article.readingTime} min read',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            // Open selected article
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleDetailScreen(article: article),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final SleepArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Read Article'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.category.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('${article.readingTime} min read'),
            const Divider(height: 32),
            Text(
              article.content,
              style: const TextStyle(fontSize: 17, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

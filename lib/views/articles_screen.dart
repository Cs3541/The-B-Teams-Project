import 'package:flutter/material.dart';
import 'app_top_bar.dart';
import '../models/articles_model.dart';
import '../presenters/articles_presenter.dart';
import '../presenters/saved_articles_presenter.dart';
import 'articles_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {

  // Create presenters.
  final ArticlesPresenter _presenter = ArticlesPresenter();

  final SavedArticlesPresenter _savedPresenter =
      SavedArticlesPresenter();

  // Search query.
  String _searchQuery = '';

  // Saved articles filter.
  bool _showSavedOnly = false;

  // Loading state.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // Load saved article IDs.
  Future<void> _loadSavedArticles() async {
    await _savedPresenter.loadSavedArticles();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Toggle article bookmark.
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
        ),
      );
    }
  }

  // Get articles based on selected filter and search.
  List<SleepArticle> get _displayedArticles {

    final articles = _showSavedOnly
        ? _savedPresenter.getSavedArticles(_presenter.articles)
        : _presenter.articles;

    return articles.where((article) {
      final query = _searchQuery.toLowerCase().trim();

      return article.title.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);
    }).toList();
  }

  // Open article details.
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

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Sleep Articles'),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Improve Your Sleep',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Discover simple habits for healthier sleep.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search bar.
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // All articles / saved articles filter.
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
                        ? Center(
                            child: Text(
                              _showSavedOnly
                                  ? 'You have no saved articles yet.'
                                  : 'No articles found.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _displayedArticles.length,
                            itemBuilder: (context, index) {
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

                                  leading: const CircleAvatar(
                                    child: Icon(Icons.bedtime),
                                  ),

                                  title: Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

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

                                  // Bookmark button.
                                  trailing: IconButton(
                                    icon: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isSaved
                                          ? Colors.pink
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        _toggleBookmark(article),
                                  ),

                                  // Open article.
                                  onTap: () => _openArticle(article),
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
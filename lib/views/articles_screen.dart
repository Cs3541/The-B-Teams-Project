
import 'package:flutter/material.dart';

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
  final ArticlesPresenter _presenter = ArticlesPresenter();
  final SavedArticlesPresenter _savedPresenter =
      SavedArticlesPresenter();

  String _searchQuery = '';
  String _selectedFilter = 'All Articles';

  final List<String> _filters = [
    'All Articles',
    'Saved Articles',
    'Sleep',
    'Sleep Disorders',
    'Sleep Basics',
  ];

  @override
  Widget build(BuildContext context) {
    // First, filter articles using the search query.
    final searchedArticles =
        _presenter.searchArticles(_searchQuery);

    // Then, apply the selected dropdown filter.
    final List<SleepArticle> displayedArticles;

    if (_selectedFilter == 'All Articles') {
      displayedArticles = searchedArticles;
    } else if (_selectedFilter == 'Saved Articles') {
      displayedArticles = searchedArticles
          .where(
            (article) =>
                _savedPresenter.isArticleSaved(article.id),
          )
          .toList();
    } else {
      displayedArticles = searchedArticles
          .where(
            (article) =>
                article.category == _selectedFilter,
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Articles'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

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
              'Discover simple habits and research '
              'for healthier sleep.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Search bar
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

            const SizedBox(height: 16),

            // Combined filter dropdown
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: InputDecoration(
                labelText: 'Filter Articles',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _filters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Article count
            Text(
              '${displayedArticles.length} articles found',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            // Article list
            Expanded(
              child: displayedArticles.isEmpty
                  ? const Center(
                      child: Text(
                        'No articles found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedArticles.length,
                      itemBuilder: (context, index) {
                        final article =
                            displayedArticles[index];

                        final isSaved =
                            _savedPresenter.isArticleSaved(
                          article.id,
                        );

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(12),

                            title: Text(
                              article.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(article.category),

                                  const SizedBox(height: 6),

                                  Text(article.summary),

                                  const SizedBox(height: 6),

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

                            // Bookmark button
                            trailing: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.pink,
                              ),
                              onPressed: () {
                                setState(() {
                                  _savedPresenter
                                      .toggleSavedArticle(
                                    article.id,
                                  );
                                });

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSaved
                                          ? 'Article removed from saved articles.'
                                          : 'Article saved!',
                                    ),
                                    duration: const Duration(
                                      seconds: 2,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Open article details
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleDetailScreen(
                                    article: article,
                                    savedPresenter:
                                        _savedPresenter,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
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

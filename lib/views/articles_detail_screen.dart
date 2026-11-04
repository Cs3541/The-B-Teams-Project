import 'package:flutter/material.dart';

import '../models/articles_model.dart';
import '../presenters/saved_articles_presenter.dart';

class ArticleDetailScreen extends StatefulWidget {

  // The selected article.
  final SleepArticle article;

  // Shared saved articles presenter.
  final SavedArticlesPresenter savedPresenter;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.savedPresenter,
  });

  @override
  State<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {

  // Toggle whether the article is bookmarked.
  Future<void> _toggleBookmark() async {

    await widget.savedPresenter.toggleSavedArticle(
      widget.article.id,
    );

    if (mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.savedPresenter.isArticleSaved(
              widget.article.id,
            )
                ? 'Article saved!'
                : 'Article removed from saved articles.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final article = widget.article;

    // Check whether the article is bookmarked.
    final isSaved =
        widget.savedPresenter.isArticleSaved(article.id);

    return Scaffold(

      appBar: AppBar(
        title: const Text('Article Details'),

        // Bookmark button.
        actions: [
          IconButton(
            icon: Icon(
              isSaved
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: isSaved ? Colors.pink : null,
            ),
            tooltip: isSaved
                ? 'Remove bookmark'
                : 'Save article',
            onPressed: _toggleBookmark,
          ),
        ],
      ),

      // Scrollable article content.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Article category.
            Text(
              article.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // Article title.
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Estimated reading time.
            Row(
              children: [

                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Text(
                  '${article.readingTime} min read',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Article summary.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                article.summary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Full article content.
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
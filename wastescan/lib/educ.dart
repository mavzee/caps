import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz.dart';
import 'cam.dart';

class EducPage extends StatefulWidget {
  const EducPage({super.key});

  @override
  State<EducPage> createState() => _EducPageState();
}

class _EducPageState extends State<EducPage> {
  List<dynamic> articles = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    const String apiKey = 'dd6d0681130244a9afe8fdcbabe2fee5';
    const String url =
        'https://newsapi.org/v2/everything?q=recycling+waste+environment&sortBy=publishedAt&apiKey=$apiKey&pageSize=20';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('articles')) {
          // Filter out articles without content
          final filteredArticles = (data['articles'] as List)
              .where((article) =>
                  article['title'] != null &&
                  article['title'] != '[Removed]' &&
                  article['urlToImage'] != null)
              .take(10) // Limit to 10 articles
              .toList();

          setState(() {
            articles = filteredArticles;
            isLoading = false;
            _errorMessage = filteredArticles.isEmpty ? 'No articles found' : null;
          });
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Failed to load news. Please try again.';
        // Add some sample articles for demo purposes
        articles = _getSampleArticles();
      });
      print('Error fetching articles: $e');
    }
  }

  List<Map<String, dynamic>> _getSampleArticles() {
    return [
      {
        'title': 'The Importance of Plastic Recycling',
        'description': 'Learn how plastic recycling reduces pollution and conserves resources.',
        'urlToImage': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
        'url': 'https://example.com/plastic-recycling',
        'source': {'name': 'Eco News'}
      },
      {
        'title': 'Composting 101: Turning Food Waste into Gold',
        'description': 'A beginner\'s guide to home composting and its environmental benefits.',
        'urlToImage': 'https://images.unsplash.com/photo-1589923186741-b7d59d6b2c4a?w=400',
        'url': 'https://example.com/composting-guide',
        'source': {'name': 'Green Living'}
      },
      {
        'title': 'Electronic Waste: The Growing Problem',
        'description': 'Understanding e-waste and proper disposal methods for electronics.',
        'urlToImage': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400',
        'url': 'https://example.com/e-waste',
        'source': {'name': 'Tech Environment'}
      },
      {
        'title': 'How to Recycle Glass Properly',
        'description': 'Tips for cleaning and separating glass for effective recycling.',
        'urlToImage': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400',
        'url': 'https://example.com/glass-recycling',
        'source': {'name': 'Recycle Today'}
      },
      {
        'title': 'Reducing Paper Waste in Offices',
        'description': 'Strategies for businesses to minimize paper consumption and waste.',
        'urlToImage': 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=400',
        'url': 'https://example.com/paper-waste',
        'source': {'name': 'Business Green'}
      },
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CamPage()),
      );
    }
  }

  void _refreshArticles() {
    setState(() {
      isLoading = true;
      articles = [];
    });
    fetchArticles();
  }

  Widget _buildArticleCard(int index) {
    final article = articles[index];
    final imageUrl = article['urlToImage']?.toString() ?? 
        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400';
    final title = article['title']?.toString() ?? 'No Title';
    final source = article['source'] is Map 
        ? article['source']['name']?.toString() ?? 'Unknown Source'
        : 'Unknown Source';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  );
                },
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          source,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '5 min read',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Read more button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailPage(article: article),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Read Article',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eco Education',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshArticles,
            tooltip: 'Refresh Articles',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Eco Articles...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null && articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshArticles,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await fetchArticles();
                  },
                  color: Colors.green[700],
                  child: articles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article, size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                'No articles available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: articles.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemBuilder: (context, index) {
                            return _buildArticleCard(index);
                          },
                        ),
                ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb),
                label: 'Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Scan',
              ),
              
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final dynamic article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article['urlToImage']?.toString() ?? 
        'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800';
    final title = article['title']?.toString() ?? 'No Title';
    final description = article['description']?.toString() ?? 'No description available.';
    final content = article['content']?.toString() ?? description;
    final source = article['source'] is Map 
        ? article['source']['name']?.toString() ?? 'Unknown Source'
        : 'Unknown Source';
    final date = article['publishedAt']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Article Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            Image.network(
              imageUrl,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                );
              },
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          source,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        date.isNotEmpty 
                            ? DateTime.parse(date).toString().substring(0, 10)
                            : 'Recent',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  const Divider(height: 1),
                  
                  const SizedBox(height: 24),
                  
                  // Content
                  Text(
                    content.length > 300 ? content.substring(0, 300) + '...' : content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Open in browser
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open Full Article'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(color: Colors.green[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
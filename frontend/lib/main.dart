import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnovativeIdeas - Mensa Feedback',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MensaFeedbackHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MensaFeedbackHomePage extends StatefulWidget {
  const MensaFeedbackHomePage({super.key});

  @override
  State<MensaFeedbackHomePage> createState() => _MensaFeedbackHomePageState();
}

class _MensaFeedbackHomePageState extends State<MensaFeedbackHomePage> {
  int _selectedIndex = 0;
  bool _isRecording = false;
  String? _selectedCategory;

  // Kategorien mit Gerichten (ohne vorgegebene Bewertungen)
  final Map<String, List<MensaFood>> _menuByCategory = {
    'Essen': [
      MensaFood(
        name: 'Asiatischer Wok mit Hähnchenstreifen',
        category: 'Essen',
        emoji: '🍜',
        description: 'Mit Kokoscurrysauce',
      ),
      MensaFood(
        name: 'Bratwurst mit Currysauce',
        category: 'Essen',
        emoji: '🌭',
        description: 'Mit Pommes frites',
      ),
      MensaFood(
        name: 'Vegane Bratwurst',
        category: 'Essen',
        emoji: '🌱',
        description: 'Mit Currysauce und Pommes',
      ),
      MensaFood(
        name: 'Spießbraten',
        category: 'Essen',
        emoji: '🥩',
        description: 'Mit Paprikarahmsauce',
      ),
      MensaFood(
        name: 'Grünkohl-Hanfratling',
        category: 'Essen',
        emoji: '🥬',
        description: 'Mit Kartoffelwürfeln',
      ),
      MensaFood(
        name: 'Burrito mit Chili sin Carne',
        category: 'Essen',
        emoji: '🌯',
        description: 'Mit Guacamole',
      ),
      MensaFood(
        name: 'Chicken-Cheese Burger',
        category: 'Essen',
        emoji: '🍔',
        description: 'Mit Cheddar und Honig-Senfcreme',
      ),
      MensaFood(
        name: 'Cevapcici vom Rind',
        category: 'Essen',
        emoji: '🍖',
        description: 'Mit Barbecuesauce',
      ),
    ],
    'Beilagen': [
      MensaFood(
        name: 'Beilagensalat Vinaigrette',
        category: 'Beilagen',
        emoji: '🥗',
        description: 'Herzhaft',
      ),
      MensaFood(
        name: 'Apfelrotkohl',
        category: 'Beilagen',
        emoji: '🟣',
        description: 'Traditionell zubereitet',
      ),
      MensaFood(
        name: 'Risoléekartoffeln',
        category: 'Beilagen',
        emoji: '🥔',
        description: 'Goldbraun gebraten',
      ),
      MensaFood(
        name: 'Weißkrautsalat',
        category: 'Beilagen',
        emoji: '🥬',
        description: 'Frisch und knackig',
      ),
      MensaFood(
        name: 'Petersilienkartoffeln',
        category: 'Beilagen',
        emoji: '🌿',
        description: 'Mit frischer Petersilie',
      ),
    ],
    'Desserts': [
      MensaFood(
        name: 'Vanillemousse mit Kirschen',
        category: 'Desserts',
        emoji: '🍒',
        description: 'Cremig und fruchtig',
      ),
      MensaFood(
        name: 'Quarkspeise Pfirsich',
        category: 'Desserts',
        emoji: '🍑',
        description: 'Erfrischend leicht',
      ),
      MensaFood(
        name: 'Nougatcreme',
        category: 'Desserts',
        emoji: '🍫',
        description: 'Mit Mandel-Nusscrunch',
      ),
      MensaFood(
        name: 'Bayrisch Creme',
        category: 'Desserts',
        emoji: '🟡',
        description: 'Mit Aprikosensauce',
      ),
      MensaFood(
        name: 'Orangen-Passionsfrucht Quark',
        category: 'Desserts',
        emoji: '🍊',
        description: 'Tropisch frisch',
      ),
      MensaFood(
        name: 'Superfood Chiashake',
        category: 'Desserts',
        emoji: '🫐',
        description: 'Mit Mandelmilch und Waldfrüchten',
      ),
    ],
  };

  // Liste für echte Bewertungen (wird erweitert wenn User bewertet)
  List<FeedbackHistory> _userFeedback = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedCategory = null; // Reset category when switching tabs
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _goBackToCategories() {
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  void initState() {
    super.initState();
    html.window.addEventListener('transcriptionResult', (event) {
      final customEvent = event as html.CustomEvent;
      final transcript = customEvent.detail;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio erkannt: "$transcript"')),
      );
    });
  }
  
  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      js.context.callMethod('startRecording');
    } else {
      js.context.callMethod('stopRecording');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _getSelectedPage(),
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildRecordingButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildMenuPage();
      case 1:
        return _buildHistoryPage();
      case 2:
        return _buildStatisticsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildMenuPage();
    }
  }

  // MENÜ SEITE (Erweitert für Kategorien und Gerichte)
  Widget _buildMenuPage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _selectedCategory == null 
            ? _buildCategoryGrid()
            : _buildFoodGrid(_selectedCategory!),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Essen', 'emoji': '🍖', 'color': Colors.brown, 'count': _menuByCategory['Essen']!.length},
      {'name': 'Beilagen', 'emoji': '🥔', 'color': Colors.green, 'count': _menuByCategory['Beilagen']!.length},
      {'name': 'Desserts', 'emoji': '🍰', 'color': Colors.pink, 'count': _menuByCategory['Desserts']!.length},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategorien - Übersicht',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _selectCategory(category['name']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  category['emoji'],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category['count']} Gerichte',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodGrid(String category) {
    final foods = _menuByCategory[category]!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _goBackToCategories,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3.5,
                mainAxisSpacing: 12,
              ),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                return _buildFoodCard(foods[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(MensaFood food) {
    return GestureDetector(
      onTap: () => _showFoodDetail(food),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(food.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // VERLAUF SEITE - zeigt echte Bewertungen
  Widget _buildHistoryPage() {
    return Column(
      children: [
        _buildPageHeader('Mein Feedback-Verlauf', Icons.history),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(),
                const SizedBox(height: 20),
                const Text(
                  'Meine Bewertungen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _userFeedback.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Noch keine Bewertungen abgegeben',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bewerte dein erstes Gericht!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _userFeedback.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(_userFeedback[index]);
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STATISTIKEN SEITE
  Widget _buildStatisticsPage() {
    return Column(
      children: [
        _buildPageHeader('Statistiken & Trends', Icons.analytics),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildOverallStats(),
                const SizedBox(height: 20),
                _buildCategoryStats(),
                const SizedBox(height: 20),
                _buildTopRatedFoods(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // PROFIL SEITE
  Widget _buildProfilePage() {
    return Column(
      children: [
        _buildPageHeader('Mein Profil', Icons.person),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildAchievements(),
                const SizedBox(height: 20),
                _buildSettings(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade600, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Bewertungen', '${_userFeedback.length}', Icons.rate_review, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Audio-Zeit', _calculateTotalAudioTime(), Icons.mic, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Ø Rating', _calculateAverageRating(), Icons.star, Colors.amber),
        ),
      ],
    );
  }

  String _calculateTotalAudioTime() {
    if (_userFeedback.isEmpty) return '0 Min';
    int totalSeconds = _userFeedback.fold(0, (sum, feedback) => sum + feedback.audioLength);
    int minutes = totalSeconds ~/ 60;
    return '$minutes Min';
  }

  String _calculateAverageRating() {
    if (_userFeedback.isEmpty) return '- ⭐';
    double average = _userFeedback.fold(0.0, (sum, feedback) => sum + feedback.rating) / _userFeedback.length;
    return '${average.toStringAsFixed(1)} ⭐';
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(FeedbackHistory feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(feedback.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.food,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < feedback.rating ? Colors.amber : Colors.grey[300],
                    )),
                    const SizedBox(width: 8),
                    Text(
                      '${feedback.audioLength}s Audio',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feedback.comment,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${feedback.date.day}.${feedback.date.month}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Meine Statistik',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverallStatItem('${_userFeedback.length}', 'Bewertungen'),
              _buildOverallStatItem(_calculateAverageRating().replaceAll(' ⭐', ''), 'Ø Rating'),
              _buildOverallStatItem('${_getDaysActive()}', 'Tage aktiv'),
            ],
          ),
        ],
      ),
    );
  }

  int _getDaysActive() {
    if (_userFeedback.isEmpty) return 0;
    var dates = _userFeedback.map((f) => DateTime(f.date.year, f.date.month, f.date.day)).toSet();
    return dates.length;
  }

  Widget _buildOverallStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCategoryStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bewertungen nach Kategorie',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCategoryBar('Essen', _getCategoryPercentage('Essen'), Colors.brown),
          _buildCategoryBar('Beilagen', _getCategoryPercentage('Beilagen'), Colors.green),
          _buildCategoryBar('Desserts', _getCategoryPercentage('Desserts'), Colors.pink),
        ],
      ),
    );
  }

  double _getCategoryPercentage(String category) {
    if (_userFeedback.isEmpty) return 0.0;
    int categoryCount = _userFeedback.where((feedback) => 
      _menuByCategory[category]!.any((food) => food.name == feedback.food)
    ).length;
    return categoryCount / _userFeedback.length;
  }

  Widget _buildCategoryBar(String category, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(category, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopRatedFoods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meine Top bewerteten Gerichte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._getTopRatedFoods(),
        ],
      ),
    );
  }

  List<Widget> _getTopRatedFoods() {
    if (_userFeedback.isEmpty) {
      return [
        Text(
          'Noch keine Bewertungen vorhanden',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ];
    }

    var sortedFeedback = List<FeedbackHistory>.from(_userFeedback);
    sortedFeedback.sort((a, b) => b.rating.compareTo(a.rating));
    
    return sortedFeedback.take(3).map((feedback) => 
      _buildTopFoodItem(feedback.emoji, feedback.food, feedback.rating.toDouble())
    ).toList();
  }

  Widget _buildTopFoodItem(String emoji, String name, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 14)),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              'HH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade600,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Henry Huynh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Student | Informatik',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mitglied seit ${DateTime.now().year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Errungenschaften',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievement('🏆', 'Erste Bewertung'),
              _buildAchievement('🔥', '7 Tage Streak'),
              _buildAchievement('⭐', '100 Bewertungen'),
              _buildAchievement('🎤', 'Audio-Experte'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(String emoji, String title) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(Icons.notifications, 'Benachrichtigungen', true),
          _buildSettingItem(Icons.dark_mode, 'Dark Mode', false),
          _buildSettingItem(Icons.language, 'Sprache', false),
          _buildSettingItem(Icons.help, 'Hilfe & Support', false),
          _buildSettingItem(Icons.logout, 'Abmelden', false),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool hasSwitch) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange.shade600),
      title: Text(title),
      trailing: hasSwitch 
        ? Switch(
            value: true,
            onChanged: (value) {},
            activeColor: Colors.orange,
          )
        : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Gericht suchen...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(22.5),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _isRecording 
            ? [Colors.red.shade400, Colors.red.shade600]
            : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: (_isRecording ? Colors.red : Colors.orange).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: _toggleRecording,
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange.shade600,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Verlauf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Statistiken',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showFoodDetail(MensaFood food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(food.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Wie hat es dir geschmeckt?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatingButton(1, 'Schlecht', food),
                  _buildRatingButton(2, 'Okay', food),
                  _buildRatingButton(3, 'Gut', food),
                  _buildRatingButton(4, 'Super', food),
                  _buildRatingButton(5, 'Perfekt', food),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Aufnahme stoppen' : 'Audio-Kommentar aufnehmen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingButton(int rating, String label, MensaFood food) {
  return Column(
    children: [
      GestureDetector(
        onTap: () => _addRating(food, rating, label),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(rating, (index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: rating <= 2 ? 12 : (rating == 3 ? 10 : 8),
                )),
              ),
              if (rating > 3) const SizedBox(height: 2),
              Text(
                '$rating',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

  void _addRating(MensaFood food, int rating, String ratingLabel) {
    Navigator.pop(context);
    
    // Neue Bewertung zur Liste hinzufügen
    setState(() {
      _userFeedback.insert(0, FeedbackHistory(
        food: food.name,
        emoji: food.emoji,
        rating: rating,
        comment: 'Bewertung: $ratingLabel', // Wird später durch Audio-Transkript ersetzt
        date: DateTime.now(),
        audioLength: 0, // Wird später durch echte Audio-Länge ersetzt
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bewertung für "${food.name}" gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class MensaFood {
  final String name;
  final String category;
  final String emoji;
  final String description;

  MensaFood({
    required this.name,
    required this.category,
    required this.emoji,
    required this.description,
  });
}

class FeedbackHistory {
  final String food;
  final String emoji;
  final int rating;
  final String comment;
  final DateTime date;
  final int audioLength;

  FeedbackHistory({
    required this.food,
    required this.emoji,
    required this.rating,
    required this.comment,
    required this.date,
    required this.audioLength,
  });
}

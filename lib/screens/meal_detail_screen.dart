import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/meal_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({Key? key, required this.mealId}) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealService _mealService = MealService();
  MealDetail? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealDetails();
  }

  Future<void> _loadMealDetails() async {
    final meal = await _mealService.getMealDetails(widget.mealId);
    setState(() {
      _meal = meal;
      _isLoading = false;
    });
  }

  Future<void> _showRandomMeal() async {
    setState(() {
      _isLoading = true;
    });
    final randomMeal = await _mealService.getRandomMeal();
    if (randomMeal != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(mealId: randomMeal.idMeal),
        ),
      );
    }
  }

  void _showYouTubeDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube линк'),
        content: SelectableText(url, style: const TextStyle(color: Colors.blue)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Затвори'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meal?.strMeal ?? 'Рецепт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _showRandomMeal,
            tooltip: 'Рандом рецепт',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meal == null
              ? const Center(child: Text('Рецептот не е пронајден'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        _meal!.strMealThumb,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 100),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _meal!.strMeal,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text(_meal!.strCategory),
                                  backgroundColor: Colors.orange.shade100,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(_meal!.strArea),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Состојки',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._meal!.getIngredients().map(
                                  (ingredient) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.orange, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(ingredient)),
                                      ],
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 24),
                            const Text(
                              'Инструкции',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _meal!.strInstructions,
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                            if (_meal!.strYoutube.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showYouTubeDialog(_meal!.strYoutube),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Погледни на YouTube'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
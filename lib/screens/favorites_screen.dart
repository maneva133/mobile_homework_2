import 'package:flutter/material.dart';
import '../models/favorite_meal.dart';
import '../services/favorites_service.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<FavoriteMeal> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String idMeal) async {
    await _favoritesService.removeFavorite(idMeal);
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Рецептот е отстранет од омилени')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Омилени рецепти'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('Немате додадено омилени рецепти.'))
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.separated(
                    itemCount: _favorites.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final favorite = _favorites[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(favorite.strMealThumb),
                        ),
                        title: Text(favorite.strMeal),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeFavorite(favorite.idMeal),
                          tooltip: 'Отстрани',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealDetailScreen(mealId: favorite.idMeal),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}


import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/favorite_meal.dart';
import '../services/favorites_service.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar.dart';
import 'meal_detail_screen.dart';
import 'favorites_screen.dart';

class MealsScreen extends StatefulWidget {
  final String categoryName;

  const MealsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final MealService _mealService = MealService();
  final FavoritesService _favoritesService = FavoritesService();
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;
  bool _favoritesLoading = true;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _loadFavorites();
  }

  Future<void> _loadMeals() async {
    final meals = await _mealService.getMealsByCategory(widget.categoryName);
    setState(() {
      _meals = meals;
      _filteredMeals = meals;
      _isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteIds = favorites.map((f) => f.idMeal).toSet();
          _favoritesLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _favoritesLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Грешка при вчитување на омилени: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _meals;
      });
      return;
    }

    final searchResults = await _mealService.searchMeals(query);
    final mealIds = _meals.map((m) => m.idMeal).toSet();
    setState(() {
      _filteredMeals = searchResults.where((m) => mealIds.contains(m.idMeal)).toList();
    });
  }

  Future<void> _showRandomMeal() async {
    final randomMeal = await _mealService.getRandomMeal();
    if (randomMeal != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(mealId: randomMeal.idMeal),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Meal meal) async {
    if (_favoritesLoading) return; // Don't allow toggling while loading
    
    final alreadyFavorite = _favoriteIds.contains(meal.idMeal);
    setState(() {
      if (alreadyFavorite) {
        _favoriteIds.remove(meal.idMeal);
      } else {
        _favoriteIds.add(meal.idMeal);
      }
    });

    try {
      if (alreadyFavorite) {
        await _favoritesService.removeFavorite(meal.idMeal);
      } else {
        await _favoritesService.addFavorite(FavoriteMeal.fromMeal(meal));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alreadyFavorite
              ? 'Рецептот е отстранет од омилени'
              : 'Рецептот е додаден во омилени'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // revert on error
      print('Error toggling favorite: $e');
      await _loadFavorites();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не успеав да ја ажурирам омилената листа: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени рецепти',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              ).then((_) => _loadFavorites());
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _showRandomMeal,
            tooltip: 'Рандом рецепт',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    hintText: 'Пребарај јадења...',
                    onChanged: _searchMeals,
                  ),
                ),
                Expanded(
                  child: _filteredMeals.isEmpty
                      ? const Center(
                          child: Text(
                            'Нема пронајдени јадења',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredMeals.length,
                          itemBuilder: (context, index) {
                            final meal = _filteredMeals[index];
                            return MealCard(
                              meal: meal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MealDetailScreen(
                                      mealId: meal.idMeal,
                                    ),
                                  ),
                                );
                              },
                              onFavoriteTap: _favoritesLoading
                                  ? null
                                  : () => _toggleFavorite(meal),
                              isFavorite: _favoriteIds.contains(meal.idMeal),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
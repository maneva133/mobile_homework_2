import 'meal.dart';

class FavoriteMeal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  FavoriteMeal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory FavoriteMeal.fromJson(Map<String, dynamic> json) {
    return FavoriteMeal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
    );
  }

  factory FavoriteMeal.fromMeal(Meal meal) {
    return FavoriteMeal(
      idMeal: meal.idMeal,
      strMeal: meal.strMeal,
      strMealThumb: meal.strMealThumb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
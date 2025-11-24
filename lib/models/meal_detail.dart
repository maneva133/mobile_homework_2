class MealDetail {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strYoutube;
  final Map<String, dynamic> rawData;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strYoutube,
    required this.rawData,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    return MealDetail(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      rawData: json,
    );
  }

  List<String> getIngredients() {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = rawData['strIngredient$i'];
      final measure = rawData['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add('${measure ?? ''} $ingredient'.trim());
      }
    }
    return ingredients;
  }
}
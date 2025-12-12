import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_meal.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;
  final String _collection = "favorites";
  
  Future<void> addFavorite(FavoriteMeal meal) async {
    try {
      await _db.collection(_collection).doc(meal.idMeal).set(meal.toJson());
      print('Favorite added successfully: ${meal.idMeal}');
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }
  
  Future<void> removeFavorite(String idMeal) async {
    try {
      await _db.collection(_collection).doc(idMeal).delete();
      print('Favorite removed successfully: $idMeal');
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }
  
  Future<List<FavoriteMeal>> getFavorites() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      print('Favorites loaded: ${snapshot.docs.length} items');
      return snapshot.docs.map((d) {
        try {
          return FavoriteMeal.fromJson(d.data());
        } catch (e) {
          print('Error parsing favorite ${d.id}: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error getting favorites: $e');
      rethrow;
    }
  }
  
  Future<bool> isFavorite(String idMeal) async {
    try {
      final doc = await _db.collection(_collection).doc(idMeal).get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite: $e');
      rethrow;
    }
  }
}
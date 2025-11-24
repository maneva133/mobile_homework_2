import 'dart:convert';
import 'dart:io';
import '../models/category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';

class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('$baseUrl/categories.php'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final List categories = data['categories'] ?? [];
        return categories.map((cat) => Category.fromJson(cat)).toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      client?.close(force: true);
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('$baseUrl/filter.php?c=$category'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final List meals = data['meals'] ?? [];
        return meals.map((meal) => Meal.fromJson(meal)).toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      client?.close(force: true);
    }
  }

  Future<MealDetail?> getMealDetails(String id) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('$baseUrl/lookup.php?i=$id'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final List meals = data['meals'] ?? [];
        if (meals.isNotEmpty) {
          return MealDetail.fromJson(meals[0]);
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('$baseUrl/search.php?s=$query'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final List? meals = data['meals'];
        if (meals != null) {
          return meals.map((meal) => Meal.fromJson(meal)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      client?.close(force: true);
    }
  }

  Future<MealDetail?> getRandomMeal() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('$baseUrl/random.php'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final List meals = data['meals'] ?? [];
        if (meals.isNotEmpty) {
          return MealDetail.fromJson(meals[0]);
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }
}
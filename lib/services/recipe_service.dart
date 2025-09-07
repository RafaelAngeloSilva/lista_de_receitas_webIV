import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../services/translation_service.dart';

class RecipeService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Buscar receitas por categoria
  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals != null) {
          List<Recipe> recipes = [];
          for (var meal in meals) {
            // Buscar detalhes completos da receita
            final recipe = await getRecipeById(meal['idMeal']);
            if (recipe != null) {
              recipes.add(recipe);
            }
          }
          return recipes;
        }
      }
      return [];
    } catch (e) {
      print('Erro ao buscar receitas: $e');
      return [];
    }
  }

  // Buscar receita por ID
  static Future<Recipe?> getRecipeById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals != null && meals.isNotEmpty) {
          return Recipe.fromJson(meals.first);
        }
      }
      return null;
    } catch (e) {
      print('Erro ao buscar receita: $e');
      return null;
    }
  }

  // Buscar receitas aleatórias
  static Future<List<Recipe>> getRandomRecipes(int count) async {
    try {
      List<Recipe> recipes = [];
      for (int i = 0; i < count; i++) {
        final response = await http.get(
          Uri.parse('$baseUrl/random.php'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final meals = data['meals'] as List?;
          
          if (meals != null && meals.isNotEmpty) {
            final recipe = Recipe.fromJson(meals.first);
            recipes.add(recipe);
          }
        }
      }
      return recipes;
    } catch (e) {
      print('Erro ao buscar receitas aleatórias: $e');
      return [];
    }
  }

  // Buscar categorias
  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List?;
        
        if (categories != null) {
          // Return raw category keys (English) for API compatibility.
          // UI should translate labels when rendering.
          return categories
              .map((category) => category['strCategory'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erro ao buscar categorias: $e');
      return [];
    }
  }

  // Buscar receitas por nome
  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals != null) {
          List<Recipe> recipes = [];
          for (var meal in meals) {
            final recipe = await getRecipeById(meal['idMeal']);
            if (recipe != null) {
              recipes.add(recipe);
            }
          }
          return recipes;
        }
      }
      return [];
    } catch (e) {
      print('Erro ao buscar receitas: $e');
      return [];
    }
  }
}

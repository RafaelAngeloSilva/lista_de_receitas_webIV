import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class LocalStorageService {
  static const String _recipesKey = 'local_recipes';
  static const String _favoritesKey = 'favorite_recipes';

  // Salvar receitas locais
  static Future<void> saveLocalRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = recipes.map((recipe) => recipe.toJson()).toList();
    await prefs.setString(_recipesKey, jsonEncode(recipesJson));
  }

  // Carregar receitas locais
  static Future<List<Recipe>> loadLocalRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesString = prefs.getString(_recipesKey);
    
    if (recipesString == null) return [];
    
    try {
      final recipesJson = jsonDecode(recipesString) as List;
      return recipesJson
          .map((json) => Recipe.fromLocalJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar receitas locais: $e');
      return [];
    }
  }

  // Adicionar nova receita local
  static Future<void> addLocalRecipe(Recipe recipe) async {
    final recipes = await loadLocalRecipes();
    recipes.add(recipe);
    await saveLocalRecipes(recipes);
  }

  // Atualizar receita local
  static Future<void> updateLocalRecipe(Recipe updatedRecipe) async {
    final recipes = await loadLocalRecipes();
    final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);
    
    if (index != -1) {
      recipes[index] = updatedRecipe;
      await saveLocalRecipes(recipes);
    }
  }

  // Remover receita local
  static Future<void> deleteLocalRecipe(String recipeId) async {
    final recipes = await loadLocalRecipes();
    recipes.removeWhere((r) => r.id == recipeId);
    await saveLocalRecipes(recipes);
  }

  // Salvar favoritos
  static Future<void> saveFavorites(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  // Carregar favoritos
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Adicionar aos favoritos
  static Future<void> addToFavorites(String recipeId) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
      await saveFavorites(favorites);
    }
  }

  // Remover dos favoritos
  static Future<void> removeFromFavorites(String recipeId) async {
    final favorites = await loadFavorites();
    favorites.remove(recipeId);
    await saveFavorites(favorites);
  }

  // Verificar se é favorito
  static Future<bool> isFavorite(String recipeId) async {
    final favorites = await loadFavorites();
    return favorites.contains(recipeId);
  }
}

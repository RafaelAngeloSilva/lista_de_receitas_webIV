import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/local_storage_service.dart';
import '../services/recipe_service.dart';
import '../widgets/molecules/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    final ids = await LocalStorageService.loadFavorites();
    List<Recipe> loaded = [];
    for (final id in ids) {
      final recipe = await RecipeService.getRecipeById(id);
      if (recipe != null) loaded.add(recipe);
    }
    setState(() {
      _favoriteRecipes = loaded;
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Recipe recipe) async {
    await LocalStorageService.removeFromFavorites(recipe.id);
    setState(() {
      _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita removida dos favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma receita favoritada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione receitas aos favoritos para vê-las aqui',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _favoriteRecipes[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: RecipeCard(
                              title: recipe.title,
                              description: recipe.description,
                              imageUrl: recipe.imageUrl,
                              category: recipe.category,
                              isFavorite: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                              onFavoriteToggle: () => _removeFromFavorites(recipe),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

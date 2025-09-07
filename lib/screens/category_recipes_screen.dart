import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/translation_service.dart';
import '../widgets/molecules/recipe_card.dart';
import 'recipe_detail_screen.dart';

class CategoryRecipesScreen extends StatefulWidget {
  final String categoryKey; // chave em inglês usada pela API

  const CategoryRecipesScreen({super.key, required this.categoryKey});

  @override
  State<CategoryRecipesScreen> createState() => _CategoryRecipesScreenState();
}

class _CategoryRecipesScreenState extends State<CategoryRecipesScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipesByCategory();
  }

  Future<void> _loadRecipesByCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await RecipeService.getRecipesByCategory(widget.categoryKey);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar receitas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translatedTitle = TranslationService.translateCategory(widget.categoryKey);
    return Scaffold(
      appBar: AppBar(
        title: Text(translatedTitle),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma receita encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
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
                                  isFavorite: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  onFavoriteToggle: null,
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



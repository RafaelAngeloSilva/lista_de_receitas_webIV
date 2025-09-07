import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/local_storage_service.dart';
import '../widgets/molecules/recipe_card.dart';
import '../widgets/atoms/custom_button.dart';
import 'recipe_detail_screen.dart';
import 'edit_recipe_screen.dart';

class LocalRecipesScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final VoidCallback onRecipeDeleted;

  const LocalRecipesScreen({
    super.key,
    required this.recipes,
    required this.onRecipeDeleted,
  });

  @override
  State<LocalRecipesScreen> createState() => _LocalRecipesScreenState();
}

class _LocalRecipesScreenState extends State<LocalRecipesScreen> {
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _recipes = List.from(widget.recipes);
  }

  void _deleteRecipe(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.deleteLocalRecipe(recipe.id);
      setState(() {
        _recipes.removeWhere((r) => r.id == recipe.id);
      });
      widget.onRecipeDeleted();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receita "${recipe.title}" excluída com sucesso!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editRecipe(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(recipe: recipe),
      ),
    );

    if (result == true) {
      // Recarregar receitas locais
      final updatedRecipes = await LocalStorageService.loadLocalRecipes();
      setState(() {
        _recipes = updatedRecipes;
      });
      widget.onRecipeDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma receita salva',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sua primeira receita!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Adicionar Receita',
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/add');
                      if (result == true) {
                        final updatedRecipes = await LocalStorageService.loadLocalRecipes();
                        setState(() {
                          _recipes = updatedRecipes;
                        });
                        widget.onRecipeDeleted();
                      }
                    },
                    icon: Icons.add,
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
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Stack(
                            children: [
                              RecipeCard(
                                title: recipe.title,
                                description: recipe.description,
                                imageUrl: recipe.imageUrl,
                                category: recipe.category,
                                isFavorite: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                },
                                onFavoriteToggle: null,
                              ),
                              // Botões de ação
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editRecipe(recipe),
                                        tooltip: 'Editar',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteRecipe(recipe),
                                        tooltip: 'Excluir',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/local_storage_service.dart';
import '../services/translation_service.dart';
import '../widgets/molecules/recipe_card.dart';
import '../widgets/atoms/custom_button.dart';
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _recipes = [];
  List<String> _favoriteIds = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRandomRecipes();
    _loadFavorites();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await RecipeService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar categorias: $e';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadRandomRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await RecipeService.getRandomRecipes(10);
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

  Future<void> _loadFavorites() async {
    final ids = await LocalStorageService.loadFavorites();
    setState(() {
      _favoriteIds = ids;
    });
  }

  Future<void> _loadRecipesByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
      _error = null;
    });

    try {
      final recipes = await RecipeService.getRecipesByCategory(category);
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

  void _toggleFavorite(Recipe recipe) async {
    if (_favoriteIds.contains(recipe.id)) {
      await LocalStorageService.removeFromFavorites(recipe.id);
      setState(() {
        _favoriteIds.remove(recipe.id);
      });
    } else {
      await LocalStorageService.addToFavorites(recipe.id);
      setState(() {
        _favoriteIds.add(recipe.id);
      });
    }
  }

  bool _isFavorite(Recipe recipe) {
    return _favoriteIds.contains(recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Deliciosas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipeScreen(),
                ),
              );
            },
            tooltip: 'Adicionar receita',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de categorias
          if (!_isLoadingCategories)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CustomButton(
                        text: 'Todas',
                        onPressed: _selectedCategory == null ? null : () {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _loadRandomRecipes();
                        },
                        backgroundColor: _selectedCategory == null
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        textColor: _selectedCategory == null
                            ? Colors.white
                            : Colors.black,
                        width: 80,
                        height: 40,
                      ),
                    );
                  }

                  final category = _categories[index - 1];
                  final isSelected = _selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomButton(
                      text: TranslationService.translateCategory(category),
                      onPressed: () => _loadRecipesByCategory(category),
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      textColor: isSelected ? Colors.white : Colors.black,
                      width: 120,
                      height: 40,
                    ),
                  );
                },
              ),
            ),

          // Lista de receitas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
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
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Tentar Novamente',
                              onPressed: _loadRandomRecipes,
                              icon: Icons.refresh,
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
                                        isFavorite: _isFavorite(recipe),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetailScreen(recipe: recipe),
                                            ),
                                          );
                                        },
                                        onFavoriteToggle: () =>
                                            _toggleFavorite(recipe),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favoritos",
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoritesScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

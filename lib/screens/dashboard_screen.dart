import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/molecules/recipe_card.dart';
import '../widgets/atoms/custom_button.dart';
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'local_recipes_screen.dart';
import 'category_recipes_screen.dart';
import '../services/translation_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Recipe> _apiRecipes = [];
  List<Recipe> _localRecipes = [];
  List<String> _favoriteIds = [];
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingCategories = true;
    });

    try {
      // Carregar dados em paralelo
      await Future.wait([
        _loadCategories(),
        _loadRandomRecipes(),
        _loadLocalRecipes(),
        _loadFavorites(),
      ]);
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await RecipeService.getCategories();
      setState(() {
        _categories = categories.map((c) => c).toList();
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
    }
  }

  Future<void> _loadRandomRecipes() async {
    try {
      final recipes = await RecipeService.getRandomRecipes(6);
      setState(() {
        _apiRecipes = recipes;
      });
    } catch (e) {
      print('Erro ao carregar receitas da API: $e');
    }
  }

  Future<void> _loadLocalRecipes() async {
    try {
      final recipes = await LocalStorageService.loadLocalRecipes();
      setState(() {
        _localRecipes = recipes;
      });
    } catch (e) {
      print('Erro ao carregar receitas locais: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await LocalStorageService.loadFavorites();
      setState(() {
        _favoriteIds = favorites;
      });
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
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
        title: const Text('Dashboard de Receitas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipeScreen(),
                ),
              );
              if (result == true) {
                _loadLocalRecipes();
              }
            },
            tooltip: 'Adicionar receita',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: AnimationLimiter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 600),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            _buildWelcomeSection(),
                            const SizedBox(height: 24),
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildLocalRecipesSection(),
                            const SizedBox(height: 24),
                            _buildApiRecipesSection(),
                            const SizedBox(height: 24),
                            _buildCategoriesSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
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

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo ao seu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const Text(
            'Livro de Receitas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_localRecipes.length} receitas salvas • ${_favoriteIds.length} favoritos',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Adicionar Receita',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRecipeScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadLocalRecipes();
                  }
                },
                icon: Icons.add,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Minhas Receitas',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocalRecipesScreen(
                        recipes: _localRecipes,
                        onRecipeDeleted: _loadLocalRecipes,
                      ),
                    ),
                  );
                },
                icon: Icons.book,
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocalRecipesSection() {
    if (_localRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Minhas Receitas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalRecipesScreen(
                      recipes: _localRecipes,
                      onRecipeDeleted: _loadLocalRecipes,
                    ),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _localRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _localRecipes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
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
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  onFavoriteToggle: () => _toggleFavorite(recipe),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApiRecipesSection() {
    if (_apiRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Receitas Sugeridas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _apiRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _apiRecipes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
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
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  onFavoriteToggle: () => _toggleFavorite(recipe),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  text: TranslationService.translateCategory(category),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryRecipesScreen(categoryKey: category),
                      ),
                    );
                  },
                  backgroundColor: Colors.grey.shade200,
                  textColor: Colors.black,
                  width: 120,
                  height: 40,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
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
            onPressed: _loadData,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }
}

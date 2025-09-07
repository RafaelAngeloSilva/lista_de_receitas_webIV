import '../services/translation_service.dart';

class Recipe {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? category;
  final String? area;
  final List<String> ingredients;
  final List<String> instructions;
  final bool isFavorite;
  final bool isLocal; // Nova propriedade para identificar receitas locais

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.category,
    this.area,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = false,
    this.isLocal = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> instructions = [];

    // Extrair ingredientes (TheMealDB usa strIngredient1, strIngredient2, etc.)
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.isNotEmpty) {
        String ingredientText = measure != null && measure.isNotEmpty
            ? '$measure $ingredient'
            : ingredient;
        ingredients.add(ingredientText);
      }
    }

    // Extrair instruções
    String? instructionsText = json['strInstructions'];
    if (instructionsText != null && instructionsText.isNotEmpty) {
      instructions = instructionsText
          .split('\n')
          .where((step) => step.trim().isNotEmpty)
          .map((step) => step.trim())
          .map((step) => TranslationService.translateInstructions(step))
          .toList();
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      description: TranslationService.translateCategory(json['strCategory']),
      imageUrl: json['strMealThumb'],
      category: TranslationService.translateCategory(json['strCategory']),
      area: TranslationService.translateArea(json['strArea']),
      ingredients: ingredients,
      instructions: instructions,
      isLocal: false,
    );
  }

  // Factory para receitas locais
  factory Recipe.fromLocalJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      area: json['area'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      isLocal: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'area': area,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'isLocal': isLocal,
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    String? area,
    List<String>? ingredients,
    List<String>? instructions,
    bool? isFavorite,
    bool? isLocal,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      area: area ?? this.area,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}

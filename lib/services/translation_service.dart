class TranslationService {
  static const Map<String, String> _categoryTranslations = {
    'Beef': 'Carne Bovina',
    'Chicken': 'Frango',
    'Lamb': 'Cordeiro',
    'Pasta': 'Massas',
    'Pork': 'Porco',
    'Seafood': 'Frutos do Mar',
    'Vegetarian': 'Vegetariano',
    'Vegan': 'Vegano',
    'Breakfast': 'Café da Manhã',
    'Dessert': 'Sobremesa',
    'Miscellaneous': 'Diversos',
    'Goat': 'Cabra',
    'Starter': 'Entrada',
  };

  static const Map<String, String> _areaTranslations = {
    'American': 'Americana',
    'British': 'Britânica',
    'Chinese': 'Chinesa',
    'French': 'Francesa',
    'Indian': 'Indiana',
    'Italian': 'Italiana',
    'Japanese': 'Japonesa',
    'Mexican': 'Mexicana',
    'Spanish': 'Espanhola',
    'Thai': 'Tailandesa',
    'Turkish': 'Turca',
    'Unknown': 'Desconhecida',
  };

  static String translateCategory(String? category) {
    if (category == null) return 'Diversos';
    return _categoryTranslations[category] ?? category;
  }

  static String translateArea(String? area) {
    if (area == null) return 'Internacional';
    return _areaTranslations[area] ?? area;
  }

  static String translateInstructions(String instructions) {
    // Traduzir algumas palavras comuns nas instruções
    String translated = instructions;
    
    final translations = {
      'Preheat': 'Pré-aqueça',
      'oven': 'forno',
      'degrees': 'graus',
      'minutes': 'minutos',
      'seconds': 'segundos',
      'Add': 'Adicione',
      'Mix': 'Misture',
      'Stir': 'Mexa',
      'Cook': 'Cozinhe',
      'Bake': 'Asse',
      'Fry': 'Frite',
      'Boil': 'Ferva',
      'Simmer': 'Cozinhe em fogo baixo',
      'Chop': 'Pique',
      'Slice': 'Corte',
      'Dice': 'Corte em cubos',
      'Grate': 'Rale',
      'Season': 'Tempere',
      'Salt': 'Sal',
      'Pepper': 'Pimenta',
      'Oil': 'Óleo',
      'Butter': 'Manteiga',
      'Flour': 'Farinha',
      'Sugar': 'Açúcar',
      'Eggs': 'Ovos',
      'Milk': 'Leite',
      'Water': 'Água',
      'Garlic': 'Alho',
      'Onion': 'Cebola',
      'Tomato': 'Tomate',
      'Cheese': 'Queijo',
      'Meat': 'Carne',
      'Chicken': 'Frango',
      'Fish': 'Peixe',
      'Rice': 'Arroz',
      'Pasta': 'Massa',
      'Bread': 'Pão',
      'Vegetables': 'Legumes',
      'Fruits': 'Frutas',
    };

    for (final entry in translations.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return translated;
  }
}

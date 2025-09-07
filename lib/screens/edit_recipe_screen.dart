import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/recipe.dart';
import '../services/local_storage_service.dart';
import '../widgets/atoms/custom_text_field.dart';
import '../widgets/atoms/custom_button.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _categoryController;
  late final TextEditingController _areaController;
  
  bool _isLoading = false;
  List<String> _ingredients = [];
  List<String> _instructions = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description);
    _ingredientsController = TextEditingController();
    _instructionsController = TextEditingController();
    _imageUrlController = TextEditingController(text: widget.recipe.imageUrl);
    _categoryController = TextEditingController(text: widget.recipe.category);
    _areaController = TextEditingController(text: widget.recipe.area);
    
    _ingredients = List.from(widget.recipe.ingredients);
    _instructions = List.from(widget.recipe.instructions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientsController.text.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientsController.text.trim());
        _ingredientsController.clear();
      });
    }
  }

  void _addInstruction() {
    if (_instructionsController.text.trim().isNotEmpty) {
      setState(() {
        _instructions.add(_instructionsController.text.trim());
        _instructionsController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
    });
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'O título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A descrição é obrigatória';
    }
    if (value.trim().length < 10) {
      return 'A descrição deve ter pelo menos 10 caracteres';
    }
    return null;
  }

  String? _validateImageUrl(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasAbsolutePath) {
        return 'Digite uma URL válida';
      }
    }
    return null;
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ingrediente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma instrução'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        ingredients: _ingredients,
        instructions: _instructions,
        isLocal: true,
      );

      await LocalStorageService.updateLocalRecipe(updatedRecipe);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar receita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receita'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: AnimationLimiter(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // Título
                CustomTextField(
                  label: 'Título da Receita *',
                  hint: 'Ex: Bolo de Chocolate',
                  controller: _titleController,
                  validator: _validateTitle,
                  prefixIcon: Icons.restaurant,
                  semanticsLabel: 'Campo para título da receita',
                ),
                const SizedBox(height: 16),

                // Descrição
                CustomTextField(
                  label: 'Descrição *',
                  hint: 'Descreva brevemente a receita',
                  controller: _descriptionController,
                  validator: _validateDescription,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  semanticsLabel: 'Campo para descrição da receita',
                ),
                const SizedBox(height: 16),

                // Categoria
                CustomTextField(
                  label: 'Categoria',
                  hint: 'Ex: Sobremesa',
                  controller: _categoryController,
                  prefixIcon: Icons.category,
                  semanticsLabel: 'Campo para categoria da receita',
                ),
                const SizedBox(height: 16),

                // Área
                CustomTextField(
                  label: 'Área/Culinária',
                  hint: 'Ex: Brasileira',
                  controller: _areaController,
                  prefixIcon: Icons.public,
                  semanticsLabel: 'Campo para área da receita',
                ),
                const SizedBox(height: 16),

                // URL da imagem
                CustomTextField(
                  label: 'URL da Imagem (opcional)',
                  hint: 'https://exemplo.com/imagem.jpg',
                  controller: _imageUrlController,
                  validator: _validateImageUrl,
                  prefixIcon: Icons.image,
                  semanticsLabel: 'Campo para URL da imagem da receita',
                ),
                const SizedBox(height: 24),

                // Seção de ingredientes
                _buildSection(
                  'Ingredientes *',
                  Icons.shopping_basket,
                  _ingredientsController,
                  _addIngredient,
                  _ingredients,
                  _removeIngredient,
                  'Adicionar ingrediente',
                ),
                const SizedBox(height: 24),

                // Seção de instruções
                _buildSection(
                  'Instruções de Preparo *',
                  Icons.format_list_numbered,
                  _instructionsController,
                  _addInstruction,
                  _instructions,
                  _removeInstruction,
                  'Adicionar instrução',
                ),
                const SizedBox(height: 32),

                // Botão atualizar
                CustomButton(
                  text: 'Atualizar Receita',
                  onPressed: _updateRecipe,
                  isLoading: _isLoading,
                  icon: Icons.save,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    TextEditingController controller,
    VoidCallback onAdd,
    List<String> items,
    Function(int) onRemove,
    String addButtonText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Lista de itens
        if (items.isNotEmpty)
          AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onRemove(index),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Campo para adicionar novo item
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: '',
                hint: addButtonText,
                controller: controller,
                prefixIcon: Icons.add,
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              text: 'Adicionar',
              onPressed: onAdd,
              width: 100,
              height: 48,
            ),
          ],
        ),
      ],
    );
  }
}

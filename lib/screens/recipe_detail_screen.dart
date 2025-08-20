import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegando argumentos com segurança e definindo defaults
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final titulo = args['titulo'] as String? ?? 'Sem título';
    final descricao = args['descricao'] as String? ?? 'Sem descrição';
    final imagemPath = args['imagem'] as String? ?? '';
    final List<String> ingredientes = (args['ingredientes'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final List<String> preparo = (args['preparo'] as List?)?.map((e) => e.toString()).toList() ?? const [];

    Widget buildPlaceholder() => Container(
      height: 220,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 48),
    );

    Widget buildImage(String path) {
      if (path.isEmpty) return buildPlaceholder();
      final isNetwork = path.startsWith('http');

      final Widget imageWidget = isNetwork
          ? Image.network(
              path,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                final total = progress.expectedTotalBytes;
                final loaded = progress.cumulativeBytesLoaded;
                final value = total != null ? loaded / total : null;
                return SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator(value: value)),
                );
              },
              errorBuilder: (context, error, stackTrace) => buildPlaceholder(),
            )
          : Image.asset(
              path,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => buildPlaceholder(),
            );

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      );
    }

    Widget buildIngredientes() {
      if (ingredientes.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Ingredientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...ingredientes.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
                  ],
                ),
              )),
        ],
      );
    }

    Widget buildPreparo() {
      if (preparo.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Modo de preparo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...preparo.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key + 1}. '),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 16))),
                  ],
                ),
              )),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImage(imagemPath),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(fontSize: 18),
            ),
            buildIngredientes(),
            buildPreparo(),
          ],
        ),
      ),
    );
  }
}

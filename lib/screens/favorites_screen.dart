import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
	final List<Map<String, dynamic>> favoritos;

	const FavoritesScreen({super.key, required this.favoritos});

	@override
	Widget build(BuildContext context) {
		Widget buildThumb(String path) {
			final isNetwork = path.startsWith('http');
			final image = isNetwork
					? Image.network(
						path,
						width: 50,
						height: 50,
						fit: BoxFit.cover,
						errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
					)
					: Image.asset(
						path,
						width: 50,
						height: 50,
						fit: BoxFit.cover,
						errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
					);
			return ClipRRect(
				borderRadius: BorderRadius.circular(6),
				child: Container(color: Colors.grey[300], child: image),
			);
		}

		return Scaffold(
			appBar: AppBar(title: const Text("Favoritos")),
			body: favoritos.isEmpty
					? const Center(child: Text("Nenhuma receita favorita ainda"))
					: ListView.builder(
						itemCount: favoritos.length,
						itemBuilder: (context, index) {
							final receita = favoritos[index];
							return Card(
								child: ListTile(
									leading: buildThumb(receita['imagem'] as String),
									title: Text(receita['titulo'] as String),
									subtitle: Text(receita['descricao'] as String),
									onTap: () => Navigator.pushNamed(
										context,
										'/detail',
										arguments: receita,
									),
								),
							);
						},
					),
			bottomNavigationBar: BottomNavigationBar(
				items: const [
					BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
					BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoritos"),
				],
				currentIndex: 1,
				onTap: (index) {
					if (index == 0) Navigator.pop(context);
				},
			),
		);
	}
}

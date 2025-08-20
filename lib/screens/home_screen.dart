import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	final List<Map<String, dynamic>> receitas = const [
	{
		'titulo': 'Bolo de Cenoura',
		'descricao': 'Com cobertura de chocolate',
		'imagem': 'assets/images/bolo.jpg',
		'ingredientes': const [
			'3 ovos',
			'2 xícaras de farinha de trigo',
			'1 e 1/2 xícara de açúcar',
			'1 xícara de leite',
			'1 colher (sopa) de fermento',
		],
		'preparo': const [
			'Bata os ovos com o açúcar até formar um creme claro.',
			'Adicione o leite e a farinha aos poucos, misturando bem.',
			'Acrescente o fermento e incorpore delicadamente.',
			'Despeje em forma untada e asse a 180°C por 35-45 minutos.',
		],
	},
	{
		'titulo': 'Lasanha',
		'descricao': 'Molho bolonhesa e queijo',
		'imagem': 'assets/images/lasanha.jpg',
		'ingredientes': const [
			'Massa de lasanha pré-cozida',
			'400 g de carne moída',
			'1 lata de molho de tomate',
			'300 g de queijo mussarela',
			'200 g de presunto',
			'Queijo parmesão ralado',
		],
		'preparo': const [
			'Refogue a carne moída e adicione o molho de tomate.',
			'Em uma assadeira, faça camadas de massa, molho, presunto e mussarela.',
			'Repita as camadas e finalize com mussarela e parmesão.',
			'Leve ao forno a 200°C por 25-30 minutos até gratinar.',
		],
	},
	{
		'titulo': 'Salada Tropical',
		'descricao': 'Refrescante e saudável',
		'imagem': 'assets/images/salada.jpg',
		'ingredientes': const [
			'Alface',
			'Tomate',
			'Manga',
			'Pepino',
			'Suco de limão',
			'Azeite e sal',
		],
		'preparo': const [
			'Lave e seque bem as folhas e os legumes.',
			'Corte os ingredientes em pedaços médios.',
			'Misture tudo em uma tigela.',
			'Tempere com suco de limão, azeite e sal a gosto.',
		],
	},
];

	final List<Map<String, dynamic>> favoritos = [];

	@override
	Widget build(BuildContext context) {
		Widget buildThumb(String path) {
			final isNetwork = path.startsWith('http');
			final image = isNetwork
					? Image.network(
						path,
						width: 60,
						height: 60,
						fit: BoxFit.cover,
						errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
					)
					: Image.asset(
						path,
						width: 60,
						height: 60,
						fit: BoxFit.cover,
						errorBuilder: (context, error, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
					);
			return ClipRRect(
				borderRadius: BorderRadius.circular(8),
				child: Container(
					color: Colors.grey[300],
					child: image,
				),
			);
		}

		return Scaffold(
			appBar: AppBar(title: const Text('Receitas')),
			body: ListView.builder(
				itemCount: receitas.length,
				itemBuilder: (context, index) {
					final receita = receitas[index];
					final isFavorito = favoritos.contains(receita);

					return Card(
						margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
						child: ListTile(
							leading: buildThumb(receita['imagem'] as String),
							title: Text(receita['titulo'] as String),
							subtitle: Text(receita['descricao'] as String),
							trailing: IconButton(
								icon: Icon(
									isFavorito ? Icons.favorite : Icons.favorite_border,
									color: isFavorito ? Colors.red : null,
								),
								onPressed: () {
									setState(() {
										if (isFavorito) {
											favoritos.remove(receita);
										} else {
											favoritos.add(receita);
										}
									});
								},
							),
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
				currentIndex: 0,
				onTap: (index) {
					if (index == 0) return;
					if (index == 1) {
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (_) => FavoritesScreen(favoritos: favoritos),
							),
						);
					}
				},
			),
		);
	}
}

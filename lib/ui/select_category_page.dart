import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_state.dart';
import 'package:loop_talk/model/categoria.dart';

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({super.key});

  @override
  State<SelectCategoryPage> createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  String _searchQuery = '';
  List<Categoria> _allCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Categoría'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Buscar categoría',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoriaBloc, CategoriaState>(
              builder: (context, state) {
                if (state is CategoriaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoriaLoaded) {
                  _allCategories = state.categorias;
                  final filteredCategories = _allCategories
                      .where((categoria) => categoria.nombre
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredCategories.isEmpty) {
                    return const Center(child: Text('No se encontraron categorías.'));
                  }

                  return ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final categoria = filteredCategories[index];
                      return ListTile(
                        title: Text(categoria.nombre),
                        onTap: () {
                          Navigator.of(context).pop(categoria);
                        },
                      );
                    },
                  );
                }
                if (state is CategoriaError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('Cargando categorías...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

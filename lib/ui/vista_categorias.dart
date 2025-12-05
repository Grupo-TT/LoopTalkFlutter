import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/components/snackbar_helper.dart';
import '../bloc/categoria_bloc.dart';
import '../bloc/categoria_event.dart';
import '../bloc/categoria_state.dart';
import '../model/categoria.dart';

class VistaCategorias extends StatefulWidget {
  final GlobalKey? tutorialFabKey;

  const VistaCategorias({super.key, this.tutorialFabKey});

  @override
  State<VistaCategorias> createState() => _VistaCategoriasState();
}

class _VistaCategoriasState extends State<VistaCategorias> {
  final List<Color> _cardColors = const [
    Color(0xFF929ED8),
    Color(0xFF92999E),
    Color(0xFFDFD565),
    Color(0xFF81BC79),
    Color(0xFFD9907C),
  ];

  @override
  void initState() {
    super.initState();
    context.read<CategoriaBloc>().add(LoadCategorias());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 70.0,
        ), // 💜 lo sube para que no se tape
        child: FloatingActionButton(
          key: widget.tutorialFabKey,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _openCreateDialog(context),
        ),
      ),
      body: BlocListener<CategoriaBloc, CategoriaState>(
        listener: (context, state) {
          if (state is CategoriaOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categoría creada correctamente')),
            );
          } else if (state is CategoriaError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: BlocBuilder<CategoriaBloc, CategoriaState>(
          builder: (context, state) {
            if (state is CategoriaLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoriaLoaded) {
              final categorias = state.categorias;
              if (categorias.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay categorías disponibles',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea una nueva categoría para comenzar',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20.0),
                itemCount: categorias.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  final cardColor = _cardColors[index % _cardColors.length];

                  return InkWell(
                    onTap: () => _openEditDialog(context, categoria),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoria.nombre,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoria.descripcion,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (state is CategoriaError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _openCreateDialog(BuildContext context) {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final categoriaBloc = context.read<CategoriaBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                final nombre = nombreController.text.trim();
                final descripcion = descripcionController.text.trim();
                if (nombre.isEmpty || descripcion.isEmpty) {
                  SnackBarHelper.showErrorMessage(
                    context,
                    "Por favor, completa todos los campos",
                  );
                  return;
                }

                // Construir la categoría (id null) y despachar al bloc
                final nueva = Categoria(
                  id: null,
                  nombre: nombre,
                  descripcion: descripcion,
                );
                categoriaBloc.add(CreateCategoria(nueva));

                Navigator.of(context).pop();
                // Opcional: mostrar feedback rápido
                SnackBarHelper.showSuccesssMessage(
                  context,
                  'Categoria creada exitosamente',
                );
              },
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openEditDialog(BuildContext context, Categoria categoria) {
    final nombreController = TextEditingController(text: categoria.nombre);
    final descripcionController = TextEditingController(
      text: categoria.descripcion,
    );
    final categoriaBloc = context.read<CategoriaBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                final nombre = nombreController.text.trim();
                final descripcion = descripcionController.text.trim();
                if (nombre.isEmpty || descripcion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos'),
                    ),
                  );
                  return;
                }

                final updated = Categoria(
                  id: categoria.id,
                  nombre: nombre,
                  descripcion: descripcion,
                );
                categoriaBloc.add(UpdateCategoria(updated));

                Navigator.of(context).pop();
                SnackBarHelper.showSuccesssMessage(
                  context,
                  'Categoria actualizada exitosamente',
                );
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

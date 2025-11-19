import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/components/snackbar_helper.dart';
import '../bloc/categoria_bloc.dart';
import '../bloc/categoria_event.dart';
import '../bloc/categoria_state.dart';
import '../model/categoria.dart';

class VistaCategorias extends StatefulWidget {
  const VistaCategorias({super.key});

  @override
  State<VistaCategorias> createState() => _VistaCategoriasState();
}

class _VistaCategoriasState extends State<VistaCategorias> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriaBloc>().add(LoadCategorias());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorías',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 70.0,
        ), // 💜 lo sube para que no se tape
        child: FloatingActionButton(
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
            // Si el bloc ya emitió CategoriaLoaded (ver lógica del bloc), la UI
            // se actualizará automáticamente. No forzamos un reload aquí.
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
                return const Center(
                  child: Text('No hay categorías disponibles.'),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];
                    return InkWell(
                      onTap: () => _openEditDialog(context, categoria),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoria.nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categoria.descripcion,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
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
                ),
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

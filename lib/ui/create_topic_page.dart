import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_event.dart';
import 'package:loop_talk/bloc/categoria_state.dart';
import 'package:loop_talk/bloc/create_topic_bloc.dart';
import 'package:loop_talk/model/categoria.dart';
import 'package:loop_talk/ui/select_category_page.dart';

class CreateTopicPage extends StatelessWidget {
  const CreateTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Tópico'),
      ),
      body: BlocListener<CreateTopicBloc, CreateTopicState>(
        listener: (context, state) {
          if (state is CreateTopicSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tópico creado con éxito')),
            );
            Navigator.of(context).pop();
          } else if (state is CreateTopicFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        child: const CreateTopicForm(),
      ),
    );
  }
}

class CreateTopicForm extends StatefulWidget {
  const CreateTopicForm({super.key});

  @override
  State<CreateTopicForm> createState() => _CreateTopicFormState();
}

class _CreateTopicFormState extends State<CreateTopicForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _categoryController = TextEditingController();
  Categoria? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    context.read<CategoriaBloc>().add(LoadCategorias());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un mensaje';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                hintText: 'Seleccione una categoría',
              ),
              onTap: () async {
                final Categoria? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectCategoryPage()),
                );

                if (result != null) {
                  setState(() {
                    _selectedCategoria = result;
                    _categoryController.text = result.nombre;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<CreateTopicBloc, CreateTopicState>(
              builder: (context, state) {
                if (state is CreateTopicInProgress) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<CreateTopicBloc>().add(
                            CreateTopicSubmitted(
                              titulo: _titleController.text,
                              mensaje: _messageController.text,
                              idCurso: _selectedCategoria!.id!,
                            ),
                          );
                    }
                  },
                  child: const Text('Crear Tópico'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}

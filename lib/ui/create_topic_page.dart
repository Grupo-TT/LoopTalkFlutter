import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_event.dart';
import 'package:loop_talk/bloc/categoria_state.dart';
import 'package:loop_talk/bloc/create_topic_bloc.dart';
import 'package:loop_talk/components/snackbar_helper.dart';
import 'package:loop_talk/model/categoria.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';
import 'package:loop_talk/ui/select_category_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
            context.read<TopicoBloc>().add(LoadTopicos());
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

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  final String _currentLocaleId = 'es-ES';
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoriaBloc>().add(LoadCategorias());
    _initSpeech();
  }

  void _initSpeech() async {
    final hasPermission = await _solicitarPermisoMicrofono();
    if (hasPermission) {
      _speechEnabled = await _speech.initialize(
        onError: _speechErrorListener,
        onStatus: _speechStatusListener,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<bool> _solicitarPermisoMicrofono() async {
    final status = await Permission.microphone.request();

    if (!mounted) return false;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      SnackBarHelper.showInfoMessage(
        context,
        'Permiso denegado para acceder al micrófono.',
      );
    } else if (status.isPermanentlyDenied) {
      SnackBarHelper.showActionMessage(
        context,
        'El permiso para el micrófono está denegado permanentemente.',
        actionLabel: 'Ajustes',
        onActionPressed: () => openAppSettings(),
      );
    }

    return false;
  }

  void _speechStatusListener(String status) {
    if (mounted) {
      setState(() {
        _isListening = _speech.isListening;
      });
    }
  }

  void _speechErrorListener(SpeechRecognitionError errorNotification) {
    if (mounted) {
      SnackBarHelper.showErrorMessage(context, 'Error: ${errorNotification.errorMsg}');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _startDictado() {
    if (!_speechEnabled) {
      SnackBarHelper.showInfoMessage(
        context,
        'El reconocimiento de voz no está disponible.',
      );
      return;
    }
    if (_isListening) return;

    setState(() {
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _messageController.text = result.recognizedWords;
            _messageController.selection = TextSelection.collapsed(
              offset: _messageController.text.length,
            );
          });
        }
      },
      localeId: _currentLocaleId,
      pauseFor: const Duration(minutes: 5),
      listenFor: const Duration(minutes: 5),
    );
  }

  void _stopDictado() {
    if (!_isListening) return;
    _speech.stop();
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
              decoration: InputDecoration(
                labelText: 'Mensaje',
                suffixIcon: Listener(
                  onPointerDown: (_) {
                    _isButtonPressed = true;
                    _startDictado();
                  },
                  onPointerUp: (_) {
                    _isButtonPressed = false;
                    _stopDictado();
                  },
                  child: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.red : Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
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
    _speech.cancel();
    super.dispose();
  }
}


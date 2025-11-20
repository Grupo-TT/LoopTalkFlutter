import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_event.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Crear Nuevo Tópico'),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        foregroundColor: Colors.white,
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
    final theme = Theme.of(context);
    final purpleColor = const Color(0xFF7C3AED);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo Tópico',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte tus ideas con la comunidad.',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: purpleColor, width: 2.0),
                      ),
                    ),
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
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: purpleColor, width: 2.0),
                      ),
                      suffixIcon: Listener(
                        onPointerDown: (_) {
                          _isButtonPressed = true;
                          _startDictado();
                        },
                        onPointerUp: (_) {
                          _isButtonPressed = false;
                          _stopDictado();
                        },
                        child: AnimatedScale(
                          scale: _isListening ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.mic,
                            color: _isListening ? purpleColor : Colors.grey,
                          ),
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
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      hintText: 'Seleccione una categoría',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: purpleColor, width: 2.0),
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purpleColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
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
                        child: const Text('Crear Tópico', style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ],
              ),
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


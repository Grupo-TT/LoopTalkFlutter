import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/topico_bloc.dart';
import '../../bloc/topico_event.dart';
import '../../bloc/topico_state.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../bloc/categoria_bloc.dart';
import '../../repository/categoria_service.dart';
import '../../components/user_avatar.dart';
import 'vista_login.dart';
import 'vista_categorias.dart';

class VistaTopicos extends StatefulWidget {
  const VistaTopicos({super.key});

  @override
  State<VistaTopicos> createState() => _VistaTopicosState();
}

class _VistaTopicosState extends State<VistaTopicos> {
  @override
  void initState() {
    super.initState();
    context.read<TopicoBloc>().add(LoadTopicos());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const VistaLogin()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'r/LoopTalk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: false,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text(
                  'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categorías'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => CategoriaBloc(CategoriaService()),
                        child: const VistaCategorias(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(LogoutEvent());
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<TopicoBloc, TopicoState>(
          builder: (context, state) {
            if (state is TopicoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TopicoLoaded) {
              return ListView.builder(
                itemCount: state.topicos.length,
                itemBuilder: (context, index) {
                  final topico = state.topicos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 8.0,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author row with profile image
                          Row(
                            children: [
                              UserAvatar(
                                userId: topico.autor?.id,
                                radius: 12,
                                backgroundColor: Colors.blueGrey,
                                iconColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                topico.autor != null
                                    ? 'u/${topico.autor!.nombre.replaceAll(' ', '_')}'
                                    : 'u/Anonimo',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                topico.curso != null
                                    ? 'r/${topico.curso!.nombre}'
                                    : 'r/General',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.more_horiz,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            topico.titulo,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topico.mensaje,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Show topic image if exists
                          if (topico.fotoUrl != null &&
                              topico.fotoUrl!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                topico.fotoUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '0 Comentarios',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.share, size: 18, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is TopicoError) {
              return Center(
                child: Text('Error al cargar tópicos: ${state.message}'),
              );
            }
            return const Center(child: Text('No hay tópicos disponibles.'));
          },
        ),
      ),
    );
  }
}

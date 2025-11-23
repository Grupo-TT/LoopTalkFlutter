import 'package:flutter_test/flutter_test.dart';
import 'package:loop_talk/model/topico.dart';
import 'package:loop_talk/model/usuario.dart';
import 'package:loop_talk/model/categoria.dart';
import 'package:loop_talk/model/rol.dart';

void main() {
  group('Topico', () {
    final autorPrueba = Usuario(
      id: 100,
      nombre: 'Autor de Tópico',
      correoElectronico: 'autor.topico@example.com',
      rol: Rol.estudiante,
    );

    final categoriaPrueba = Categoria(
      id: 200,
      nombre: 'Flutter',
      descripcion: 'Desarrollo de aplicaciones con Flutter.',
    );

    test('debería crear un objeto Topico correctamente', () {
      final topico = Topico(
        id: 1,
        titulo: 'Mi primer Tópico',
        mensaje: 'Este es el contenido de mi primer tópico.',
        estado: 'ABIERTO',
        fechaCreacion: '2025-11-22T14:00:00Z',
        autor: autorPrueba,
        curso: categoriaPrueba,
      );

      expect(topico.id, 1);
      expect(topico.titulo, 'Mi primer Tópico');
      expect(topico.mensaje, 'Este es el contenido de mi primer tópico.');
      expect(topico.estado, 'ABIERTO');
      expect(topico.fechaCreacion, '2025-11-22T14:00:00Z');
      expect(topico.autor, autorPrueba);
      expect(topico.curso, categoriaPrueba);
    });

    group('fromJson', () {
      test('debería parsear JSON a Topico correctamente', () {
        final json = {
          'id': 2,
          'titulo': 'Tópico desde JSON',
          'mensaje': 'Contenido del tópico desde JSON.',
          'estado': 'CERRADO',
          'fechaCreacion': '2025-11-22T15:00:00Z',
          'autor': {
            'id': 101,
            'nombre': 'Autor JSON',
            'correoElectronico': 'json@example.com',
            'rol': 'profesor',
          },
          'curso': {
            'id': 201,
            'nombre': 'Dart',
            'categoria': 'Programación en Dart.',
          },
        };
        final topico = Topico.fromJson(json);

        expect(topico.id, 2);
        expect(topico.titulo, 'Tópico desde JSON');
        expect(topico.mensaje, 'Contenido del tópico desde JSON.');
        expect(topico.estado, 'CERRADO');
        expect(topico.fechaCreacion, '2025-11-22T15:00:00Z');
        expect(topico.autor, isNotNull);
        expect(topico.autor!.id, 101);
        expect(topico.curso, isNotNull);
        expect(topico.curso!.id, 201);
        expect(topico.curso!.nombre, 'Dart');
      });

      test('debería manejar campos nulos correctamente', () {
        final json = {
          'id': 3,
          'titulo': 'Tópico simple',
          'mensaje': 'Solo con título y mensaje.',
        };
        final topico = Topico.fromJson(json);

        expect(topico.id, 3);
        expect(topico.titulo, 'Tópico simple');
        expect(topico.mensaje, 'Solo con título y mensaje.');
        expect(topico.estado, isNull);
        expect(topico.fechaCreacion, isNull);
        expect(topico.autor, isNull);
        expect(topico.curso, isNull);
      });
    });

    group('toJsonCreate', () {
      test('debería convertir a JSON para creación correctamente', () {
        final topico = Topico(
          titulo: 'Nuevo Tópico para API',
          mensaje: 'Este es el mensaje que se enviará.',
        );
        final json = topico.toJsonCreate(300);

        expect(json, {
          'titulo': 'Nuevo Tópico para API',
          'mensaje': 'Este es el mensaje que se enviará.',
          'idCurso': 300,
        });
      });
    });
  });
}

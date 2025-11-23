import 'package:flutter_test/flutter_test.dart';
import 'package:loop_talk/model/comentario.dart';
import 'package:loop_talk/model/usuario.dart';
import 'package:loop_talk/model/rol.dart';

void main() {
  group('Comentario', () {
    final autorPrueba = Usuario(
      id: 100,
      nombre: 'Autor de Prueba',
      correoElectronico: 'autor@example.com',
      rol: Rol.estudiante,
    );

    test('debería crear un objeto Comentario correctamente', () {
      final comentario = Comentario(
        id: 1,
        contenido: 'Este es un comentario de prueba.',
        fechaCreacion: '2025-11-22T10:00:00Z',
        autor: autorPrueba,
        topicoId: 10,
      );

      expect(comentario.id, 1);
      expect(comentario.contenido, 'Este es un comentario de prueba.');
      expect(comentario.fechaCreacion, '2025-11-22T10:00:00Z');
      expect(comentario.autor, isNotNull);
      expect(comentario.autor!.id, 100);
      expect(comentario.topicoId, 10);
    });

    group('fromJson', () {
      test('debería parsear JSON a Comentario correctamente', () {
        final json = {
          'id': 2,
          'contenido': 'Contenido desde JSON.',
          'fechaCreacion': '2025-11-22T11:00:00Z',
          'autor': {
            'id': 101,
            'nombre': 'Autor JSON',
            'correoElectronico': 'json@example.com',
            'rol': 'profesor',
          },
          'topicoId': 20,
        };
        final comentario = Comentario.fromJson(json);

        expect(comentario.id, 2);
        expect(comentario.contenido, 'Contenido desde JSON.');
        expect(comentario.fechaCreacion, '2025-11-22T11:00:00Z');
        expect(comentario.autor, isNotNull);
        expect(comentario.autor!.id, 101);
        expect(comentario.autor!.nombre, 'Autor JSON');
        expect(comentario.autor!.rol, Rol.profesor);
        expect(comentario.topicoId, 20);
      });

      test('debería usar "mensaje" si "contenido" es nulo', () {
        final json = {
          'id': 3,
          'mensaje': 'Contenido desde la clave "mensaje".',
          'fechaCreacion': '2025-11-22T12:00:00Z',
        };
        final comentario = Comentario.fromJson(json);

        expect(comentario.id, 3);
        expect(comentario.contenido, 'Contenido desde la clave "mensaje".');
      });

      test('debería usar topico.id si topicoId es nulo', () {
        final json = {
          'id': 4,
          'contenido': 'Probando topico anidado.',
          'topico': {'id': 30},
        };
        final comentario = Comentario.fromJson(json);

        expect(comentario.id, 4);
        expect(comentario.topicoId, 30);
      });

      test('debería manejar campos nulos correctamente', () {
        final json = {
          'id': 5,
          'contenido': 'Comentario sin autor ni fecha.',
        };
        final comentario = Comentario.fromJson(json);

        expect(comentario.id, 5);
        expect(comentario.contenido, 'Comentario sin autor ni fecha.');
        expect(comentario.fechaCreacion, isNull);
        expect(comentario.autor, isNull);
        expect(comentario.topicoId, isNull);
      });

      test('debería usar un string vacío si "contenido" y "mensaje" son nulos', () {
        final json = {'id': 6};
        final comentario = Comentario.fromJson(json);
        expect(comentario.contenido, '');
      });
    });

    group('toJsonCreate', () {
      test('debería convertir a JSON para creación correctamente', () {
        final comentario = Comentario(
          contenido: 'Nuevo comentario para enviar.',
        );
        final json = comentario.toJsonCreate(40);

        expect(json, {
          'contenido': 'Nuevo comentario para enviar.',
          'mensaje': 'Nuevo comentario para enviar.',
          'topicoId': 40,
          'topico': {'id': 40},
        });
      });
    });
  });
}

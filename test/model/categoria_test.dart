import 'package:flutter_test/flutter_test.dart';
import 'package:loop_talk/model/categoria.dart';

void main() {
  group('Categoria', () {
    test('debería crear un objeto Categoria correctamente con id', () {
      final categoria = Categoria(
        id: 1,
        nombre: 'Programación',
        descripcion: 'Discusiones sobre lenguajes de programación y desarrollo.',
      );

      expect(categoria.id, 1);
      expect(categoria.nombre, 'Programación');
      expect(categoria.descripcion, 'Discusiones sobre lenguajes de programación y desarrollo.');
    });

    test('debería crear un objeto Categoria correctamente sin id', () {
      final categoria = Categoria(
        nombre: 'Diseño Gráfico',
        descripcion: 'Todo sobre diseño, UI y UX.',
      );

      expect(categoria.id, isNull);
      expect(categoria.nombre, 'Diseño Gráfico');
      expect(categoria.descripcion, 'Todo sobre diseño, UI y UX.');
    });

    group('fromJson', () {
      test('debería parsear JSON a Categoria correctamente', () {
        final json = {
          'id': 10,
          'nombre': 'Bases de Datos',
          'categoria': 'Consultas, modelos y administración de bases de datos.',
        };
        final categoria = Categoria.fromJson(json);

        expect(categoria.id, 10);
        expect(categoria.nombre, 'Bases de Datos');
        expect(categoria.descripcion, 'Consultas, modelos y administración de bases de datos.');
      });

      test('debería manejar un id nulo en JSON', () {
        final json = {
          'id': null,
          'nombre': 'Redes',
          'categoria': 'Protocolos y configuración de redes.',
        };
        final categoria = Categoria.fromJson(json);

        expect(categoria.id, isNull);
        expect(categoria.nombre, 'Redes');
        expect(categoria.descripcion, 'Protocolos y configuración de redes.');
      });
    });

    group('toJson', () {
      test('toJsonCreate debería convertir a JSON sin id', () {
        final categoria = Categoria(
          nombre: 'Seguridad Informática',
          descripcion: 'Técnicas de hacking ético y ciberseguridad.',
        );
        final json = categoria.toJsonCreate();

        expect(json, {
          'nombre': 'Seguridad Informática',
          'categoria': 'Técnicas de hacking ético y ciberseguridad.',
        });
      });

      test('toJsonUpdate debería convertir a JSON con id', () {
        final categoria = Categoria(
          id: 20,
          nombre: 'Inteligencia Artificial',
          descripcion: 'Machine learning, deep learning y más.',
        );
        final json = categoria.toJsonUpdate();

        expect(json, {
          'id': 20,
          'nombre': 'Inteligencia Artificial',
          'categoria': 'Machine learning, deep learning y más.',
        });
      });
    });
  });
}

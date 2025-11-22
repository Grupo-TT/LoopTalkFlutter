import 'package:flutter_test/flutter_test.dart';
import 'package:loop_talk/model/usuario.dart';
import 'package:loop_talk/model/rol.dart';

void main() {
  group('Usuario', () {
    test('debería crear un objeto Usuario correctamente', () {
      final usuario = Usuario(
        id: 1,
        nombre: 'Usuario de Prueba',
        correoElectronico: 'test@example.com',
        rol: Rol.estudiante,
        contrasenia: 'clave123',
      );

      expect(usuario.id, 1);
      expect(usuario.nombre, 'Usuario de Prueba');
      expect(usuario.correoElectronico, 'test@example.com');
      expect(usuario.rol, Rol.estudiante);
      expect(usuario.contrasenia, 'clave123');
    });

    group('fromJson', () {
      test('debería parsear JSON correctamente con todos los campos', () {
        final json = {
          'id': 2,
          'nombre': 'Otro Usuario',
          'correoElectronico': 'another@example.com',
          'rol': 'profesor',
        };
        final usuario = Usuario.fromJson(json);

        expect(usuario.id, 2);
        expect(usuario.nombre, 'Otro Usuario');
        expect(usuario.correoElectronico, 'another@example.com');
        expect(usuario.rol, Rol.profesor);
        expect(usuario.contrasenia, isNull);
      });

      test('debería parsear JSON correctamente usando "username" en lugar de "nombre"', () {
        final json = {
          'id': 3,
          'username': 'Usuario Con Username',
          'correoElectronico': 'username@example.com',
          'rol': 'estudiante',
        };
        final usuario = Usuario.fromJson(json);

        expect(usuario.id, 3);
        expect(usuario.nombre, 'Usuario Con Username');
        expect(usuario.correoElectronico, 'username@example.com');
        expect(usuario.rol, Rol.estudiante);
      });

      test('debería manejar campos faltantes con valores por defecto', () {
        final json = {
          'id': 4,
          'correoElectronico': 'missing@example.com',
          // 'nombre' y 'rol' están ausentes
        };
        final usuario = Usuario.fromJson(json);

        expect(usuario.id, 4);
        expect(usuario.nombre, 'Usuario'); // Valor por defecto de fromJson
        expect(usuario.correoElectronico, 'missing@example.com');
        expect(usuario.rol, Rol.estudiante); // Valor por defecto de _parseRol
      });

      test('debería parsear el rol desde un valor enum', () {
        final json = {
          'id': 5,
          'nombre': 'Usuario con Rol Enum',
          'correoElectronico': 'enum@example.com',
          'rol': Rol.profesor,
        };
        final usuario = Usuario.fromJson(json);

        expect(usuario.id, 5);
        expect(usuario.rol, Rol.profesor);
      });

      test('debería usar "estudiante" por defecto si el rol es inválido o no existe', () {
        final jsonInvalidRol = {
          'id': 6,
          'nombre': 'Usuario con Rol Inválido',
          'correoElectronico': 'invalid@example.com',
          'rol': 'rol_invalido',
        };
        final usuarioInvalidRol = Usuario.fromJson(jsonInvalidRol);
        expect(usuarioInvalidRol.rol, Rol.estudiante);

        final jsonMissingRol = {
          'id': 7,
          'nombre': 'Usuario con Rol Faltante',
          'correoElectronico': 'missingrol@example.com',
        };
        final usuarioMissingRol = Usuario.fromJson(jsonMissingRol);
        expect(usuarioMissingRol.rol, Rol.estudiante);
      });
    });

    group('toJson', () {
      test('debería convertir un objeto Usuario a JSON correctamente', () {
        final usuario = Usuario(
          id: 1,
          nombre: 'Usuario de Prueba',
          correoElectronico: 'test@example.com',
          rol: Rol.estudiante,
        );
        final json = usuario.toJson();

        expect(json, {
          'id': 1,
          'nombre': 'Usuario de Prueba',
          'correoElectronico': 'test@example.com',
          'rol': 'estudiante',
        });
      });
    });

    group('toJsonLogin', () {
      test('debería convertir un objeto Usuario a JSON para login correctamente', () {
        final usuario = Usuario(
          id: 1,
          nombre: 'Usuario de Prueba',
          correoElectronico: 'Test@Example.com', // Mayúsculas y minúsculas para probar toLowerCase
          rol: Rol.estudiante,
          contrasenia: 'claveSegura',
        );
        final json = usuario.toJsonLogin();

        expect(json, {
          'correoElectronico': 'test@example.com',
          'contrasenia': 'claveSegura',
        });
      });
    });
  });
}
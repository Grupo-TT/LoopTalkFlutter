import 'package:flutter_test/flutter_test.dart';
import 'package:loop_talk/model/rol.dart';

void main() {
  group('Rol', () {
    test('debería tener 3 valores definidos', () {
      expect(Rol.values.length, 3);
    });

    test('debería contener los valores estudiante, moderador y profesor', () {
      expect(Rol.values, contains(Rol.estudiante));
      expect(Rol.values, contains(Rol.moderador));
      expect(Rol.values, contains(Rol.profesor));
    });
  });
}

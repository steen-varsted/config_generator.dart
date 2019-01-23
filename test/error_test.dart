import 'package:test/test.dart';
import 'test_support.dart';

void main() {
  group('Tests', () {
    test('Abstract', () async {
      var result = await generate('''
class Test {
}       
      ''');
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Config classes must be abstract.'));
    });
    test('Const constructor', () async {
      var result = await generate('''
abstract class Test {
}       
      ''');
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Config classes mmust have exactly one const noarg constructor.'));
    });
    test('References', () async {
      var result = await generate('''
abstract class Test {
  const Test();
  dynamic get test2;
}       
      ''');
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('The type dynamic is not String or int, and is not defined in the config library.'));
    });
    test('Top level 0', () async {
      var result = await generate('''
      ''');
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Top level configuration class not found.'));
    });
    test('Top level 2', () async {
      var result = await generate('''
abstract class Test1 {
  const Test1();
}       
abstract class Test2 {
  const Test2();
}       
      ''');
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Top level configuration class not found - multiple candidates.'));
    });
    test('Int', () async {
      var result = await generate('''
abstract class Test1 {
  const Test1();
  int get test;
}       
      ''', config: <String, dynamic>{'test': 'a'});
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Expected int for Test1.test in yaml file.'));
    });
    test('String', () async {
      var result = await generate('''
abstract class Test1 {
  const Test1();
  String get test;
}       
      ''', config: <String, dynamic>{'test': <String, dynamic>{'a': 'b'}});
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Expected String for Test1.test in yaml file.'));
    });
    test('Map', () async {
      var result = await generate('''
abstract class Test1 {
  const Test1();
  Test2 get test;
}       
abstract class Test2 {
  const Test2();
  int get test;
}       
      ''', config: <String, dynamic>{'test': 'a'});
      expect(result, isInvalidGenerationSourceError);
      expect(result.toString(), equals('Expected map for Test1.test in yaml file.'));
    });
  });
}


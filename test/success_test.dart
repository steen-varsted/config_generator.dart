import 'package:test/test.dart';
import 'test_support.dart';

void main() {
  group('Tests', () {
    test('Int', () async {
      var result = await generate('''
part 'config.g.dart';
abstract class Test1 {
  const Test1();
  int get test;
}       
      ''', config: <String, dynamic>{'test': 1});
      expect(result, stringContainsInOrder(['Test1(1)']));
    });
    test('String', () async {
      var result = await generate('''
part 'config.g.dart';
abstract class Test1 {
  const Test1();
  String get test;
}       
      ''', config: <String, dynamic>{'test': 'a'});
      expect(result, stringContainsInOrder(["Test1('a')"]));
    });
    test('Nested', () async {
      var result = await generate('''
part 'config.g.dart';
abstract class Test1 {
  const Test1();
  Test2 get test;
}       
abstract class Test2 {
  const Test2();
  String get test;
}       
      ''', config: <String, dynamic>{'test': <String, dynamic>{'test': 'a'}});
      expect(result, stringContainsInOrder(["Test2('a')"]));
    });
  });
}


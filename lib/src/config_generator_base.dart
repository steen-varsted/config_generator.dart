import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:async';

class _Descriptor {
  ClassElement element;

  _Descriptor(this.element) {
    if (!this.element.isAbstract) {
      throw InvalidGenerationSourceError('Config classes must be abstract.',
          todo: 'Make ${this.element.name} abstract');
    }
    if (this.element.constructors.length != 1 || !this.element.constructors[0].isConst) {
      throw InvalidGenerationSourceError('Config classes mmust have exactly one const noarg constructor.',
          todo: 'Make sure ${this.element.name} has exactly one const noarg cosntructor');
    }
  }

  Iterable<String> get references => element.fields
      .where((f) => !f.isStatic)
      .map((f) => ['String', 'int'].contains(f.getter.returnType.name) ? null : f.getter.returnType.name)
      .where(((n) => n != null));

  Iterable<PropertyAccessorElement> get getters => element.fields.map((f) => f.getter).where((g) => !g.isStatic);
}

class ConfigGenerator extends Generator {
  BuilderOptions _options;

  ConfigGenerator(this._options);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    var classMap = library.classes.toList().asMap().map((i, c) => MapEntry(c.name, _Descriptor(c)));
    var allReferences = classMap.length > 0
        ? classMap.values.map((d) => d.references).reduce((i1, i2) => i1.toList() + i2.toList())
        : <String>[];
    if (allReferences.any((r) => !classMap.containsKey(r))) {
      throw InvalidGenerationSourceError(
          'The type ${allReferences.firstWhere((r) => !classMap.containsKey(r))} is not String or int, and is not defined in the config library.');
    }
    var top = classMap.keys.where((k) => !allReferences.contains(k));
    if (top.length == 0) {
      throw InvalidGenerationSourceError('Top level configuration class not found.');
    }
    if (top.length > 1) {
      throw InvalidGenerationSourceError('Top level configuration class not found - multiple candidates.');
    }
    var configClass = top.first;
    var generated = classMap.values.map((c) => generateClass(c));
    var initializer = generateInitializer(classMap[configClass], classMap, _options.config);
    final emitter = DartEmitter();
    return generated.map((c) => c.accept(emitter).toString()).join('\n\n') +
        '\n\n' +
        initializer.accept(emitter).toString();
  }

  Field generateInitializer(_Descriptor d, Map<String, _Descriptor> classMap, Map<String, dynamic> config) {
    return Field((m) => m
      ..name = 'config'
      ..type = Reference(d.element.name.startsWith('_') ? d.element.interfaces.first.name : d.element.name)
      ..modifier = FieldModifier.constant
      ..assignment = Code(generateConstruction(d, classMap, config)));
  }

  String generateConstruction(_Descriptor d, Map<String, _Descriptor> classMap, Map<String, dynamic> config) {
    return 'const _${d.element.name}(' + generateArgumentList(d, classMap, config).join(', ') + ')';
  }

  Iterable<String> generateArgumentList(_Descriptor d, Map<String, _Descriptor> classMap, Map<String, dynamic> config) {
    return d.getters.map((g) => generateArgument(g, config[g.name], classMap));
  }

  String generateArgument(PropertyAccessorElement getter, dynamic config, Map<String, _Descriptor> classMap) {
    if (config == null) {
      return 'null';
    } else if (getter.returnType.name == 'int') {
      if (config is int) {
        return config.toString();
      } else if (config is String) {
        var value = int.tryParse(config);
        if (value != null) {
          return value.toString();
        }
      }
      throw InvalidGenerationSourceError(
          'Expected int for ${getter.enclosingElement.name}.${getter.name} in yaml file.');
    } else if (getter.returnType.name == 'String') {
      if (config is String) {
        return "'$config'";
      } else {
        throw InvalidGenerationSourceError(
            'Expected String for ${getter.enclosingElement.name}.${getter.name} in yaml file.');
      }
    } else {
      if (classMap.containsKey(getter.returnType.name)) {
        if (config is Map) {
          var mapConfig = config as Map;
          return generateConstruction(classMap[getter.returnType.name], classMap,
              mapConfig.map((k, v) => MapEntry<String, dynamic>(k.toString(), v)));
        } else {
          throw InvalidGenerationSourceError(
              'Expected map for ${getter.enclosingElement.name}.${getter.name} in yaml file.');
        }
      }
    }
  }

  Class generateClass(_Descriptor d) {
    return Class((c) => c
      ..name = '_' + d.element.name
      ..extend = Reference(d.element.name)
      ..fields.addAll(d.getters.map((g) => Field((f) => f
        ..name = g.name
        ..modifier = FieldModifier.final$
        ..type = Reference(g.returnType.toString()))))
      ..constructors.add(Constructor((c) => c
        ..constant = true
        ..requiredParameters.addAll(d.getters.map((g) => Parameter((p) => p..name = 'this.${g.name}'))))));
  }
}

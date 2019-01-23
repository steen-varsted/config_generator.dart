import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:config_generator/config_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

var isInvalidGenerationSourceError = const TypeMatcher<InvalidGenerationSourceError>();

final String pkgName = 'pkg';

Future<dynamic> generate(String source, { Map<String, dynamic> config = const <String, dynamic>{} }) async {
  final srcs = <String, String>{
    '$pkgName|lib/config.dart': source
  };

  dynamic error;
  void saveError(LogRecord logRecord) => error ??= logRecord.error;

  final writer = new InMemoryAssetWriter();
  await testBuilder(configBuilder(BuilderOptions(config)), srcs,
      rootPackage: pkgName, writer: writer, onLog: saveError);

  return error ??
      new String.fromCharCodes(
          writer.assets[new AssetId(pkgName, 'lib/config.config_builder.g.part')] ?? []);
}
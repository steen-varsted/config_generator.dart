library config_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/config_generator_base.dart';

Builder configBuilder(BuilderOptions options) => SharedPartBuilder([ConfigGenerator(options)], 'config_builder');

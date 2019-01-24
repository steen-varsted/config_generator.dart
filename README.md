# Config Generator

A simple generator to create implementations of config classes from build.yaml files.

## Usage

Add as a development dependency:
```yaml
dev_dependencies:
  config_generator: ^0.1.0
```

For each build environment create a `build.<env>.yaml` (e.g. `build.dev.yaml`) file that configures this builder:
```yaml
targets:
  $default:
    builders:
      config_generator|config_builder:
        generate_for:
          include: ["lib/src/config.dart"]
        enabled: true
        options:
          env: dev
          firebase:
            apiKey: xxx
```
The `include` option should list a single dart file with a single class hierarchy - meaning 
that there should be a single toplevel class that is not used in any of the other classes.

All classes in the class hierarchy should be `abstract`, and have a `const` noarg constructor.
The only valid members are methods, and getters with a type of either `String`, `int` or a class defined in
the same file.

The settings under `options` in the `build.<env>.yaml` should map to the class hierarchy. 
 
```dart
part 'config.g.dart';

abstract class Config {
  const Config();
  String get env;
  FirebaseConfig get firebase;
}

abstract class FirebaseConfig {
  const FirebaseConfig();
  String get apiKey;
}
```

Build with `pub run build_runner build --config=<env>` where `<env>` is one of the environments
you created a build file for.

The build process will generate implementations of all the classes and a const value of the
top level class with the name `config` and instantiated with the `options` values from the `build.yaml` file.
This value can then be used in your code: 

```dart
import 'src/config.dart';

someWhere() {
  if(config.env == 'dev') {
    // do something specific for dev environment
  }
}
```

## License

[BSD-3-Clause](https://github.com/steen-varsted/config_generator.dart/blob/master/LICENSE).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/steen-varsted/config_generator.dart/issues

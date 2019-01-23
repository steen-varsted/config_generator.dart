part 'config.g.dart';

abstract class Config {
  const Config();
  String get env;
  int get testInt;
  FirebaseConfig get firebase;
}

abstract class FirebaseConfig {
  const FirebaseConfig();
  String get apiKey;
}

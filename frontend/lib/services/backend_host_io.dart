import 'dart:io';

String defaultBackendHost() {
  if (Platform.isAndroid) return 'http://10.0.2.2:8080';
  if (Platform.isIOS) return 'http://localhost:8080';
  return 'http://localhost:8080';
}

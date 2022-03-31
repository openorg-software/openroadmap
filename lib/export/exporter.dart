import 'package:openroadmap/provider/backend_provider_interface.dart';

abstract class Exporter {
  void export(BackendProviderInterface orProvider);
}

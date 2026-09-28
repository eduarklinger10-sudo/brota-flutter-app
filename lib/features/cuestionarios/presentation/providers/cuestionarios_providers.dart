import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fake_cuestionarios_repository.dart';
import '../../domain/cuestionarios_repository.dart';

/// Enchufe único entre la UI y el repositorio: controllers, pantallas y
/// tests dependen de ESTE provider, nunca de una clase concreta.
///
/// ⚠️ TEMPORAL (tarea de Eduard): apunta al fake en memoria mientras el
/// impl real de Julián no existe. Cuando su PR entre a `develop`, aquí
/// se apunta a `CuestionariosRepositoryImpl(ref.watch(dioProvider))` (con
/// Dio de `core/network/network_providers.dart`, mismo patrón de
/// `programas_providers.dart`) y el fake se mueve bajo `test/`.
final Provider<CuestionariosRepository> cuestionariosRepositoryProvider =
    Provider<CuestionariosRepository>((ref) => FakeCuestionariosRepository());

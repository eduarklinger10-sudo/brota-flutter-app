import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/cuestionarios_access_repository_impl.dart';
import '../../data/fake_cuestionarios_repository.dart';
import '../../domain/cuestionarios_access_repository.dart';
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

final Provider<CuestionariosAccessRepository>
cuestionariosAccessRepositoryProvider = Provider<CuestionariosAccessRepository>(
  (ref) => CuestionariosAccessRepositoryImpl(ref.watch(dioProvider)),
);

/// El rol pertenece al perfil de usuario; se vuelve a consultar cuando
/// cambia la sesión para que el acceso no dependa de datos de otro usuario.
final FutureProvider<Result<bool>> institutionAccessProvider =
    FutureProvider<Result<bool>>((ref) async {
      ref.watch(authStateChangesProvider);
      final user = ref.watch(authRepositoryProvider).currentUser;
      if (user == null) {
        return const ResultError(AuthFailure('Inicia sesión para continuar.'));
      }
      return ref
          .watch(cuestionariosAccessRepositoryProvider)
          .isInstitution(user.id);
    });

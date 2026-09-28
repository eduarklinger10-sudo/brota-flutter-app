import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/cuestionario.dart';
import '../../domain/cuestionarios_repository.dart';
import '../providers/cuestionarios_providers.dart';
import 'cuestionarios_state.dart';

final StateNotifierProvider<CuestionariosController, CuestionariosState>
cuestionariosControllerProvider =
    StateNotifierProvider<CuestionariosController, CuestionariosState>(
      (ref) =>
          CuestionariosController(ref.watch(cuestionariosRepositoryProvider)),
    );

/// Casos de uso de la lista de cuestionarios: cargar, crear, editar y
/// eliminar. Un método público por caso de uso, mismo patrón de
/// `ProgramasController`. Nunca lanza excepciones: consume el `Result`
/// del repositorio con `fold` y traduce el desenlace a estado.
///
/// Los métodos de escritura devuelven lo mínimo que la pantalla necesita
/// para reaccionar (`Cuestionario?` para navegar al crear, `bool` para el
/// SnackBar) — mostrar diálogos o navegar es cosa de la pantalla, no de
/// este controller.
final class CuestionariosController extends StateNotifier<CuestionariosState> {
  CuestionariosController(this._repository)
    : super(const CuestionariosState()) {
    load();
  }

  final CuestionariosRepository _repository;

  Future<void> load() async {
    state = state.copyWith(
      status: CuestionariosStatus.loading,
      errorMessage: null,
    );

    final result = await _repository.getCuestionarios();
    state = result.fold(
      (cuestionarios) => state.copyWith(
        status: CuestionariosStatus.idle,
        cuestionarios: List<Cuestionario>.of(cuestionarios),
      ),
      (failure) => state.copyWith(
        status: CuestionariosStatus.error,
        errorMessage: failure.message,
      ),
    );
  }

  /// Devuelve el cuestionario creado (o `null` si falló) para que la
  /// pantalla decida si navega a sus preguntas.
  Future<Cuestionario?> create(NuevoCuestionario input) async {
    state = state.copyWith(saving: true, errorMessage: null);

    final result = await _repository.crearCuestionario(input);
    return result.fold(
      (creado) {
        // Arriba de la lista: es el más reciente (el backend ordena por
        // created_at DESC, mismo criterio acá).
        state = state.copyWith(
          saving: false,
          cuestionarios: [creado, ...state.cuestionarios],
        );
        return creado;
      },
      (failure) {
        state = state.copyWith(saving: false, errorMessage: failure.message);
        return null;
      },
    );
  }

  Future<bool> update(String id, NuevoCuestionario input) async {
    state = state.copyWith(saving: true, errorMessage: null);

    final result = await _repository.actualizarCuestionario(id, input);
    return result.fold(
      (actualizado) {
        state = state.copyWith(
          saving: false,
          cuestionarios: [
            for (final Cuestionario c in state.cuestionarios)
              if (c.id == id) actualizado else c,
          ],
        );
        return true;
      },
      (failure) {
        state = state.copyWith(saving: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  /// El borrado es en cascada (preguntas + opciones) — la pantalla pide
  /// la confirmación ANTES de llamar acá, no después.
  Future<bool> delete(String id) async {
    final result = await _repository.eliminarCuestionario(id);
    return result.fold(
      (_) {
        state = state.copyWith(
          cuestionarios: state.cuestionarios
              .where((c) => c.id != id)
              .toList(),
        );
        return true;
      },
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
    );
  }
}

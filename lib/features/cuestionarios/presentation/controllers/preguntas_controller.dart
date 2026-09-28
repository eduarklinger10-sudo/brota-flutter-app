import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/cuestionarios_repository.dart';
import '../../domain/pregunta.dart';
import '../providers/cuestionarios_providers.dart';
import 'preguntas_state.dart';

final StateNotifierProvider<PreguntasController, PreguntasState>
preguntasControllerProvider =
    StateNotifierProvider<PreguntasController, PreguntasState>(
      (ref) =>
          PreguntasController(ref.watch(cuestionariosRepositoryProvider)),
    );

/// Preguntas del cuestionario que se está administrando — uno a la vez:
/// `load(cuestionarioId)` fija cuál. No es un provider.family a propósito
/// porque la pantalla de detalle solo muestra un cuestionario en pantalla
/// (mismo criterio de `ProgramasController` guardando sus filtros).
final class PreguntasController extends StateNotifier<PreguntasState> {
  PreguntasController(this._repository) : super(const PreguntasState());

  final CuestionariosRepository _repository;

  Future<void> load(String cuestionarioId) async {
    state = state.copyWith(
      cuestionarioId: cuestionarioId,
      status: PreguntasStatus.loading,
      errorMessage: null,
    );

    final result = await _repository.getPreguntas(cuestionarioId);
    state = result.fold(
      (preguntas) => state.copyWith(
        status: PreguntasStatus.idle,
        // El backend las ordena por `orden`; el fake también — se respeta
        // el orden que venga.
        preguntas: List<Pregunta>.of(preguntas),
      ),
      (failure) => state.copyWith(
        status: PreguntasStatus.error,
        errorMessage: failure.message,
      ),
    );
  }

  /// Crea la pregunta y la deja al final de la lista ([NuevaPregunta.orden]
  /// se ignora: el siguiente número libre lo calcula este controller para
  /// que ninguna pantalla pueda calcularlo mal).
  Future<Pregunta?> create(NuevaPregunta input) async {
    final int siguienteOrden = state.preguntas.length + 1;
    final NuevaPregunta conOrden = NuevaPregunta(
      texto: input.texto,
      tipo: input.tipo,
      orden: siguienteOrden,
      opciones: input.opciones,
      categoria: input.categoria,
      peso: input.peso,
    );

    state = state.copyWith(saving: true, errorMessage: null);
    final result = await _repository.crearPregunta(
      state.cuestionarioId,
      conOrden,
    );
    return result.fold(
      (creada) {
        state = state.copyWith(
          saving: false,
          preguntas: [...state.preguntas, creada],
        );
        return creada;
      },
      (failure) {
        state = state.copyWith(saving: false, errorMessage: failure.message);
        return null;
      },
    );
  }

  /// Al editar, el backend reemplaza las opciones completas — la pregunta
  /// que llega ya viene con las opciones nuevas y sustituye a la vieja.
  Future<bool> update(String id, NuevaPregunta input) async {
    state = state.copyWith(saving: true, errorMessage: null);

    final result = await _repository.actualizarPregunta(id, input);
    return result.fold(
      (actualizada) {
        state = state.copyWith(
          saving: false,
          preguntas: [
            for (final Pregunta p in state.preguntas)
              if (p.id == id) actualizada else p,
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

  Future<bool> delete(String id) async {
    final result = await _repository.eliminarPregunta(id);
    return result.fold(
      (_) {
        state = state.copyWith(
          preguntas: state.preguntas.where((p) => p.id != id).toList(),
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

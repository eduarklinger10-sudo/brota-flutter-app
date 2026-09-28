import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/pregunta.dart';

part 'preguntas_state.freezed.dart';

enum PreguntasStatus { idle, loading, error }

/// Estado de las preguntas del cuestionario que se está administrando.
/// [cuestionarioId] recuerda de qué cuestionario vienen — [load] lo fija
/// y los demás métodos lo usan para crear contra el destino correcto.
@freezed
abstract class PreguntasState with _$PreguntasState {
  const factory PreguntasState({
    @Default(PreguntasStatus.idle) PreguntasStatus status,
    @Default('') String cuestionarioId,
    @Default([]) List<Pregunta> preguntas,
    @Default(false) bool saving,
    String? errorMessage,
  }) = _PreguntasState;
}

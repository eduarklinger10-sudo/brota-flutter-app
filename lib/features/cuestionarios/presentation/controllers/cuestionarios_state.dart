import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/cuestionario.dart';

part 'cuestionarios_state.freezed.dart';

enum CuestionariosStatus { idle, loading, error }

/// Estado de la lista de cuestionarios. `loading` cubre la carga inicial
/// y los refetch (reemplaza la lista); `saving` marca que hay una
/// creación/edición en vuelo — sirve para deshabilitar el botón del
/// formulario sin bloquear la lista de fondo.
@freezed
abstract class CuestionariosState with _$CuestionariosState {
  const factory CuestionariosState({
    @Default(CuestionariosStatus.idle) CuestionariosStatus status,
    @Default([]) List<Cuestionario> cuestionarios,
    @Default(false) bool saving,
    String? errorMessage,
  }) = _CuestionariosState;
}

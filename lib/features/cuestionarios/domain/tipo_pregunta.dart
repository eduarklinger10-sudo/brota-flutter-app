/// Catálogo de tipos de pregunta del test vocacional — réplica en Dart
/// del catálogo del web (`frontend/src/utils/tiposPregunta.js`, tarea de
/// Mateo, y `backend/src/utils/tiposPregunta.js`). Los alias importan:
/// en la base ya hay preguntas grabadas con los valores viejos
/// (`single`, `seleccion`, `multiple`) y hay que entenderlas igual que
/// el web las entiende.
enum TipoPregunta {
  opcionUnica,
  opcionMultiple,
  likert;

  static TipoPregunta? _fromAlias(String raw) => switch (raw) {
    'opcion_unica' || 'single' || 'seleccion' => TipoPregunta.opcionUnica,
    'opcion_multiple' || 'multiple' => TipoPregunta.opcionMultiple,
    'likert' => TipoPregunta.likert,
    _ => null,
  };

  /// Lo que manda la API (GET) → enum. Un tipo desconocido cae a
  /// [opcionUnica] para que nunca rompa la pantalla — mismo criterio
  /// "fallback seguro" del dispatcher del web.
  static TipoPregunta fromApi(String raw) =>
      _fromAlias(raw) ?? TipoPregunta.opcionUnica;

  /// Enum → valor que espera el backend al crear/actualizar (POST/PATCH).
  String toApi() => switch (this) {
    TipoPregunta.opcionUnica => 'opcion_unica',
    TipoPregunta.opcionMultiple => 'opcion_multiple',
    TipoPregunta.likert => 'likert',
  };

  /// Etiqueta visible al usuario (UI en español).
  String get label => switch (this) {
    TipoPregunta.opcionUnica => 'Opción única',
    TipoPregunta.opcionMultiple => 'Opción múltiple',
    TipoPregunta.likert => 'Escala Likert',
  };
}

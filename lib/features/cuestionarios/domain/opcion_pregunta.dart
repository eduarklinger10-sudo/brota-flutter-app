/// Una opción de respuesta de una pregunta, con sus pesos por categoría
/// vocacional. Tal cual la devuelve `GET /api/institucion/preguntas`
/// (opciones aplanadas y `pesos` como mapa — ver
/// `backend/src/controllers/institucion/preguntasController.js`).
///
/// `pesos` es `{ categoria: puntos }`, p.ej.
/// `{'tecnologia': 3, 'arte': 1}` — lo que el motor del test usa para
/// calcular el perfil vocacional del estudiante.
final class OpcionPregunta {
  const OpcionPregunta({
    required this.label,
    required this.orden,
    this.id,
    this.icon,
    this.pesos = const {},
  });

  /// `null` en una opción recién creada (el backend aún no le asignó id).
  factory OpcionPregunta.fromJson(Map<String, dynamic> json) {
    return OpcionPregunta(
      id: json['id'] as String?,
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      pesos: _pesosFromJson(json['pesos']),
    );
  }

  final String? id;
  final String label;

  /// Emoji o nombre de ícono mostrado junto a la opción.
  final String? icon;
  final int orden;
  final Map<String, int> pesos;

  /// Lo que viaja anidado en el body de la pregunta (POST/PATCH). Las
  /// opciones no tienen endpoint propio: el backend reemplaza las filas
  /// de `opciones`/`pesos_opciones` con lo que llegue acá.
  Map<String, dynamic> toApi() => <String, dynamic>{
    if (id != null) 'id': id,
    'label': label,
    'icon': icon,
    'orden': orden,
    'pesos': pesos,
  };

  static Map<String, int> _pesosFromJson(Object? raw) {
    if (raw is! Map) return const {};
    final Map<String, int> pesos = <String, int>{};
    for (final MapEntry<dynamic, dynamic> entry in raw.entries) {
      final Object? value = entry.value;
      if (value is num) pesos[entry.key as String] = value.toInt();
    }
    return pesos;
  }
}

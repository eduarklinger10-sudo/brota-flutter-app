/// Un cuestionario de la institución, tal como lo devuelve
/// `GET /api/institucion/cuestionarios` (el backend adjunta
/// `num_preguntas` con un count de la tabla `preguntas`).
final class Cuestionario {
  const Cuestionario({
    required this.id,
    required this.nombre,
    required this.version,
    required this.activo,
    this.descripcion,
    this.numPreguntas = 0,
  });

  factory Cuestionario.fromJson(Map<String, dynamic> json) {
    return Cuestionario(
      id: json['id'] as String,
      nombre: json['nombre'] as String? ?? '',
      version: json['version'] as String? ?? '1',
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? false,
      numPreguntas: (json['num_preguntas'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String nombre;

  /// Versión del cuestionario (el backend exige nombre + versión).
  final String version;
  final String? descripcion;

  /// Solo un cuestionario por institución está activo a la vez — es el
  /// que ven los estudiantes al tomar el test (el backend desactiva a
  /// los demás cuando se activa uno).
  final bool activo;
  final int numPreguntas;
}

/// Input de creación/edición. `activo` va aparte porque el backend crea
/// los cuestionarios inactivos a propósito (recién creado no tiene
/// preguntas) y la activación es una operación del PATCH.
final class NuevoCuestionario {
  const NuevoCuestionario({
    required this.nombre,
    required this.version,
    this.descripcion,
  });

  final String nombre;
  final String version;
  final String? descripcion;

  Map<String, dynamic> toApi() => <String, dynamic>{
    'nombre': nombre,
    'version': version,
    if (descripcion != null) 'descripcion': descripcion,
  };
}

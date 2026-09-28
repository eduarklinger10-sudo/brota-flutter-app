import 'opcion_pregunta.dart';
import 'tipo_pregunta.dart';

/// Una pregunta del test tal cual la devuelve
/// `GET /api/institucion/preguntas?cuestionario_id=...`.
final class Pregunta {
  const Pregunta({
    required this.id,
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    required this.orden,
    this.categoria,
    this.peso = 1.0,
    this.opciones = const [],
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'] as String,
      cuestionarioId: json['cuestionario_id'] as String,
      texto: json['texto'] as String? ?? '',
      tipo: TipoPregunta.fromApi(json['tipo'] as String? ?? ''),
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      categoria: json['categoria'] as String?,
      peso: (json['peso'] as num?)?.toDouble() ?? 1.0,
      opciones: ((json['opciones'] as List<dynamic>?) ?? const [])
          .map((e) => OpcionPregunta.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;

  /// Posición de la pregunta dentro del cuestionario (1-based).
  final int orden;

  /// Categoría vocacional sugerida (p.ej. 'tecnologia'); informativa.
  final String? categoria;

  /// Multiplicador del puntaje de esta pregunta (backend usa 1.0 por defecto).
  final double peso;
  final List<OpcionPregunta> opciones;
}

/// Input de creación/edición. Separado de [Pregunta] porque al crear la
/// pregunta aún no tiene `id` y `cuestionarioId` llega por parámetro del
/// contrato; al editar el backend reemplaza las opciones completas.
final class NuevaPregunta {
  const NuevaPregunta({
    required this.texto,
    required this.tipo,
    required this.orden,
    required this.opciones,
    this.categoria,
    this.peso = 1.0,
  });

  final String texto;
  final TipoPregunta tipo;
  final int orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;

  Map<String, dynamic> toApi() => <String, dynamic>{
    'texto': texto,
    'tipo': tipo.toApi(),
    'orden': orden,
    if (categoria != null) 'categoria': categoria,
    'peso': peso,
    'opciones': opciones.map((o) => o.toApi()).toList(),
  };
}

import 'dart:math';

import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/cuestionario.dart';
import '../domain/cuestionarios_repository.dart';
import '../domain/opcion_pregunta.dart';
import '../domain/pregunta.dart';
import '../domain/tipo_pregunta.dart';

/// Repositorio falso en memoria que implementa el mismo contrato que
/// implementará Julián con Dio (`CuestionariosRepositoryImpl`). Existe
/// para que las pantallas del CRUD (tarea de Eduard) se puedan construir
/// y probar SIN esperar al PR de Julián ni a un backend corriendo.
///
/// Cuando ese PR entre a `develop`: apuntar `cuestionariosRepositoryProvider`
/// (presentation/providers/cuestionarios_providers.dart) al impl real y
/// mover este archivo bajo `test/` como doble de pruebas — ver
/// PLAN_TRABAJO §4.4 "Cómo avanzar sin esperar a Julián".
final class FakeCuestionariosRepository implements CuestionariosRepository {
  FakeCuestionariosRepository() {
    _seed();
  }

  final List<Cuestionario> _cuestionarios = [];
  final List<Pregunta> _preguntas = [];
  final Random _random = Random();

  String _nextId() => (_random.nextInt(1 << 32)).toRadixString(16);

  /// Simula la latencia de red para que los estados loading de la UI se
  /// ejerciten de verdad (con latencia 0 ni se verían).
  Future<void> _latencia() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  void _seed() {
    const Cuestionario activo = Cuestionario(
      id: 'seed-cuestionario-1',
      nombre: 'Test vocacional 2026',
      version: '2',
      descripcion: 'Cuestionario activo para el grado once.',
      activo: true,
      numPreguntas: 3,
    );
    const Cuestionario borrador = Cuestionario(
      id: 'seed-cuestionario-2',
      nombre: 'Piloto salud',
      version: '1',
      descripcion: 'Borrador para la jornada de la tarde.',
      activo: false,
      numPreguntas: 1,
    );
    _cuestionarios.addAll([activo, borrador]);

    _preguntas.addAll([
      const Pregunta(
        id: 'seed-pregunta-1',
        cuestionarioId: 'seed-cuestionario-1',
        texto: '¿Qué actividad disfrutas más en tu tiempo libre?',
        tipo: TipoPregunta.opcionUnica,
        orden: 1,
        categoria: 'tecnologia',
        opciones: [
          OpcionPregunta(label: 'Armar o reparar cosas', orden: 1, pesos: {'tecnologia': 3}),
          OpcionPregunta(label: 'Dibujar o crear arte', orden: 2, pesos: {'arte': 3}),
          OpcionPregunta(label: 'Cuidar plantas o animales', orden: 3, pesos: {'ciencias': 3}),
        ],
      ),
      const Pregunta(
        id: 'seed-pregunta-2',
        cuestionarioId: 'seed-cuestionario-1',
        texto: '¿Cuáles de estas áreas te llaman la atención?',
        tipo: TipoPregunta.opcionMultiple,
        orden: 2,
        opciones: [
          OpcionPregunta(label: 'Programación', orden: 1, pesos: {'tecnologia': 2}),
          OpcionPregunta(label: 'Medicina', orden: 2, pesos: {'salud': 2}),
          OpcionPregunta(label: 'Diseño gráfico', orden: 3, pesos: {'arte': 2}),
        ],
      ),
      const Pregunta(
        id: 'seed-pregunta-3',
        cuestionarioId: 'seed-cuestionario-1',
        texto: '¿Qué tan cómodo te sientes hablando en público?',
        tipo: TipoPregunta.likert,
        orden: 3,
        opciones: [
          OpcionPregunta(label: 'Nada cómodo', orden: 1, pesos: {'social': 1}),
          OpcionPregunta(label: 'Poco cómodo', orden: 2, pesos: {'social': 2}),
          OpcionPregunta(label: 'Neutral', orden: 3, pesos: {'social': 3}),
          OpcionPregunta(label: 'Cómodo', orden: 4, pesos: {'social': 4}),
          OpcionPregunta(label: 'Muy cómodo', orden: 5, pesos: {'social': 5}),
        ],
      ),
      const Pregunta(
        id: 'seed-pregunta-4',
        cuestionarioId: 'seed-cuestionario-2',
        texto: '¿Qué área de la salud te interesa más?',
        tipo: TipoPregunta.opcionUnica,
        orden: 1,
        categoria: 'salud',
        opciones: [
          OpcionPregunta(label: 'Enfermería', orden: 1, pesos: {'salud': 3}),
          OpcionPregunta(label: 'Nutrición', orden: 2, pesos: {'salud': 3}),
        ],
      ),
    ]);
  }

  // ---- Nivel 1: cuestionarios ----

  @override
  Future<Result<List<Cuestionario>>> getCuestionarios() async {
    await _latencia();
    return Success(List.unmodifiable(_cuestionarios));
  }

  @override
  Future<Result<Cuestionario>> crearCuestionario(NuevoCuestionario input) async {
    await _latencia();
    if (input.nombre.trim().isEmpty || input.version.trim().isEmpty) {
      return const ResultError(
        ValidationFailure('Nombre y versión son obligatorios.'),
      );
    }
    final Cuestionario creado = Cuestionario(
      id: _nextId(),
      nombre: input.nombre.trim(),
      version: input.version.trim(),
      descripcion: input.descripcion?.trim(),
      // Igual que el backend: nace inactivo a propósito.
      activo: false,
    );
    _cuestionarios.insert(0, creado);
    return Success(creado);
  }

  @override
  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    NuevoCuestionario input,
  ) async {
    await _latencia();
    final int index = _cuestionarios.indexWhere((c) => c.id == id);
    if (index == -1) {
      return const ResultError(ServerFailure('Cuestionario no encontrado.', statusCode: 404));
    }
    if (input.nombre.trim().isEmpty || input.version.trim().isEmpty) {
      return const ResultError(
        ValidationFailure('Nombre y versión son obligatorios.'),
      );
    }
    final Cuestionario actual = _cuestionarios[index];
    _cuestionarios[index] = Cuestionario(
      id: actual.id,
      nombre: input.nombre.trim(),
      version: input.version.trim(),
      descripcion: input.descripcion?.trim(),
      activo: actual.activo,
      numPreguntas: actual.numPreguntas,
    );
    return Success(_cuestionarios[index]);
  }

  @override
  Future<Result<void>> eliminarCuestionario(String id) async {
    await _latencia();
    final int index = _cuestionarios.indexWhere((c) => c.id == id);
    if (index == -1) {
      return const ResultError(ServerFailure('Cuestionario no encontrado.', statusCode: 404));
    }
    _cuestionarios.removeAt(index);
    // Cascada, igual que hace la base con las filas de preguntas.
    _preguntas.removeWhere((p) => p.cuestionarioId == id);
    return const Success(null);
  }

  // ---- Nivel 2: preguntas de un cuestionario ----

  @override
  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId) async {
    await _latencia();
    final bool existe = _cuestionarios.any((c) => c.id == cuestionarioId);
    if (!existe) {
      return const ResultError(ServerFailure('Cuestionario no encontrado.', statusCode: 404));
    }
    final List<Pregunta> propias =
        _preguntas.where((p) => p.cuestionarioId == cuestionarioId).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));
    return Success(List.unmodifiable(propias));
  }

  @override
  Future<Result<Pregunta>> crearPregunta(
    String cuestionarioId,
    NuevaPregunta input,
  ) async {
    await _latencia();
    final bool existe = _cuestionarios.any((c) => c.id == cuestionarioId);
    if (!existe) {
      return const ResultError(ServerFailure('Cuestionario no encontrado.', statusCode: 404));
    }
    if (input.texto.trim().isEmpty) {
      return const ResultError(ValidationFailure('El texto de la pregunta es obligatorio.'));
    }
    // Mismo backend: toda pregunta que no sea Likert pide al menos 2 opciones.
    if (input.opciones.length < 2) {
      return const ResultError(
        ValidationFailure('La pregunta necesita al menos 2 opciones.'),
      );
    }
    final Pregunta creada = Pregunta(
      id: _nextId(),
      cuestionarioId: cuestionarioId,
      texto: input.texto.trim(),
      tipo: input.tipo,
      orden: input.orden,
      categoria: input.categoria,
      peso: input.peso,
      opciones: List<OpcionPregunta>.of(input.opciones),
    );
    _preguntas.add(creada);
    _refrescarNumPreguntas(cuestionarioId);
    return Success(creada);
  }

  @override
  Future<Result<Pregunta>> actualizarPregunta(String id, NuevaPregunta input) async {
    await _latencia();
    final int index = _preguntas.indexWhere((p) => p.id == id);
    if (index == -1) {
      return const ResultError(ServerFailure('Pregunta no encontrada.', statusCode: 404));
    }
    if (input.opciones.length < 2) {
      return const ResultError(
        ValidationFailure('La pregunta necesita al menos 2 opciones.'),
      );
    }
    final Pregunta actual = _preguntas[index];
    // El backend reemplaza las opciones completas (borra y re-inserta).
    _preguntas[index] = Pregunta(
      id: actual.id,
      cuestionarioId: actual.cuestionarioId,
      texto: input.texto.trim(),
      tipo: input.tipo,
      orden: input.orden,
      categoria: input.categoria,
      peso: input.peso,
      opciones: List<OpcionPregunta>.of(input.opciones),
    );
    return Success(_preguntas[index]);
  }

  @override
  Future<Result<void>> eliminarPregunta(String id) async {
    await _latencia();
    final int index = _preguntas.indexWhere((p) => p.id == id);
    if (index == -1) {
      return const ResultError(ServerFailure('Pregunta no encontrada.', statusCode: 404));
    }
    final String cuestionarioId = _preguntas[index].cuestionarioId;
    _preguntas.removeAt(index);
    _refrescarNumPreguntas(cuestionarioId);
    return const Success(null);
  }

  void _refrescarNumPreguntas(String cuestionarioId) {
    final int index = _cuestionarios.indexWhere((c) => c.id == cuestionarioId);
    if (index == -1) return;
    final Cuestionario actual = _cuestionarios[index];
    final int total = _preguntas.where((p) => p.cuestionarioId == cuestionarioId).length;
    _cuestionarios[index] = Cuestionario(
      id: actual.id,
      nombre: actual.nombre,
      version: actual.version,
      descripcion: actual.descripcion,
      activo: actual.activo,
      numPreguntas: total,
    );
  }
}

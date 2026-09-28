import '../../../core/result/result.dart';
import 'cuestionario.dart';
import 'pregunta.dart';

/// EL CONTRATO compartido entre Julián y Eduard (ver PLAN_TRABAJO §4.3/4.4).
///
/// Julián implementa esto con Dio contra `backend/src` (el repo web);
/// Eduard consume esto desde controllers y pantallas. Mientras el impl
/// real no exista, `FakeCuestionariosRepository` (en `data/`) cumple el
/// mismo contrato en memoria.
///
/// Todos los endpoints viven bajo `/api/institucion` y requieren sesión
/// con rol institución — el Dio del core ya adjunta el token vía
/// `auth_interceptor`. IMPORTANTE: hablar con `/api/institucion/*`, nunca
/// con `/api/admin/*` (el CRUD admin escribe `preguntas.opciones` JSONB,
/// campo legado que el motor del test no lee).
abstract class CuestionariosRepository {
  // ---- Nivel 1: cuestionarios ----

  Future<Result<List<Cuestionario>>> getCuestionarios();

  Future<Result<Cuestionario>> crearCuestionario(NuevoCuestionario input);

  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    NuevoCuestionario input,
  );

  /// Borra el cuestionario y en cascada sus preguntas y opciones
  /// (cascada hecha por la base, no por el cliente).
  Future<Result<void>> eliminarCuestionario(String id);

  // ---- Nivel 2: preguntas de un cuestionario ----

  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId);

  Future<Result<Pregunta>> crearPregunta(
    String cuestionarioId,
    NuevaPregunta input,
  );

  Future<Result<Pregunta>> actualizarPregunta(String id, NuevaPregunta input);

  Future<Result<void>> eliminarPregunta(String id);
}

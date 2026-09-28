import '../../../core/result/result.dart';

/// Consulta si el perfil autenticado tiene permiso para gestionar
/// cuestionarios institucionales.
abstract interface class CuestionariosAccessRepository {
  Future<Result<bool>> isInstitution(String userId);
}

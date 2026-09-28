import 'package:dio/dio.dart';

import '../../../core/network/api_exception_mapper.dart';
import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/cuestionarios_access_repository.dart';

final class CuestionariosAccessRepositoryImpl
    implements CuestionariosAccessRepository {
  CuestionariosAccessRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<bool>> isInstitution(String userId) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/perfil/$userId');
      final Map<String, dynamic>? profile =
          _asJsonMap(response.data?['data']) ?? response.data;
      if (profile == null || profile['rol'] is! String) {
        return const ResultError(
          UnknownFailure('No se pudo verificar el rol de la cuenta.'),
        );
      }
      return Success(profile['rol'] == 'institucion');
    } on DioException catch (e) {
      return ResultError(mapDioExceptionToFailure(e));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  Map<String, dynamic>? _asJsonMap(Object? value) =>
      value is Map<String, dynamic> ? value : null;
}

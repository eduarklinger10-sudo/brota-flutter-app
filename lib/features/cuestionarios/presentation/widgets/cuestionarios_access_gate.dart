import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/cuestionarios_providers.dart';

/// Solo deja entrar al CRUD a perfiles con rol de institución.
class CuestionariosAccessGate extends ConsumerWidget {
  const CuestionariosAccessGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Result<bool>> access = ref.watch(
      institutionAccessProvider,
    );

    return access.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _AccessMessage(
        title: 'No se pudo verificar el acceso',
        message: 'Revisa tu conexión e inténtalo de nuevo.',
        onRetry: () => ref.invalidate(institutionAccessProvider),
      ),
      data: (result) => result.fold(
        (isInstitution) => isInstitution
            ? child
            : const _AccessMessage(
                title: 'Acceso para instituciones',
                message:
                    'Esta sección está disponible para cuentas de institución.',
              ),
        (failure) => _AccessMessage(
          title: 'No se pudo verificar el acceso',
          message: failure.message,
          onRetry: () => ref.invalidate(institutionAccessProvider),
        ),
      ),
    );
  }
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cuestionarios')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.headlineMd(scheme.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

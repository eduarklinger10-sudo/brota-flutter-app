import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/cuestionario.dart';
import '../controllers/cuestionarios_controller.dart';
import '../controllers/cuestionarios_state.dart';
import '../widgets/cuestionario_card.dart';

/// `/dashboard/cuestionarios` — lista de cuestionarios de la institución.
///
/// La pantalla NO toma decisiones: traduce `CuestionariosState` a widgets
/// (switch exhaustivo sobre `status` → imposible olvidar un estado) y le
/// pide acciones al controller con `ref.read`. Misma estructura que
/// `profesiones_screen.dart`.
class CuestionariosScreen extends ConsumerWidget {
  const CuestionariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: ante cada cambio del estado, Flutter redibuja esta pantalla.
    final CuestionariosState state = ref.watch(cuestionariosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cuestionarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/cuestionarios/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: SafeArea(
        // switch expression (Dart 3): el compilador exige cubrir TODOS
        // los valores del enum. Si mañana se agrega un status, analyze
        // falla hasta manejarlo — cero pantallas en blanco.
        child: switch (state.status) {
          CuestionariosStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          CuestionariosStatus.error => _ErrorView(
            message: state.errorMessage ?? 'Ocurrió un error inesperado.',
            onRetry: () =>
                ref.read(cuestionariosControllerProvider.notifier).load(),
          ),
          CuestionariosStatus.idle =>
            state.cuestionarios.isEmpty
                ? _EmptyView(
                    onCrear: () =>
                        context.push('/dashboard/cuestionarios/nuevo'),
                  )
                : _CuestionariosList(
                    cuestionarios: state.cuestionarios,
                    onAbrir: (c) => context.push(
                      '/dashboard/cuestionarios/${c.id}/preguntas',
                      extra: c,
                    ),
                    onEditar: (c) => context.push(
                      '/dashboard/cuestionarios/${c.id}/editar',
                      extra: c,
                    ),
                    onEliminar: (c) => _confirmarEliminacion(context, ref, c),
                  ),
        },
      ),
    );
  }

  Future<void> _confirmarEliminacion(
    BuildContext context,
    WidgetRef ref,
    Cuestionario cuestionario,
  ) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('¿Eliminar cuestionario?'),
        content: Text(
          '"${cuestionario.nombre}" y todas sus preguntas y opciones '
          'se borrarán. Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    final bool eliminado = await ref
        .read(cuestionariosControllerProvider.notifier)
        .delete(cuestionario.id);
    if (!context.mounted) return;

    final String mensaje = eliminado
        ? 'Cuestionario y sus preguntas eliminados.'
        : ref.read(cuestionariosControllerProvider).errorMessage ??
              'No se pudo eliminar el cuestionario.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class _CuestionariosList extends StatelessWidget {
  const _CuestionariosList({
    required this.cuestionarios,
    required this.onAbrir,
    required this.onEditar,
    required this.onEliminar,
  });

  final List<Cuestionario> cuestionarios;
  final ValueChanged<Cuestionario> onAbrir;
  final ValueChanged<Cuestionario> onEditar;
  final ValueChanged<Cuestionario> onEliminar;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sm,
        AppSpacing.screenMargin,
        AppSpacing.lg,
      ),
      children: [
        Text(
          '${cuestionarios.length} cuestionarios',
          style: AppTypography.headlineMd(scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final Cuestionario c in cuestionarios) ...[
          CuestionarioCard(
            cuestionario: c,
            onTap: () => onAbrir(c),
            onEditar: () => onEditar(c),
            onEliminar: () => onEliminar(c),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCrear});

  final VoidCallback onCrear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aún no hay cuestionarios',
              style: AppTypography.headlineMd(scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Crea el primero para empezar a armar el test '
              'vocacional de tu institución.',
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onCrear,
              icon: const Icon(Icons.add),
              label: const Text('Crear el primero'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: scheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/cuestionario.dart';
import '../controllers/cuestionarios_controller.dart';
import '../controllers/cuestionarios_state.dart';
import '../widgets/cuestionario_card.dart';
import 'cuestionario_form_screen.dart';

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
        onPressed: () => _abrirFormulario(context),
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
          CuestionariosStatus.idle => state.cuestionarios.isEmpty
              ? _EmptyView(onCrear: () => _abrirFormulario(context))
              : _CuestionariosList(
                  cuestionarios: state.cuestionarios,
                  onAbrir: (c) => _abrirFormulario(context, cuestionario: c),
                ),
        },
      ),
    );
  }

  /// Mientras el router (bloque 5) no exista, navegamos con Navigator
  /// directo. Cuando entren las rutas de go_router, SOLO este método
  /// cambia — el resto de la pantalla no se entera.
  Future<void> _abrirFormulario(
    BuildContext context, {
    Cuestionario? cuestionario,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CuestionarioFormScreen(cuestionario: cuestionario),
      ),
    );
  }
}

class _CuestionariosList extends StatelessWidget {
  const _CuestionariosList({
    required this.cuestionarios,
    required this.onAbrir,
  });

  final List<Cuestionario> cuestionarios;
  final ValueChanged<Cuestionario> onAbrir;

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
          CuestionarioCard(cuestionario: c, onTap: () => onAbrir(c)),
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
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: scheme.onSurfaceVariant,
            ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: scheme.error,
            ),
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

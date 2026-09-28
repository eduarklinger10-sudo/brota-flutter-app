import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/pregunta.dart';
import '../controllers/preguntas_controller.dart';
import '../controllers/preguntas_state.dart';
import '../widgets/pregunta_tile.dart';

/// Preguntas de UN cuestionario. A diferencia de la lista de
/// cuestionarios (pantalla sin estado propio), esta SÍ es
/// ConsumerStatefulWidget porque necesita disparar `load(cuestionarioId)`
/// una vez al aparecer — el controller no puede saber por sí solo a qué
/// cuestionario apuntar.
class PreguntasScreen extends ConsumerStatefulWidget {
  const PreguntasScreen({
    super.key,
    required this.cuestionarioId,
    required this.tituloCuestionario,
  });

  final String cuestionarioId;
  final String tituloCuestionario;

  @override
  ConsumerState<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends ConsumerState<PreguntasScreen> {
  @override
  void initState() {
    super.initState();
    // Primer disparo de la carga. Llamar un provider en initState es
    // seguro (fire-and-forget): el build de abajo ya ve loading y pinta
    // el spinner mientras llega la respuesta.
    ref.read(preguntasControllerProvider.notifier).load(widget.cuestionarioId);
  }

  Future<void> _abrirFormulario({Pregunta? pregunta}) async {
    final String rutaBase =
        '/dashboard/cuestionarios/${widget.cuestionarioId}/preguntas';
    if (pregunta == null) {
      await context.push('$rutaBase/nueva');
    } else {
      await context.push('$rutaBase/${pregunta.id}/editar', extra: pregunta);
    }
  }

  /// Confirmación antes de eliminar (plan: SIEMPRE AlertDialog). Para
  /// una pregunta el "cascada" son sus opciones; para un cuestionario
  /// entero serán sus preguntas (se usa el mismo patrón allá).
  Future<bool> _confirmarEliminar(Pregunta pregunta) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('¿Eliminar pregunta?'),
        content: Text(
          '"${_resumir(pregunta.texto)}" y sus '
          '${pregunta.opciones.length} opciones se borrarán. '
          'Esta acción no se puede deshacer.',
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
    return confirmado ?? false;
  }

  String _resumir(String texto) =>
      texto.length > 40 ? '${texto.substring(0, 40)}…' : texto;

  @override
  Widget build(BuildContext context) {
    final PreguntasState state = ref.watch(preguntasControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.tituloCuestionario)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Pregunta'),
      ),
      body: SafeArea(
        child: switch (state.status) {
          PreguntasStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          PreguntasStatus.error => _ErrorView(
            message: state.errorMessage ?? 'Ocurrió un error inesperado.',
            onRetry: () => ref
                .read(preguntasControllerProvider.notifier)
                .load(widget.cuestionarioId),
          ),
          PreguntasStatus.idle =>
            state.preguntas.isEmpty
                ? _EmptyView(onAgregar: _abrirFormulario)
                : _PreguntasList(
                    preguntas: state.preguntas,
                    onAbrir: (p) => _abrirFormulario(pregunta: p),
                    onEliminarPreguntado: _confirmarEliminar,
                    // El `ref` vive en la pantalla (ConsumerState); los
                    // widgets privados de abajo reciben acciones, no providers.
                    onEliminar: (p) => ref
                        .read(preguntasControllerProvider.notifier)
                        .delete(p.id),
                  ),
        },
      ),
    );
  }
}

class _PreguntasList extends StatelessWidget {
  const _PreguntasList({
    required this.preguntas,
    required this.onAbrir,
    required this.onEliminarPreguntado,
    required this.onEliminar,
  });

  final List<Pregunta> preguntas;
  final ValueChanged<Pregunta> onAbrir;

  /// El listón pregunta "¿de verdad?" ANTES de borrar. Si la respuesta
  /// es no, el swipe se cancela y el tile vuelve a su sitio.
  final Future<bool> Function(Pregunta) onEliminarPreguntado;

  /// Ya confirmado: borrar de verdad (el controller quita del estado).
  final ValueChanged<Pregunta> onEliminar;

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
          '${preguntas.length} preguntas',
          style: AppTypography.headlineMd(scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Desliza una pregunta a la izquierda para eliminarla.',
          style: AppTypography.labelMd(scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final Pregunta p in preguntas)
          // Dismissible = la fila se puede arrastrar fuera. La key única
          // por pregunta es OBLIGATORIA: es como Flutter sabe cuál fila
          // se está deslizando (y el error clásico es reusar la posición
          // como key — se rompe al borrar la primera).
          Dismissible(
            key: ValueKey<String>(p.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: AppRadii.xlRadius,
              ),
              child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
            ),
            confirmDismiss: (_) => onEliminarPreguntado(p),
            onDismissed: (_) => onEliminar(p),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PreguntaTile(pregunta: p, onTap: () => onAbrir(p)),
            ),
          ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAgregar});

  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Este cuestionario no tiene preguntas',
              style: AppTypography.headlineMd(scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Agrega la primera para que los estudiantes puedan '
              'responderlo.',
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar la primera'),
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

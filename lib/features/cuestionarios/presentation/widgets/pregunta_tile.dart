import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/pregunta.dart';
import '../../domain/tipo_pregunta.dart';

/// Fila de la lista de preguntas: número de orden, texto, badge del tipo
/// y cuántas opciones tiene. Tocable para abrir la edición.
///
/// El badge del tipo es requisito del plan (§4.4 `pregunta_tile.dart`):
/// quien administra el cuestionario debe distinguir de un vistazo una
/// Likert de una de opción múltiple.
class PreguntaTile extends StatelessWidget {
  const PreguntaTile({
    super.key,
    required this.pregunta,
    required this.onTap,
  });

  final Pregunta pregunta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: AppRadii.xlRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlRadius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Círculo con el número de orden: refuerza que el test se
              // responde en ese orden y facilita ver huecos al editar.
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.secondaryContainer,
                child: Text(
                  '${pregunta.orden}',
                  style: AppTypography.labelMd(scheme.onSecondaryContainer),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregunta.texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd(scheme.onSurface).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _TipoBadge(tipo: pregunta.tipo),
                        Text(
                          '${pregunta.opciones.length} opciones',
                          style:
                              AppTypography.labelMd(scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip del tipo de pregunta. El ícono acompaña al texto porque un
/// color distinto por tipo haría la UI ruidosa (3 colores + el de
/// "Activa" + el de error...); el ícono sí diferencia sin ensuciar.
class _TipoBadge extends StatelessWidget {
  const _TipoBadge({required this.tipo});

  final TipoPregunta tipo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: AppRadii.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (tipo) {
              TipoPregunta.opcionUnica => Icons.radio_button_checked,
              TipoPregunta.opcionMultiple => Icons.checklist,
              TipoPregunta.likert => Icons.linear_scale,
            },
            size: 14,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            tipo.label,
            style: AppTypography.labelMd(scheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/cuestionario.dart';

/// Tarjeta de la lista de cuestionarios: nombre, descripción y chips de
/// metadatos (versión, número de preguntas, badge "Activa"). Tocable con
/// efecto ripple para abrir la edición / sus preguntas.
///
/// Detalle de Material que vale la pena conocer: `InkWell` pinta el
/// splash sobre el widget `Material` MÁS CERCANO, no sobre sí mismo.
/// Por eso el orden es Material(color) → InkWell → contenido. Si el
/// color fuera del Container interno, el ripple quedaría tapado detrás.
class CuestionarioCard extends StatelessWidget {
  const CuestionarioCard({
    super.key,
    required this.cuestionario,
    required this.onTap,
  });

  final Cuestionario cuestionario;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cuestionario.nombre,
                style: AppTypography.bodyLg(scheme.onSurface).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (cuestionario.descripcion != null &&
                  cuestionario.descripcion!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cuestionario.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd(scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _MetaChip(label: 'Versión ${cuestionario.version}'),
                  _MetaChip(label: '${cuestionario.numPreguntas} preguntas'),
                  if (cuestionario.activo)
                    const _MetaChip(label: 'Activa', destacado: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.destacado = false});

  final String label;

  /// true → chip "Activa": colores de acento para que salte a la vista
  /// (solo un cuestionario puede estar activo a la vez, ver domain).
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: destacado ? scheme.primaryContainer : scheme.secondaryContainer,
        borderRadius: AppRadii.fullRadius,
      ),
      child: Text(
        label,
        style: AppTypography.labelMd(
          destacado ? scheme.onPrimaryContainer : scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

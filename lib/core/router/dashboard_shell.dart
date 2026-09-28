import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/result/result.dart';
import '../../features/cuestionarios/presentation/providers/cuestionarios_providers.dart';

/// Bottom navigation scaffold for the authenticated dashboard area.
///
/// Mirrors `frontend/src/components/layout/TopNavbar.jsx`, adapted to
/// mobile: the desktop's 6-tab horizontal bar doesn't fit a phone width,
/// so the 5 primary destinations become tabs for students (Inicio, Explorar,
/// Test, Recursos, Comunidad), with Cuestionarios added for institutions.
/// "Rutas formativas" y las icons
/// secundarias (favoritos, mensajes, ajustes) stay reachable from within
/// Inicio/perfil instead of competing for tab-bar space — see
/// `MOBILE_DESIGN_BRIEF.md` sección 2.2 y CLAUDE.md "Estado de la
/// implementación".
///
/// Íconos del set de marca (`assets/icons/icon-*.svg`, ver
/// `MOBILE_DESIGN_BRIEF.md` §1.2.2), re-tintados en runtime (no en
/// `BrotaIconBadge`, que preserva el color multicolor original): la
/// barra de tabs necesita un glyph plano de un solo color por estado
/// (activo/inactivo), como cualquier ícono de Material — el tratamiento
/// ilustrado multicolor con badge crema es para tarjetas grandes, no
/// para 24px en una barra.
///
/// Wraps [StatefulShellRoute.indexedStack]'s [navigationShell] so each
/// tab keeps its own navigation stack and scroll position when the user
/// switches away and back.
class DashboardShell extends ConsumerWidget {
  const DashboardShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_DashboardDestination> _destinations = [
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-inicio.svg',
      label: 'Inicio',
    ),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-buscar.svg',
      label: 'Explorar',
    ),
    // icon-confirmar.svg pierde el checkmark al aplanarse a un color: el
    // check y el aro ya eran el mismo #360E0A en el original, solo se
    // distinguían por estar sobre relleno crema — con un solo tinte los
    // dos se fusionan y queda un círculo liso. Excepción con ícono de
    // Material hasta que se rehaga ese SVG con el check como hueco real.
    _DashboardDestination(materialIcon: Icons.quiz_outlined, label: 'Test'),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-recursos.svg',
      label: 'Recursos',
    ),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-comunidad.svg',
      label: 'Comunidad',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int currentIndex = navigationShell.currentIndex;
    final bool isQuestionnaireRoute = GoRouterState.of(
      context,
    ).uri.path.startsWith('/dashboard/cuestionarios');
    final Result<bool>? access = ref
        .watch(institutionAccessProvider)
        .valueOrNull;
    final bool isInstitution = access is Success<bool> && access.value;
    final List<_DashboardDestination> destinations = [
      ..._destinations,
      if (isInstitution)
        const _DashboardDestination(
          iconAsset: 'assets/icons/icon-confirmar.svg',
          label: 'Cuestionarios',
        ),
    ];
    final int selectedIndex = isInstitution && isQuestionnaireRoute
        ? _destinations.length
        : currentIndex.clamp(0, _destinations.length - 1);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          if (isInstitution && index == _destinations.length) {
            context.go('/dashboard/cuestionarios');
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
        destinations: [
          for (final _DashboardDestination destination in destinations)
            NavigationDestination(
              icon: _TabIcon(
                destination: destination,
                color: scheme.onSurfaceVariant,
              ),
              selectedIcon: _TabIcon(
                destination: destination,
                color: scheme.primary,
              ),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.destination, required this.color});

  final _DashboardDestination destination;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (destination.materialIcon != null) {
      return Icon(destination.materialIcon, color: color, size: 24);
    }
    return SvgPicture.asset(
      destination.iconAsset!,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _DashboardDestination {
  const _DashboardDestination({
    this.iconAsset,
    this.materialIcon,
    required this.label,
  }) : assert(
         (iconAsset == null) != (materialIcon == null),
         'Pasa exactamente uno de iconAsset o materialIcon.',
       );

  final String? iconAsset;
  final IconData? materialIcon;
  final String label;
}

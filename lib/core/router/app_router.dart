import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/comunidad/presentation/screens/comunidad_screen.dart';
import '../../features/cuestionarios/domain/cuestionario.dart';
import '../../features/cuestionarios/domain/pregunta.dart';
import '../../features/cuestionarios/presentation/screens/cuestionario_form_screen.dart';
import '../../features/cuestionarios/presentation/screens/cuestionarios_screen.dart';
import '../../features/cuestionarios/presentation/screens/pregunta_form_screen.dart';
import '../../features/cuestionarios/presentation/screens/preguntas_screen.dart';
import '../../features/cuestionarios/presentation/widgets/cuestionarios_access_gate.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profesiones/presentation/screens/profesiones_screen.dart';
import '../../features/recursos/presentation/screens/recursos_screen.dart';
import '../../features/rutas/presentation/screens/rutas_screen.dart';
import '../../features/test_vocacional/presentation/screens/test_vocacional_screen.dart';
import 'dashboard_shell.dart';
import 'go_router_refresh_stream.dart';

const Set<String> _publicRoutes = {'/login', '/register', '/forgot-password'};

/// App-wide route table. Mirrors the auth-gated split in
/// `frontend/src/App.jsx` (`puedeAcceder` inline guard): everything
/// outside [_publicRoutes] requires a Supabase session, enforced here
/// once instead of per-screen.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
      final bool isLoggedIn = authRepository.currentUser != null;
      final bool isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublicRoute) return '/login';
      if (isLoggedIn && isPublicRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard/rutas',
        builder: (context, state) => const RutasScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            DashboardShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'cuestionarios',
                    builder: (context, state) => const CuestionariosAccessGate(
                      child: CuestionariosScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'nuevo',
                        builder: (context, state) =>
                            const CuestionariosAccessGate(
                              child: CuestionarioFormScreen(),
                            ),
                      ),
                      GoRoute(
                        path: ':cuestionarioId/editar',
                        builder: (context, state) {
                          final Object? extra = state.extra;
                          return CuestionariosAccessGate(
                            child: extra is Cuestionario
                                ? CuestionarioFormScreen(cuestionario: extra)
                                : const _RouteDataMissingScreen(),
                          );
                        },
                      ),
                      GoRoute(
                        path: ':cuestionarioId/preguntas',
                        builder: (context, state) {
                          final String id =
                              state.pathParameters['cuestionarioId']!;
                          final Object? extra = state.extra;
                          final Cuestionario? cuestionario =
                              extra is Cuestionario ? extra : null;
                          return CuestionariosAccessGate(
                            child: PreguntasScreen(
                              cuestionarioId: id,
                              tituloCuestionario:
                                  cuestionario?.nombre ?? 'Preguntas',
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'nueva',
                            builder: (context, state) =>
                                const CuestionariosAccessGate(
                                  child: PreguntaFormScreen(),
                                ),
                          ),
                          GoRoute(
                            path: ':preguntaId/editar',
                            builder: (context, state) {
                              final Object? extra = state.extra;
                              return CuestionariosAccessGate(
                                child: extra is Pregunta
                                    ? PreguntaFormScreen(pregunta: extra)
                                    : const _RouteDataMissingScreen(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/profesiones',
                builder: (context, state) => const ProfesionesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/test',
                builder: (context, state) => const TestVocacionalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/recursos',
                builder: (context, state) => const RecursosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/comunidad',
                builder: (context, state) => const ComunidadScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouteDataMissingScreen extends StatelessWidget {
  const _RouteDataMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No se pudo abrir')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Vuelve a la lista y abre este formulario desde el elemento que '
            'quieres editar.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

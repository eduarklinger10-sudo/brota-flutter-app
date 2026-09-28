import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/cuestionario.dart';
import '../controllers/cuestionarios_controller.dart';
import '../controllers/cuestionarios_state.dart';

/// Crear (`cuestionario == null`) o editar (`cuestionario != null`) un
/// cuestionario. Una sola pantalla para los dos casos: `_esEdicion`
/// decide título, textos y a qué método del controller llamar — es el
/// patrón "formulario paramétrico".
class CuestionarioFormScreen extends ConsumerStatefulWidget {
  const CuestionarioFormScreen({super.key, this.cuestionario});

  final Cuestionario? cuestionario;

  @override
  ConsumerState<CuestionarioFormScreen> createState() =>
      _CuestionarioFormScreenState();
}

class _CuestionarioFormScreenState
    extends ConsumerState<CuestionarioFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _version;
  late final TextEditingController _descripcion;

  @override
  void initState() {
    super.initState();
    // Los TextEditingController se SIEMBRA una vez en initState (no en
    // build: cada redibujado borraba lo escrito). Con el cuestionario a
    // editar pre-cargado; en modo crear, versión por defecto "1".
    final Cuestionario? c = widget.cuestionario;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _version = TextEditingController(text: c?.version ?? '1');
    _descripcion = TextEditingController(text: c?.descripcion ?? '');
  }

  @override
  void dispose() {
    // Los controllers de texto son recursos: hay que liberarlos.
    _nombre.dispose();
    _version.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  bool get _esEdicion => widget.cuestionario != null;

  Future<void> _guardar() async {
    // validate() corre todos los validators del Form; si alguno falla,
    // no seguimos (los mensajes los pinta cada campo).
    if (!_formKey.currentState!.validate()) return;

    final NuevoCuestionario input = NuevoCuestionario(
      nombre: _nombre.text.trim(),
      version: _version.text.trim(),
      descripcion: _descripcion.text.trim().isEmpty
          ? null
          : _descripcion.text.trim(),
    );

    final CuestionariosController notifier = ref.read(
      cuestionariosControllerProvider.notifier,
    );
    // El controller responde true/false (o null) — la UI decide qué
    // mostrar. Nada de try/catch acá: eso lo resuelve el Result del repo.
    final bool ok = _esEdicion
        ? await notifier.update(widget.cuestionario!.id, input)
        : await notifier.create(input) != null;

    // El await pudo tardar: el widget pudo haberse cerrado mientras.
    // Usar context después de un await sin verificar `mounted` es el
    // error clásico que el lint use_build_context_synchronously caza.
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion ? 'Cuestionario actualizado' : 'Cuestionario creado',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      // Fallo en vuelo (con el impl real: red, 403, etc.). El formulario
      // NO se cierra: el usuario no pierde lo que escribió.
      final String? mensaje =
          ref.read(cuestionariosControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje ?? 'No se pudo guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // select(): solo reacciona al campo `saving` — la pantalla del
    // formulario NO se redibuja cuando la lista de fondo cambia.
    final bool saving = ref.watch(
      cuestionariosControllerProvider.select((CuestionariosState s) => s.saving),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar cuestionario' : 'Nuevo cuestionario'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            children: [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: _decoracion(scheme, 'Nombre del cuestionario'),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _version,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: _decoracion(
                  scheme,
                  'Versión (el backend exige nombre + versión)',
                ),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'La versión es obligatoria.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: _decoracion(scheme, 'Descripción (opcional)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: saving ? null : _guardar,
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(_esEdicion ? 'Guardar cambios' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(ColorScheme scheme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      border: const OutlineInputBorder(borderRadius: AppRadii.xlRadius),
    );
  }
}

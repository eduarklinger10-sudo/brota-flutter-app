import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/opcion_pregunta.dart';
import '../../domain/pregunta.dart';
import '../../domain/tipo_pregunta.dart';
import '../controllers/preguntas_controller.dart';
import '../controllers/preguntas_state.dart';
import '../widgets/opciones_editor.dart';

/// Crear o editar una pregunta. Es EL formulario que "cambia según el
/// tipo" (plan §4.4.3, en paralelo a lo que hace Brayan en el web):
/// única/múltiple piden opciones con pesos, Likert pre-carga las 5
/// etiquetas de la escala.
///
/// El truco que hace posible el cambio dinámico: el [OpcionesEditor] se
/// reconstruye desde cero cuando cambia el tipo, gracias al `key`
/// (ValueKey(tipo)). Cambiar la key = "este widget es OTRO widget":
/// Flutter destruye el estado viejo (controllers incluidos) y crea uno
/// nuevo con las opciones por defecto del tipo nuevo.
class PreguntaFormScreen extends ConsumerStatefulWidget {
  const PreguntaFormScreen({super.key, this.pregunta});

  final Pregunta? pregunta;

  @override
  ConsumerState<PreguntaFormScreen> createState() =>
      _PreguntaFormScreenState();
}

class _PreguntaFormScreenState extends ConsumerState<PreguntaFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _texto;
  late final TextEditingController _categoria;

  late TipoPregunta _tipo;
  List<OpcionPregunta> _opcionesActuales = const <OpcionPregunta>[];

  @override
  void initState() {
    super.initState();
    final Pregunta? p = widget.pregunta;
    _texto = TextEditingController(text: p?.texto ?? '');
    _categoria = TextEditingController(text: p?.categoria ?? '');
    _tipo = p?.tipo ?? TipoPregunta.opcionUnica;
  }

  @override
  void dispose() {
    _texto.dispose();
    _categoria.dispose();
    super.dispose();
  }

  bool get _esEdicion => widget.pregunta != null;

  /// Opciones con las que nace el editor según el tipo. Al EDITAR con el
  /// mismo tipo se conservan las opciones reales; al CAMBIAR de tipo se
  /// parte de cero (y el editor siembra sus defaults: 5 etiquetas en
  /// Likert, 2 filas vacías en el resto).
  List<OpcionPregunta> get _opcionesIniciales {
    final Pregunta? p = widget.pregunta;
    if (p != null && p.tipo == _tipo) return p.opciones;
    return const <OpcionPregunta>[];
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones de opciones que el Form no cubre (la lista vive en
    // el editor, no en campos del Form):
    if (_opcionesActuales.length < 2) {
      _mostrar('La pregunta necesita al menos 2 opciones.');
      return;
    }
    if (_opcionesActuales.any((OpcionPregunta o) => o.label.isEmpty)) {
      _mostrar('Completa el texto de todas las opciones.');
      return;
    }
    // "Advertir, no bloquear": una Likert espera 5 etiquetas, pero si el
    // usuario quiso otra cantidad, su criterio manda (plan §4.4.2).
    if (_tipo == TipoPregunta.likert && _opcionesActuales.length != 5) {
      _mostrar(
        'Ojo: una escala Likert normalmente tiene 5 niveles '
        '(tienes ${_opcionesActuales.length}). Se guarda igual.',
      );
    }

    final NuevaPregunta input = NuevaPregunta(
      texto: _texto.text.trim(),
      tipo: _tipo,
      // Al editar se conserva el orden original; al crear el controller
      // lo ignora y asigna el siguiente número libre.
      orden: widget.pregunta?.orden ?? 0,
      categoria: _categoria.text.trim().isEmpty ? null : _categoria.text.trim(),
      opciones: _opcionesActuales,
    );

    final PreguntasController notifier = ref.read(
      preguntasControllerProvider.notifier,
    );
    final bool ok = _esEdicion
        ? await notifier.update(widget.pregunta!.id, input)
        : await notifier.create(input) != null;

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion ? 'Pregunta actualizada' : 'Pregunta agregada',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      _mostrar(
        ref.read(preguntasControllerProvider).errorMessage ??
            'No se pudo guardar la pregunta.',
      );
    }
  }

  void _mostrar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool saving = ref.watch(
      preguntasControllerProvider.select((PreguntasState s) => s.saving),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar pregunta' : 'Nueva pregunta'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            children: [
              TextFormField(
                controller: _texto,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Texto de la pregunta',
                  labelStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.xlRadius,
                  ),
                ),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'La pregunta no puede estar vacía.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<TipoPregunta>(
                initialValue: _tipo,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Tipo de pregunta',
                  labelStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.xlRadius,
                  ),
                ),
                items: <TipoPregunta>[
                  for (final TipoPregunta t in TipoPregunta.values) t,
                ]
                    .map(
                      (TipoPregunta t) => DropdownMenuItem<TipoPregunta>(
                        value: t,
                        child: Text(t.label),
                      ),
                    )
                    .toList(),
                onChanged: (TipoPregunta? nuevo) {
                  if (nuevo == null || nuevo == _tipo) return;
                  setState(() {
                    _tipo = nuevo;
                    // Opciones acumuladas de un tipo no sirven en otro:
                    // se reinician (el editor nuevo siembra las defaults).
                    _opcionesActuales = const <OpcionPregunta>[];
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _categoria,
                style: AppTypography.bodyMd(scheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Categoría (opcional)',
                  labelStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
                  helperText:
                      'Ej: tecnologia, salud, arte. Suma contexto, no bloquea.',
                  helperStyle: AppTypography.labelMd(scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.xlRadius,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 👇 La key hace la magia del cambio dinámico (ver doc de
              // la clase). ValueKey cambia → estado nuevo.
              OpcionesEditor(
                key: ValueKey<TipoPregunta>(_tipo),
                tipo: _tipo,
                opcionesIniciales: _opcionesIniciales,
                onChanged: (List<OpcionPregunta> opciones) {
                  _opcionesActuales = opciones;
                },
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
                          : Text(_esEdicion ? 'Guardar cambios' : 'Agregar'),
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
}

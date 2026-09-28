import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/opcion_pregunta.dart';
import '../../domain/tipo_pregunta.dart';

/// Editor de opciones de una pregunta: agregar, quitar, reordenar y
/// editar label + emoji + pesos por categoría. Es el widget "con más
/// chicha" del plan (§4.4) porque administra una LISTA mutable de filas,
/// cada una con sus propios controllers de texto.
///
/// Decisiones de diseño:
/// - El editor es la fuente de verdad de la lista mientras se edita y
///   avisa al padre con [onChanged] en cada cambio. El formulario no
///   manipula filas: solo guarda la última lista emitida.
/// - `orden` no se almacena: ES la posición en la lista. Al emitir se
///   calcula `index + 1`, así reordenar es gratis y nunca queda un
///   orden inconsistente.
/// - Reordenar con flechas ↑↓ y no con arrastre (`ReorderableListView`):
///   con 2–7 filas es más preciso con el dedo y mucho menos propenso a
///   bugs dentro de un formulario con scroll.
class OpcionesEditor extends StatefulWidget {
  const OpcionesEditor({
    super.key,
    required this.tipo,
    this.opcionesIniciales = const [],
    required this.onChanged,
  });

  final TipoPregunta tipo;
  final List<OpcionPregunta> opcionesIniciales;
  final ValueChanged<List<OpcionPregunta>> onChanged;

  @override
  State<OpcionesEditor> createState() => _OpcionesEditorState();
}

/// Una fila editable. Guarda los controllers VIVOS (TextField no puede
/// funcionar sin controller propio si el contenido cambia por fuera) y
/// el `id` original de la opción, para que al editar una pregunta el
/// backend pueda conservar la fila (y sus pesos) en vez de borrarla.
class _Fila {
  _Fila({
    required String label,
    required String icon,
    required this.pesos,
    this.id,
  })  : labelCtrl = TextEditingController(text: label),
        iconCtrl = TextEditingController(text: icon);

  factory _Fila.de(OpcionPregunta o) => _Fila(
        label: o.label,
        icon: o.icon ?? '',
        pesos: Map<String, int>.of(o.pesos),
        id: o.id,
      );

  final String? id;
  final TextEditingController labelCtrl;
  final TextEditingController iconCtrl;
  Map<String, int> pesos;

  OpcionPregunta aOpcion(int orden) => OpcionPregunta(
        id: id,
        label: labelCtrl.text.trim(),
        icon: iconCtrl.text.trim().isEmpty ? null : iconCtrl.text.trim(),
        orden: orden,
        pesos: Map<String, int>.of(pesos),
      );

  void dispose() {
    labelCtrl.dispose();
    iconCtrl.dispose();
  }
}

class _OpcionesEditorState extends State<OpcionesEditor> {
  final List<_Fila> _filas = <_Fila>[];

  @override
  void initState() {
    super.initState();
    // La lista inicial se carga UNA vez. El padre "reinicia" el editor
    // cambiándole el `key` (ver formulario): es el patrón estándar para
    // re-seedear un StatefulWidget desde afuera sin agregar setters.
    _filas.addAll(widget.opcionesIniciales.map(_Fila.de));
    if (_filas.isEmpty) _agregarVaciasPorDefecto();
  }

  @override
  void dispose() {
    for (final _Fila f in _filas) {
      f.dispose();
    }
    super.dispose();
  }

  void _agregarVaciasPorDefecto() {
    // Likert nace con sus 5 etiquetas (plan §4.4.3); los otros tipos
    // con 2 filas vacías listas para escribir.
    if (widget.tipo == TipoPregunta.likert) {
      const List<String> etiquetas = <String>[
        'Muy en desacuerdo',
        'En desacuerdo',
        'Neutral',
        'De acuerdo',
        'Muy de acuerdo',
      ];
      _filas.addAll(
        etiquetas.map((String l) => _Fila(label: l, icon: '', pesos: const {})),
      );
    } else {
      _filas.addAll(<_Fila>[
        _Fila(label: '', icon: '', pesos: const {}),
        _Fila(label: '', icon: '', pesos: const {}),
      ]);
    }
  }

  void _emitir() {
    widget.onChanged(<OpcionPregunta>[
      for (int i = 0; i < _filas.length; i++) _filas[i].aOpcion(i + 1),
    ]);
  }

  void _agregar() {
    // setState recibe una FUNCIÓN que ejecuta el cambio — pasarle la
    // llamada directa (add devuelve void) es error de tipos.
    setState(() {
      _filas.add(_Fila(label: '', icon: '', pesos: const {}));
    });
    _emitir();
  }

  void _quitar(int index) {
    setState(() {
      _filas.removeAt(index).dispose();
    });
    _emitir();
  }

  void _mover(int index, int delta) {
    final int destino = index + delta;
    if (destino < 0 || destino >= _filas.length) return;
    setState(() {
      final _Fila f = _filas.removeAt(index);
      _filas.insert(destino, f);
    });
    _emitir();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool faltanOpciones = _filas.length < 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opciones', style: AppTypography.headlineMd(scheme.onSurface)),
        const SizedBox(height: AppSpacing.xs),
        if (faltanOpciones)
          Text(
            'La pregunta necesita al menos 2 opciones para guardarse.',
            style: AppTypography.labelMd(scheme.error),
          ),
        const SizedBox(height: AppSpacing.sm),
        for (int i = 0; i < _filas.length; i++)
          _FilaCard(
            fila: _filas[i],
            index: i,
            total: _filas.length,
            // Likert no usa emoji (son etiquetas de una escala).
            mostrarIcono: widget.tipo != TipoPregunta.likert,
            onQuitar: () => _quitar(i),
            onSubir: () => _mover(i, -1),
            onBajar: () => _mover(i, 1),
            onPesos: () => _editarPesos(i),
            onCambioTexto: _emitir,
          ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _agregar,
          icon: const Icon(Icons.add),
          label: const Text('Agregar opción'),
        ),
      ],
    );
  }

  Future<void> _editarPesos(int index) async {
    final Map<String, int>? resultado = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => _PesosDialog(inicial: _filas[index].pesos),
    );
    if (resultado == null) return;
    setState(() {
      _filas[index].pesos = resultado;
    });
    _emitir();
  }
}

class _FilaCard extends StatelessWidget {
  const _FilaCard({
    required this.fila,
    required this.index,
    required this.total,
    required this.mostrarIcono,
    required this.onQuitar,
    required this.onSubir,
    required this.onBajar,
    required this.onPesos,
    required this.onCambioTexto,
  });

  final _Fila fila;
  final int index;
  final int total;
  final bool mostrarIcono;
  final VoidCallback onQuitar;
  final VoidCallback onSubir;
  final VoidCallback onBajar;
  final VoidCallback onPesos;
  final VoidCallback onCambioTexto;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.mdRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Flechas de reordenar: deshabilitadas en los bordes.
              Column(
                children: [
                  _Flecha(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: index == 0 ? null : onSubir,
                  ),
                  _Flecha(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: index == total - 1 ? null : onBajar,
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              if (mostrarIcono) ...[
                SizedBox(
                  width: 56,
                  child: TextField(
                    controller: fila.iconCtrl,
                    onChanged: (_) => onCambioTexto(),
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMd(scheme.onSurface),
                    decoration: InputDecoration(
                      hintText: '💡',
                      hintStyle: AppTypography.headlineMd(
                        scheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.mdRadius,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: TextField(
                  controller: fila.labelCtrl,
                  onChanged: (_) => onCambioTexto(),
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.bodyMd(scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Texto de la opción',
                    hintStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    border: const OutlineInputBorder(
                      borderRadius: AppRadii.mdRadius,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                onPressed: onQuitar,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Quitar opción',
                color: scheme.error,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _PesosChip(pesos: fila.pesos, onTap: onPesos),
          ),
        ],
      ),
    );
  }
}

class _Flecha extends StatelessWidget {
  const _Flecha({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 22,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _PesosChip extends StatelessWidget {
  const _PesosChip({required this.pesos, required this.onTap});

  final Map<String, int> pesos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.fullRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 14, color: scheme.primary),
            const SizedBox(width: 4),
            Text(
              pesos.isEmpty
                  ? 'Pesos por categoría (sin definir)'
                  : pesos.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join(' · '),
              style: AppTypography.labelMd(
                pesos.isEmpty ? scheme.onSurfaceVariant : scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para editar el mapa `{ categoria: puntos }` de una opción.
/// Trabaja sobre COPIAS (filas con controllers propios) y solo entrega
/// el resultado si el usuario guarda — así Cancelar no contamina la
/// opción real. Los controllers se liberan al cerrar, guarde o cancele.
class _PesosDialog extends StatefulWidget {
  const _PesosDialog({required this.inicial});

  final Map<String, int> inicial;

  @override
  State<_PesosDialog> createState() => _PesosDialogState();
}

class _PesosDialogState extends State<_PesosDialog> {
  final List<TextEditingController> _categorias = <TextEditingController>[];
  final List<TextEditingController> _puntos = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    for (final MapEntry<String, int> e in widget.inicial.entries) {
      _agregarFila(e.key, e.value);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _categorias) {
      c.dispose();
    }
    for (final TextEditingController c in _puntos) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregarFila([String categoria = '', int puntos = 1]) {
    setState(() {
      _categorias.add(TextEditingController(text: categoria));
      _puntos.add(TextEditingController(text: '$puntos'));
    });
  }

  void _quitarFila(int index) {
    setState(() {
      _categorias.removeAt(index).dispose();
      _puntos.removeAt(index).dispose();
    });
  }

  /// Recolecta: ignora filas sin categoría; los puntos inválidos caen
  /// a 1 (mejor un peso neutro que perder la fila por un typo).
  Map<String, int> _recolectar() {
    final Map<String, int> pesos = <String, int>{};
    for (int i = 0; i < _categorias.length; i++) {
      final String categoria = _categorias[i].text.trim();
      if (categoria.isEmpty) continue;
      pesos[categoria] = int.tryParse(_puntos[i].text.trim()) ?? 1;
    }
    return pesos;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Pesos por categoría'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Cuántos puntos suma esta opción a cada categoría vocacional.',
              style: AppTypography.labelMd(scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < _categorias.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _categorias[i],
                        decoration: InputDecoration(
                          hintText: 'categoría (ej: tecnologia)',
                          isDense: true,
                          filled: true,
                          fillColor: scheme.surfaceContainerLowest,
                        border: const OutlineInputBorder(
                          borderRadius: AppRadii.mdRadius,
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _puntos[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: scheme.surfaceContainerLowest,
                        border: const OutlineInputBorder(
                          borderRadius: AppRadii.mdRadius,
                        ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _quitarFila(i),
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: _agregarFila,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Agregar categoría'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_recolectar()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

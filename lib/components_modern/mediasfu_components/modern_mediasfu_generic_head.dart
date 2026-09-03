part of 'modern_mediasfu_generic.dart';

/// Renders the exact modern interface owned by an already-mounted
/// [ModernMediasfuGeneric] room engine.
///
/// This widget owns no socket, transport, participant, or modal state. Pass
/// the current parameter bag published by a
/// `ModernMediasfuGeneric(returnUI: false)` instance. The mounted engine then
/// supplies the same builders and notifiers used by its normal UI path, so
/// controls, sidebars, modals, and media stay on one lifecycle.
///
/// An application-created parameter bag cannot be used here. When no mounted
/// engine owns [parameters], [unavailableBuilder] is rendered instead.
class ModernMediasfuGenericHead extends StatefulWidget {
  const ModernMediasfuGenericHead({
    super.key,
    required this.parameters,
    this.unavailableBuilder,
  });

  final MediasfuParameters parameters;
  final WidgetBuilder? unavailableBuilder;

  @override
  State<ModernMediasfuGenericHead> createState() =>
      _ModernMediasfuGenericHeadState();
}

class _ModernMediasfuGenericHeadState extends State<ModernMediasfuGenericHead> {
  _ModernMediasfuGenericHeadBinding? _binding;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant ModernMediasfuGenericHead oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.parameters, widget.parameters)) {
      _unbind();
      _bind();
    }
  }

  void _bind() {
    final binding = _modernMediasfuGenericHeadBindings[widget.parameters];
    if (binding == null || !binding.isMounted) return;
    _binding = binding;
    binding.attach();
  }

  void _unbind() {
    _binding?.detach();
    _binding = null;
  }

  @override
  void dispose() {
    _unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final binding = _binding;
    if (binding != null && binding.isMounted) {
      return binding.buildStandardUi(context);
    }

    return widget.unavailableBuilder?.call(context) ?? const SizedBox.shrink();
  }
}

final Expando<_ModernMediasfuGenericHeadBinding>
_modernMediasfuGenericHeadBindings = Expando<_ModernMediasfuGenericHeadBinding>(
  'ModernMediasfuGenericHeadBindings',
);

class _ModernMediasfuGenericHeadBinding {
  _ModernMediasfuGenericHeadBinding(this.engine);

  final _ModernMediasfuGenericState engine;

  bool get isMounted => engine.mounted;

  void attach() {
    engine._attachedHeadRenderers += 1;
  }

  void detach() {
    if (engine._attachedHeadRenderers > 0) {
      engine._attachedHeadRenderers -= 1;
    }
  }

  Widget buildStandardUi(BuildContext context) {
    if (!engine.mounted) return const SizedBox.shrink();
    return engine._buildRoomInterface(forceStandardUi: true);
  }
}

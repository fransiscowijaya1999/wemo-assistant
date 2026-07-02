import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catalog_repository.dart';
import 'fitment_controller.dart';
import 'models.dart';

/// Bottom sheet where the clerk picks the customer's bike: variant chips
/// (when the machine has variants) + an optional frame-serial field. Applies
/// to [FitmentController], so every screen for this machine filters the same way.
Future<void> showFitmentSheet(
  BuildContext context, {
  required String machineId,
  required String machineLabel,
}) async {
  final repo = context.read<CatalogRepository>();
  final controller = context.read<FitmentController>();
  final variants = await repo.machineVariants(machineId);
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FitmentSheet(
      machineId: machineId,
      machineLabel: machineLabel,
      variants: variants,
      controller: controller,
    ),
  );
}

class _FitmentSheet extends StatefulWidget {
  const _FitmentSheet({
    required this.machineId,
    required this.machineLabel,
    required this.variants,
    required this.controller,
  });

  final String machineId;
  final String machineLabel;
  final List<VariantOption> variants;
  final FitmentController controller;

  @override
  State<_FitmentSheet> createState() => _FitmentSheetState();
}

class _FitmentSheetState extends State<_FitmentSheet> {
  late String? _variantId = widget.controller.fitmentFor(widget.machineId).variantId;
  late final TextEditingController _serial =
      TextEditingController(text: widget.controller.fitmentFor(widget.machineId).serial ?? '');

  @override
  void dispose() {
    _serial.dispose();
    super.dispose();
  }

  void _apply() {
    final serial = _serial.text.trim();
    VariantOption? variant;
    for (final v in widget.variants) {
      if (v.id == _variantId) variant = v;
    }
    widget.controller.set(
      widget.machineId,
      Fitment(
        variantId: variant?.id,
        variantName: variant?.name,
        serial: serial.isEmpty ? null : serial,
      ),
    );
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.controller.clear(widget.machineId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wasActive = widget.controller.fitmentFor(widget.machineId).isActive;
    return Padding(
      // Keep the sheet above the keyboard while typing the serial.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer's bike", style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              widget.machineLabel,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (widget.variants.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Any variant'),
                    selected: _variantId == null,
                    onSelected: (_) => setState(() => _variantId = null),
                  ),
                  for (final v in widget.variants)
                    ChoiceChip(
                      label: Text(v.name),
                      selected: _variantId == v.id,
                      onSelected: (_) => setState(() => _variantId = v.id),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _serial,
              decoration: const InputDecoration(
                labelText: 'Frame serial (optional)',
                helperText: 'Filters parts by the catalog No. Seri ranges',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _apply(),
            ),
            const SizedBox(height: 16),
            // Theme's FilledButton is full-width (Size.fromHeight) — keep it
            // out of unbounded-width parents like Row.
            FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
            if (wasActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Center(
                  child: TextButton(onPressed: _clear, child: const Text('Clear')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
